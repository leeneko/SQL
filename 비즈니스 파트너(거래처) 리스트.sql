-- 비즈니스 파트너(거래처) 리스트 : OCRD
-- BP 코드				CardCode
-- 별칭					AliasName
-- BP 이름				CardName
-- 대표자 성명			RepName
-- 사업자등록번호		VATRegNum
-- 그룹 이름			OCRG.GroupName
-- 영업사원이름			OSLP.SlpName
-- 최종매출일			A/R 송장(OINV)의 마지막 거래일
-- 현잔액				Balance
-- BP 통화				Currency
-- 전화번호 1			Phone1
-- 전화번호 2			Phone2
-- 휴대폰				Cellular
-- 팩스번호				Fax
-- 전자메일				E_Mail
-- 비고					Notes
-- 업태					Industry
-- 종목					Business
-- 여신 한도			CreditLine
-- 채무 한도			DebtLine
-- 광역시/도			CRD1.State
-- 청구처				Address			-- AdresType : B (청구처)
-- 납품처				MailAddress		-- AdresType : S (납품처)
-- 지급 조건 코드		OCTG.PymntGroup
-- 은행 이름			BankCode
-- 주거래 은행 계좌		HousBnkAct
-- 세금 그룹			ECVatGroup
-- 비고					Free_Text

SELECT TOP 5
	A."CardCode" AS "BP 코드",
	TO_NVARCHAR(A."AliasName") AS "별칭",
	A."CardName" AS "BP 이름",
	A."RepName" AS "대표자 성명",
	A."VATRegNum" AS "사업자등록번호",
	B."GroupName" AS "그룹 이름",
	D."SlpName" AS "영업사원이름",
	MAX(C."DocDate") AS "최종매출일",
	A."Balance" AS "현잔액",
	A."Currency" AS "BP 통화",
	A."Phone1" AS "전화번호 1",
	A."Phone2" AS "전화번호 2",
	A."Cellular" AS "휴대폰",
	A."Fax" AS "팩스번호",
	A."E_Mail" AS "이메일",
	A."Notes" AS "비고",
	TO_NVARCHAR(A."Industry") AS "업태",
	TO_NVARCHAR(A."Business") AS "종목",
	A."CreditLine" AS "여신한도",
	A."DebtLine" AS "채무한도",
--	F."Name" AS "광역시/도"
	A."Address" AS "청구처",
	A."MailAddres" AS "납품처",
	E."PymntGroup" AS "지급 조건 코드",
	A."HousBnkAct" AS "주거래 은행 계좌",
	A."ECVatGroup" AS "세금 그룹",
	TO_NVARCHAR(A."Free_Text") AS "비고"
FROM OCRD A
INNER JOIN OCRG B ON A."GroupCode" = B."GroupCode"
LEFT JOIN OINV C ON A."CardCode" = C."CardCode"
INNER JOIN OSLP D ON A."SlpCode" = D."SlpCode"
INNER JOIN OCTG E ON A."GroupNum" = E."GroupNum"
GROUP BY A."CardCode", TO_NVARCHAR(A."AliasName"), A."CardName", A."RepName", A."VATRegNum", 
	B."GroupName", D."SlpName", A."Balance", A."Currency", A."Phone1", A."Phone2", A."Cellular", 
	A."Fax", A."E_Mail", A."Notes", TO_NVARCHAR(A."Industry"), TO_NVARCHAR(A."Business"), 
	A."CreditLine", A."DebtLine", A."Address", A."MailAddres", E."PymntGroup", A."HousBnkAct", A."ECVatGroup", TO_NVARCHAR(A."Free_Text")
ORDER BY A."CardCode"
;

SELECT MAX("DocDate") FROM OINV WHERE "CardCode" = 'C00001';
SELECT * FROM OSLP;
SELECT * FROM OCTG;