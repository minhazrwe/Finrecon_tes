


CREATE PROCEDURE [dbo].[Archive_VM_Netting_Tables]
AS
BEGIN TRY
	DECLARE @LogInfo INTEGER
	DECLARE @proc NVARCHAR(40)
	DECLARE @step INTEGER

	DECLARE @COB as date

	SELECT @COB = AsOfDate_EOM FROM dbo.AsOfDate


	SELECT @step = 1

	SELECT @proc = '[dbo].[Archive_VM_Netting_Tables]'

	SELECT @step = 10

	SELECT @LogInfo = [dbo].[LogInfo].[LogInfo]
	FROM [dbo].[LogInfo]

	SELECT @step = @step + 1

	IF @LogInfo >= 1
	BEGIN
		INSERT INTO [dbo].[Logfile]
		SELECT 'Archive_VM_Netting_Tables - START'
			,GETDATE()
	END

	SELECT @step = @step + 1

	

	-- and inster the curent data
	IF @LogInfo >= 1
	BEGIN
		INSERT INTO [dbo].[Logfile]
		SELECT 'Archive VM_NETTING_Deallevel'
			,GETDATE()
	END

	DELETE
	FROM [dbo].[VM_NETTING_Deallevel_archive]
	WHERE [AsOfDate] = (
			SELECT AsOfDate_EOM
			FROM dbo.AsOfDate
			)

	INSERT INTO [dbo].[VM_NETTING_Deallevel_archive] (
		[AsofDate]
		,[source]
		,[DealNumber]
		,[olfpnl]
		,[Product]
		,[ExchangeCode]
		,[Currency]
		,[Portfolio]
		,[ExternalBU]
		,[ContractDate]
		)
	SELECT (
			SELECT dd.AsOfDate_EOM
			FROM dbo.AsOfDate dd
			)
		,[source]
		,[DealNumber]
		,[olfpnl]
		,[Product]
		,[ExchangeCode]
		,[Currency]
		,[Portfolio]
		,[ExternalBU]
		,[ContractDate]
	FROM [dbo].[VM_NETTING_Deallevel]

	SELECT @step = @step + 1

	-- and inster the curent data
	IF @LogInfo >= 1
	BEGIN
		INSERT INTO [dbo].[Logfile]
		SELECT 'Archive VM_NETTING_Produktzuordnung'
			,GETDATE()
	END

	DELETE
	FROM [dbo].[VM_NETTING_Produktzuordnung_Archive]
	WHERE [AsOfDate] = (
			SELECT AsOfDate_EOM
			FROM dbo.AsOfDate
			)

	INSERT INTO [dbo].[VM_NETTING_Produktzuordnung_Archive] (
		[AsofDate]
		,[ExtBunit]
		,[InstrumentType]
		,[Kommentar]
		,[TimeStamp]
		)
	SELECT (
			SELECT dd.AsOfDate_EOM
			FROM dbo.AsOfDate dd
			)
		,[ExtBunit]
		,[InstrumentType]
		,[Kommentar]
		,[TimeStamp]
	FROM [FinRecon].[dbo].[VM_NETTING_Produktzuordnung]

	SELECT @step = @step + 1

	-- and inster the curent data
	IF @LogInfo >= 1
	BEGIN
		INSERT INTO [dbo].[Logfile]
		SELECT 'Archive VM_NETTING_Produktzuordnung_Ausnahmen_vom_Produktnetting'
			,GETDATE()
	END

	DELETE
	FROM [dbo].[VM_NETTING_Produktzuordnung_Ausnahmen_vom_Produktnetting_Archive]
	WHERE [AsOfDate] = (
			SELECT AsOfDate_EOM
			FROM dbo.AsOfDate
			)

	INSERT INTO [dbo].[VM_NETTING_Produktzuordnung_Ausnahmen_vom_Produktnetting_Archive] (
		[AsofDate]
		,[InstrumentType]
		,[Kennzeichnung_in_InsRef]
		,[TimeStamp]
		)
	SELECT (
			SELECT dd.AsOfDate_EOM
			FROM dbo.AsOfDate dd
			)
		,[InstrumentType]
		,[Kennzeichnung_in_InsRef]
		,[TimeStamp]
	FROM [dbo].[VM_NETTING_Produktzuordnung_Ausnahmen_vom_Produktnetting]

	SELECT @step = @step + 1

	-- and inster the curent data
	IF @LogInfo >= 1
	BEGIN
		INSERT INTO [dbo].[Logfile]
		SELECT 'Archive table_VM_NETTING_1a_DeferralInput'
			,GETDATE()
	END

	DELETE
	FROM [dbo].[table_VM_NETTING_1a_DeferralInput_Archive]
	WHERE [AsOfDate] = (
			SELECT AsOfDate_EOM
			FROM dbo.AsOfDate
			)

	INSERT INTO [dbo].[table_VM_NETTING_1a_DeferralInput_Archive] (
		[AsofDate]
		,[DataSource]
		,[CCY]
		,[SettlementDate]
		,[AccountName]
		,[Portfolio]
		,[DealNumber]
		,[ContractName]
		,[ContractDate]
		,[ProjectionIndex1]
		,[ProjectionIndex2]
		,[Toolset]
		,[Position]
		,[TradePrice]
		,[SettlementPrice]
		,[RealizedPNL]
		,[ExternalBU]
		,[GueltigVon]
		,[GueltigBis]
		,[LastUpdate]
		)
	SELECT (
			SELECT dd.AsOfDate_EOM
			FROM dbo.AsOfDate dd
			)
		,[DataSource]
		,[CCY]
		,[SettlementDate]
		,[AccountName]
		,[Portfolio]
		,[DealNumber]
		,[ContractName]
		,[ContractDate]
		,[ProjectionIndex1]
		,[ProjectionIndex2]
		,[Toolset]
		,[Position]
		,[TradePrice]
		,[SettlementPrice]
		,[RealizedPNL]
		,[ExternalBU]
		,[GueltigVon]
		,[GueltigBis]
		,[LastUpdate]
	FROM [FinRecon].[dbo].[table_VM_NETTING_1a_DeferralInput]

	SELECT @step = @step + 1

	-- and inster the curent data
	IF @LogInfo >= 1
	BEGIN
		INSERT INTO [dbo].[Logfile]
		SELECT 'Archive table_VM_NETTING_1b_OtherExchangesInput'
			,GETDATE()
	END

	DELETE
	FROM [FinRecon].[dbo].[table_VM_NETTING_1b_OtherExchangesInput_Archive]
	WHERE [AsOfDate] = (
			SELECT AsOfDate_EOM
			FROM dbo.AsOfDate
			)

	INSERT INTO [FinRecon].[dbo].[table_VM_NETTING_1b_OtherExchangesInput_Archive] (
		[AsofDate]
		,[DataSource]
		,[DealNumber]
		,[TradeDate]
		,[InternalBU]
		,[ExternalBU]
		,[Position]
		,[Price]
		,[BuySell]
		,[BrokerID]
		,[StartDate]
		,[MaturityDate]
		,[Status]
		,[InsReference]
		,[Portfolio]
		,[Ticker]
		,[VM]
		,[UnrealizedPNL]
		,[CCY]
		,[LastUpdate]
		)
	SELECT (
			SELECT dd.AsOfDate_EOM
			FROM dbo.AsOfDate dd
			)
		,[DataSource]
		,[DealNumber]
		,[TradeDate]
		,[InternalBU]
		,[ExternalBU]
		,[Position]
		,[Price]
		,[BuySell]
		,[BrokerID]
		,[StartDate]
		,[MaturityDate]
		,[Status]
		,[InsReference]
		,[Portfolio]
		,[Ticker]
		,[VM]
		,[UnrealizedPNL]
		,[CCY]
		,[LastUpdate]
	FROM [FinRecon].[dbo].[table_VM_NETTING_1b_OtherExchangesInput]

	SELECT @step = @step + 1

	-- and inster the curent data
	IF @LogInfo >= 1
	BEGIN
		INSERT INTO [dbo].[Logfile]
		SELECT 'Archive table_VM_NETTING_2_Mapping_Archive'
			,GETDATE()
	END

	DELETE
	FROM [FinRecon].[dbo].[table_VM_NETTING_2_Mapping_Archive]
	WHERE [AsOfDate] = (
			SELECT AsOfDate_EOM
			FROM dbo.AsOfDate
			)

	INSERT INTO [FinRecon].[dbo].[table_VM_NETTING_2_Mapping_Archive] (
		[AsofDate]
		,[Product]
		,[ExchangeCode]
		,[ExternalBU]
		,[NettingType]
		,[LastUpdate]
		)
	SELECT (
			SELECT dd.AsOfDate_EOM
			FROM dbo.AsOfDate dd
			)
		,[Product]
		,[ExchangeCode]
		,[ExternalBU]
		,[NettingType]
		,[LastUpdate]
	FROM [FinRecon].[dbo].[table_VM_NETTING_2_Mapping]

	SELECT @step = @step + 1

	-- and inster the curent data
	IF @LogInfo >= 1
	BEGIN
		INSERT INTO [dbo].[Logfile]
		SELECT 'Archive table_VM_NETTING_4_Analysis_incl_FT_Archive'
			,GETDATE()
	END

	DELETE
	FROM [FinRecon].[dbo].[table_VM_NETTING_4_Analysis_incl_FT_Archive]
	WHERE [AsOfDate] = (
			SELECT AsOfDate_EOM
			FROM dbo.AsOfDate
			)

	INSERT INTO [FinRecon].[dbo].[table_VM_NETTING_4_Analysis_incl_FT_Archive] (
		[AsofDate]
		,[BODealNumber]
		,[BOsource]
		,[BODealtype]
		,[BODataType]
		,[FTSubsidiary]
		,[FTStrategy]
		,[FTBook]
		,[FTReferenceID]
		,[FTInternalPortfolio]
		,[FTExtBusinessUnit]
		,[FTExtLegalEntity]
		,[FTCounterpartyGroup]
		,[FTCurvename]
		,[FTProjIndexGroup]
		,[FTInstrumentType]
		,[FTAccountingTreatment]
		,[BOProduct]
		,[BOExchangeCode]
		,[BOCurrency]
		,[BOPortfolio]
		,[BOExternalBU]
		,[BOContractDate]
		,[BONettingType]
		,[FTProductYearTermEnd]
		,[BORate]
		,[BORateRisk]
		,[BOolfpnl]
		,[BOolfpnlCalcinEURRate]
		,[BOolfpnlCalcinEURRateRisk]
		,[FTSummeVolume]
		,[FTSummeVolumefinal]
		,[FTPNL]
		,[FTOCI]
		,[FTTotal_MtM]
		,[FTTotal_MtMCalcinFXCCYRateRisk]
		,[DiffBOolfpnlCalcinEURRateRiskFTTotal_MtM]
		,[FinMtMtoNet]
		,[posnegVM]
		,[CheckVZ]
		,[HedgeExtern]
		,DESK
		,OrderNumber
		)
	SELECT (
			SELECT dd.AsOfDate_EOM
			FROM dbo.AsOfDate dd
			)
		,[BODealNumber]
		,[BOsource]
		,[BODealtype]
		,[BODataType]
		,[FTSubsidiary]
		,[FTStrategy]
		,[FTBook]
		,[FTReferenceID]
		,[FTInternalPortfolio]
		,[FTExtBusinessUnit]
		,[FTExtLegalEntity]
		,[FTCounterpartyGroup]
		,[FTCurvename]
		,[FTProjIndexGroup]
		,[FTInstrumentType]
		,[FTAccountingTreatment]
		,[BOProduct]
		,[BOExchangeCode]
		,[BOCurrency]
		,[BOPortfolio]
		,[BOExternalBU]
		,[BOContractDate]
		,[BONettingType]
		,[FTProductYearTermEnd]
		,[BORate]
		,[BORateRisk]
		,[BOolfpnl]
		,[BOolfpnlCalcinEURRate]
		,[BOolfpnlCalcinEURRateRisk]
		,[FTSummeVolume]
		,[FTSummeVolumefinal]
		,[FTPNL]
		,[FTOCI]
		,[FTTotal_MtM]
		,[FTTotal_MtMCalcinFXCCYRateRisk]
		,[DiffBOolfpnlCalcinEURRateRiskFTTotal_MtM]
		,[FinMtMtoNet]
		,[posnegVM]
		,[CheckVZ]
		,[HedgeExtern]
		,DESK
		,OrderNumber
	FROM [FinRecon].[dbo].[table_VM_NETTING_4_Analysis_incl_FT]

	SELECT @step = @step + 1

	IF @LogInfo >= 1
	BEGIN
		INSERT INTO [dbo].[Logfile]
		SELECT 'Archive_VM_Netting_Tables - FINISHED'
			,GETDATE()
	END
END TRY

BEGIN CATCH
	--insert into [dbo].[Logfile] select 'ERROR-OCCURED', @TimeStamp
	BEGIN
		INSERT INTO [dbo].[Logfile]
		SELECT 'Archive_VM_Netting_Tables - FAILED'
			,GETDATE()
	END

	EXEC [dbo].[usp_GetErrorInfo] @proc
		,@step
END CATCH

GO

