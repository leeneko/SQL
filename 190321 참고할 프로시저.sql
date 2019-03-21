CREATE PROCEDURE APR_OEM0904A (
	IN FR_DT NVARCHAR(8),
	IN TO_DT NVARCHAR(8)
)
LANGUAGE SQLSCRIPT
SQL SECURITY INVOKER
AS
BEGIN
	DECLARE MON NVARCHAR(6);
	MON := LEFT(:FR_DT, 6);
	
	SELECT 
		A."CardCode", 
		A."CardName",
		SUM( CASE WHEN TO_NVARCHAR( A."DocDate", 'YYYYMMDD' ) = :MON || '01' THEN B."Quantity" ELSE 0 END ) AS "1일",
		SUM( CASE WHEN TO_NVARCHAR( A."DocDate", 'YYYYMMDD' ) = :MON || '02' THEN B."Quantity" ELSE 0 END ) AS "2일",
		SUM( CASE WHEN TO_NVARCHAR( A."DocDate", 'YYYYMMDD' ) = :MON || '03' THEN B."Quantity" ELSE 0 END ) AS "3일",
		SUM( CASE WHEN TO_NVARCHAR( A."DocDate", 'YYYYMMDD' ) = :MON || '04' THEN B."Quantity" ELSE 0 END ) AS "4일",
		SUM( CASE WHEN TO_NVARCHAR( A."DocDate", 'YYYYMMDD' ) = :MON || '05' THEN B."Quantity" ELSE 0 END ) AS "5일",
		SUM( CASE WHEN TO_NVARCHAR( A."DocDate", 'YYYYMMDD' ) = :MON || '06' THEN B."Quantity" ELSE 0 END ) AS "6일",
		SUM( CASE WHEN TO_NVARCHAR( A."DocDate", 'YYYYMMDD' ) = :MON || '07' THEN B."Quantity" ELSE 0 END ) AS "7일",
		SUM( CASE WHEN TO_NVARCHAR( A."DocDate", 'YYYYMMDD' ) = :MON || '08' THEN B."Quantity" ELSE 0 END ) AS "8일",
		SUM( CASE WHEN TO_NVARCHAR( A."DocDate", 'YYYYMMDD' ) = :MON || '09' THEN B."Quantity" ELSE 0 END ) AS "9일",
		SUM( CASE WHEN TO_NVARCHAR( A."DocDate", 'YYYYMMDD' ) = :MON || '10' THEN B."Quantity" ELSE 0 END ) AS "10일",
		SUM( CASE WHEN TO_NVARCHAR( A."DocDate", 'YYYYMMDD' ) = :MON || '11' THEN B."Quantity" ELSE 0 END ) AS "11일",
		SUM( CASE WHEN TO_NVARCHAR( A."DocDate", 'YYYYMMDD' ) = :MON || '12' THEN B."Quantity" ELSE 0 END ) AS "12일",
		SUM( CASE WHEN TO_NVARCHAR( A."DocDate", 'YYYYMMDD' ) = :MON || '13' THEN B."Quantity" ELSE 0 END ) AS "13일",
		SUM( CASE WHEN TO_NVARCHAR( A."DocDate", 'YYYYMMDD' ) = :MON || '14' THEN B."Quantity" ELSE 0 END ) AS "14일",
		SUM( CASE WHEN TO_NVARCHAR( A."DocDate", 'YYYYMMDD' ) = :MON || '15' THEN B."Quantity" ELSE 0 END ) AS "15일",
		SUM( CASE WHEN TO_NVARCHAR( A."DocDate", 'YYYYMMDD' ) = :MON || '16' THEN B."Quantity" ELSE 0 END ) AS "16일",
		SUM( CASE WHEN TO_NVARCHAR( A."DocDate", 'YYYYMMDD' ) = :MON || '17' THEN B."Quantity" ELSE 0 END ) AS "17일",
		SUM( CASE WHEN TO_NVARCHAR( A."DocDate", 'YYYYMMDD' ) = :MON || '18' THEN B."Quantity" ELSE 0 END ) AS "18일",
		SUM( CASE WHEN TO_NVARCHAR( A."DocDate", 'YYYYMMDD' ) = :MON || '19' THEN B."Quantity" ELSE 0 END ) AS "19일",
		SUM( CASE WHEN TO_NVARCHAR( A."DocDate", 'YYYYMMDD' ) = :MON || '20' THEN B."Quantity" ELSE 0 END ) AS "20일",
		SUM( CASE WHEN TO_NVARCHAR( A."DocDate", 'YYYYMMDD' ) = :MON || '21' THEN B."Quantity" ELSE 0 END ) AS "21일",
		SUM( CASE WHEN TO_NVARCHAR( A."DocDate", 'YYYYMMDD' ) = :MON || '22' THEN B."Quantity" ELSE 0 END ) AS "22일",
		SUM( CASE WHEN TO_NVARCHAR( A."DocDate", 'YYYYMMDD' ) = :MON || '23' THEN B."Quantity" ELSE 0 END ) AS "23일",
		SUM( CASE WHEN TO_NVARCHAR( A."DocDate", 'YYYYMMDD' ) = :MON || '24' THEN B."Quantity" ELSE 0 END ) AS "24일",
		SUM( CASE WHEN TO_NVARCHAR( A."DocDate", 'YYYYMMDD' ) = :MON || '25' THEN B."Quantity" ELSE 0 END ) AS "25일",
		SUM( CASE WHEN TO_NVARCHAR( A."DocDate", 'YYYYMMDD' ) = :MON || '26' THEN B."Quantity" ELSE 0 END ) AS "26일",
		SUM( CASE WHEN TO_NVARCHAR( A."DocDate", 'YYYYMMDD' ) = :MON || '27' THEN B."Quantity" ELSE 0 END ) AS "27일",
		SUM( CASE WHEN TO_NVARCHAR( A."DocDate", 'YYYYMMDD' ) = :MON || '28' THEN B."Quantity" ELSE 0 END ) AS "28일",
		SUM( CASE WHEN TO_NVARCHAR( A."DocDate", 'YYYYMMDD' ) = :MON || '29' THEN B."Quantity" ELSE 0 END ) AS "29일",
		SUM( CASE WHEN TO_NVARCHAR( A."DocDate", 'YYYYMMDD' ) = :MON || '30' THEN B."Quantity" ELSE 0 END ) AS "30일",
		SUM( CASE WHEN TO_NVARCHAR( A."DocDate", 'YYYYMMDD' ) = :MON || '31' THEN B."Quantity" ELSE 0 END ) AS "31일",
		SUM( B."Quantity") AS "집계"
	FROM "ORDR" A
	INNER JOIN "RDR1" B ON A."DocEntry" = B."DocEntry"
	WHERE TO_NVARCHAR( A."DocDate", 'YYYYMMDD' ) BETWEEN :FR_DT AND :TO_DT
	GROUP BY A."CardCode", A."CardName"
	ORDER BY A."CardCode";
END;