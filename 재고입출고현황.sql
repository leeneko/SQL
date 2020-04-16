CREATE PROCEDURE STD_ICM_O_120 (
	IN FROMDT NVARCHAR(10),
	IN TODATE NVARCHAR(10),
	IN ITEMGRP NVARCHAR(20),
	IN WHSCODE NVARCHAR(8),
	IN ITEMCODE NVARCHAR(50)
)
LANGUAGE SQLSCRIPT
SQL SECURITY INVOKER
AS
BEGIN
	SELECT
		V."전표유형" AS "전표유형L000Y",
		V."일자" AS "일자L000Y",
		V."품목그룹" AS "품목그룹L000Y",
		V."품목코드" AS "품목코드L004Y",
		V."품명" AS "품명L000Y",
		V."창고" AS "창고L000Y",
		V."입고" AS "입고R000Y",
		V."출고" AS "출고R000Y",
		SUM(V."재고") OVER (PARTITION BY V."품목코드" ORDER BY V."전표번호") AS "재고R000Y",
		V."총평균단가" AS "총평균단가R000Y",
		V."재고금액" AS "재고금액R000Y"
	FROM (
		SELECT
			0 AS "전표번호",
			'' AS "전표유형",
			'' AS "일자",
			'' AS "품목그룹",
			A."ItemCode" AS "품목코드",
			B."ItemName" AS "품명",
			'' AS "창고",
			0 AS "입고",
			0 AS "출고",
			SUM(A."InQty" - A."OutQty") AS "재고",
			0 AS "총평균단가",
			0 AS "재고금액"
		FROM OINM A
		INNER JOIN OITM B ON A."ItemCode" = B."ItemCode"
		WHERE A."DocDate" < :FROMDT
		GROUP BY A."ItemCode", B."ItemName"
		
		UNION ALL
		
		SELECT
			A."TransNum",
			APR_TRANSTYPE(A."TransType"),
			TO_NVARCHAR(A."DocDate", 'YYYY-MM-DD'),
			C."ItmsGrpNam",
			A."ItemCode",
			B."ItemName",
			D."WhsName",
			A."InQty",
			A."OutQty",
			A."InQty" - A."OutQty",
			0,
			0
		FROM OINM A
		INNER JOIN OITM B ON A."ItemCode" = B."ItemCode"
		INNER JOIN OITB C ON B."ItmsGrpCod" = C."ItmsGrpCod"
		INNER JOIN OWHS D ON A."Warehouse" = D."WhsCode"
		WHERE A."DocDate" >= :FROMDT
		AND A."DocDate" <= :TODATE
		AND (B."ItmsGrpCod" = :ITEMGRP OR '' = :ITEMGRP)
		AND (A."Warehouse" = :WHSCODE OR '' = :WHSCODE)
		AND A."ItemCode" = :ITEMCODE
	) V
	ORDER BY V."품목코드", V."창고", V."전표번호";
END;
CALL STD_ICM_O_120 ('20200325', '20201231', '', '', '10003');