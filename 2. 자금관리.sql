ALTER PROCEDURE STD_BSM_M_110 (
	
)
LANGUAGE SQLSCRIPT
SQL SECURITY INVOKER
AS
BEGIN
	SELECT
		C."CardName" AS "구분",
		B."Debit" AS "입금",
		B."Credit" AS "지급",
		0 AS "비용",
		A."Memo"
	FROM OJDT A
	INNER JOIN JDT1 B ON A."TransId" = B."TransId"
	INNER JOIN OCRD C ON B."ContraAct" = C."CardCode"
	WHERE A."TransType" IN (24, 46)
	AND A."RefDate" = CURRENT_DATE
	
	UNION ALL
	
	SELECT
		C."AcctName",
		0,
		0,
		A."SysTotal",
		A."Memo"
	FROM OJDT A
	INNER JOIN JDT1 B ON A."TransId" = B."TransId"
	INNER JOIN OACT	C ON B."ShortName" = C."AcctCode" AND C."GroupMask" = 5
	WHERE A."TransType" IN (30)
	AND A."RefDate" = CURRENT_DATE
;
END;
CALL STD_BSM_M_110 ();