-- 품목 마스터 리스트 : OITM
-- 그룹 이름		OITB.ItmsGrpNam
-- 소분류명			@APR_GROUP1.
-- 품목 번호		ItemCode
-- HS코드			U_HSCODE
-- 영문명			FrgnName ???
-- 품명				ItemName
-- 규격				FrgnName
-- 단위 그룹 이름	OUGP.UgpName
-- 중량(KG)			SWeight1
-- BOX 수량			U_BOXQTY
-- 배치관리여부		ManBtchNum
-- 기본 창고		DfltWH
-- 매입부가세		VatGroupPu
-- 매출부가세		VatGourpSa ???
-- 재고 품목		InvntItem
-- 판매 품목		SellItem
-- 구매 품목		PrchseItem

-- OITB - 품목 그룹, OUGP - 단위 그룹, @APR_GROUP1 - 소분류 그룹명, OMLT, MLT1

SELECT
	B."ItmsGrpNam" AS "그룹 이름",
	C."Name" AS "소분류명",
	A."ItemCode" AS "품목 번호",
	A."U_HSCODE" AS "HS코드",
	F."Trans" AS "영문명",
	A."ItemName" AS "품명",
	A."FrgnName" AS "규격",
	D."UgpName" AS "단위 그룹 이름",
	A."SWeight1" AS "중량(KG)",
	A."U_BOXQTY" AS "BOX 수량",
	A."ManBtchNum" AS "배치관리여부",
	A."DfltWH" AS "기본 창고",
	A."VatGroupPu" AS "매입부가세",
	A."VatGourpSa" AS "매출부가세",
	A."InvntItem" AS "재고 품목",
	A."SellItem" AS "판매 품목",
	A."PrchseItem" AS "구매 품목"
FROM OITM A
INNER JOIN OITB B ON A."ItmsGrpCod" = B."ItmsGrpCod"
LEFT JOIN "@APR_GROUP1" C ON A.U_GROUP1 = C."Code"
INNER JOIN OUGP D ON A."UgpEntry" = D."UgpEntry"
LEFT JOIN OMLT E ON A."ItemCode" = E."PK"
LEFT JOIN MLT1 F ON E."TranEntry" = F."TranEntry"
ORDER BY A."ItemCode"
;