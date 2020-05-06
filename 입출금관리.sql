SELECT
	TO_NVARCHAR(A."RefDate", 'YYYY-MM-DD') AS "일자",
 	ROW_NUMBER() OVER (ORDER BY A."TransId") AS "순서",
--	A."TransId" AS "순서",
	LEFT(TO_NVARCHAR(A."CreateTime"), 2) || ':' || RIGHT(TO_NVARCHAR(A."CreateTime"), 2) AS "시간",
	APR_TRANSTYPE(A."TransType") AS "구분",
	A."TransId" AS "문서번호",
	A."Memo" AS "내역",
	'' AS "회원명",
	CASE
		WHEN C."GroupMask" IN (1, 4)
		THEN B."Debit"
	END AS "수입",
	CASE
		WHEN C."GroupMask" IN (2, 3, 5)
		THEN B."Debit"
	END AS "지출",
	0 AS "현금결제",
	0 AS "카드결제",
	'' AS "?",
	0 AS "미수금",
	'' AS "상품명"
FROM OJDT A
INNER JOIN JDT1 B ON A."TransId" = B."TransId"
INNER JOIN OACT C ON B."Account" = C."AcctCode"
WHERE B."Debit" > 0;