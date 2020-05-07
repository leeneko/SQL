CREATE PROCEDURE STD_FAM_M_110 (
	
)
LANGUAGE SQLSCRIPT
SQL SECURITY INVOKER
AS
BEGIN
	SELECT
		A."AcctName" AS "구분",
		A."CurrTotal" AS "금액"
	FROM OACT A
	WHERE A."FatherNum" = '111003'
	
	UNION ALL
	
	SELECT
		'합계' AS "구분",
		SUM(A."CurrTotal") AS "금액"
	FROM OACT A
	WHERE A."FatherNum" = '111003';
END;

-- 필요한 내용, 결정해야될 사항
-- 1 어떤 계정을 표시해줄지 사용자 정의 필드를 추가하여 설정한 계정만 표시한다.

-- 구분, 전일, 금일

CALL STD_FAM_M_110 ();