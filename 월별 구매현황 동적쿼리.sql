ALTER PROCEDURE STD_POM_O_140 (
	IN YYYY NVARCHAR(10),
	IN BPLID NVARCHAR(20),
	IN SELTYPE NVARCHAR(10),
	IN SLPCODE NVARCHAR(20),
	IN CARDCODE NVARCHAR(15),
	IN ITMGRP NVARCHAR(20),
	IN ITEMCODE NVARCHAR(50)
)
LANGUAGE SQLSCRIPT
SQL SECURITY INVOKER
AS
BEGIN
	DECLARE MON INT := 1;
	DECLARE QUERY NVARCHAR(4000) = 'SELECT ';
	
	IF (:SELTYPE = '1')
	THEN
		QUERY := :QUERY || 'A."CardCode" AS "거래처L002Y", ';
		QUERY := :QUERY || 'A."CardName" AS "거래처명L000Y", ';
		QUERY := :QUERY || 'C."SlpName" AS "영업사원L000Y", ';
	ELSEIF (:SELTYPE = '2')
	THEN
		QUERY := :QUERY || 'E."ItmsGrpNam" AS "품목그룹L000Y", ';
		QUERY := :QUERY || 'D."ItemCode" AS "품목L004Y", ';
		QUERY := :QUERY || 'D."ItemName" AS "품명L000Y", ';
	END IF;
	WHILE :MON <= 12 DO
		QUERY := :QUERY || 'SUM(CASE WHEN MONTH(A."DocDate") = ''' || :MON || ''' THEN COALESCE(B."LineTotal", 0) END) AS "' || :MON || '월R000Y", ';
		MON := :MON + 1;
	END WHILE;
	QUERY := :QUERY || 'SUM(B."LineTotal") AS "합계R000Y" ';
	QUERY := :QUERY || 'FROM OPCH A ';
	QUERY := :QUERY || 'INNER JOIN PCH1 B ON A."DocEntry" = B."DocEntry" ';
	QUERY := :QUERY || 'INNER JOIN OSLP C ON A."SlpCode" = C."SlpCode" ';
	QUERY := :QUERY || 'INNER JOIN OITM D ON B."ItemCode" = D."ItemCode" ';
	QUERY := :QUERY || 'INNER JOIN OITB E ON D."ItmsGrpCod" = E."ItmsGrpCod" ';
	QUERY := :QUERY || 'WHERE YEAR(A."DocDate") = ''' || :YYYY || ''' '; -- 연도
	QUERY := :QUERY || 'AND (A."BPLId" = ''' || :BPLID || ''' OR '''' = ''' || :BPLID || ''') '; -- 사업장
	QUERY := :QUERY || 'AND (A."SlpCode" = ''' || :SLPCODE || ''' OR '''' = ''' || :SLPCODE || ''') '; -- 영업사원
	QUERY := :QUERY || 'AND (A."CardCode" = ''' || :CARDCODE || ''' OR '''' = ''' || :CARDCODE || ''') '; -- 거래처
	QUERY := :QUERY || 'AND (D."ItmsGrpCod" = ''' || :ITMGRP || ''' OR '''' = ''' || :ITMGRP || ''') '; -- 품목그룹
	QUERY := :QUERY || 'AND (D."ItemCode" = ''' || :ITEMCODE || ''' OR '''' = ''' || :ITEMCODE || ''') '; -- 품목
	IF (:SELTYPE = '1')
	THEN
		QUERY := :QUERY || 'GROUP BY A."CardCode", A."CardName", C."SlpName" ';
		QUERY := :QUERY || 'ORDER BY A."CardCode", C."SlpName";';
	ELSEIF (:SELTYPE = '2')
	THEN
		QUERY := :QUERY || 'GROUP BY E."ItmsGrpNam", D."ItemCode", D."ItemName" ';
		QUERY := :QUERY || 'ORDER BY E."ItmsGrpNam", D."ItemCode";';
	END IF;
	
	-- SELECT :QUERY FROM DUMMY;
	EXECUTE IMMEDIATE (:QUERY);
END;
CALL STD_POM_O_140 ('2020', '1', '1', '', '', '', '');