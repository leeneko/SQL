ALTER PROCEDURE SBO_SP_TransactionNotification
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
			DECLARE CURSOR CURSOR1 FOR
				SELECT
					COALESCE(A."BaseEntry", 0) AS "BaseEntry"
				FROM PCH1 A
				WHERE A."DocEntry" = :list_of_cols_val_tab_del;
			
			FOR CROW1 AS CURSOR1 DO
				IF :CROW1."BaseEntry" > 0
				THEN
					DECLARE CURSOR CURSOR2 FOR
						SELECT
							A."U_RINCHK" AS "CHK"
						FROM POR1 A
						INNER JOIN OITM B ON A."ItemCode" = B."ItemCode" AND B."U_RINCHK" = 'Y'
						WHERE A."DocEntry" = :CROW1."BaseEntry";
					
					FOR CROW2 AS CURSOR2 DO
						IF :CROW2.CHK = 'N'
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
			END FOR;
		END IF;	
	ELSEIF :object_type = '20' -- 입고 PO (OPDN)
	THEN
		IF :transaction_type = 'A'
		THEN
			DECLARE CURSOR CURSOR1 FOR
				SELECT
					COALESCE(A."BaseEntry", 0) AS "BaseEntry"
				FROM PDN1 A
				WHERE A."DocEntry" = :list_of_cols_val_tab_del;
			
			FOR CROW1 AS CURSOR1 DO
				IF :CROW1."BaseEntry" > 0
				THEN
					DECLARE CURSOR CURSOR2 FOR
						SELECT
							A."U_RINCHK" AS "CHK"
						FROM POR1 A
						INNER JOIN OITM B ON A."ItemCode" = B."ItemCode" AND B."U_RINCHK" = 'Y'
						WHERE A."DocEntry" = :CROW1."BaseEntry";
					
					FOR CROW2 AS CURSOR2 DO
						IF :CROW2.CHK = 'N'
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
			END FOR;
		END IF;	
	END IF;
	
	DROP TABLE #TEMPITEMLIST;
	
	-- Select the return values
	select :error, :error_message FROM dummy;
end;