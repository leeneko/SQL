ALTER PROCEDURE STD_PDM_I_130 (
	IN ORDERDT NVARCHAR(10),
	IN ITEMGRP NVARCHAR(20),
	IN WHSCODE NVARCHAR(20)
)
LANGUAGE SQLSCRIPT
SQL SECURITY INVOKER
AS
BEGIN
	SELECT
		'' AS "선택L000Y",
		A."DocEntry" AS "문서번호L202Y",
		C."LineNum" AS "라인번호R000N",
		CASE A."Type"
			WHEN 'S'
			THEN '표준'
			WHEN 'P'
			THEN '판매'
			WHEN 'D'
			THEN '분해'
		END AS "유형L000Y",
		CASE A."Status"
			WHEN 'P'
			THEN '계획'
			WHEN 'R'
			THEN '릴리즈'
			WHEN 'L'
			THEN '마감'
		END AS "상태L000Y",
--		A."Priority" AS "우선순위R000Y",
		A."ItemCode" AS "제품코드L004Y",
		A."ProdName" AS "제품명L000Y",
		A."PlannedQty" AS "오더수량R000Y",
		C."ItemCode" AS "품목코드L004Y",
		D."ItemName" AS "품명L000Y",
		C."BaseQty" AS "기준수량R000Y",
		C."PlannedQty" AS "계획수량R000Y",
		CAST(C."PlannedQty" - C."IssuedQty" AS DOUBLE) AS "미결수량R000Y",
		C."IssuedQty" AS "출고수량R000Y",
		A."Warehouse" AS "창고L064Y"
	FROM OWOR A
	INNER JOIN OITM B ON A."ItemCode" = B."ItemCode"
	INNER JOIN WOR1 C ON A."DocEntry" = C."DocEntry"
	INNER JOIN OITM D ON C."ItemCode" = D."ItemCode"
	WHERE A."PostDate" = :ORDERDT
	AND (B."ItmsGrpCod" = :ITEMGRP OR '' = :ITEMGRP)
	AND (A."Warehouse" = :WHSCODE OR '' = :WHSCODE)
	AND A."Status" = 'R'
	AND C."IssueType" = 'M'; -- 출고 방식 M:수동
END;
CALL STD_PDM_I_130 ('20200421', '', '');