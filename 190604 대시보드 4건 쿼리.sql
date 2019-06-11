/**********************************유지보수금액************************************/
SELECT
	A."RefDate",
	E."GroupName",
	SUM (
		CASE
			WHEN TO_NVARCHAR(A."RefDate", 'YYYY') = TO_NVARCHAR(ADD_YEARS(NOW(), -1), 'YYYY')
			THEN B."Debit" - B."Credit"
			ELSE 0
		END
	) AS "Pre", -- 작년
	SUM (
		CASE
			WHEN TO_NVARCHAR(A."RefDate", 'YYYY') = TO_NVARCHAR(NOW(), 'YYYY')
			THEN B."Debit" - B."Credit"
			ELSE 0
		END
	) AS "Now" -- 올해
FROM OJDT A
INNER JOIN JDT1 B ON A."TransId" = B."TransId"
INNER JOIN OINV C ON A."BaseRef" = C."DocNum"
INNER JOIN OCRD D ON C."CardCode" = D."CardCode"
INNER JOIN OCRG E ON D."GroupCode" = E."GroupCode"
WHERE A."TransType" IN ('13', '14')
AND C."CANCELED" != 'Y'
AND B."ContraAct" = '4140101'
AND (YEAR(A."RefDate") = YEAR(NOW()) OR YEAR(A."RefDate") = YEAR(ADD_YEARS(NOW(), -1)))
--AND ((A."RefDate" BETWEEN YEAR(NOW()) || '0101' AND NOW()) OR (A."RefDate" BETWEEN YEAR(ADD_YEARS(NOW(), -1)) || 0101 AND ADD_YEARS(NOW(), -1)))
GROUP BY A."RefDate", E."GroupName";

/**********************************유지보수증감률************************************/
SELECT
	V."GroupName",
	SUM(V."Pre"),
	SUM(V."Now"),
	LEFT((((SUM(V."Now") - SUM(V."Pre")) / SUM(V."Pre")) * 100), 3) || '%' AS "ChangeRate"
FROM (
	SELECT
		A."RefDate",
		E."GroupName",
		CASE
			WHEN TO_NVARCHAR(A."RefDate", 'YYYY') = TO_NVARCHAR(ADD_YEARS(NOW(), -1), 'YYYY')
			THEN B."Debit" - B."Credit"
			ELSE 0
		END AS "Pre",
		CASE
			WHEN TO_NVARCHAR(A."RefDate", 'YYYY') = TO_NVARCHAR(NOW(), 'YYYY')
			THEN B."Debit" - B."Credit"
			ELSE 0
		END AS "Now"
	FROM OJDT A
	INNER JOIN JDT1 B ON A."TransId" = B."TransId"
	INNER JOIN OINV C ON A."BaseRef" = C."DocNum"
	INNER JOIN OCRD D ON C."CardCode" = D."CardCode"
	INNER JOIN OCRG E ON D."GroupCode" = E."GroupCode"
	WHERE A."TransType" IN ('13', '14')
	AND C."CANCELED" != 'Y'
	AND B."ContraAct" = '4140101'
	AND (YEAR(A."RefDate") = YEAR(NOW()) OR YEAR(A."RefDate") = YEAR(ADD_YEARS(NOW(), -1)))
) V
WHERE (TO_NVARCHAR(V."RefDate", 'YYYYMMDD') BETWEEN YEAR(ADD_MONTHS(NOW(), -12)) || '0101' AND TO_NVARCHAR(ADD_MONTHS(NOW(), -12), 'YYYYMMDD')
	OR TO_NVARCHAR(V."RefDate", 'YYYYMMDD') BETWEEN YEAR(NOW()) || '0101' AND TO_NVARCHAR(NOW(), 'YYYYMMDD')) -- 현재의 같은 날짜까지
GROUP BY V."GroupName";

/**********************************유지보수현황************************************/
SELECT
	V.YQ,
	COUNT(V.YQ),
	CAST((SUM(V."Balance") / 1000000) AS INT) AS "Million"
FROM (
SELECT
	A."RefDate",
	CASE
		WHEN YEAR(A."RefDate") = YEAR(ADD_MONTHS(NOW(), -12))
		THEN 
			CASE
				WHEN MONTH(A."RefDate") IN ('1', '2', '3')
				THEN YEAR(ADD_YEARS(NOW(), -1)) || '-1'
				WHEN MONTH(A."RefDate") IN ('4', '5', '6')
				THEN YEAR(ADD_YEARS(NOW(), -1)) || '-2'
				WHEN MONTH(A."RefDate") IN ('7', '8', '9')
				THEN YEAR(ADD_YEARS(NOW(), -1)) || '-3'
				WHEN MONTH(A."RefDate") IN ('10', '11', '12')
				THEN YEAR(ADD_YEARS(NOW(), -1)) || '-4'
				ELSE ''
			END
		WHEN YEAR(A."RefDate") = YEAR(NOW())
		THEN 
			CASE
				WHEN MONTH(A."RefDate") IN ('1', '2', '3')
				THEN YEAR(NOW()) || '-1'
				WHEN MONTH(A."RefDate") IN ('4', '5', '6')
				THEN YEAR(NOW()) || '-2'
				WHEN MONTH(A."RefDate") IN ('7', '8', '9')
				THEN YEAR(NOW()) || '-3'
				WHEN MONTH(A."RefDate") IN ('10', '11', '12')
				THEN YEAR(NOW()) || '-4'
				ELSE ''
			END
		ELSE ''
	END AS YQ,
	SUM(B."Debit") - SUM(B."Credit") AS "Balance"
FROM OJDT A
INNER JOIN JDT1 B ON A."TransId" = B."TransId"
INNER JOIN OINV C ON A."BaseRef" = C."DocNum"
INNER JOIN OCRD D ON C."CardCode" = D."CardCode"
INNER JOIN OCRG E ON D."GroupCode" = E."GroupCode"
WHERE A."TransType" IN ('13', '14')
AND C."CANCELED" != 'Y'
AND B."ContraAct" = '4140101'
AND (YEAR(A."RefDate") = YEAR(NOW()) OR YEAR(A."RefDate") = YEAR(ADD_YEARS(NOW(), -1)))
GROUP BY A."RefDate"
) V
GROUP BY V.YQ;

/*************************************프로젝트 진행률*******************************************/
SELECT
	A.CARDNAME AS "거래처명",
	A.NAME AS "프로젝트명",
	F."Name" AS "담당자",
	C."SlpName" AS "영업사원",
	D."lastName" || D."firstName" AS "소유자",
	CASE
		WHEN A.STATUS = 'S'
		THEN '시작됨'
		WHEN A.STATUS = 'P'
		THEN '일시중지'
		WHEN A.STATUS = 'T'
		THEN '중지'
		ELSE NULL
	END AS "상태",
	FIRST_VALUE(E."Name" ORDER BY B."LineID") AS "단계",
	TO_NVARCHAR(A."START", 'YYYY-MM-DD') AS "시작일",
	TO_NVARCHAR(A.DUEDATE, 'YYYY-MM-DD') AS "만기일",
	TO_NVARCHAR(A.CLOSING, 'YYYY-MM-DD') AS "마감일",
	CAST(A.FINISHED AS INT) || '%' AS "진행률"
FROM OPMG A
LEFT JOIN PMG1 B ON A."AbsEntry" = B."AbsEntry"
LEFT JOIN OSLP C ON A.EMPLOYEE = C."SlpCode"
LEFT JOIN OHEM D ON A.OWNER = D."empID"
LEFT JOIN PMC6 E ON B."Task" = E."TaskID"
LEFT JOIN OCPR F ON A.CARDCODE = F."CardCode" AND A.CONTACT = F."CntctCode"
WHERE YEAR(A."START") = YEAR(NOW())
AND A.STATUS != 'F'
AND B.FINISH = 'N'
GROUP BY A.CARDCODE, A.CARDNAME, A.NAME, F."Name", C."SlpName", D."lastName", D."firstName", A.STATUS, A."START", A.DUEDATE, A.CLOSING, A.FINISHED
ORDER BY A."START";

/************************************프로젝트 진행률2****************************************/
SELECT
	B."CardName",
	100 AS "All",
	CAST(((DAYS_BETWEEN (A."START", NOW()) / DAYS_BETWEEN (A."START", A.DUEDATE)) * 100) AS INT) AS "Days",
	A.FINISHED AS "Progress"
FROM OPMG A
INNER JOIN OCRD B ON A.CARDCODE = B."CardCode"
WHERE YEAR(A."START") = YEAR(NOW())
AND A.STATUS != 'F'
ORDER BY A."START";

/***********************************유지보수 신규/해지**********************************/
SELECT
	COALESCE(COUNT(V."CardCode"), 0) AS "Cnt",
	COALESCE(V."Type", '') AS "Type",
	CASE
		WHEN MONTH(V."RefDate") IN ('1', '2', '3')
		THEN 'Q1'
		WHEN MONTH(V."RefDate") IN ('4', '5', '6')
		THEN 'Q2'
		WHEN MONTH(V."RefDate") IN ('7', '8', '9')
		THEN 'Q3'
		WHEN MONTH(V."RefDate") IN ('10', '11', '12')
		THEN 'Q4'
		ELSE ''
	END AS "QDate"
FROM (
SELECT
	'신규' AS "Type",
	A."CardCode",
	A."CardName",
	A."validFrom" AS "RefDate"
FROM OCRD A
WHERE YEAR(A."validFrom") = YEAR(NOW())

UNION ALL

SELECT
	'해지' AS "Type",
	A."CardCode",
	A."CardName",
	A."validTo"
FROM OCRD A
WHERE YEAR(A."validTo") = YEAR(NOW())
) V
GROUP BY V."Type", V."RefDate"
