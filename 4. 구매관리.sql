ALTER PROCEDURE STD_POM_M_110 (

)
LANGUAGE SQLSCRIPT
SQL SECURITY INVOKER
AS
BEGIN
	SELECT
		'구매오더' AS "구분",
		SUM(
			CASE
				WHEN A."DocDate" = CURRENT_DATE
				THEN A."DocTotal"
			END
		) AS "일",
		SUM(
			CASE
				WHEN MONTH(A."DocDate") = MONTH(CURRENT_DATE)
				THEN A."DocTotal"
			END
		) AS "월",
		SUM(
			CASE
				WHEN YEAR(A."DocDate") = YEAR(CURRENT_DATE)
				THEN A."DocTotal"
			END
		) AS "년",
		SUM(
			CASE
				WHEN YEAR(A."DocDate") = YEAR(CURRENT_DATE)
				THEN A."DocTotal"
			END
		) / COUNT(DISTINCT MONTH(A."DocDate")) AS "월 평균"
	FROM OPOR A
	WHERE A."CANCELED" = 'N'
	AND YEAR(A."DocDate") = YEAR(CURRENT_DATE)
	
	UNION ALL
	
	SELECT
		'입고 PO',
		SUM(
			CASE
				WHEN A."DocDate" = CURRENT_DATE
				THEN A."DocTotal"
			END
		) AS "일",
		SUM(
			CASE
				WHEN MONTH(A."DocDate") = MONTH(CURRENT_DATE)
				THEN A."DocTotal"
			END
		) AS "월",
		SUM(
			CASE
				WHEN YEAR(A."DocDate") = YEAR(CURRENT_DATE)
				THEN A."DocTotal"
			END
		) AS "년",
		SUM(
			CASE
				WHEN YEAR(A."DocDate") = YEAR(CURRENT_DATE)
				THEN A."DocTotal"
			END
		) / COUNT(DISTINCT MONTH(A."DocDate")) AS "월 평균"
	FROM OPDN A
	WHERE A."CANCELED" = 'N'
	AND YEAR(A."DocDate") = YEAR(CURRENT_DATE)
	
	UNION ALL
	
	SELECT
		'A/P송장(매입)',
		SUM(
			CASE
				WHEN A."DocDate" = CURRENT_DATE
				THEN A."DocTotal"
			END
		) AS "일",
		SUM(
			CASE
				WHEN MONTH(A."DocDate") = MONTH(CURRENT_DATE)
				THEN A."DocTotal"
			END
		) AS "월",
		SUM(
			CASE
				WHEN YEAR(A."DocDate") = YEAR(CURRENT_DATE)
				THEN A."DocTotal"
			END
		) AS "년",
		SUM(
			CASE
				WHEN YEAR(A."DocDate") = YEAR(CURRENT_DATE)
				THEN A."DocTotal"
			END
		) / COUNT(DISTINCT MONTH(A."DocDate")) AS "월 평균"
	FROM OPCH A
	WHERE A."CANCELED" = 'N'
	AND YEAR(A."DocDate") = YEAR(CURRENT_DATE)
	
	UNION ALL
	
	SELECT
		'반품(대변메모포함)',
		SUM(V."일"),
		SUM(V."월"),
		SUM(V."년"),
		SUM(V."월 평균")
	FROM (
		SELECT
			SUM(
				CASE
					WHEN A."DocDate" = CURRENT_DATE
					THEN A."DocTotal"
				END
			) AS "일",
			SUM(
				CASE
					WHEN MONTH(A."DocDate") = MONTH(CURRENT_DATE)
					THEN A."DocTotal"
				END
			) AS "월",
			SUM(
				CASE
					WHEN YEAR(A."DocDate") = YEAR(CURRENT_DATE)
					THEN A."DocTotal"
				END
			) AS "년",
			SUM(
				CASE
					WHEN YEAR(A."DocDate") = YEAR(CURRENT_DATE)
					THEN A."DocTotal"
				END
			) / COUNT(DISTINCT MONTH(A."DocDate")) AS "월 평균"
		FROM ORPD A
		WHERE A."CANCELED" = 'N'
		AND YEAR(A."DocDate") = YEAR(CURRENT_DATE)
		
		UNION ALL
		
		SELECT
			SUM(
				CASE
					WHEN A."DocDate" = CURRENT_DATE
					THEN A."DocTotal"
				END
			) AS "일",
			SUM(
				CASE
					WHEN MONTH(A."DocDate") = MONTH(CURRENT_DATE)
					THEN A."DocTotal"
				END
			) AS "월",
			SUM(
				CASE
					WHEN YEAR(A."DocDate") = YEAR(CURRENT_DATE)
					THEN A."DocTotal"
				END
			) AS "년",
			SUM(
				CASE
					WHEN YEAR(A."DocDate") = YEAR(CURRENT_DATE)
					THEN A."DocTotal"
				END
			) / COUNT(DISTINCT MONTH(A."DocDate")) AS "월 평균"
		FROM ORPC A
		WHERE A."CANCELED" = 'N'
		AND YEAR(A."DocDate") = YEAR(CURRENT_DATE)
	) V;
END;
CALL STD_POM_M_110 ();