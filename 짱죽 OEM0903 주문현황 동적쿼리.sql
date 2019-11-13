ALTER PROCEDURE APR_OEM0903 (
	IN ORDERDT NVARCHAR(30) -- 판매오더 일괄등록 전표 주문일 기준
)
LANGUAGE SQLSCRIPT
SQL SECURITY INVOKER
AS
BEGIN
	DECLARE query NVARCHAR(4000) := '';
	DECLARE i INT := 0;
	DECLARE n INT := 0;
	DECLARE code NVARCHAR(100);
	DECLARE name NVARCHAR(100);
	
	CREATE LOCAL TEMPORARY TABLE #TEMPGRP2 (
		SEQ	INT,
		CODE NVARCHAR(30),
		NAME NVARCHAR(30)
	);
	
	INSERT INTO #TEMPGRP2 (
		SEQ,
		CODE,
		NAME
	)
	SELECT
		ROW_NUMBER() OVER (ORDER BY V."Code"),
		V."Code",
		V."Name"
	FROM (
	SELECT DISTINCT
		D."Code",
		D."Name"
	FROM "@APR_OSHP" A
	INNER JOIN "@APR_SHP1" B ON A."DocEntry" = B."DocEntry"
	INNER JOIN OITM C ON B."U_ITEMCODE" = C."ItemCode"
	INNER JOIN "@APR_GRP2" D ON C."U_GROUP2" = D."Code"
	WHERE A."U_ORDERDT" = :ORDERDT
	) V;
	
	
	SELECT
		MIN(A."SEQ"), MAX(A."SEQ")
	INTO i, n
	FROM #TEMPGRP2 A;
	
	query := :query || 'SELECT ';
	query := :query || '	B."U_ITEMCODE" AS "ItemCode", ';
	query := :query || '	B."U_ITEMNAME" AS "ItemName", ';
	query := :query || '	SUM(B."U_QUANTITY") AS "Quantity" ';
		WHILE i <= n DO
			SELECT
				A."CODE", A."NAME"
			INTO code, name
			FROM #TEMPGRP2 A
			WHERE A."SEQ" = :i;
			
	query := :query || '	, SUM(CASE WHEN C."U_GROUP2" = ' || :code || ' THEN B."U_QUANTITY" ELSE 0 END) AS "' || :name || '" ';
			
			i := :i + 1;
		END WHILE;
	query := :query || 'FROM "@APR_OSHP" A ';
	query := :query || 'INNER JOIN "@APR_SHP1" B ON A."DocEntry" = B."DocEntry" ';
	query := :query || 'INNER JOIN OITM C ON B."U_ITEMCODE" = C."ItemCode" AND B."U_ITEMNAME" = C."ItemName" ';
	query := :query || 'WHERE TO_NVARCHAR(A."U_ORDERDT", ''YYYYMMDD'') = ' || :ORDERDT || ' ';
	query := :query || 'GROUP BY B."U_ITEMCODE", B."U_ITEMNAME" ';
	query := :query || 'ORDER BY B."U_ITEMCODE"';
	
	EXECUTE IMMEDIATE (:query);
	DROP TABLE #TEMPGRP2;
END;
CALL APR_OEM0903 ('20191112');