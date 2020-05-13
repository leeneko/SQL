ALTER PROCEDURE STD_MAILING (
)
LANGUAGE SQLSCRIPT
SQL SECURITY INVOKER
AS
BEGIN
	DECLARE DIGITS INT := 0;
	DECLARE RULES NVARCHAR(10) := 'R';
	DECLARE REPLEZERO NVARCHAR(10) := '0';
	
	DECLARE SQLTEXT CLOB = '
		<meta name="viewport" content="width=device-width, initial-scale=1">
		<style>
			@media ( min-width: 966px ) {
                .col-sm-6 {
                    display: inline-block;
                    width: 49.7%;
                }
            }
		    table {
		        width: 100%;
		        min-width: 640px;
		        border-top: 1px solid #444444;
		        border-collapse:collapse;
		        margin-top: 25px;
		    }
		    th, td {
		        border-bottom: 1px solid #444444;
		        padding: 10px;
		    }
		    caption {
		        background-image: linear-gradient(to right, #00f2fe 10%, #4facfe 60%);
		        padding-top: 10px;
		        padding-bottom: 10px;
		        font-weight: bold;
		        color: #FFFFFF;
		    }
		    .align-right {
		        text-align: right;
		    }
		</style>
		<div style="text-align: center;">
			<img src="http://drive.google.com/uc?export=view&id=1kH_vRnbqzM0jOoNVmi1GN55TQeCxpNXy" />
		</div>';
	
	DECLARE CURSOR CURSOR1 FOR
		SELECT
			A."AcctName" AS "구분",
			APR_SAM_GETN2S(A."CurrTotal", :DIGITS, :RULES, :REPLEZERO) AS "금액"
		FROM OACT A
		WHERE A."FatherNum" = '111003'
		
		UNION ALL
		
		SELECT
			'합계',
			APR_SAM_GETN2S(SUM(A."CurrTotal"), :DIGITS, :RULES, :REPLEZERO)
		FROM OACT A
		WHERE A."FatherNum" = '111003';
		
	DECLARE CURSOR CURSOR2 FOR
		SELECT
			C."ItmsGrpNam" AS "구분",
			APR_SAM_GETN2S(SUM(CASE WHEN A."DocDate" < CURRENT_DATE THEN (A."InQty" * A."Price") - (A."OutQty" * A."Price") END), :DIGITS, :RULES, :REPLEZERO) AS "전일(금액)",
			APR_SAM_GETN2S(SUM(CASE WHEN A."DocDate" <= CURRENT_DATE THEN (A."InQty" * A."Price") - (A."OutQty" * A."Price") END), :DIGITS, :RULES, :REPLEZERO) AS "당일(금액)"
--			, SUM(CASE WHEN A."DocDate" < CURRENT_DATE THEN (A."TransValue") - (A."TransValue") END) AS "전일(금액)T"
--			, SUM(CASE WHEN A."DocDate" <= CURRENT_DATE THEN (A."TransValue") - (A."TransValue") END) AS "당일(금액)T"
		FROM OINM A
		INNER JOIN OITM B ON A."ItemCode" = B."ItemCode"
		INNER JOIN OITB C ON B."ItmsGrpCod" = C."ItmsGrpCod"
		GROUP BY C."ItmsGrpNam", C."ItmsGrpCod"
		ORDER BY C."ItmsGrpCod";
	
	DECLARE CURSOR CURSOR3 FOR
		SELECT
			D."BPLName" AS "사업장",
			C."CardName" AS "구분",
			B."Debit" AS "입금",
			B."Credit" AS "지급",
			0 AS "비용",
			A."Memo" AS "비고"
		FROM OJDT A
		INNER JOIN JDT1 B ON A."TransId" = B."TransId"
		INNER JOIN OCRD C ON B."ContraAct" = C."CardCode"
		LEFT JOIN OBPL D ON B."BPLId" = D."BPLId"
		WHERE A."TransType" IN (24, 46)
		AND A."RefDate" = CURRENT_DATE
		
		UNION ALL
		
		SELECT
			D."BPLName",
			C."AcctName",
			0,
			0,
			A."SysTotal",
			A."Memo"
		FROM OJDT A
		INNER JOIN JDT1 B ON A."TransId" = B."TransId"
		INNER JOIN OACT	C ON B."ShortName" = C."AcctCode" AND C."GroupMask" = 5
		LEFT JOIN OBPL D ON B."BPLId" = D."BPLId"
		WHERE A."TransType" IN (30)
		AND A."RefDate" = CURRENT_DATE;
	
	DECLARE CURSOR CURSOR4 FOR
		SELECT
			T."사업장",
			T."구분",
			T."일",
			T."월",
			T."년",
			T."월 평균"
		FROM (
			SELECT
				B."BPLName" AS "사업장",
				'판매오더(주문)' AS "구분",
				APR_SAM_GETN2S(SUM(COALESCE(CASE WHEN A."DocDate" = CURRENT_DATE THEN A."DocTotal" END, 0)), :DIGITS, :RULES, :REPLEZERO) AS "일",
				APR_SAM_GETN2S(SUM(COALESCE(CASE WHEN MONTH(A."DocDate") = MONTH(CURRENT_DATE) THEN A."DocTotal" END, 0)), :DIGITS, :RULES, :REPLEZERO) AS "월",
				APR_SAM_GETN2S(SUM(COALESCE(CASE WHEN YEAR(A."DocDate") = YEAR(CURRENT_DATE) THEN A."DocTotal" END, 0)), :DIGITS, :RULES, :REPLEZERO) AS "년",
				APR_SAM_GETN2S((SUM(COALESCE(CASE WHEN YEAR(A."DocDate") = YEAR(CURRENT_DATE) THEN A."DocTotal" END, 0)) / COUNT(DISTINCT MONTH(A."DocDate"))), :DIGITS, :RULES, :REPLEZERO) AS "월 평균"
			FROM ORDR A
			INNER JOIN OBPL B ON A."BPLId" = B."BPLId"
			WHERE A."CANCELED" = 'N'
			AND YEAR(A."DocDate") = YEAR(CURRENT_DATE)
			GROUP BY B."BPLName"
		
			UNION ALL
		
			SELECT
				B."BPLName" AS "사업장",
				'납품(출고)',
				APR_SAM_GETN2S(SUM(COALESCE(CASE WHEN A."DocDate" = CURRENT_DATE THEN A."DocTotal" END, 0)), :DIGITS, :RULES, :REPLEZERO) AS "일",
				APR_SAM_GETN2S(SUM(COALESCE(CASE WHEN MONTH(A."DocDate") = MONTH(CURRENT_DATE) THEN A."DocTotal" END, 0)), :DIGITS, :RULES, :REPLEZERO) AS "월",
				APR_SAM_GETN2S(SUM(COALESCE(CASE WHEN YEAR(A."DocDate") = YEAR(CURRENT_DATE) THEN A."DocTotal" END, 0)), :DIGITS, :RULES, :REPLEZERO) AS "년",
				APR_SAM_GETN2S((SUM(COALESCE(CASE WHEN YEAR(A."DocDate") = YEAR(CURRENT_DATE) THEN A."DocTotal" END, 0)) / COUNT(DISTINCT MONTH(A."DocDate"))), :DIGITS, :RULES, :REPLEZERO) AS "월 평균"
			FROM ODLN A
			INNER JOIN OBPL B ON A."BPLId" = B."BPLId"
			WHERE A."CANCELED" = 'N'
			AND YEAR(A."DocDate") = YEAR(CURRENT_DATE)
			GROUP BY B."BPLName"
			
			UNION ALL
			
			SELECT
				B."BPLName" AS "사업장",
				'A/R송장(매출)',
				APR_SAM_GETN2S(SUM(COALESCE(CASE WHEN A."DocDate" = CURRENT_DATE THEN A."DocTotal" END, 0)), :DIGITS, :RULES, :REPLEZERO) AS "일",
				APR_SAM_GETN2S(SUM(COALESCE(CASE WHEN MONTH(A."DocDate") = MONTH(CURRENT_DATE) THEN A."DocTotal" END, 0)), :DIGITS, :RULES, :REPLEZERO) AS "월",
				APR_SAM_GETN2S(SUM(COALESCE(CASE WHEN YEAR(A."DocDate") = YEAR(CURRENT_DATE) THEN A."DocTotal" END, 0)), :DIGITS, :RULES, :REPLEZERO) AS "년",
				APR_SAM_GETN2S((SUM(COALESCE(CASE WHEN YEAR(A."DocDate") = YEAR(CURRENT_DATE) THEN A."DocTotal" END, 0)) / COUNT(DISTINCT MONTH(A."DocDate"))), :DIGITS, :RULES, :REPLEZERO) AS "월 평균"
			FROM OINV A
			INNER JOIN OBPL B ON A."BPLId" = B."BPLId"
			WHERE A."CANCELED" = 'N'
			AND YEAR(A."DocDate") = YEAR(CURRENT_DATE)
			GROUP BY B."BPLName"
			
			UNION ALL
			
			SELECT
				V."사업장",
				'반품(대변메모포함)',
				APR_SAM_GETN2S(COALESCE(SUM(V."일"), 0), :DIGITS, :RULES, :REPLEZERO),
				APR_SAM_GETN2S(COALESCE(SUM(V."월"), 0), :DIGITS, :RULES, :REPLEZERO),
				APR_SAM_GETN2S(COALESCE(SUM(V."년"), 0), :DIGITS, :RULES, :REPLEZERO),
				APR_SAM_GETN2S(COALESCE(SUM(V."월 평균"), 0), :DIGITS, :RULES, :REPLEZERO)
			FROM (
				SELECT
					B."BPLName" AS "사업장",
					SUM(COALESCE(CASE WHEN A."DocDate" = CURRENT_DATE THEN A."DocTotal" END, 0)) AS "일",
					SUM(COALESCE(CASE WHEN MONTH(A."DocDate") = MONTH(CURRENT_DATE) THEN A."DocTotal" END, 0)) AS "월",
					SUM(COALESCE(CASE WHEN YEAR(A."DocDate") = YEAR(CURRENT_DATE) THEN A."DocTotal" END, 0)) AS "년",
					SUM(COALESCE(CASE WHEN YEAR(A."DocDate") = YEAR(CURRENT_DATE) THEN A."DocTotal" END, 0)) / COUNT(DISTINCT MONTH(A."DocDate")) AS "월 평균"
				FROM ORDN A
				INNER JOIN OBPL B ON A."BPLId" = B."BPLId"
				WHERE A."CANCELED" = 'N'
				AND YEAR(A."DocDate") = YEAR(CURRENT_DATE)
				GROUP BY B."BPLName"
				
				UNION ALL
				
				SELECT
					B."BPLName" AS "사업장",
					SUM(COALESCE(CASE WHEN A."DocDate" = CURRENT_DATE THEN A."DocTotal" END, 0)) AS "일",
					SUM(COALESCE(CASE WHEN MONTH(A."DocDate") = MONTH(CURRENT_DATE) THEN A."DocTotal" END, 0)) AS "월",
					SUM(COALESCE(CASE WHEN YEAR(A."DocDate") = YEAR(CURRENT_DATE) THEN A."DocTotal" END, 0)) AS "년",
					SUM(COALESCE(CASE WHEN YEAR(A."DocDate") = YEAR(CURRENT_DATE) THEN A."DocTotal" END, 0)) / COUNT(DISTINCT MONTH(A."DocDate")) AS "월 평균"
				FROM ORIN A
				INNER JOIN OBPL B ON A."BPLId" = B."BPLId"
				WHERE A."CANCELED" = 'N'
				AND YEAR(A."DocDate") = YEAR(CURRENT_DATE)
				GROUP BY B."BPLName"
			) V
			GROUP BY "사업장"
		) T;
	
	DECLARE CURSOR CURSOR5 FOR
	SELECT
		T."사업장",
		T."구분",
		APR_SAM_GETN2S(T."일", :DIGITS, :RULES, :REPLEZERO) AS "일",
		APR_SAM_GETN2S(T."월", :DIGITS, :RULES, :REPLEZERO) AS "월",
		APR_SAM_GETN2S(T."년", :DIGITS, :RULES, :REPLEZERO) AS "년",
		APR_SAM_GETN2S(T."월 평균", :DIGITS, :RULES, :REPLEZERO) AS "월 평균"
	FROM (
		SELECT
			B."BPLName" AS "사업장",
			'구매오더' AS "구분",
			SUM(COALESCE(CASE WHEN A."DocDate" = CURRENT_DATE THEN A."DocTotal" END, 0)) AS "일",
			SUM(COALESCE(CASE WHEN MONTH(A."DocDate") = MONTH(CURRENT_DATE) THEN A."DocTotal" END, 0)) AS "월",
			SUM(COALESCE(CASE WHEN YEAR(A."DocDate") = YEAR(CURRENT_DATE) THEN A."DocTotal" END, 0)) AS "년",
			SUM(COALESCE(CASE WHEN YEAR(A."DocDate") = YEAR(CURRENT_DATE) THEN A."DocTotal" END, 0)) / COUNT(DISTINCT MONTH(A."DocDate")) AS "월 평균"
		FROM OPOR A
		INNER JOIN OBPL B ON A."BPLId" = B."BPLId"
		WHERE A."CANCELED" = 'N'
		AND YEAR(A."DocDate") = YEAR(CURRENT_DATE)
		GROUP BY B."BPLName"
		
		UNION ALL
		
		SELECT
			B."BPLName" AS "사업장",
			'입고 PO',
			SUM(COALESCE(CASE WHEN A."DocDate" = CURRENT_DATE THEN A."DocTotal" END, 0)) AS "일",
			SUM(COALESCE(CASE WHEN MONTH(A."DocDate") = MONTH(CURRENT_DATE) THEN A."DocTotal" END, 0)) AS "월",
			SUM(COALESCE(CASE WHEN YEAR(A."DocDate") = YEAR(CURRENT_DATE) THEN A."DocTotal" END, 0)) AS "년",
			SUM(COALESCE(CASE WHEN YEAR(A."DocDate") = YEAR(CURRENT_DATE) THEN A."DocTotal" END, 0)) / COUNT(DISTINCT MONTH(A."DocDate")) AS "월 평균"
		FROM OPDN A
		INNER JOIN OBPL B ON A."BPLId" = B."BPLId"
		WHERE A."CANCELED" = 'N'
		AND YEAR(A."DocDate") = YEAR(CURRENT_DATE)
		GROUP BY B."BPLName"
		
		UNION ALL
		
		SELECT
			B."BPLName" AS "사업장",
			'A/P송장(매입)',
			SUM(COALESCE(CASE WHEN A."DocDate" = CURRENT_DATE THEN A."DocTotal" END, 0)) AS "일",
			SUM(COALESCE(CASE WHEN MONTH(A."DocDate") = MONTH(CURRENT_DATE) THEN A."DocTotal" END, 0)) AS "월",
			SUM(COALESCE(CASE WHEN YEAR(A."DocDate") = YEAR(CURRENT_DATE) THEN A."DocTotal" END, 0)) AS "년",
			SUM(COALESCE(CASE WHEN YEAR(A."DocDate") = YEAR(CURRENT_DATE) THEN A."DocTotal" END, 0)) / COUNT(DISTINCT MONTH(A."DocDate")) AS "월 평균"
		FROM OPCH A
		INNER JOIN OBPL B ON A."BPLId" = B."BPLId"
		WHERE A."CANCELED" = 'N'
		AND YEAR(A."DocDate") = YEAR(CURRENT_DATE)
		GROUP BY B."BPLName"
		
		UNION ALL
		
		SELECT
			V."사업장",
			'반품(대변메모포함)',
			SUM(V."일"),
			SUM(V."월"),
			SUM(V."년"),
			SUM(V."월 평균")
		FROM (
			SELECT
				B."BPLName" AS "사업장",
				SUM(COALESCE(CASE WHEN A."DocDate" = CURRENT_DATE THEN A."DocTotal" END, 0)) AS "일",
				SUM(COALESCE(CASE WHEN MONTH(A."DocDate") = MONTH(CURRENT_DATE) THEN A."DocTotal" END, 0)) AS "월",
				SUM(COALESCE(CASE WHEN YEAR(A."DocDate") = YEAR(CURRENT_DATE) THEN A."DocTotal" END, 0)) AS "년",
				SUM(COALESCE(CASE WHEN YEAR(A."DocDate") = YEAR(CURRENT_DATE) THEN A."DocTotal" END, 0)) / COUNT(DISTINCT MONTH(A."DocDate")) AS "월 평균"
			FROM ORPD A
			INNER JOIN OBPL B ON A."BPLId" = B."BPLId"
			WHERE A."CANCELED" = 'N'
			AND YEAR(A."DocDate") = YEAR(CURRENT_DATE)
			GROUP BY B."BPLName"
			
			UNION ALL
			
			SELECT
				B."BPLName" AS "사업장",
				SUM(COALESCE(CASE WHEN A."DocDate" = CURRENT_DATE THEN A."DocTotal" END, 0)) AS "일",
				SUM(COALESCE(CASE WHEN MONTH(A."DocDate") = MONTH(CURRENT_DATE) THEN A."DocTotal" END, 0)) AS "월",
				SUM(COALESCE(CASE WHEN YEAR(A."DocDate") = YEAR(CURRENT_DATE) THEN A."DocTotal" END, 0)) AS "년",
				SUM(COALESCE(CASE WHEN YEAR(A."DocDate") = YEAR(CURRENT_DATE) THEN A."DocTotal" END, 0)) / COUNT(DISTINCT MONTH(A."DocDate")) AS "월 평균"
			FROM ORPC A
			INNER JOIN OBPL B ON A."BPLId" = B."BPLId"
			WHERE A."CANCELED" = 'N'
			AND YEAR(A."DocDate") = YEAR(CURRENT_DATE)
			GROUP BY B."BPLName"
		) V
		GROUP BY V."사업장"
	) T;
	
	DECLARE CURSOR CURSOR6 FOR
		SELECT
			B."ItemCode" AS "구분",
			APR_SAM_GETN2S(SUM(COALESCE(CASE WHEN B."DocDate" = CURRENT_DATE THEN B."Quantity" END, 0)), :DIGITS, :RULES, :REPLEZERO) AS "일",
			APR_SAM_GETN2S(SUM(COALESCE(CASE WHEN MONTH(B."DocDate") = MONTH(CURRENT_DATE) THEN B."Quantity" END, 0)), :DIGITS, :RULES, :REPLEZERO) AS "월",
			APR_SAM_GETN2S(SUM(COALESCE(CASE WHEN YEAR(B."DocDate") = YEAR(CURRENT_DATE) THEN B."Quantity" END, 0)), :DIGITS, :RULES, :REPLEZERO) AS "년",
			APR_SAM_GETN2S(SUM(COALESCE(CASE WHEN YEAR(B."DocDate") = YEAR(CURRENT_DATE) THEN B."Quantity" END, 0)) / COUNT(DISTINCT MONTH(A."DocDate")), :DIGITS, :RULES, :REPLEZERO) AS "월 평균"
		FROM OIGN A
		INNER JOIN IGN1 B ON A."DocEntry" = B."DocEntry"
		WHERE A."CANCELED" = 'N'
		AND YEAR(A."DocDate") = YEAR(CURRENT_DATE)
		GROUP BY B."ItemCode";
	
	DECLARE CURSOR CURSOR7 FOR
		SELECT
			V."ItemCode" AS "품목코드",
			X."WhsName" AS "창고",
			V."Dscription" AS "품명",
			APR_SAM_GETN2S(W."OnHand", :DIGITS, :RULES, :REPLEZERO) AS "재고",
			APR_SAM_GETN2S(COALESCE(((SUM(V."Price") / SUM(V."InQty")) * W."OnHand"), 0), :DIGITS, :RULES, :REPLEZERO) AS "재고금액",
			DAYS_BETWEEN(V."DocDate", CURRENT_DATE) AS "장기일수"
		FROM (
			SELECT
				A."ItemCode",
				A."Warehouse",
				A."Dscription",
				A."InQty" AS "InQty",
				CASE WHEN A."InQty" > 0 THEN (A."Price" * A."InQty") END AS "Price",
				MAX(A."DocDate") AS "DocDate"
			FROM OINM A
			GROUP BY A."ItemCode", A."Warehouse", A."Dscription", A."InQty", A."Price"
		) V
		INNER JOIN OITM W ON V."ItemCode" = W."ItemCode"
		INNER JOIN OWHS X ON V."Warehouse" = X."WhsCode"
		WHERE DAYS_BETWEEN(V."DocDate", CURRENT_DATE) > 90
		GROUP BY V."ItemCode", X."WhsName", V."Dscription", W."OnHand", V."DocDate"
		ORDER BY V."DocDate", V."ItemCode", X."WhsName";
		-- 품목원가로 계산(이동평균 - OITW.AvgPrice)
	
	DECLARE CURSOR CURSOR8 FOR
		SELECT
			V."구분",
			COALESCE(V."거래처명", '') AS "거래처명",
			APR_SAM_GETN2S(V."금액", 0, 'R', '0') AS "금액",
			APR_SAM_GETN2S(COALESCE(V."지연일수", 0), 0, 'R', '0') AS "지연일수",
			V."최근거래일"
		FROM (
			SELECT
				CASE GROUPING(A."CardName")
					WHEN 1 THEN '합계' ELSE '미수금'
				END AS "구분",
				A."CardName" AS "거래처명",
				SUM(A."DocTotal") AS "금액",
				CASE GROUPING(A."CardName")
					WHEN 1 THEN NULL ELSE DAYS_BETWEEN(MAX(A."DocDate"), CURRENT_DATE)
				END AS "지연일수",
				CASE GROUPING(A."CardName")
					WHEN 1 THEN '' ELSE TO_NVARCHAR(MAX(A."DocDate"), 'YYYY-MM-DD')
				END AS "최근거래일"
			FROM OINV A
			WHERE A."CANCELED" = 'N'
			AND A."DocStatus" = 'O'
			AND DAYS_BETWEEN(A."DocDate", CURRENT_DATE) > 90
			GROUP BY ROLLUP (A."CardName")
			
			UNION ALL
			
			SELECT
				CASE GROUPING(A."CardName")
					WHEN 1 THEN '합계' ELSE '미지급금'
				END AS "구분",
				A."CardName" AS "거래처명",
				SUM(A."DocTotal") AS "금액",
				CASE GROUPING(A."CardName")
					WHEN 1 THEN NULL ELSE DAYS_BETWEEN(MAX(A."DocDate"), CURRENT_DATE)
				END AS "지연일수",
				CASE GROUPING(A."CardName")
					WHEN 1 THEN '' ELSE TO_NVARCHAR(MAX(A."DocDate"), 'YYYY-MM-DD')
				END AS "최근거래일"
			FROM OPCH A
			WHERE A."CANCELED" = 'N'
			AND A."DocStatus" = 'O'
			AND DAYS_BETWEEN(A."DocDate", CURRENT_DATE) > 90
			GROUP BY ROLLUP (A."CardName")
		) V
		ORDER BY "구분", "지연일수" DESC;
	
	DECLARE CURSOR CURSOR9 FOR
		SELECT
			V."구분",
			V."코드",
			V."이름",
			V."메모1",
			V."메모2"
		FROM (
			SELECT
				'비지니스마스터' AS "구분",
				A."CardCode" AS "코드",
				A."CardName" AS "이름",
				A."RepName" AS "메모1",
				A."Notes" AS "메모2"
			FROM OCRD A
			WHERE A."CreateDate" >= ADD_DAYS(CURRENT_DATE, -3)
			
			UNION ALL
			
			SELECT
				'품목',
				A."ItemCode",
				A."ItemName",
				A."InvntryUom",
				B."ItmsGrpNam"
			FROM OITM A
			INNER JOIN OITB B ON A."ItmsGrpCod" = B."ItmsGrpCod"
			WHERE A."CreateDate" >= ADD_DAYS(CURRENT_DATE, -3)
			
			UNION ALL
			
			SELECT
				'BOM',
				B."ItemCode",
				B."ItemName",
				B."InvntryUom",
				''
			FROM OITT A
			INNER JOIN OITM B ON A."Code" = B."ItemCode"
			WHERE A."CreateDate" >= ADD_DAYS(CURRENT_DATE, -3)
			
			UNION ALL
			
			SELECT
				'계정과목',
				A."AcctCode",
				A."AcctName",
				'',
				''
			FROM OACT A
			WHERE A."CreateDate" >= ADD_DAYS(CURRENT_DATE, -3)
		) V;

/* ############################################################################################################################################################################################## */

	SQLTEXT := :SQLTEXT || '<div class="container">';
	SQLTEXT := :SQLTEXT || '	<div class="row">';
	SQLTEXT := :SQLTEXT || '		<div class="col-sm-6">';
	SQLTEXT := :SQLTEXT || '			<table>';
	SQLTEXT := :SQLTEXT || '				<caption>현금시재</caption>';
	SQLTEXT := :SQLTEXT || '				<thead>';
	SQLTEXT := :SQLTEXT || '					<tr>';
	SQLTEXT := :SQLTEXT || '						<th>구분</th>';
	SQLTEXT := :SQLTEXT || '						<th>금액</th>';
	SQLTEXT := :SQLTEXT || '					</tr>';
	SQLTEXT := :SQLTEXT || '				</thead>';
	SQLTEXT := :SQLTEXT || '				<tbody>';
	FOR CROW AS CURSOR1 DO
		SQLTEXT := :SQLTEXT || '				<tr>';
		SQLTEXT := :SQLTEXT || '					<td>';
		SQLTEXT := :SQLTEXT || 							CROW."구분";
		SQLTEXT := :SQLTEXT || '					</td>';
		SQLTEXT := :SQLTEXT || '					<td class="align-right">';
		SQLTEXT := :SQLTEXT || 							CROW."금액";
		SQLTEXT := :SQLTEXT || '					</td>';
		SQLTEXT := :SQLTEXT || '				</tr>';
	END FOR;
	SQLTEXT := :SQLTEXT || '				</tbody>';
	SQLTEXT := :SQLTEXT || '			</table>';
	SQLTEXT := :SQLTEXT || '		</div>';
	SQLTEXT := :SQLTEXT || '		<div class="col-sm-6">';
	SQLTEXT := :SQLTEXT || '			<table>';
	SQLTEXT := :SQLTEXT || '				<caption>재고금액</caption>';
	SQLTEXT := :SQLTEXT || '				<thead>';
	SQLTEXT := :SQLTEXT || '					<tr>';
	SQLTEXT := :SQLTEXT || '						<th>구분</th>';
	SQLTEXT := :SQLTEXT || '						<th>전일(금액)</th>';
	SQLTEXT := :SQLTEXT || '						<th>당일(금액)</th>';
	SQLTEXT := :SQLTEXT || '					</tr>';
	SQLTEXT := :SQLTEXT || '				</thead>';
	SQLTEXT := :SQLTEXT || '				<tbody>';
	FOR CROW AS CURSOR2 DO
		SQLTEXT := :SQLTEXT || '				<tr>';
		SQLTEXT := :SQLTEXT || '					<td>';
		SQLTEXT := :SQLTEXT || 							CROW."구분";
		SQLTEXT := :SQLTEXT || '					</td>';
		SQLTEXT := :SQLTEXT || '					<td class="align-right">';
		SQLTEXT := :SQLTEXT || 							CROW."전일(금액)";
		SQLTEXT := :SQLTEXT || '					</td>';
		SQLTEXT := :SQLTEXT || '					<td class="align-right">';
		SQLTEXT := :SQLTEXT || 							CROW."당일(금액)";
		SQLTEXT := :SQLTEXT || '					</td>';
		SQLTEXT := :SQLTEXT || '				</tr>';
	END FOR;
	SQLTEXT := :SQLTEXT || '				</tbody>';
	SQLTEXT := :SQLTEXT || '			</table>';
	SQLTEXT := :SQLTEXT || '		</div>';
	SQLTEXT := :SQLTEXT || '	</div>';
	SQLTEXT := :SQLTEXT || '	<div class="row">';
	SQLTEXT := :SQLTEXT || '		<div class="col-sm-12">';
	SQLTEXT := :SQLTEXT || '			<table>';
	SQLTEXT := :SQLTEXT || '				<caption>자금관리</caption>';
	SQLTEXT := :SQLTEXT || '				<thead>';
	SQLTEXT := :SQLTEXT || '					<th>사업장</th>';
	SQLTEXT := :SQLTEXT || '					<th>구분</th>';
	SQLTEXT := :SQLTEXT || '					<th>입금</th>';
	SQLTEXT := :SQLTEXT || '					<th>지급</th>';
	SQLTEXT := :SQLTEXT || '					<th>비용</th>';
	SQLTEXT := :SQLTEXT || '					<th>비고</th>';
	SQLTEXT := :SQLTEXT || '				</thead>';
	SQLTEXT := :SQLTEXT || '				<tbody>';
	FOR CROW AS CURSOR3 DO
		SQLTEXT := :SQLTEXT || '				<tr>';
		SQLTEXT := :SQLTEXT || '					<td>';
		SQLTEXT := :SQLTEXT ||							CROW."사업장";
		SQLTEXT := :SQLTEXT || '					</td>';
		SQLTEXT := :SQLTEXT || '					<td>';
		SQLTEXT := :SQLTEXT ||							CROW."구분";
		SQLTEXT := :SQLTEXT || '					</td>';
		SQLTEXT := :SQLTEXT || '					<td class="align-right">';
		SQLTEXT := :SQLTEXT ||							CROW."입금";
		SQLTEXT := :SQLTEXT || '					</td>';
		SQLTEXT := :SQLTEXT || '					<td class="align-right">';
		SQLTEXT := :SQLTEXT ||							CROW."지급";
		SQLTEXT := :SQLTEXT || '					</td>';
		SQLTEXT := :SQLTEXT || '					<td class="align-right">';
		SQLTEXT := :SQLTEXT ||							CROW."비용";
		SQLTEXT := :SQLTEXT || '					</td>';
		SQLTEXT := :SQLTEXT || '					<td>';
		SQLTEXT := :SQLTEXT ||							CROW."비고";
		SQLTEXT := :SQLTEXT || '					</td>';
		SQLTEXT := :SQLTEXT || '				</tr>';
	END FOR;
	SQLTEXT := :SQLTEXT || '				</tbody>';
	SQLTEXT := :SQLTEXT || '			</table>';
	SQLTEXT := :SQLTEXT || '		</div>';
	SQLTEXT := :SQLTEXT || '	</div>';
	SQLTEXT := :SQLTEXT || '	<div class="row">';
	SQLTEXT := :SQLTEXT || '		<div class="col-sm-12">';
	SQLTEXT := :SQLTEXT || '			<table>';
	SQLTEXT := :SQLTEXT || '				<caption>판매관리</caption>';
	SQLTEXT := :SQLTEXT || '				<thead>';
	SQLTEXT := :SQLTEXT || '					<th>사업장</th>';
	SQLTEXT := :SQLTEXT || '					<th>구분</th>';
	SQLTEXT := :SQLTEXT || '					<th>일</th>';
	SQLTEXT := :SQLTEXT || '					<th>월</th>';
	SQLTEXT := :SQLTEXT || '					<th>년</th>';
	SQLTEXT := :SQLTEXT || '					<th>월 평균</th>';
	SQLTEXT := :SQLTEXT || '				</thead>';
	SQLTEXT := :SQLTEXT || '				<tbody>';
	FOR CROW AS CURSOR4 DO
		SQLTEXT := :SQLTEXT || '				<tr>';
		SQLTEXT := :SQLTEXT || '					<td>';
		SQLTEXT := :SQLTEXT ||							CROW."사업장";
		SQLTEXT := :SQLTEXT || '					</td>';
		SQLTEXT := :SQLTEXT || '					<td>';
		SQLTEXT := :SQLTEXT ||							CROW."구분";
		SQLTEXT := :SQLTEXT || '					</td>';
		SQLTEXT := :SQLTEXT || '					<td class="align-right">';
		SQLTEXT := :SQLTEXT ||							CROW."일";
		SQLTEXT := :SQLTEXT || '					</td>';
		SQLTEXT := :SQLTEXT || '					<td class="align-right">';
		SQLTEXT := :SQLTEXT ||							CROW."월";
		SQLTEXT := :SQLTEXT || '					</td>';
		SQLTEXT := :SQLTEXT || '					<td class="align-right">';
		SQLTEXT := :SQLTEXT ||							CROW."년";
		SQLTEXT := :SQLTEXT || '					</td>';
		SQLTEXT := :SQLTEXT || '					<td class="align-right">';
		SQLTEXT := :SQLTEXT ||							CROW."월 평균";
		SQLTEXT := :SQLTEXT || '					</td>';
		SQLTEXT := :SQLTEXT || '				</tr>';
	END FOR;
	SQLTEXT := :SQLTEXT || '				</tbody>';
	SQLTEXT := :SQLTEXT || '			</table>';
	SQLTEXT := :SQLTEXT || '		</div>';
	SQLTEXT := :SQLTEXT || '	</div>';
	SQLTEXT := :SQLTEXT || '	<div class="row">';
	SQLTEXT := :SQLTEXT || '		<div class="col-sm-12">';
	SQLTEXT := :SQLTEXT || '			<table>';
	SQLTEXT := :SQLTEXT || '				<caption>구매관리</caption>';
	SQLTEXT := :SQLTEXT || '				<thead>';
	SQLTEXT := :SQLTEXT || '					<th>사업장</th>';
	SQLTEXT := :SQLTEXT || '					<th>구분</th>';
	SQLTEXT := :SQLTEXT || '					<th>일</th>';
	SQLTEXT := :SQLTEXT || '					<th>월</th>';
	SQLTEXT := :SQLTEXT || '					<th>년</th>';
	SQLTEXT := :SQLTEXT || '					<th>월 평균</th>';
	SQLTEXT := :SQLTEXT || '				</thead>';
	SQLTEXT := :SQLTEXT || '				<tbody>';
	FOR CROW AS CURSOR5 DO
		SQLTEXT := :SQLTEXT || '				<tr>';
		SQLTEXT := :SQLTEXT || '					<td>';
		SQLTEXT := :SQLTEXT ||							CROW."사업장";
		SQLTEXT := :SQLTEXT || '					</td>';
		SQLTEXT := :SQLTEXT || '					<td>';
		SQLTEXT := :SQLTEXT ||							CROW."구분";
		SQLTEXT := :SQLTEXT || '					</td>';
		SQLTEXT := :SQLTEXT || '					<td class="align-right">';
		SQLTEXT := :SQLTEXT ||							CROW."일";
		SQLTEXT := :SQLTEXT || '					</td>';
		SQLTEXT := :SQLTEXT || '					<td class="align-right">';
		SQLTEXT := :SQLTEXT ||							CROW."월";
		SQLTEXT := :SQLTEXT || '					</td>';
		SQLTEXT := :SQLTEXT || '					<td class="align-right">';
		SQLTEXT := :SQLTEXT ||							CROW."년";
		SQLTEXT := :SQLTEXT || '					</td>';
		SQLTEXT := :SQLTEXT || '					<td class="align-right">';
		SQLTEXT := :SQLTEXT ||							CROW."월 평균";
		SQLTEXT := :SQLTEXT || '					</td>';
		SQLTEXT := :SQLTEXT || '				</tr>';
	END FOR;
	SQLTEXT := :SQLTEXT || '				</tbody>';
	SQLTEXT := :SQLTEXT || '			</table>';
	SQLTEXT := :SQLTEXT || '		</div>';
	SQLTEXT := :SQLTEXT || '	</div>';
	SQLTEXT := :SQLTEXT || '	<div class="row">';
	SQLTEXT := :SQLTEXT || '		<div class="col-sm-12">';
	SQLTEXT := :SQLTEXT || '			<table>';
	SQLTEXT := :SQLTEXT || '				<caption>생산관리</caption>';
	SQLTEXT := :SQLTEXT || '				<thead>';
	SQLTEXT := :SQLTEXT || '					<th>구분</th>';
	SQLTEXT := :SQLTEXT || '					<th>일</th>';
	SQLTEXT := :SQLTEXT || '					<th>월</th>';
	SQLTEXT := :SQLTEXT || '					<th>년</th>';
	SQLTEXT := :SQLTEXT || '					<th>월 평균</th>';
	SQLTEXT := :SQLTEXT || '				</thead>';
	SQLTEXT := :SQLTEXT || '				<tbody>';
	FOR CROW AS CURSOR6 DO
		SQLTEXT := :SQLTEXT || '				<tr>';
		SQLTEXT := :SQLTEXT || '					<td>';
		SQLTEXT := :SQLTEXT ||							CROW."구분";
		SQLTEXT := :SQLTEXT || '					</td>';
		SQLTEXT := :SQLTEXT || '					<td class="align-right">';
		SQLTEXT := :SQLTEXT ||							CROW."일";
		SQLTEXT := :SQLTEXT || '					</td>';
		SQLTEXT := :SQLTEXT || '					<td class="align-right">';
		SQLTEXT := :SQLTEXT ||							CROW."월";
		SQLTEXT := :SQLTEXT || '					</td>';
		SQLTEXT := :SQLTEXT || '					<td class="align-right">';
		SQLTEXT := :SQLTEXT ||							CROW."년";
		SQLTEXT := :SQLTEXT || '					</td>';
		SQLTEXT := :SQLTEXT || '					<td class="align-right">';
		SQLTEXT := :SQLTEXT ||							CROW."월 평균";
		SQLTEXT := :SQLTEXT || '					</td>';
		SQLTEXT := :SQLTEXT || '				</tr>';
	END FOR;
	SQLTEXT := :SQLTEXT || '				</tbody>';
	SQLTEXT := :SQLTEXT || '			</table>';
	SQLTEXT := :SQLTEXT || '		</div>';
	SQLTEXT := :SQLTEXT || '	</div>';
	SQLTEXT := :SQLTEXT || '	<div class="row">';
	SQLTEXT := :SQLTEXT || '		<div class="col-sm-12">';
	SQLTEXT := :SQLTEXT || '			<table>';
	SQLTEXT := :SQLTEXT || '				<caption>장기재고</caption>';
	SQLTEXT := :SQLTEXT || '				<thead>';
	SQLTEXT := :SQLTEXT || '					<th>품목코드</th>';
	SQLTEXT := :SQLTEXT || '					<th>창고</th>';
	SQLTEXT := :SQLTEXT || '					<th>품명</th>';
	SQLTEXT := :SQLTEXT || '					<th>재고</th>';
	SQLTEXT := :SQLTEXT || '					<th>재고금액</th>';
	SQLTEXT := :SQLTEXT || '					<th>장기일수</th>';
	SQLTEXT := :SQLTEXT || '				</thead>';
	SQLTEXT := :SQLTEXT || '				<tbody>';
	FOR CROW AS CURSOR7 DO
		SQLTEXT := :SQLTEXT || '				<tr>';
		SQLTEXT := :SQLTEXT || '					<td>';
		SQLTEXT := :SQLTEXT ||							CROW."품목코드";
		SQLTEXT := :SQLTEXT || '					</td>';
		SQLTEXT := :SQLTEXT || '					<td>';
		SQLTEXT := :SQLTEXT ||							CROW."창고";
		SQLTEXT := :SQLTEXT || '					</td>';
		SQLTEXT := :SQLTEXT || '					<td>';
		SQLTEXT := :SQLTEXT ||							CROW."품명";
		SQLTEXT := :SQLTEXT || '					</td>';
		SQLTEXT := :SQLTEXT || '					<td class="align-right">';
		SQLTEXT := :SQLTEXT ||							CROW."재고";
		SQLTEXT := :SQLTEXT || '					</td>';
		SQLTEXT := :SQLTEXT || '					<td class="align-right">';
		SQLTEXT := :SQLTEXT ||							CROW."재고금액";
		SQLTEXT := :SQLTEXT || '					</td>';
		SQLTEXT := :SQLTEXT || '					<td class="align-right">';
		SQLTEXT := :SQLTEXT ||							CROW."장기일수";
		SQLTEXT := :SQLTEXT || '					</td>';
		SQLTEXT := :SQLTEXT || '				</tr>';
	END FOR;
	SQLTEXT := :SQLTEXT || '				</tbody>';
	SQLTEXT := :SQLTEXT || '			</table>';
	SQLTEXT := :SQLTEXT || '		</div>';
	SQLTEXT := :SQLTEXT || '	</div>';
	SQLTEXT := :SQLTEXT || '	<div class="row">';
	SQLTEXT := :SQLTEXT || '		<div class="col-sm-12">';
	SQLTEXT := :SQLTEXT || '			<table>';
	SQLTEXT := :SQLTEXT || '				<caption>장기 미지미수</caption>';
	SQLTEXT := :SQLTEXT || '				<thead>';
	SQLTEXT := :SQLTEXT || '					<th>구분</th>';
	SQLTEXT := :SQLTEXT || '					<th>거래처명</th>';
	SQLTEXT := :SQLTEXT || '					<th>금액</th>';
	SQLTEXT := :SQLTEXT || '					<th>지연일수</th>';
	SQLTEXT := :SQLTEXT || '					<th>최근거래일</th>';
	SQLTEXT := :SQLTEXT || '				</thead>';
	SQLTEXT := :SQLTEXT || '				<tbody>';
	FOR CROW AS CURSOR8 DO
		SQLTEXT := :SQLTEXT || '				<tr>';
		SQLTEXT := :SQLTEXT || '					<td>';
		SQLTEXT := :SQLTEXT ||							CROW."구분";
		SQLTEXT := :SQLTEXT || '					</td>';
		SQLTEXT := :SQLTEXT || '					<td>';
		SQLTEXT := :SQLTEXT ||							CROW."거래처명";
		SQLTEXT := :SQLTEXT || '					</td>';
		SQLTEXT := :SQLTEXT || '					<td class="align-right">';
		SQLTEXT := :SQLTEXT ||							CROW."금액";
		SQLTEXT := :SQLTEXT || '					</td>';
		SQLTEXT := :SQLTEXT || '					<td class="align-right">';
		SQLTEXT := :SQLTEXT ||							CROW."지연일수";
		SQLTEXT := :SQLTEXT || '					</td>';
		SQLTEXT := :SQLTEXT || '					<td>';
		SQLTEXT := :SQLTEXT ||							CROW."최근거래일";
		SQLTEXT := :SQLTEXT || '					</td>';
		SQLTEXT := :SQLTEXT || '				</tr>';
	END FOR;
	SQLTEXT := :SQLTEXT || '				</tbody>';
	SQLTEXT := :SQLTEXT || '			</table>';
	SQLTEXT := :SQLTEXT || '		</div>';
	SQLTEXT := :SQLTEXT || '	</div>';
	SQLTEXT := :SQLTEXT || '	<div class="row">';
	SQLTEXT := :SQLTEXT || '		<div class="col-sm-12">';
	SQLTEXT := :SQLTEXT || '			<table style="width: 100%;">';
	SQLTEXT := :SQLTEXT || '				<caption>마스터 정보(주단위)</caption>';
	SQLTEXT := :SQLTEXT || '				<thead>';
	SQLTEXT := :SQLTEXT || '					<th>구분</th>';
	SQLTEXT := :SQLTEXT || '					<th>코드</th>';
	SQLTEXT := :SQLTEXT || '					<th>이름</th>';
	SQLTEXT := :SQLTEXT || '					<th>메모1</th>';
	SQLTEXT := :SQLTEXT || '					<th>메모2</th>';
	SQLTEXT := :SQLTEXT || '				</thead>';
	SQLTEXT := :SQLTEXT || '				<tbody>';
	FOR CROW AS CURSOR9 DO
		SQLTEXT := :SQLTEXT || '				<tr>';
		SQLTEXT := :SQLTEXT || '					<td>';
		SQLTEXT := :SQLTEXT ||							CROW."구분";
		SQLTEXT := :SQLTEXT || '					</td>';
		SQLTEXT := :SQLTEXT || '					<td>';
		SQLTEXT := :SQLTEXT ||							CROW."코드";
		SQLTEXT := :SQLTEXT || '					</td>';
		SQLTEXT := :SQLTEXT || '					<td>';
		SQLTEXT := :SQLTEXT ||							CROW."이름";
		SQLTEXT := :SQLTEXT || '					</td>';
		SQLTEXT := :SQLTEXT || '					<td>';
		SQLTEXT := :SQLTEXT ||							CROW."메모1";
		SQLTEXT := :SQLTEXT || '					</td>';
		SQLTEXT := :SQLTEXT || '					<td">';
		SQLTEXT := :SQLTEXT ||							CROW."메모2";
		SQLTEXT := :SQLTEXT || '					</td>';
		SQLTEXT := :SQLTEXT || '				</tr>';
	END FOR;
	SQLTEXT := :SQLTEXT || '				</tbody>';
	SQLTEXT := :SQLTEXT || '			</table>';
	SQLTEXT := :SQLTEXT || '		</div>';
	SQLTEXT := :SQLTEXT || '	</div>';
	SQLTEXT := :SQLTEXT || '</div>';
	
	SELECT :SQLTEXT FROM DUMMY;
END;
CALL STD_MAILING();