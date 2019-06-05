/* 계정별거래처잔액
SELECT
	*
FROM OJDT A
INNER JOIN JDT1 B ON A."TransId" = B."TransId"
INNER JOIN OCRD C ON B."ShortName" = C."CardCode"
WHERE (A."RefDate" >= [%0] OR '' = [%0])
AND (A."RefDate" <= [%1] OR '' = [%1])
AND (C."CardCode" = [%2])
AND (C."CardName" LIKE '%' || [%3] || '%')
*/
DROP PROCEDURE TEST01;
CREATE PROCEDURE TEST01 (
	IN FR_DT NVARCHAR(10),
	IN TO_DT NVARCHAR(10),
	IN CARDCODE NVARCHAR(50),
	IN CARDNAME NVARCHAR(100)
)
LANGUAGE SQLSCRIPT
SQL SECURITY INVOKER
AS
BEGIN
	SELECT
		A."CardCode" AS "BP코드",
		A."CardName" AS "BP이름",
		A."Balance" AS "현잔액",
		A."DebPayAcct" AS "관리계정",
		B."AcctName" AS "관리계정명",
		SUM(C."Balance") AS "이월",
		SUM(C."Debit") AS "차변",
		SUM(C."Credit") AS "대변",
		SUM(C."Balance" + C."Debit" - C."Credit") AS "잔액",
		A."Notes" AS "비고",
		D."PymntGroup" AS "지급조건코드"
	FROM OCRD A
	INNER JOIN OACT B ON A."DebPayAcct" = B."AcctCode"
	INNER JOIN (
		SELECT
			B."ShortName" AS "ShortName",
			0 AS "Debit",
			0 As "Credit",
			B."Debit" - B."Credit" AS "Balance"
		FROM OJDT A
		INNER JOIN JDT1 B ON A."TransId" = B."TransId"
		WHERE (B."RefDate" < :FR_DT OR '' = :FR_DT)
		
		UNION ALL
		
		SELECT
			B."ShortName" AS "ShortName",
			B."Debit",
			B."Credit",
			0
		FROM OJDT A
		INNER JOIN JDT1 B ON A."TransId" = B."TransId"
		WHERE (B."RefDate" >= :FR_DT OR '' = :FR_DT)
		AND (B."RefDate" <= :TO_DT OR '' = :TO_DT)
		) C ON A."CardCode" = C."ShortName"
	INNER JOIN OCTG D ON A."GroupNum" = D."GroupNum"
	INNER JOIN OCRD E ON A."CardCode" = E."CardCode"
	WHERE (A."CardCode" = :CARDCODE OR '' = :CARDCODE)
	AND E."CardName" LIKE '%' || :CARDNAME || '%'
	GROUP BY A."Notes", A."CardCode", A."CardName", A."Balance", A."DebPayAcct", B."AcctName", D."PymntGroup"
	ORDER BY A."CardCode";
END;
CALL TEST01 ('', '', '', '서울');