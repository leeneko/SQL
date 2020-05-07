ALTER PROCEDURE STD_OEM_M_110 (

)
LANGUAGE SQLSCRIPT
SQL SECURITY INVOKER
AS
BEGIN
	SELECT
		'판매오더(주문)' AS "구분",
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
	FROM ORDR A
	WHERE A."CANCELED" = 'N'
	AND YEAR(A."DocDate") = YEAR(CURRENT_DATE)
	
	UNION ALL
	
	SELECT
		'납품(출고)',
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
	FROM ODLN A
	WHERE A."CANCELED" = 'N'
	AND YEAR(A."DocDate") = YEAR(CURRENT_DATE)
	
	UNION ALL
	
	SELECT
		'A/R송장(매출)',
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
	FROM OINV A
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
		FROM ORDN A
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
		FROM ORIN A
		WHERE A."CANCELED" = 'N'
		AND YEAR(A."DocDate") = YEAR(CURRENT_DATE)
	) V;
END;
CALL STD_OEM_M_110 ();