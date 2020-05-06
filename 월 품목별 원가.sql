ALTER PROCEDURE STD_ICM_I_110 (
	IN YYYYMM NVARCHAR(10),
	IN BPLID NVARCHAR(10),
	IN SLPCODE NVARCHAR(10)
)
LANGUAGE SQLSCRIPT
SQL SECURITY INVOKER
AS
BEGIN
	SELECT
		C."ItmsGrpNam" AS "품목그룹",
		A."ItemCode" AS "품목코드",
		A."Dscription" AS "품명",
		D."WhsName" AS "창고",
		SUM(A."InQty" - A."OutQty") AS "수량",
		SUM(A."TransValue") AS "금액",
		ROUND(SUM(A."TransValue") / SUM(A."InQty" - A."OutQty")) AS "총평균단가"
	FROM OINM A
	INNER JOIN OITM B ON A."ItemCode" = B."ItemCode"
	INNER JOIN OITB C ON B."ItmsGrpCod" = C."ItmsGrpCod"
	INNER JOIN OWHS D ON A."Warehouse" = D."WhsCode"
	--INNER JOIN OPDN D ON A."CreatedBy" = D."DocEntry"
	WHERE A."TransType" IN (18, 20, 22)
	AND TO_NVARCHAR(A."DocDate", 'YYYY-MM') = :YYYYMM
	--AND (D."BPLId" = :BPLID OR '' = :BPLID)
	AND (A."SlpCode" = :SLPCODE OR '' = :SLPCODE)
	GROUP BY C."ItmsGrpNam", A."ItemCode", A."Dscription", D."WhsName"
	
	UNION ALL
	
	SELECT
		C."ItmsGrpNam" AS "품목그룹",
		A."ItemCode" AS "품목코드",
		A."Dscription" AS "품명",
		D."WhsName" AS "창고",
		SUM(A."InQty" - A."OutQty") AS "수량",
		SUM(A."TransValue") AS "금액",
		ROUND(SUM(A."TransValue") / SUM(A."InQty" - A."OutQty")) AS "총평균단가"
	FROM OINM A
	INNER JOIN OITM B ON A."ItemCode" = B."ItemCode"
	INNER JOIN OITB C ON B."ItmsGrpCod" = C."ItmsGrpCod"
	INNER JOIN OWHS D ON A."Warehouse" = D."WhsCode"
	WHERE A."TransType" = 59 AND A."AppObjType" = 'P'
	AND TO_NVARCHAR(A."DocDate", 'YYYY-MM') = :YYYYMM
	AND (A."SlpCode" = :SLPCODE OR '' = :SLPCODE)
	GROUP BY C."ItmsGrpNam", A."ItemCode", A."Dscription", D."WhsName";
END;
CALL STD_ICM_I_110 ('2020-04', '1', '-1');