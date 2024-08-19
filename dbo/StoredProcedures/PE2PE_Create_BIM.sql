



/* =============================================
Author:			Stefan Urban														
Created:		2023/12											
Description:	create PE2PE BIM  
=============================================*/

CREATE PROCEDURE [dbo].[PE2PE_Create_BIM] 
AS
BEGIN TRY

--	IF OBJECT_ID('[dbo].[create_PE2PE_BIM]', 'P') IS NOT NULL 
--	BEGIN 
--		DROP PROCEDURE [dbo].[create_PE2PE_BIM] 
--	END;

	DECLARE @step Integer		
	DECLARE @proc nvarchar(50)
	DECLARE @LogInfo Integer	
	DECLARE @CCY nvarchar(3)
	DECLARE @LegalEntity nvarchar (20)
	DECLARE @CompanyCode nvarchar (20)
	DECLARE @CountryCode nvarchar (20)
	DECLARE @TempTableName nvarchar(300)
	DECLARE @sql nvarchar (max)
	DECLARE @counter Integer
	DECLARE @RecordCounter1 Integer
	DECLARE @RecordCounter2 Integer
	DECLARE @AsOfDate_DE nvarchar(20)
	DECLARE @AsOfDate_EN nvarchar(20)
	DECLARE @LogEntry nvarchar(max)
	DECLARE @Main_Process nvarchar(100)
	DECLARE @Calling_Application nvarchar(100)
	DECLARE @Session_Key nvarchar(100)
	
	SELECT @proc = Object_Name(@@PROCID)

	SET @TempTableName = 'table_PE2PE_BIM'
	
  --/* get Info if Logging is enabled */
	SET @step = 100
	SELECT @LogInfo = dbo.LogInfo.LogInfo FROM dbo.LogInfo

	SET @LogInfo = 2 -- Jetzt wird erstmal immer geloggt

	SET @proc = 'Create PE2PE BIM:'

	SELECT @Main_Process = ''
	SELECT @Calling_Application = ''
	SELECT @Session_Key = ''
	SELECT @LogEntry = 'START'
	EXECUTE [dbo].[Write_Log] 'Info', @LogEntry, @proc, @Main_Process, @Calling_Application, @step, 1 , @Session_Key

--	BEGIN INSERT INTO dbo.Logfile SELECT @proc + ' - START', GETDATE () END
--	BEGIN INSERT INTO dbo.Logfile SELECT @proc + ' - CREATE PE2PE TABLE', GETDATE () END

	SELECT @AsOfDate_DE = FORMAT((
					SELECT AsOfDate_EOM
					FROM FinRecon.dbo.AsOfDate
					), 'dd.MM.yyy');
	
	SET @step = 200

	SELECT @AsOfDate_EN = FORMAT((
			SELECT AsOfDate_EOM
			FROM FinRecon.dbo.AsOfDate
			), 'yyyy/MM');

	IF OBJECT_ID(@TempTableName, 'U') IS NOT NULL
    BEGIN
        -- Wenn die Tabelle existiert, lösche sie
		IF @LogInfo >= 1  BEGIN 
			SELECT @LogEntry = 'DROP PE2PE TABLE'
			EXECUTE [dbo].[Write_Log] 'Info', @LogEntry, @proc, @Main_Process, @Calling_Application, @step, 1 , @Session_Key
		END
		DROP TABLE dbo.table_PE2PE_BIM
    END
	SET @step = 300

    -- create tmep table for PE2PE BIM
    BEGIN
		IF @LogInfo >= 1  BEGIN 
			SELECT @LogEntry = 'CREATE PE2PE TABLE'
			EXECUTE [dbo].[Write_Log] 'Info', @LogEntry, @proc, @Main_Process, @Calling_Application, @step, 1 , @Session_Key
--			INSERT INTO dbo.Logfile SELECT @proc + 'CREATE PE2PE TABLE', GETDATE () 
		END
		
		CREATE TABLE dbo.table_PE2PE_BIM 
		(ID INT IDENTITY(1,1) PRIMARY KEY,
		KopfIdent varchar(255) NULL,
		Buchungskreis varchar(255) NULL,
		Belegdatum varchar(255) NULL,
		Belegart varchar(255) NULL,
		Buchungsdatum varchar(255) NULL,
		Currency varchar(255) NULL,
		Belegkopftext varchar(255) NULL,
		Referenz varchar(255) NULL,
		dummy1 varchar(255) NULL,
		dummy2 varchar(255) NULL,
		dummy3 varchar(255) NULL,
		dummy4 varchar(255) NULL,
		dummy5 varchar(255) NULL,
		dummy6 varchar(255) NULL,
		dummy7 varchar(255) NULL,
		dummy8 varchar(255) NULL,
		dummy9 varchar(255) NULL,
		dummy10 varchar(255) NULL,
		dummy11 varchar(255) NULL);


	END

	SET @step = 500

	-- Schleife durch den Cursor und führen Sie SQL-Anweisungen aus
	BEGIN
		-- define LegalEntity Cursor
		-- define cursor for PE2PE
		IF @LogInfo >= 1  BEGIN 
			SELECT @LogEntry = 'CURSOR1 PE2PE TABLE'
			EXECUTE [dbo].[Write_Log] 'Info', @LogEntry, @proc, @Main_Process, @Calling_Application, @step, 1 , @Session_Key
		END
		DECLARE BIMCursorLE CURSOR FOR
		SELECT
			distinct case when map_order.LegalEntity = 'n/a' then 'RWEST DE' else map_order.LegalEntity  end as LegalEntity
			,case when map_order.LegalEntity = 'n/a' then '0600' else CompanyCode  end	as CompanyCode
			,case when map_order.LegalEntity = 'n/a' then 'DE' else VAT_CountryCode  end as CountryCode
			,[Currency] AS CCY
		FROM 
				dbo.table_PE2PE_with_matching_deals
				left join dbo.map_order on table_PE2PE_with_matching_deals.OrderNo= map_order.OrderNo
				left join dbo.table_Clearer_map_LegalEntity_CompanyCode on dbo.map_order.LegalEntity = dbo.table_Clearer_map_LegalEntity_CompanyCode.LegalEntity
		WHERE 
			map_order.LegalEntity	not in ('RWEST SH','RWESTA - PE')
			AND NOT (map_order.LegalEntity = 'RWEST DE' AND dbo.table_PE2PE_with_matching_deals.VAT_CountryCode = 'GB' )
		ORDER BY 
			LegalEntity,
			[Currency]
		OPEN BIMCursorLE
		SET @step = 600

		FETCH NEXT FROM BIMCursorLE INTO @LegalEntity, @CompanyCode, @CountryCode, @CCY

		-- 1. Header SAP Beleg
		INSERT INTO dbo.table_PE2PE_BIM 
			(KopfIdent
			,Buchungskreis
			,Belegdatum
			,Belegart
			,Buchungsdatum
			,Currency
			,Belegkopftext
			,Referenz
			,dummy1
			,dummy2
			,dummy3
			,dummy4
			,dummy5
			,dummy6
			,dummy7
			,dummy8
			,dummy9
			,dummy10
			,dummy11)
		SELECT
			KopfIdent
			,Buchungskreis
			,Belegdatum
			,Belegart
			,Buchungsdatum
			,Currency
			,Belegkopftext
			,Referenz
			,dummy1
			,dummy2
			,dummy3
			,dummy4
			,dummy5
			,dummy6
			,dummy7
			,dummy8
			,dummy9
			,dummy10
			,dummy11
		FROM 
			dbo.table_PE2PE_BIM_header

		SET @step = 700

		EXEC sp_executesql @sql

		WHILE @@FETCH_STATUS = 0
		BEGIN

			SET @LegalEntity = @LegalEntity + ' - PE' -- postfix because of internal LE

			-- 2. Subheader SAP Beleg
			INSERT INTO dbo.table_PE2PE_BIM 
				(KopfIdent
				,Buchungskreis
				,Belegdatum
				,Belegart
				,Buchungsdatum
				,Currency
				,Belegkopftext
				,Referenz
				,dummy1
				,dummy2
				,dummy3
				,dummy4
				,dummy5
				,dummy6
				,dummy7
				,dummy8
				,dummy9
				,dummy10
				,dummy11)
			SELECT 
				'BKPF'
				,'' + @CompanyCode + ''
				,'' + @AsOfDate_DE +  ''
				,'AB'
				,'' + @AsOfDate_DE + ''
				,'' + @CCY + ''
				,'PE2PE'
				,'PE2PE' + @AsOfDate_EN + ''
				,NULL
				,NULL
				,NULL
				,NULL
				,NULL
				,NULL
				,NULL
				,NULL
				,NULL
				,NULL
				,NULL

			-- 3. sum for LE
			IF @LogInfo >= 1  BEGIN 
				SELECT @LogEntry = 'SUM PE2PE TABLE' + @LegalEntity + ', ' + @CCY
				EXECUTE [dbo].[Write_Log] 'Info', @LogEntry, @proc, @Main_Process, @Calling_Application, @step, 1 , @Session_Key
			END
			SET @step = 800
			INSERT INTO dbo.table_PE2PE_BIM 
				(KopfIdent
				,Buchungskreis
				,Belegdatum
				,Belegart
				,Buchungsdatum
				,Currency
				,Belegkopftext
				,Referenz
				,dummy1
				,dummy2
				,dummy3
				,dummy4
				,dummy5
				,dummy6
				,dummy7
				,dummy8
				,dummy9
				,dummy10
				,dummy11)
			SELECT 
				NULL
				,IIF(SUM(Realised) < 0, '40', '50')
				,SAP_Account
				,OrderNo
				,CONVERT(VARCHAR, FORMAT(ABS(SUM(Realised)), 'G'))
				,CONVERT(VARCHAR, FORMAT(ABS(SUM(round(Volume_new, 3))), 'G'))
				,IIF(InstrumentType LIKE 'REN-%'
					OR InstrumentType LIKE 'EM-%', 'ST', 'MWh')
				,'' + @AsOfDate_EN + ''

				,IIF(Ticker = 'not assigned'
					OR Ticker = '', InstrumentType, Ticker) + ';GB;' + LZB + ';' + ExternalPortfolio + ';UK'
				,IIF(LEFT(SAP_Account, 1) = 4, 'AP', 'VP')
				,'' + @CompanyCode + ''
				,NULL
				,NULL
				,Ticker
				,LZB
				,InstrumentType
				,ExternalPortfolio
				,CONVERT(VARCHAR, FORMAT(SUM(Realised), 'G'))
				,CONVERT(VARCHAR, FORMAT(SUM(round(Volume_new, 3)), 'G'))
			FROM 
				FinRecon.dbo.table_PE2PE_with_matching_deals
			WHERE 
				InternalLegalEntity = '' + @LegalEntity + ''
				AND Currency = ''+ @CCY + ''
			GROUP BY 
				OrderNO
				,SAP_Account
				,InstrumentType
				,CashflowType
				,ExternalPortfolio
				,Ticker
				,UNIT_TO
				,LZB
			HAVING 
				NOT (
					SUM(Realised) = 0
					AND SUM(Volume_new) <> 0
					)
			-- 4. transfer PE2PE

			IF @LogInfo >= 1  BEGIN 
				SELECT @LogEntry = 'TRANSFER PE2PE TABLE ' + @LegalEntity + ', ' + @CCY
				EXECUTE [dbo].[Write_Log] 'Info', @LogEntry, @proc, @Main_Process, @Calling_Application, @step, 1 , @Session_Key
			END
			SET @step = 900
			INSERT INTO dbo.table_PE2PE_BIM 
				(KopfIdent
				,Buchungskreis
				,Belegdatum
				,Belegart
				,Buchungsdatum
				,Currency
				,Belegkopftext
				,Referenz
				,dummy1
				,dummy2
				,dummy3
				,dummy4
				,dummy5
				,dummy6
				,dummy7
				,dummy8
				,dummy9
				,dummy10
				,dummy11)
			SELECT 
				'999'
				,'37'
				,'80002'
				,'/'
				,CONVERT(VARCHAR, FORMAT(ABS(SUM(Realised)), 'G'))
				,'/'
				,'/'
				,'' + @AsOfDate_EN + ''
				,'Transfer PE2PE'
				,'/'
				,'' + @CompanyCode +''
				,NULL
				,NULL
				,NULL
				,NULL
				,NULL
				,NULL
				,NULL
				,NULL
			FROM 
				FinRecon.dbo.table_PE2PE_with_matching_deals
			WHERE 
				InternalLegalEntity = '' + @LegalEntity + ''
				AND Currency = '' + @CCY +''
				--GROUP BY OrderNO, SAP_Account, InstrumentType, CashflowType, ExternalPortfolio, Ticker, UNIT_TO
			HAVING 
				NOT (
					SUM(Realised) = 0
					AND SUM(Volume_new) <> 0
					)

			-- next LE
			FETCH NEXT FROM BIMCursorLE INTO @LegalEntity, @CompanyCode, @CountryCode, @CCY
		END
		----------------------------------------------------------
		-- reset cursor and second loop for volume corrections
		----------------------------------------------------------
		SET @step = 1000

		CLOSE BIMCursorLE
		DEALLOCATE BIMCursorLE

		DECLARE BIMCursorLE CURSOR FOR
		SELECT
			distinct case when map_order.LegalEntity = 'n/a' then 'RWEST DE' else map_order.LegalEntity  end as LegalEntity
			,case when map_order.LegalEntity = 'n/a' then '0600' else CompanyCode  end	as CompanyCode
			,case when map_order.LegalEntity = 'n/a' then 'DE' else VAT_CountryCode  end as CountryCode
			,[Currency] AS CCY
		FROM 
				dbo.table_PE2PE_with_matching_deals
				left join dbo.map_order on table_PE2PE_with_matching_deals.OrderNo= map_order.OrderNo
				left join dbo.table_Clearer_map_LegalEntity_CompanyCode on dbo.map_order.LegalEntity = dbo.table_Clearer_map_LegalEntity_CompanyCode.LegalEntity
		WHERE 
			map_order.LegalEntity not in ('RWEST SH','RWESTA - PE')
			AND NOT (map_order.LegalEntity = 'RWEST DE' AND dbo.table_PE2PE_with_matching_deals.VAT_CountryCode = 'GB' )
		ORDER BY 
			LegalEntity,
			[Currency]
		OPEN BIMCursorLE

		FETCH NEXT FROM BIMCursorLE INTO @LegalEntity, @CompanyCode, @CountryCode, @CCY
		-- header Volume Correction
		INSERT INTO dbo.table_PE2PE_BIM 
				(KopfIdent
				,Buchungskreis
				,Belegdatum
				,Belegart
				,Buchungsdatum
				,Currency
				,Belegkopftext
				,Referenz
				,dummy1
				,dummy2
				,dummy3
				,dummy4
				,dummy5
				,dummy6
				,dummy7
				,dummy8
				,dummy9
				,dummy10
				,dummy11)
			SELECT 'VOLUME CORRECTION BELOW'
				,'VOLUME CORRECTION BELOW'
				,'VOLUME CORRECTION BELOW'
				,'VOLUME CORRECTION BELOW'
				,'VOLUME CORRECTION BELOW'
				,'VOLUME CORRECTION BELOW'
				,'VOLUME CORRECTION BELOW'
				,'VOLUME CORRECTION BELOW'
				,'VOLUME CORRECTION BELOW'
				,'VOLUME CORRECTION BELOW'
				,'VOLUME CORRECTION BELOW'
				,'VOLUME CORRECTION BELOW'
				,'VOLUME CORRECTION BELOW'
				,'VOLUME CORRECTION BELOW'
				,'VOLUME CORRECTION BELOW'
				,'VOLUME CORRECTION BELOW'
				,'VOLUME CORRECTION BELOW'
				,'VOLUME CORRECTION BELOW'
				,'VOLUME CORRECTION BELOW'

		SET @step = 1100

		WHILE @@FETCH_STATUS = 0
		BEGIN
		
		SET @LegalEntity = @LegalEntity + ' - PE'

		INSERT INTO dbo.table_PE2PE_BIM 
				(KopfIdent
				,Buchungskreis
				,Belegdatum
				,Belegart
				,Buchungsdatum
				,Currency
				,Belegkopftext
				,Referenz
				,dummy1
				,dummy2
				,dummy3
				,dummy4
				,dummy5
				,dummy6
				,dummy7
				,dummy8
				,dummy9
				,dummy10
				,dummy11)
				SELECT 'BKPF'
				,'' + @CompanyCode + ''
				,'' + @AsOfDate_DE + ''
				,'AB'
				,'' + @AsOfDate_DE + ''
				,'' + @CCY + ''
				,'PE2PE'
				,'PE2PE ' + @AsOfDate_EN + ''
				,NULL
				,NULL
				,NULL
				,NULL
				,NULL
				,NULL
				,NULL
				,NULL
				,NULL
				,NULL
				,NULL

		SET @step = 1200
		IF @LogInfo >= 1  BEGIN 
			SELECT @LogEntry = 'Volume Correction PE2PE TABLE ' + @LegalEntity + ', ' + @CCY
			EXECUTE [dbo].[Write_Log] 'Info', @LogEntry, @proc, @Main_Process, @Calling_Application, @step, 1 , @Session_Key
		END

		INSERT INTO dbo.table_PE2PE_BIM 
				(KopfIdent
				,Buchungskreis
				,Belegdatum
				,Belegart
				,Buchungsdatum
				,Currency
				,Belegkopftext
				,Referenz
				,dummy1
				,dummy2
				,dummy3
				,dummy4
				,dummy5
				,dummy6
				,dummy7
				,dummy8
				,dummy9
				,dummy10
				,dummy11)
				SELECT 
					''
					,IIF(SUM([Volume_new]) < 0, '40', '50')
					,[SAP_Account]
					,[OrderNo]
					,'0.01'
					,CONVERT(Varchar, FORMAT(ABS(SUM([Volume_new])), 'G'))
					,IIF([InstrumentType] LIKE 'REN-%' OR [InstrumentType] LIKE 'EM-%', 'ST', 'MWh')
					,'' + @AsOfDate_DE + ''
					,IIF([Ticker] = 'not assigned' OR [Ticker] = '', [InstrumentType], [Ticker]) + ';GB;' + [LZB] + ';' + [ExternalPortfolio] + ';UK'
					,IIF(LEFT([SAP_Account], 1) = 4, 'AP', 'VP')
					,'' + @CompanyCode + ''
					,NULL
					,NULL
					,[Ticker]
					,[LZB]
					,[InstrumentType]
					,[ExternalPortfolio]
					,'0.01'
					,CONVERT(Varchar, FORMAT(ROUND(SUM([Volume_new]), 3), 'G'))
					FROM 
						[FinRecon].[dbo].[table_PE2PE_with_matching_deals]
					WHERE 
						[InternalLegalEntity] = '' + @LegalEntity + ''
						AND [Currency] = '' + @CCY + ''
					GROUP BY 
						OrderNO, 
						SAP_Account, 
						InstrumentType, 
						CashflowType, 
						[ExternalPortfolio], 
						[Ticker], 
						[UNIT_TO], 
						[LZB]
					HAVING (SUM([Realised]) = 0 AND SUM([Volume_new]) <> 0)

			FETCH NEXT FROM BIMCursorLE INTO @LegalEntity, @CompanyCode, @CountryCode, @CCY
		END


		CLOSE BIMCursorLE
		DEALLOCATE BIMCursorLE

	END

	SELECT @LogEntry = 'FINISHED'
	EXECUTE [dbo].[Write_Log] 'Info', @LogEntry, @proc, @Main_Process, @Calling_Application, @step, 1 , @Session_Key

NoFurtherAction:
	/*down here the drops is gelutscht*/

	END TRY

	BEGIN CATCH
		EXEC [dbo].[usp_GetErrorInfo] @proc, @step		
		SELECT @LogEntry = 'FAILED'
		EXECUTE [dbo].[Write_Log] 'Info', @LogEntry, @proc, @Main_Process, @Calling_Application, @step, 1 , @Session_Key
	END CATCH

GO

