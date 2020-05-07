ALTER PROCEDURE STD_ICM_M_110 (
	
)
LANGUAGE SQLSCRIPT
SQL SECURITY INVOKER
AS
BEGIN
	SELECT
		C."ItmsGrpNam",
		SUM(
			CASE
				WHEN A."DocDate" < CURRENT_DATE
				THEN (A."InQty" * A."Price") - (A."OutQty" * A."Price")
			END
		) AS "전일(금액)",
		SUM(
			CASE
				WHEN A."DocDate" <= CURRENT_DATE
				THEN (A."InQty" * A."Price") - (A."OutQty" * A."Price")
			END
		) AS "당일(금액)",
		SUM(
			CASE
				WHEN A."DocDate" < CURRENT_DATE
				THEN (A."TransValue") - (A."TransValue")
			END
		) AS "전일(금액)T",
		SUM(
			CASE
				WHEN A."DocDate" <= CURRENT_DATE
				THEN (A."TransValue") - (A."TransValue")
			END
		) AS "당일(금액)T"
	FROM OINM A
	INNER JOIN OITM B ON A."ItemCode" = B."ItemCode"
	INNER JOIN OITB C ON B."ItmsGrpCod" = C."ItmsGrpCod"
	GROUP BY C."ItmsGrpNam", C."ItmsGrpCod"
	ORDER BY C."ItmsGrpCod";
END;
CALL STD_ICM_M_110 ();
