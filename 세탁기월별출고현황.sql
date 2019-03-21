DROP PROCEDURE APR_ICM0910B;
CREATE PROCEDURE APR_ICM0910B (
	IN DT DATETIME,
	OUT TEMP TABLE (
		"품목코드"		NVARCHAR(30),
		"현재고"		DECIMAL(28, 6),
		"출하수량"		DECIMAL(28, 6),
		"1"			DECIMAL(28, 6),
		"2"			DECIMAL(28, 6),
		"3"			DECIMAL(28, 6),
		"4"			DECIMAL(28, 6),
		"5"			DECIMAL(28, 6),
		"6"			DECIMAL(28, 6),
		"7"			DECIMAL(28, 6),
		"8"			DECIMAL(28, 6),
		"9"			DECIMAL(28, 6),
		"10"		DECIMAL(28, 6),
		"11"		DECIMAL(28, 6),
		"12"		DECIMAL(28, 6),
		"13"		DECIMAL(28, 6),
		"14"		DECIMAL(28, 6),
		"15"		DECIMAL(28, 6),
		"16"		DECIMAL(28, 6),
		"17"		DECIMAL(28, 6),
		"18"		DECIMAL(28, 6),
		"19"		DECIMAL(28, 6),
		"20"		DECIMAL(28, 6),
		"21"		DECIMAL(28, 6),
		"22"		DECIMAL(28, 6),
		"23"		DECIMAL(28, 6),
		"24"		DECIMAL(28, 6),
		"25"		DECIMAL(28, 6),
		"26"		DECIMAL(28, 6),
		"27"		DECIMAL(28, 6),
		"28"		DECIMAL(28, 6),
		"29"		DECIMAL(28, 6),
		"30"		DECIMAL(28, 6),
		"31"		DECIMAL(28, 6),
		"이월"		DECIMAL(28, 6),
		"대납"		DECIMAL(28, 6),
		"동아대납"		DECIMAL(28, 6)
	)
)
LANGUAGE SQLSCRIPT
SQL SECURITY INVOKER
AS
BEGIN
	-- 세탁기 출고, 날짜 1개를 입력받아 해당 날짜의 월에 포함된 데이터 출력
	DECLARE QUERY NVARCHAR(4000) = '';
	DECLARE MON NVARCHAR(6);
	DECLARE FR_DT NVARCHAR(8);
	DECLARE TO_DT NVARCHAR(8);
	DECLARE CNT INT;
	CREATE LOCAL TEMPORARY TABLE #TEMPRES (
		"품목코드"		NVARCHAR(30),
		"현재고"		DECIMAL(28, 6),
		"출하수량"		DECIMAL(28, 6),
		"1"			DECIMAL(28, 6),
		"2"			DECIMAL(28, 6),
		"3"			DECIMAL(28, 6),
		"4"			DECIMAL(28, 6),
		"5"			DECIMAL(28, 6),
		"6"			DECIMAL(28, 6),
		"7"			DECIMAL(28, 6),
		"8"			DECIMAL(28, 6),
		"9"			DECIMAL(28, 6),
		"10"		DECIMAL(28, 6),
		"11"		DECIMAL(28, 6),
		"12"		DECIMAL(28, 6),
		"13"		DECIMAL(28, 6),
		"14"		DECIMAL(28, 6),
		"15"		DECIMAL(28, 6),
		"16"		DECIMAL(28, 6),
		"17"		DECIMAL(28, 6),
		"18"		DECIMAL(28, 6),
		"19"		DECIMAL(28, 6),
		"20"		DECIMAL(28, 6),
		"21"		DECIMAL(28, 6),
		"22"		DECIMAL(28, 6),
		"23"		DECIMAL(28, 6),
		"24"		DECIMAL(28, 6),
		"25"		DECIMAL(28, 6),
		"26"		DECIMAL(28, 6),
		"27"		DECIMAL(28, 6),
		"28"		DECIMAL(28, 6),
		"29"		DECIMAL(28, 6),
		"30"		DECIMAL(28, 6),
		"31"		DECIMAL(28, 6),
		"이월"		DECIMAL(28, 6),
		"대납"		DECIMAL(28, 6),
		"동아대납"		DECIMAL(28, 6)
	);
	
	MON := LEFT(TO_NVARCHAR(:DT, 'YYYYMMDD'), 6);
	FR_DT := MON || '01';
	TO_DT := MON || '31';
	
	CNT := 1;
	
	QUERY := :QUERY || 'INSERT INTO #TEMPRES ';
	QUERY := :QUERY || '("품목코드", "현재고", "출하수량", "1", "2", "3", "4", "5", "6", "7", "8", "9", "10", "11", "12", "13", "14", "15", "16", "17", "18", "19", "20", "21", "22", "23", "24", "25", "26", "27", "28", "29", "30", "31", "이월", "대납", "동아대납") ';
	QUERY := :QUERY || 'SELECT ';
	QUERY := :QUERY || '	A."ItemCode" AS "품목코드", ';
	QUERY := :QUERY || '	A."OnHand" AS "현재고", ';
	QUERY := :QUERY || '	SUM( B."OutQty" ) AS "출하수량", ';
	
	WHILE :CNT <= 31 DO
	
		IF LENGTH(:CNT) = 1 THEN
			QUERY := :QUERY || 'SUM( CASE WHEN TO_NVARCHAR( B."DocDate", ''YYYYMMDD'' ) = ''' || :MON || '0' || TO_NVARCHAR(:CNT) || ''' THEN B."OutQty" ELSE 0 END ) AS "' || TO_NVARCHAR(:CNT) || '", ';
		ELSE
			QUERY := :QUERY || 'SUM( CASE WHEN TO_NVARCHAR( B."DocDate", ''YYYYMMDD'' ) = ''' || :MON || :CNT || ''' THEN B."OutQty" ELSE 0 END ) AS "' || TO_NVARCHAR(:CNT) || '", ';
		END IF;
		
		CNT := :CNT + 1;
	END WHILE;
	
	QUERY := :QUERY || '	0 AS "이월", ';
	QUERY := :QUERY || '	0 AS "대납", ';
	QUERY := :QUERY || '	0 AS "동아대납" ';
	QUERY := :QUERY || 'FROM OITM AS A ';
	QUERY := :QUERY || 'RIGHT JOIN OINM AS B ON A."ItemCode" = B."ItemCode" ';
	QUERY := :QUERY || 'WHERE TO_NVARCHAR( B."DocDate", ''YYYYMMDD'' ) BETWEEN ''' || :FR_DT || ''' AND ''' || :TO_DT || ''' ';
	QUERY := :QUERY || 'GROUP BY A."ItemCode", A."OnHand";';
	
	EXECUTE IMMEDIATE (:QUERY);
	TEMP = SELECT * FROM #TEMPRES;
	DROP TABLE #TEMPRES;
END;

CALL APR_ICM0910B('20190221', ?);