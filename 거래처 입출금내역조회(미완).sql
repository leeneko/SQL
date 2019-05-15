-- 거래처 입출금내역조회

-- 검색 조건 : 전기일 FR_DT ~ TO_DT, 비고

-- OJDT - 분개(회계전표), JDT1, OACT - G/L 계정, OCRD - 비즈니스 파트너, OUSR - 사용자

-- TransType = Transaction type : 데이터베이스 트랜잭션은 데이터베이스 관리 시스템 또는 유사한 시스템에서 상호작용의 단위이다.
-- 여기서 유사한 시스템이란 트랜잭션이 성공과 실패가 분명하고 상호 독립적이며, 일관되고 믿을 수 있는 시스템을 의미한다.

-- 입출금구분
-- 문서구분
-- 전기일
-- 거래번호
-- 계정 이름
-- 상계 계정
-- 계정 이름
-- BP 코드
-- BP 이름
-- 입금액
-- 출금액
-- 분개 비고
-- 행 세부사항
-- 생성자

SELECT
	CASE WHEN B."Debit" > '0' THEN '지급' ELSE '입금' END AS "입출금구분",
	CASE WHEN A."TransType" = 13 THEN '매출'
	WHEN A."TransType" = 14 THEN '매출반품'
	WHEN A."TransType" = 15 THEN '납품'
	WHEN A."TransType" = 16 THEN '판매반품'
	WHEN A."TransType" = 18 THEN '매입'
	WHEN A."TransType" = 19 THEN 'A/P 대변메모'
	WHEN A."TransType" = 20 THEN '입고'
	WHEN A."TransType" = 21 THEN '구매반품'
	WHEN A."TransType" = 24 THEN '입금'
	WHEN A."TransType" = 30 THEN '분개'
	WHEN A."TransType" = 46 THEN '지급'
	WHEN A."TransType" = 59 THEN '재고입고'
	WHEN A."TransType" = 60 THEN '재고출고'
	WHEN A."TransType" = 67 THEN '재고이전'
	WHEN A."TransType" = 162 THEN '재고재평가'
	WHEN A."TransType" = 321 THEN '내부조정'
	WHEN A."TransType" = 10000071 THEN '재고전기'
	ELSE A."TransType" END AS "문서구분",
	A."RefDate" AS "전기일",
	A."TransId" AS "거래번호",
	B."Credit" AS "입금액",
	B."Debit" AS "출금액"
FROM OJDT A
INNER JOIN JDT1 B ON A."TransId" = B."TransId"
WHERE (B."Credit" > 0 OR B."Debit" > 0)
AND A."TransType" != 13 AND A."TransType" !=  15 AND A."TransType" !=  18 AND A."TransType" !=  20 AND A."TransType" !=  24  AND A."TransType" !=  -3
AND A."TransType" !=  30 AND A."TransType" !=  46 AND A."TransType" !=  59 AND A."TransType" !=  14 AND A."TransType" !=  60 
AND A."TransType" !=  67 AND A."TransType" !=  202 AND A."TransType" !=  16 AND A."TransType" !=  21 AND A."TransType" !=  10000071
ORDER BY A."TransId"

-- TransType -3?