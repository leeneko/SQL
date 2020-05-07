CREATE PROCEDURE STD_MST_M_110 (

)
LANGUAGE SQLSCRIPT
SQL SECURITY INVOKER
AS
BEGIN
	SELECT
		'비지니스마스터' AS "분류",
		A."CardCode" AS "Code",
		A."CardName" AS "Name",
		A."RepName" AS "기타1",
		A."Notes" AS "기타2"
	FROM OCRD A
	WHERE A."CreateDate" >= ADD_DAYS(CURRENT_DATE, -3)
	
	UNION ALL
	
	SELECT
		'품목',
		A."ItemCode",
		A."ItemName",
		A."InvntryUom",
		B."ItmsGrpNam"
	FROM OITM A
	INNER JOIN OITB B ON A."ItmsGrpCod" = B."ItmsGrpCod"
	WHERE A."CreateDate" >= ADD_DAYS(CURRENT_DATE, -3)
	
	UNION ALL
	
	SELECT
		'BOM',
		B."ItemCode",
		B."ItemName",
		B."InvntryUom",
		''
	FROM OITT A
	INNER JOIN OITM B ON A."Code" = B."ItemCode"
	WHERE A."CreateDate" >= ADD_DAYS(CURRENT_DATE, -3)
	
	UNION ALL
	
	SELECT
		'계정과목',
		A."AcctCode",
		A."AcctName",
		'',
		''
	FROM OACT A
	WHERE A."CreateDate" >= ADD_DAYS(CURRENT_DATE, -3);
END;
-- 계정과목 테이블에 등록자나 수정한 사람 정보가 없음
CALL STD_MST_M_110 ();