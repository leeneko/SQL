CREATE PROCEDURE STD_ICM_O_130 (
	IN FROMDT NVARCHAR(10),
	IN TODATE NVARCHAR(10),
	IN CARDCODE NVARCHAR(15),
	IN ITEMGRP NVARCHAR(20),
	IN WHSCODE NVARCHAR(8),
	IN ITEMCODE NVARCHAR(50)
)
LANGUAGE SQLSCRIPT
SQL SECURITY INVOKER
AS
BEGIN
	SELECT
		A."TransNum" AS "전표번호L000N",
		APR_TRANSTYPE(A."TransType") AS "전표유형L000Y",
		TO_NVARCHAR(A."DocDate", 'YYYY-MM-DD') AS "일자L000Y",
		A."CardCode" AS "거래처L002Y",
		B."CardName" AS "거래처명L000Y",
		D."ItmsGrpNam" AS "품목그룹L000Y",
		A."ItemCode" AS "품목코드L004Y",
		C."ItemName" AS "품명L000Y",
		C."InvntryUom" AS "단위L000Y",
		E."WhsName" AS "창고L000Y",
		ABS(A."InQty" - A."OutQty") AS "수량R000Y",
		A."Price" AS "단가R000Y",
		ABS(A."InQty" - A."OutQty") * A."Price" AS "금액R000Y"
	FROM OINM A
	INNER JOIN OCRD B ON A."CardCode" = B."CardCode"
	INNER JOIN OITM C ON A."ItemCode" = C."ItemCode"
	INNER JOIN OITB D ON C."ItmsGrpCod" = D."ItmsGrpCod"
	INNER JOIN OWHS E ON A."Warehouse" = E."WhsCode"
	WHERE A."DocDate" >= :FROMDT
	AND A."DocDate" <= :TODATE
	AND A."CardCode" LIKE '%' || :CARDCODE || '%'
	AND C."ItmsGrpCod" LIKE '%' || :ITEMGRP || '%'
	AND A."Warehouse" LIKE '%' || :WHSCODE || '%'
	AND A."ItemCode" LIKE '%' || :ITEMCODE || '%'
	ORDER BY A."TransNum";
END;
CALL STD_ICM_O_130 ('20200325', '20201231', '', '', '', '10003');