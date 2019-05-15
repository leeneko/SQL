-- 미결 납품 금액 (DocStatus - O(미결), C(마감)
-- ODLN(납품)
-- 고객/공급업체 코드	CardCode
-- 고객 코드			
-- 고객 이름			
-- Open Amount			
-- 미결 금액			

SELECT
	A."CardCode" AS "고객/공급업체 코드",
	A."CardName" AS "고객/공급업체 이름",
	A."DocTotal" AS "전표 총계",
	A."PaidToDate" AS "누적 지급",
	A."DocTotal" - "PaidToDate" AS "미결금액"
FROM ODLN A
WHERE "DocStatus" != 'C'