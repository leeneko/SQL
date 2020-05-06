ALTER PROCEDURE STD_PDM_I_120 (
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
		A."Priority" AS "우선순위R000Y",
		A."ItemCode" AS "품목코드L004Y",
		A."ProdName" AS "품명L000Y",
		A."PlannedQty" AS "오더수량R000Y",
		A."PlannedQty" - A."CmpltQty" AS "미결수량R000Y",
		A."CmpltQty" AS "입고수량R000Y",
		A."Warehouse" AS "창고L064Y"
	FROM OWOR A
	INNER JOIN OITM B ON A."ItemCode" = B."ItemCode"
	WHERE A."PostDate" = :ORDERDT
	AND (B."ItmsGrpCod" = :ITEMGRP OR '' = :ITEMGRP)
	AND (A."Warehouse" = :WHSCODE OR '' = :WHSCODE)
	AND A."Status" = 'R';
END;
CALL STD_PDM_I_120 ('20200421', '', '');