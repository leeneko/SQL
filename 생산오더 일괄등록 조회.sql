ALTER PROCEDURE STD_PDM_I_110 (
	IN ITEMGRP NVARCHAR(20),
	IN ITEMCODE NVARCHAR(50),
	IN ITEMNAME NVARCHAR(100),
	IN DOCDATE NVARCHAR(10), -- 생산오더일
	IN WHSCODE NVARCHAR(20)
)
LANGUAGE SQLSCRIPT
SQL SECURITY INVOKER
AS
BEGIN
	SELECT
		'' AS "선택L000Y",
		V."ItemCode" AS "품목코드L004Y",
		V."ItemName" AS "품명L000Y",
		V."CmpltQty" AS "진행수량R000Y",
		V."PlannedQty" AS "오더수량R000Y",
		V."Warehouse" AS "창고L000Y",
		V."Priority" AS "우선순위R000Y",
		V."UserSign" AS "사용자L000Y",
		V."OriginNum" AS "판매오더L000Y",
		V."CardCode" AS "고객L000Y",
		V."OcrCode" AS "배부규칙L000Y",
		V."Project" AS "프로젝트L000Y"
	FROM (
		SELECT
			A."ItemCode",
			A."ItemName",
			0 AS "CmpltQty",
			0 AS "PlannedQty",
			A."DfltWH" AS "Warehouse",
			0 AS "Priority",
			0 AS "UserSign",
			0 AS "OriginNum",
			'' AS "CardCode",
			'' AS "OcrCode",
			'' AS "Project"
		FROM OITM A
		INNER JOIN OITT B ON A."ItemCode" = B."Code"
		INNER JOIN OITB C ON A."ItmsGrpCod" = C."ItmsGrpCod"
		WHERE (A."ItmsGrpCod" = :ITEMGRP OR '' = :ITEMGRP)
		AND A."ItemCode" LIKE '%' || :ITEMCODE || '%'
		AND A."ItemName" LIKE '%' || :ITEMNAME || '%'
		AND B."TreeType" = 'P'
		
		UNION ALL
		
		SELECT
			A."ItemCode",
			A."ProdName",
			A."CmpltQty",
			A."PlannedQty",
			A."Warehouse",
			A."Priority",
			A."UserSign",
			A."OriginNum",
			A."CardCode",
			A."OcrCode",
			A."Project"
		FROM OWOR A
		WHERE (A."PostDate" = :DOCDATE OR '' = :DOCDATE)
		AND (A."Warehouse" = :WHSCODE OR '' = :WHSCODE)
		AND A."Status" = 'R'
	) V
	ORDER BY V."ItemCode";
END;
CALL STD_PDM_I_110 ('', '', '', '', '');