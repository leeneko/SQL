/*
SELECT
	*
FROM OPCH A
WHERE A."DocDate" = [%0]
*/
SELECT
	A."CARDCODE" AS "거래처코드",
	A."CARDNAME" AS "거래처명",
	A."VATRN" AS "사업자번호",
	SUM(A."AMT") AS "전표 공급가액",
	SUM(A."VAT") AS "전표 세액",
	SUM(A."SUM") AS "전표 총액",
	SUM(A."CAMT") AS "등록 공급가액",
	SUM(A."CVAT") AS "등록 세액",
	SUM(A."CSUM") AS "등록 총액",
	SUM(A."AMT" - A."CAMT") AS "차이 공급가액",
	SUM(A."VAT" - A."CVAT") AS "차이 세액",
	SUM(A."SUM" - A."CSUM") AS "차이 총액"
FROM (
	SELECT
		C."CardCode" AS "CARDCODE",
		C."CardName" AS "CARDNAME",
		C."VATRegNum" AS "VATRN",
		SUM(B."LineTotal") AS "AMT",
		SUM(B."VatSum") AS "VAT",
		SUM(B."LineTotal" + B."VatSum") AS "SUM",
		0 AS "CAMT",
		0 AS "CVAT",
		0 AS "CSUM"
	FROM OPCH A
	INNER JOIN PCH1 B ON A."DocEntry" = B."DocEntry"
	INNER JOIN OCRD C ON A."CardCode" = C."CardCode"
	WHERE TO_NVARCHAR(A."DocDate", 'YYYYMM') = [%0]
	AND A."CANCELED" = 'N'
	GROUP BY C."CardCode", C."CardName", C."VATRegNum"
	
	UNION ALL
	
	SELECT
		C."CardCode",
		C."CardName",
		C."VATRegNum",
		-1 * SUM(B."LineTotal"),
		-1 * SUM(B."VatSum"),
		-1 * SUM(B."LineTotal" + B."VatSum"),
		0,
		0,
		0
	FROM ORPC A
	INNER JOIN RPC1 B ON A."DocEntry" = B."DocEntry"
	INNER JOIN OCRD C ON A."CardCode" = C."CardCode"
	WHERE TO_NVARCHAR(A."DocDate", 'YYYYMM') = [%0]
	AND A."CANCELED" = 'N'
	GROUP BY C."CardCode", C."CardName", C."VATRegNum"
	
	UNION ALL
	
	SELECT
		COALESCE(MAX(C."CardCode"), ''),
		B."U_CARDNAME",
		B."U_REGNUM",
		0,
		0,
		0,
		SUM(B."U_LINEAMT"),
		SUM(B."U_VATAMT"),
		SUM(B."U_SUMAMT")
	FROM "@APR_OPTX" A
	INNER JOIN "@APR_PTX1" B ON A."DocEntry" = B."DocEntry"
	LEFT JOIN OCRD C ON B."U_REGNUM" = C."VATRegNum"
	WHERE TO_NVARCHAR(A."U_DOCDATE", 'YYYYMM') = [%0]
	AND A."Canceled" = 'N'
	GROUP BY B."U_CARDNAME", "U_REGNUM"
) A
GROUP BY A."CARDNAME", A."VATRN" -- 거래처명, 사업자번호