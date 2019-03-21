DROP PROCEDURE OCRDTEST;
CREATE PROCEDURE OCRDTEST (
	IN FR_DT NVARCHAR(10),
	IN TO_DT NVARCHAR(10),
	IN CARDCODE NVARCHAR(20)
)
LANGUAGE SQLSCRIPT
SQL SECURITY INVOKER
AS 
BEGIN
	DECLARE query NVARCHAR(4000) = '';
	DECLARE DAYCNT INT;
	DECLARE CNT INT;
	DECLARE DD NVARCHAR(8) = '';
	DECLARE ALIAS NVARCHAR(10) = '';
	
	SELECT
		DAYS_BETWEEN(:FR_DT, :TO_DT)
	INTO DAYCNT
	FROM DUMMY;
	
	CNT := 0;
		
	query := :query || 'SELECT  ';
	query := :query || '	A."CardCode",  ';
	query := :query || '	A."CardName", ';

	WHILE CNT <= DAYCNT DO
	
		SELECT TO_NVARCHAR(ADD_DAYS(:FR_DT, :CNT), 'YYYYMMDD')
		INTO DD
		FROM DUMMY;
		
		ALIAS := RIGHT(:DD, 2) || '일';
		query := :query || '	SUM( CASE WHEN TO_NVARCHAR( A."DocDate", ''YYYYMMDD'' ) = ''' || :DD || ''' THEN B."Quantity" ELSE 0 END ) AS "' || :ALIAS || '", ';
	
		CNT := :CNT + 1;
	END WHILE;
	
	query := :query || '	SUM( B."Quantity") AS "집계" ';
	query := :query || 'FROM "ORDR" A ';
	query := :query || 'INNER JOIN "RDR1" B ON A."DocEntry" = B."DocEntry" ';
	query := :query || 'WHERE TO_NVARCHAR( A."DocDate", ''YYYYMMDD'' ) BETWEEN ''' || :FR_DT || ''' AND ''' || :TO_DT || ''' ';
	query := :query || 'AND A."CardCode" LIKE ''%' || :CARDCODE || '%'' ';
	query := :query || 'GROUP BY A."CardCode", A."CardName" ';
	query := :query || 'ORDER BY A."CardCode"; ';
	
	EXECUTE IMMEDIATE (:query);
END;

CALL OCRDTEST('20190220', '20190310', '');