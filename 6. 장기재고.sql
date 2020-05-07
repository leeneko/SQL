ALTER PROCEDURE STD_ICM_M_120 (

)
LANGUAGE SQLSCRIPT
SQL SECURITY INVOKER
AS
BEGIN
	SELECT
		V."ItemCode" AS "품목코드",
		X."WhsName" AS "창고",
		V."Dscription" AS "품명",
		W."OnHand" AS "재고",
		(SUM(V."Price") / SUM(V."InQty")) * W."OnHand" AS "재고금액",
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
END;
CALL STD_ICM_M_120 ();

