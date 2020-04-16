CREATE PROCEDURE STD_ICM_O_110 (
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
		V."ItmsGrpNam" AS "품목그룹L000Y",
		V."ItemCode" AS "품목코드L004Y",
		V."ItemName" AS "품명L000Y",
		V."WhsName" AS "창고L000Y",
		SUM(V."Restocked") AS "이전재고R000Y",
		SUM(V."InQty") AS "입고R000Y",
		SUM(V."OutQty") AS "출고R000Y",
		SUM(V."Quantity") AS "현재고R000Y",
		SUM(V."AvgPrice") AS "총평균단가R000Y",
		SUM(V."StockAmount") AS "재고금액R000Y"
	FROM (
		SELECT
			C."ItmsGrpNam",
			A."ItemCode",
			B."ItemName",
			D."WhsName",
			SUM(A."InQty" - A."OutQty") AS "Restocked",
			0 AS "InQty",
			0 AS "OutQty",
			SUM(A."InQty" - A."OutQty") AS "Quantity",
			0 AS "AvgPrice",
			0 AS "StockAmount"
		FROM OINM A
		INNER JOIN OITM B ON A."ItemCode" = B."ItemCode"
		INNER JOIN OITB C ON B."ItmsGrpCod" = C."ItmsGrpCod"
		INNER JOIN OWHS D ON A."Warehouse" = D."WhsCode"
		WHERE A."DocDate" < :FROMDT
		AND (B."ItmsGrpCod" = :ITEMGRP OR '' = :ITEMGRP)
		AND (A."Warehouse" = :WHSCODE OR '' = :WHSCODE)
		AND A."ItemCode" LIKE '%' || :ITEMCODE || '%'
		GROUP BY C."ItmsGrpNam", A."ItemCode", A."Warehouse", B."ItemName", D."WhsName"
		
		UNION ALL
		
		SELECT
			C."ItmsGrpNam",
			A."ItemCode",
			B."ItemName",
			D."WhsName",
			0,
			SUM(A."InQty"),
			SUM(A."OutQty"),
			SUM(A."InQty" - A."OutQty"),
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
		AND A."ItemCode" LIKE '%' || :ITEMCODE || '%'
		GROUP BY C."ItmsGrpNam", A."ItemCode", A."Warehouse", B."ItemName", D."WhsName"
	) V
	GROUP BY V."ItmsGrpNam", V."ItemCode", V."ItemName", V."WhsName";
END;
CALL STD_ICM_O_110 ('20200325', '20201231', '', '', '10003');