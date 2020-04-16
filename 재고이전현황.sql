CREATE PROCEDURE STD_ICM_O_140 (
	IN FROMDT NVARCHAR(10),
	IN TODATE NVARCHAR(10),
	IN ITEMGRP NVARCHAR(20),
	IN FROMWHS NVARCHAR(8),
	IN TOWHS NVARCHAR(8),
	IN ITEMCODE NVARCHAR(50)
)
LANGUAGE SQLSCRIPT
SQL SECURITY INVOKER
AS
BEGIN
	SELECT
		TO_NVARCHAR(A."DocDate", 'YYYY-MM-DD') AS "일자L000Y",
		D."ItmsGrpNam" AS "품목그룹L000Y",
		B."ItemCode" AS "품목코드L004Y",
		B."Dscription" AS "품명L000Y",
--		B."FromWhsCod" AS "출고창고L000Y",
		E."WhsName" AS "출고창고L000Y",
--		B."WhsCode" AS "입고창고L000Y",
		F."WhsName" AS "입고창고L000Y",
		B."Quantity" AS "수량R000Y",
		0 AS "총평균단가R000Y",
		0 AS "재고금액R000Y"
	FROM OWTR A
	INNER JOIN WTR1 B ON A."DocEntry" = B."DocEntry"
	INNER JOIN OITM C ON B."ItemCode" = C."ItemCode"
	INNER JOIN OITB D ON C."ItmsGrpCod" = D."ItmsGrpCod"
	LEFT JOIN OWHS E ON B."FromWhsCod" = E."WhsCode"
	LEFT JOIN OWHS F ON B."WhsCode" = F."WhsCode"
	WHERE A."DocDate" >= :FROMDT
	AND A."DocDate" <= :TODATE
	AND (C."ItmsGrpCod" = :ITEMGRP OR '' = :ITEMGRP)
	AND (B."FromWhsCod" = :FROMWHS OR '' = :FROMWHS)
	AND (B."WhsCode" = :TOWHS OR '' = :TOWHS)
	AND (B."ItemCode" = :ITEMCODE OR '' = :ITEMCODE);
END;
CALL STD_ICM_O_140 ('20200101', '20201231', '', '', '', '10003');
