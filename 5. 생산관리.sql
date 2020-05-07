ALTER PROCEDURE STD_PDM_M_110 (

)
LANGUAGE SQLSCRIPT
SQL SECURITY INVOKER
AS
BEGIN
	SELECT
		B."ItemCode" AS "구분",
		SUM(
			CASE
				WHEN B."DocDate" = CURRENT_DATE
				THEN B."Quantity"
			END
		) AS "일",
		SUM(
			CASE
				WHEN MONTH(B."DocDate") = MONTH(CURRENT_DATE)
				THEN B."Quantity"
			END
		) AS "월",
		SUM(
			CASE
				WHEN YEAR(B."DocDate") = YEAR(CURRENT_DATE)
				THEN B."Quantity"
			END
		) AS "년",
		SUM(
			CASE
				WHEN YEAR(B."DocDate") = YEAR(CURRENT_DATE)
				THEN B."Quantity"
			END
		) / COUNT(DISTINCT MONTH(A."DocDate")) AS "월 평균"
	FROM OIGN A
	INNER JOIN IGN1 B ON A."DocEntry" = B."DocEntry"
	WHERE A."CANCELED" = 'N'
	AND YEAR(A."DocDate") = YEAR(CURRENT_DATE)
	GROUP BY B."ItemCode";
END;
CALL STD_PDM_M_110 ();