CREATE PROCEDURE STD_OEM_O_130 (
	IN FROMDT NVARCHAR(10),
	IN TODATE NVARCHAR(10),
	IN BPLID NVARCHAR(11),
	IN CARDCODE NVARCHAR(15),
	IN SLPCODE NVARCHAR(11),
	IN ITEMGRP NVARCHAR(20),
	IN ITEMCODE NVARCHAR(50),
	IN WHSCODE NVARCHAR(8),
	IN STATUS NVARCHAR(1)
)
LANGUAGE SQLSCRIPT
SQL SECURITY INVOKER
AS
BEGIN
	SELECT
		TO_NVARCHAR(A."DocDate", 'YYYY-MM-DD') AS "일자L000Y",
		A."DocEntry" AS "문서번호L017Y",
		A."CardCode" AS "거래처L002Y",
		A."CardName" AS "거래처명L000Y",
		D."SlpName" AS "영업사원L000Y",
		B."LineNum" AS "순번L000Y",
		B."ItemCode" AS "품목L004Y",
		B."Dscription" AS "품명L000Y",
		B."unitMsr" AS "단위L000Y",
		B."Quantity" AS "오더수량R000Y",
		B."Price" As "단가R000Y",
		B."LineTotal" AS "금액R000Y",
		B."DelivrdQty" AS "마감수량R000Y",
		B."OpenQty" AS "미결수량R000Y",
		B."Text" AS "비고L000Y" -- A."Comments"
	FROM ORDR A
	INNER JOIN RDR1 B ON A."DocEntry" = B."DocEntry"
	INNER JOIN OITM C ON B."ItemCode" = C."ItemCode"
	LEFT JOIN OSLP D ON A."SlpCode" = D."SlpCode"
	WHERE A."DocDate" >= :FROMDT
	AND A."DocDate" <= :TODATE
	AND (CAST(A."BPLId" AS NVARCHAR) = :BPLID OR '' = :BPLID)
	AND (A."CardCode" = :CARDCODE OR '' = :CARDCODE)
	AND (CAST(A."SlpCode" AS NVARCHAR) = :SLPCODE OR '' = :SLPCODE)
	AND (C."ItmsGrpCod" = :ITEMGRP OR '' = :ITEMGRP)
	AND (B."ItemCode" = :ITEMCODE OR '' = :ITEMCODE)
	AND (B."WhsCode" = :WHSCODE OR '' = :WHSCODE)
	AND (A."DocStatus" = :STATUS OR '' = :STATUS);
END;
CALL STD_OEM_O_130 ('20200101', '20200416', '1', 'C00001', '', '', '', '', '');