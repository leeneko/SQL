CREATE PROCEDURE STD_PDM_O_120 (
	IN FROMDT NVARCHAR(10),
	IN TODATE NVARCHAR(10),
	IN ITEMGRP NVARCHAR(20),
	IN WHSCODE NVARCHAR(20),
	IN ITEMCODE NVARCHAR(50)
)
LANGUAGE SQLSCRIPT
SQL SECURITY INVOKER
AS
BEGIN
	SELECT
		TO_NVARCHAR(A."PostDate", 'YYYY-MM-DD') AS "생산오더일L000Y",
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
			WHEN 'C'
			THEN '취소'
		END AS "상태L000Y",
		A."ItemCode" AS "제품코드L004Y",
		A."ProdName" AS "제품명L000Y",
		A."PlannedQty" AS "계획R000Y",
		TO_NVARCHAR(A."DueDate", 'YYYY-MM-DD') AS "생산일L000Y",
		A."CmpltQty" AS "완료R000Y",
		A."PlannedQty" - A."CmpltQty" AS "미결R000Y",
		B."ItemCode" AS "품목코드L004Y",
		C."ItemName" AS "품명L000Y",
		B."BaseQty" AS "기준수량R000Y",
		B."PlannedQty" AS "계획수량R000Y",
		B."PlannedQty" - B."IssuedQty" AS "미결수량R000Y",
		B."IssuedQty" AS "출고R000Y",
		B."wareHouse" AS "창고L000Y"
	FROM OWOR A
	INNER JOIN WOR1 B ON A."DocEntry" = B."DocEntry"
	INNER JOIN OITM C ON B."ItemCode" = C."ItemCode"
	INNER JOIN OITM D ON A."ItemCode" = D."ItemCode"
	WHERE TO_NVARCHAR(A."PostDate", 'YYYYMMDD') >= :FROMDT
	AND TO_NVARCHAR(A."PostDate", 'YYYYMMDD') <= :TODATE
	AND (D."ItmsGrpCod" = :ITEMGRP OR '' = :ITEMGRP)
	AND (A."Warehouse" = :WHSCODE OR '' = :WHSCODE)
	AND (A."ItemCode" = :ITEMCODE OR '' = :ITEMCODE);
END;
CALL STD_PDM_O_120 ('20200421', '20200421', '', '', '');