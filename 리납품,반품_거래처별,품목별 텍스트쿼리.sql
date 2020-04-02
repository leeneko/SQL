DROP PROCEDURE APR_SAMPLE_02;
CREATE PROCEDURE APR_SAMPLE_02 (
	IN FROMDT NVARCHAR(10), -- 조회기간 FROM ~
	IN TODATE NVARCHAR(10), -- 조회기간 ~ TO
	IN BPLID NVARCHAR(10), -- 사업장
	IN CARDCODE NVARCHAR(15), -- 거래처 코드
	IN CHKCOMBO NVARCHAR(10), -- 콤보 (거래처 : 0, 상품 : 1)
	IN CHKODLN NVARCHAR(10), -- 체크박스 납품
	IN CHKORDN NVARCHAR(10) -- 체크박스 반품
)
LANGUAGE SQLSCRIPT
SQL SECURITY INVOKER
AS
BEGIN
	DECLARE QUERY NVARCHAR(4000) = '';
	-- 0) 프로그램에서 조회기간, 사업장, 체크박스 한개 이상 체크한 뒤 아래 실행
	QUERY := :QUERY || 'SELECT ';
	QUERY := :QUERY || '	* ';
	QUERY := :QUERY || 'FROM (';
	IF (:CHKODLN = '1')
	THEN
		QUERY := :QUERY || 'SELECT ';
		QUERY := :QUERY || '	A."CardCode" AS "거래처코드L002Y", ';
		QUERY := :QUERY || '	A."CardName" AS "거래처명L000Y", ';
		IF (:CHKCOMBO = '1')
		THEN
			QUERY := :QUERY || 'B."ItemCode" AS "아이템코드L004Y", ';
			QUERY := :QUERY || 'B."Dscription" AS "아이템명L000Y", ';
		END IF;
		QUERY := :QUERY || '	SUM(B."Quantity") AS "수량R000Y", ';
		QUERY := :QUERY || '	SUM(B."LineTotal") AS "단가R000Y", ';
		QUERY := :QUERY || '	SUM(B."VatSum") AS "세액R000Y", ';
		QUERY := :QUERY || '	SUM(B."GTotal") AS "합계R000Y" ';
		QUERY := :QUERY || 'FROM ODLN A ';
		QUERY := :QUERY || 'INNER JOIN DLN1 B ON A."DocEntry" = B."DocEntry" ';
		IF (:BPLID != '')
		THEN
			QUERY := :QUERY || 'WHERE CAST(A."BPLId" AS NVARCHAR) = ' || :BPLID || ' ';
		END IF;
		QUERY := :QUERY || 'AND TO_NVARCHAR(A."DocDate", ''YYYYMMDD'') >= ' || :FROMDT || ' ';
		QUERY := :QUERY || 'AND TO_NVARCHAR(A."DocDate", ''YYYYMMDD'') <= ' || :TODATE || ' ';
		QUERY := :QUERY || 'AND A."CANCELED" != ''Y'' ';
		QUERY := :QUERY || 'GROUP BY A."CardCode", A."CardName" ';
		IF (:CHKCOMBO = '1')
		THEN
			QUERY := :QUERY || ', B."ItemCode", B."Dscription" ';
		END IF;
	END IF;
	-- 1+2) 납품과 반품 모두 선택
	IF (:CHKODLN = '1' AND :CHKORDN = '1')
	THEN
		QUERY := :QUERY || 'UNION ALL ';
	END IF;
	-- 2) 반품
	IF (:CHKORDN = '1')
	THEN
		QUERY := :QUERY || 'SELECT ';
		QUERY := :QUERY || '	A."CardCode" AS "거래처코드L002Y", ';
		QUERY := :QUERY || '	A."CardName" AS "거래처명L000Y", ';
		IF (:CHKCOMBO = '1')
		THEN
			QUERY := :QUERY || 'B."ItemCode" AS "아이템코드L004Y", ';
			QUERY := :QUERY || 'B."Dscription" AS "아이템명L000Y", ';
		END IF;
		QUERY := :QUERY || '	SUM(B."Quantity") AS "수량R000Y", ';
		QUERY := :QUERY || '	SUM(B."LineTotal") AS "단가R000Y", ';
		QUERY := :QUERY || '	SUM(B."VatSum") AS "세액R000Y", ';
		QUERY := :QUERY || '	SUM(B."GTotal") AS "합계R000Y" ';
		QUERY := :QUERY || 'FROM ORDN A ';
		QUERY := :QUERY || 'INNER JOIN RDN1 B ON A."DocEntry" = B."DocEntry" ';
		IF (:BPLID != '')
		THEN
			QUERY := :QUERY || 'WHERE CAST(A."BPLId" AS NVARCHAR) = ' || :BPLID || ' ';
		END IF;
		QUERY := :QUERY || 'AND TO_NVARCHAR(A."DocDate", ''YYYYMMDD'') >= ' || :FROMDT || ' ';
		QUERY := :QUERY || 'AND TO_NVARCHAR(A."DocDate", ''YYYYMMDD'') <= ' || :TODATE || ' ';
		QUERY := :QUERY || 'AND A."CANCELED" != ''Y'' ';
		QUERY := :QUERY || 'GROUP BY A."CardCode", A."CardName" ';
		IF (:CHKCOMBO = '1')
		THEN
			QUERY := :QUERY || ', B."ItemCode", B."Dscription" ';
		END IF;
	END IF;	
	QUERY := :QUERY || ') V ';
	QUERY := :QUERY || 'WHERE V."거래처코드L002Y" LIKE ''%' || :CARDCODE || '%'' ';
	QUERY := :QUERY || 'ORDER BY V."거래처코드L002Y"';
	
	-- SELECT :QUERY FROM DUMMY;
	EXECUTE IMMEDIATE (:QUERY);
END;
-- CALL APR_SAMPLE_02 ('FROMDT', 'TODATE', 사업장, '거래처코드', '거래처 품목 콤보', '납품', '반품');
CALL APR_SAMPLE_02 ('20191101', '20200402', '', '', '0', '1', '0');