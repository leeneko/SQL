CREATE PROCEDURE STD_BSM_M_120 (

)
LANGUAGE SQLSCRIPT
SQL SECURITY INVOKER
AS
BEGIN
	SELECT
		*
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
END;
CALL STD_BSM_M_120 ();