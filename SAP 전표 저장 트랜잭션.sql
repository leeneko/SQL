CREATE PROCEDURE SBO_SP_TransactionNotification
(
	in object_type nvarchar(30), 				-- SBO Object Type
	in transaction_type nchar(1),			-- [A]dd, [U]pdate, [D]elete, [C]ancel, C[L]ose
	in num_of_cols_in_key int,
	in list_of_key_cols_tab_del nvarchar(255),
	in list_of_cols_val_tab_del nvarchar(255)
)
LANGUAGE SQLSCRIPT
AS
-- Return values
error  int;				-- Result (0 for no error)
error_message nvarchar (200); 		-- Error string to be displayed
begin
	
	DECLARE TEMPNUM INT := 0;
	DECLARE CHK NVARCHAR(10) := 'N';
	DECLARE ACHK NVARCHAR(10) := 'N';
	
	CREATE LOCAL TEMPORARY TABLE #TEMPITEMLIST (
		ITEMCODE NVARCHAR(50),
		RINCHK NVARCHAR(10)
	);
	
	error := 0;
	error_message := N'Ok';
	
	IF :object_type = '18' -- A/P 송장 (OPCH)
	THEN
		IF :transaction_type = 'A'
		THEN
			-- 기준전표(구매오더) 존재여부 체크
			SELECT
				COALESCE(A."BaseEntry", 0)
			INTO TEMPNUM
			FROM PCH1 A
			WHERE A."DocEntry" = :list_of_cols_val_tab_del
			GROUP BY A."BaseEntry";
			
			IF :TEMPNUM > 0
			THEN
				DECLARE CURSOR CURSOR1 FOR
					SELECT
						A."ITEMCODE"
					FROM #TEMPITEMLIST A;
					
				-- 기준전표의 구성품 중 품목마스터에 수입검사여부 체크
				INSERT INTO #TEMPITEMLIST (
					ITEMCODE,
					RINCHK
				)
				SELECT
					E."ItemCode",
					E."U_RINCHK"
				FROM OPOR A
				INNER JOIN POR1 B ON A."DocEntry" = B."DocEntry"
				INNER JOIN PCH1 C ON B."DocEntry" = C."BaseEntry" AND B."LineNum" = C."BaseLine"
				INNER JOIN OPCH D ON C."DocEntry" = D."DocEntry"
				INNER JOIN OITM E ON B."ItemCode" = E."ItemCode"
				WHERE D."DocEntry" = :list_of_cols_val_tab_del
				AND E."U_RINCHK" = 'Y';
				
				FOR CROW AS CURSOR1 DO
					SELECT
						B."U_RINCHK"
					INTO CHK
					FROM OPOR A
					INNER JOIN POR1 B ON A."DocEntry" = B."DocEntry"
					WHERE A."DocEntry" = :TEMPNUM
					AND B."ItemCode" = :CROW."ITEMCODE";
					
					IF :CHK = 'N'
					THEN
						error := 2;
						error_message := '[AhproFW] 구매오더의 수입검사여부를 확인하여 다시 시도해주세요.';
					END IF;
				END FOR;
			ELSE
				-- 기준전표인 구매오더가 없을 때
				error := 2;
				error_message := '[AhproFW] 복사 원본인 구매오더를 확인하여 다시 시도해주세요.';
			END IF;
		END IF;
	ELSEIF :object_type = '20' -- 입고 PO (OPDN)
	THEN
		IF :transaction_type = 'A'
		THEN
			-- 기준전표(구매오더) 존재여부 체크
			SELECT
				COALESCE(A."BaseEntry", 0)
			INTO TEMPNUM
			FROM PDN1 A
			WHERE A."DocEntry" = :list_of_cols_val_tab_del
			GROUP BY A."BaseEntry";
			
			IF :TEMPNUM > 0
			THEN
				DECLARE CURSOR CURSOR1 FOR
					SELECT
						A."ITEMCODE"
					FROM #TEMPITEMLIST A;
					
				-- 기준전표의 구성품 중 품목마스터에 수입검사여부 체크
				INSERT INTO #TEMPITEMLIST (
					ITEMCODE,
					RINCHK
				)
				SELECT
					E."ItemCode",
					E."U_RINCHK"
				FROM OPOR A
				INNER JOIN POR1 B ON A."DocEntry" = B."DocEntry"
				INNER JOIN PDN1 C ON B."DocEntry" = C."BaseEntry" AND B."LineNum" = C."BaseLine"
				INNER JOIN OPDN D ON C."DocEntry" = D."DocEntry"
				INNER JOIN OITM E ON B."ItemCode" = E."ItemCode"
				WHERE D."DocEntry" = :list_of_cols_val_tab_del
				AND E."U_RINCHK" = 'Y';
				
				FOR CROW AS CURSOR1 DO
					SELECT
						B."U_RINCHK"
					INTO CHK
					FROM OPOR A
					INNER JOIN POR1 B ON A."DocEntry" = B."DocEntry"
					WHERE A."DocEntry" = :TEMPNUM
					AND B."ItemCode" = :CROW."ITEMCODE";
					
					IF :CHK = 'N'
					THEN
						error := 2;
						error_message := '[AhproFW] 구매오더의 수입검사여부를 확인하여 다시 시도해주세요.';
					END IF;
				END FOR;
			ELSE
				-- 기준전표인 구매오더가 없을 때
				error := 2;
				error_message := '[AhproFW] 복사 원본인 구매오더를 확인하여 다시 시도해주세요.';
			END IF;
		END IF;
	END IF;
	
	DROP TABLE #TEMPITEMLIST;
	
	-- Select the return values
	select :error, :error_message FROM dummy;
end;