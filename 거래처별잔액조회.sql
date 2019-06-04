SELECT
	B."ShortName",
	D."CardName",
	B."Account",
	C."AcctName",
	SUM(
		CASE
			WHEN A."RefDate" < '20190201'
			THEN B."Debit" - B."Credit"
			ELSE 0
		END
	) AS "이월",
	SUM(
		CASE
			WHEN (A."RefDate" >= '20190201' OR '' = '20190201') AND (A."RefDate" <= '20190603' OR '' = '20190603')
			THEN B."Debit"
			ELSE 0
		END
	) AS "차변",
	SUM(
		CASE
			WHEN (A."RefDate" >= '20190201' OR '' = '20190201') AND (A."RefDate" <= '20190603' OR '' = '20190603')
			THEN B."Credit"
			ELSE 0
		END
	) AS "대변",
	SUM(
		(CASE
			WHEN A."RefDate" < '20190201'
			THEN B."Debit" - B."Credit"
			ELSE 0
		END) 
		 + 
		(CASE
			WHEN (A."RefDate" >= '20190201' OR '' = '20190201') AND (A."RefDate" <= '20190603' OR '' = '20190603')
			THEN B."Debit" - B."Credit"
			ELSE 0
		END)
	) AS "잔액"
FROM OJDT A
INNER JOIN JDT1 B ON A."TransId" = B."TransId"
INNER JOIN OACT C ON B."Account" = C."AcctCode"
INNER JOIN OCRD D ON B."ShortName" = D."CardCode"
GROUP BY B."ShortName", D."CardName", B."Account", C."AcctName"
ORDER BY B."ShortName"
-- 거래처코드	OCRD."CardCode"
-- 거래처명		OCRD."CardName",
-- 관리계정		OACT."AcctCode",
-- 관리계정명	OACT."AcctName",
-- 이월			JDT1."Balance"
-- 차변			JDT1."Debit",
-- 대변			JDT1."Credit"
-- 잔액			JDT1."Balance" + JDT1."Debit" - JDT1."Credit"
-- A."TransId" NOT IN (SELECT distinct x,"StornoToTr" IS NOT NULL -- StornoToTr (역분개 트랜잭션)
