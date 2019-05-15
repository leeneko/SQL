DROP PROCEDURE APR_OIGE_TEST;
CREATE PROCEDURE APR_OIGE_TEST (
	IN IN_DT DATETIME,
	OUT TEMP TABLE (
		"품목코드"		NVARCHAR(100),
		"품명"		NVARCHAR(100),
		"생산오더합"	DECIMAL(28, 6),
		"생산출고합"	DECIMAL(28, 6),
		"1월생산오더"	DECIMAL(28, 6),
		"1월생산출고"	DECIMAL(28, 6),
		"2월생산오더"	DECIMAL(28, 6),
		"2월생산출고"	DECIMAL(28, 6),
		"3월생산오더"	DECIMAL(28, 6),
		"3월생산출고"	DECIMAL(28, 6),
		"4월생산오더"	DECIMAL(28, 6),
		"4월생산출고"	DECIMAL(28, 6),
		"5월생산오더"	DECIMAL(28, 6),
		"5월생산출고"	DECIMAL(28, 6),
		"6월생산오더"	DECIMAL(28, 6),
		"6월생산출고"	DECIMAL(28, 6),
		"7월생산오더"	DECIMAL(28, 6),
		"7월생산출고"	DECIMAL(28, 6),
		"8월생산오더"	DECIMAL(28, 6),
		"8월생산출고"	DECIMAL(28, 6),
		"9월생산오더"	DECIMAL(28, 6),
		"9월생산출고"	DECIMAL(28, 6),
		"10월생산오더"	DECIMAL(28, 6),
		"10월생산출고"	DECIMAL(28, 6),
		"11월생산오더"	DECIMAL(28, 6),
		"11월생산출고"	DECIMAL(28, 6),
		"12월생산오더"	DECIMAL(28, 6),
		"12월생산출고"	DECIMAL(28, 6)
	)
)
LANGUAGE SQLSCRIPT
SQL SECURITY INVOKER
AS 
BEGIN
	DECLARE DT NVARCHAR(4) = TO_NVARCHAR( :IN_DT, 'YYYY' );
	
	TEMP = SELECT
		A."ItemCode" AS "품목코드",
		B."ItemName" AS "품명",
		SUM(A."PlannedQty") AS "생산오더합",
		SUM(C."Quantity") AS "생산출고합",
		SUM( CASE WHEN TO_NVARCHAR( A."StartDate", 'MM' ) = '01' THEN A."PlannedQty" ELSE 0 END ) AS "1월생산오더",
		SUM( CASE WHEN TO_NVARCHAR( C."DocDate", 'MM' ) = '01' THEN C."Quantity" ELSE 0 END ) AS "1월생산출고",
		SUM( CASE WHEN TO_NVARCHAR( A."StartDate", 'MM' ) = '02' THEN A."PlannedQty" ELSE 0 END ) AS "2월생산오더",
		SUM( CASE WHEN TO_NVARCHAR( C."DocDate", 'MM' ) = '02' THEN C."Quantity" ELSE 0 END ) AS "2월생산출고",
		SUM( CASE WHEN TO_NVARCHAR( A."StartDate", 'MM' ) = '03' THEN A."PlannedQty" ELSE 0 END ) AS "3월생산오더",
		SUM( CASE WHEN TO_NVARCHAR( C."DocDate", 'MM' ) = '03' THEN C."Quantity" ELSE 0 END ) AS "3월생산출고",
		SUM( CASE WHEN TO_NVARCHAR( A."StartDate", 'MM' ) = '04' THEN A."PlannedQty" ELSE 0 END ) AS "4월생산오더",
		SUM( CASE WHEN TO_NVARCHAR( C."DocDate", 'MM' ) = '04' THEN C."Quantity" ELSE 0 END ) AS "4월생산출고",
		SUM( CASE WHEN TO_NVARCHAR( A."StartDate", 'MM' ) = '05' THEN A."PlannedQty" ELSE 0 END ) AS "5월생산오더",
		SUM( CASE WHEN TO_NVARCHAR( C."DocDate", 'MM' ) = '05' THEN C."Quantity" ELSE 0 END ) AS "5월생산출고",
		SUM( CASE WHEN TO_NVARCHAR( A."StartDate", 'MM' ) = '06' THEN A."PlannedQty" ELSE 0 END ) AS "6월생산오더",
		SUM( CASE WHEN TO_NVARCHAR( C."DocDate", 'MM' ) = '06' THEN C."Quantity" ELSE 0 END ) AS "6월생산출고",
		SUM( CASE WHEN TO_NVARCHAR( A."StartDate", 'MM' ) = '07' THEN A."PlannedQty" ELSE 0 END ) AS "7월생산오더",
		SUM( CASE WHEN TO_NVARCHAR( C."DocDate", 'MM' ) = '07' THEN C."Quantity" ELSE 0 END ) AS "7월생산출고",
		SUM( CASE WHEN TO_NVARCHAR( A."StartDate", 'MM' ) = '08' THEN A."PlannedQty" ELSE 0 END ) AS "8월생산오더",
		SUM( CASE WHEN TO_NVARCHAR( C."DocDate", 'MM' ) = '08' THEN C."Quantity" ELSE 0 END ) AS "8월생산출고",
		SUM( CASE WHEN TO_NVARCHAR( A."StartDate", 'MM' ) = '09' THEN A."PlannedQty" ELSE 0 END ) AS "9월생산오더",
		SUM( CASE WHEN TO_NVARCHAR( C."DocDate", 'MM' ) = '09' THEN C."Quantity" ELSE 0 END ) AS "9월생산출고",
		SUM( CASE WHEN TO_NVARCHAR( A."StartDate", 'MM' ) = '10' THEN A."PlannedQty" ELSE 0 END ) AS "10월생산오더",
		SUM( CASE WHEN TO_NVARCHAR( C."DocDate", 'MM' ) = '10' THEN C."Quantity" ELSE 0 END ) AS "10월생산출고",
		SUM( CASE WHEN TO_NVARCHAR( A."StartDate", 'MM' ) = '11' THEN A."PlannedQty" ELSE 0 END ) AS "11월생산오더",
		SUM( CASE WHEN TO_NVARCHAR( C."DocDate", 'MM' ) = '11' THEN C."Quantity" ELSE 0 END ) AS "11월생산출고",
		SUM( CASE WHEN TO_NVARCHAR( A."StartDate", 'MM' ) = '12' THEN A."PlannedQty" ELSE 0 END ) AS "12월생산오더",
		SUM( CASE WHEN TO_NVARCHAR( C."DocDate", 'MM' ) = '12' THEN C."Quantity" ELSE 0 END ) AS "12월생산출고"
	FROM WOR1 A
	INNER JOIN OITM B ON A."ItemCode" = B."ItemCode"
	LEFT JOIN IGE1 C ON A."DocEntry" = C."BaseEntry" AND A."LineNum" = C."LineNum"
	WHERE TO_NVARCHAR( A."StartDate", 'YYYY' ) = :DT
	GROUP BY A."ItemCode", B."ItemName";
END;
CALL APR_OIGE_TEST('20190403', ?);