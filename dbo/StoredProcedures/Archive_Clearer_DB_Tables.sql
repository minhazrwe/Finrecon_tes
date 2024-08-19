
--Added on 30/07/2024 by PG
--Requested by Anna Lena Maas and Dennis Schley


CREATE PROCEDURE [dbo].[Archive_Clearer_DB_Tables]
AS
BEGIN TRY
	DECLARE @LogInfo INTEGER
	DECLARE @proc NVARCHAR(40)
	DECLARE @step INTEGER

	DECLARE @COB as date

	SELECT @COB = AsOfDate_EOM FROM dbo.AsOfDate


	SELECT @step = 1

	SELECT @proc = '[dbo].[Archive_Clearer_DB_Tables]'

	SELECT @step = 10

	SELECT @LogInfo = [dbo].[LogInfo].[LogInfo]
	FROM [dbo].[LogInfo]

	SELECT @step = @step + 1

	IF @LogInfo >= 1
	BEGIN
		INSERT INTO [dbo].[Logfile]
		SELECT 'Archive_Clearer_DB_Tables - START'
			,GETDATE()
	END

	SELECT @step = @step + 1

	

	--#1 and insert the curent data
	IF @LogInfo >= 1
	BEGIN
		INSERT INTO [dbo].[Logfile]
		SELECT 'Archive table_Clearer_AccountingData'
			,GETDATE()
	END

	DELETE
	FROM [dbo].[table_Clearer_AccountingData_Archive]
	WHERE COB = (
			SELECT max(CoB)
			FROM dbo.[table_Clearer_AccountingData]
			)

	INSERT INTO [dbo].[table_Clearer_AccountingData_Archive] (
	   [CoB]
      ,[DealNumber]
      ,[AccountName]
      ,[InternalPortfolio]
      ,[ContractName]
      ,[ContractDate]
      ,[ProductName]
      ,[SettlementDate]
      ,[ExerciseDate]
      ,[DeliveryDate]
      ,[DeliveryType]
      ,[ProjectionIndex1]
      ,[ProjectionIndex2]
      ,[Toolset]
      ,[Position]
      ,[TradePrice]
      ,[SettlementPrice]
      ,[RealisedPnL]
      ,[CCY]
      ,[ClearerID]
      ,[ClearerType]
      ,[LastImport]
		)
	SELECT 
	   [CoB]
      ,[DealNumber]
      ,[AccountName]
      ,[InternalPortfolio]
      ,[ContractName]
      ,[ContractDate]
      ,[ProductName]
      ,[SettlementDate]
      ,[ExerciseDate]
      ,[DeliveryDate]
      ,[DeliveryType]
      ,[ProjectionIndex1]
      ,[ProjectionIndex2]
      ,[Toolset]
      ,[Position]
      ,[TradePrice]
      ,[SettlementPrice]
      ,[RealisedPnL]
      ,[CCY]
      ,[ClearerID]
      ,[ClearerType]
      ,[LastImport]
	FROM [dbo].[table_Clearer_AccountingData]
	WHERE CoB = (
			SELECT max(CoB)
			FROM dbo.[table_Clearer_AccountingData]
			)
	
	--done
	SELECT @step = @step + 1

	--#2 and insert the curent data
	IF @LogInfo >= 1
	BEGIN
		INSERT INTO [dbo].[Logfile]
		SELECT 'Archive table_Clearer_CashData'
			,GETDATE()
	END

	DELETE
	FROM [dbo].[table_Clearer_CashData_Archive]
	WHERE [AsOfDate] = (
			SELECT AsOfDate_EOM
			FROM dbo.AsOfDate
			)

	INSERT INTO [dbo].[table_Clearer_CashData_Archive] (
		[AsofDate]
	  ,[Account_Name]
      ,[Report_Date]
      ,[Opening_Balance]
      ,[Margin_Funds_Transfer]
      ,[Commission_Fees]
      ,[Interests]
      ,[Option_Premium]
      ,[Net_Invoice]
      ,[Invoiced_VAT]
      ,[Realized_PNL]
      ,[Closing_Balance]
      ,[Variation_Margin]
      ,[Net_Option_Value]
      ,[Initial_Margin]
      ,[Intercommodity_Credit]
      ,[Special_Delivery_Margin]
      ,[Collateral_Used]
      ,[Prefunding_Amount]
      ,[Letter_of_Credit]
      ,[Excess_Deficit]
      ,[Commentary]
      ,[Security_Interest_Check]
      ,[CCY]
      ,[Product_Name]
      ,[Commodity]
      ,[Clearer_id]
      ,[LastImport]
		)
	SELECT (
			SELECT dd.AsOfDate_EOM
			FROM dbo.AsOfDate dd
			)
	  ,[Account_Name]
      ,[Report_Date]
      ,[Opening_Balance]
      ,[Margin_Funds_Transfer]
      ,[Commission_Fees]
      ,[Interests]
      ,[Option_Premium]
      ,[Net_Invoice]
      ,[Invoiced_VAT]
      ,[Realized_PNL]
      ,[Closing_Balance]
      ,[Variation_Margin]
      ,[Net_Option_Value]
      ,[Initial_Margin]
      ,[Intercommodity_Credit]
      ,[Special_Delivery_Margin]
      ,[Collateral_Used]
      ,[Prefunding_Amount]
      ,[Letter_of_Credit]
      ,[Excess_Deficit]
      ,[Commentary]
      ,[Security_Interest_Check]
      ,[CCY]
      ,[Product_Name]
      ,[Commodity]
      ,[Clearer_id]
      ,[LastImport]
	FROM [FinRecon].[dbo].[table_Clearer_CashData]

	--done
	SELECT @step = @step + 1

	--#3 and inster the curent data
	IF @LogInfo >= 1
	BEGIN
		INSERT INTO [dbo].[Logfile]
		SELECT 'Archive table_Clearer_DealData'
			,GETDATE()
	END

	DELETE
	FROM [dbo].[table_Clearer_DealData_Archive]
	WHERE [AsOfDate] = (
			SELECT AsOfDate_EOM
			FROM dbo.AsOfDate
			)

	INSERT INTO [dbo].[table_Clearer_DealData_Archive] (
	   [AsofDate]
	  ,[ReportDate]
      ,[DealNumber]
      ,[AccountName]
      ,[InternalPortfolio]
      ,[ExternalBusinessUnit]
      ,[ContractName]
      ,[ContractSize]
      ,[BrokerName]
      ,[TradeDate]
      ,[StartDate]
      ,[EndDate]
      ,[ProjectionIndex1]
      ,[ProjectionIndex2]
      ,[Toolset]
      ,[Position]
      ,[CCY]
      ,[TradePrice]
      ,[StrikePrice]
      ,[Premium]
      ,[CallPut]
      ,[FeeType]
      ,[FeeRate]
      ,[TotalFee]
      ,[AdjustedTotalFee]
      ,[ClearerID]
      ,[ClearerType]
      ,[Source]
      ,[LastImport]
		)
	SELECT (
			SELECT dd.AsOfDate_EOM
			FROM dbo.AsOfDate dd
			)
	  ,[ReportDate]
      ,[DealNumber]
      ,[AccountName]
      ,[InternalPortfolio]
      ,[ExternalBusinessUnit]
      ,[ContractName]
      ,[ContractSize]
      ,[BrokerName]
      ,[TradeDate]
      ,[StartDate]
      ,[EndDate]
      ,[ProjectionIndex1]
      ,[ProjectionIndex2]
      ,[Toolset]
      ,[Position]
      ,[CCY]
      ,[TradePrice]
      ,[StrikePrice]
      ,[Premium]
      ,[CallPut]
      ,[FeeType]
      ,[FeeRate]
      ,[TotalFee]
      ,[AdjustedTotalFee]
      ,[ClearerID]
      ,[ClearerType]
      ,[Source]
      ,[LastImport]
	FROM [dbo].[table_Clearer_DealData]

	SELECT @step = @step + 1

	--#4 and insert the current data
	IF @LogInfo >= 1
	BEGIN
		INSERT INTO [dbo].[Logfile]
		SELECT 'Archive table_Clearer_Manual_Adjustments'
			,GETDATE()
	END

	DELETE
	FROM [dbo].[table_Clearer_Manual_Adjustments_Archive]
	WHERE [AsOfDate] = (
			SELECT AsOfDate_EOM
			FROM dbo.AsOfDate
			)

	INSERT INTO [dbo].[table_Clearer_Manual_Adjustments_Archive] (
	   [AsofDate]
      ,[Trade_Date]
      ,[Adjustment_Value]
      ,[Adjustment_Type]
      ,[Account_Name]
      ,[Adjustment_Comment]
      ,[Product_Name]
      ,[Commodity]
      ,[Clearer_id]
      ,[LastImport]
		)
	SELECT (
			SELECT dd.AsOfDate_EOM
			FROM dbo.AsOfDate dd
			)
      ,[Trade_Date]
      ,[Adjustment_Value]
      ,[Adjustment_Type]
      ,[Account_Name]
      ,[Adjustment_Comment]
      ,[Product_Name]
      ,[Commodity]
      ,[Clearer_id]
      ,[LastImport]
	FROM [FinRecon].[dbo].[table_Clearer_Manual_Adjustments]

	SELECT @step = @step + 1

	--#5 and inster the curent data
	IF @LogInfo >= 1
	BEGIN
		INSERT INTO [dbo].[Logfile]
		SELECT 'Archive table_D2D_realised_data'
			,GETDATE()
	END

	DELETE
	FROM [FinRecon].[dbo].[table_D2D_realised_data_archive]
	WHERE [AsOfDate] = (
			SELECT AsOfDate_EOM
			FROM dbo.AsOfDate
			)

	INSERT INTO [FinRecon].[dbo].[table_D2D_realised_data_Archive] (
	   [AsofDate]
	  ,[IntDesk]
      ,[ExtDesk]
      ,[Commodity]
      ,[OrderNo]
      ,[UNIT_TO]
      ,[Unit]
      ,[Volume_new]
      ,[Deal]
      ,[OffsetDealNumber]
      ,[Reference]
      ,[Tran Status]
      ,[InstrumentType]
      ,[InternalLegalEntity]
      ,[InternalBusinessUnit]
      ,[PfID]
      ,[InternalPortfolio]
      ,[ExternalBusinessUnit]
      ,[ExternalLegalEntity]
      ,[ExternalPortfolio]
      ,[Currency]
      ,[Action]
      ,[DocumentNumber]
      ,[EventDate]
      ,[TradeDate]
      ,[DeliveryMonth]
      ,[FXRate]
      ,[Realised]
      ,[CashflowType]
      ,[InstrumentSubType]
      ,[Ticker]
      ,[SAP_Account]
      ,[LegalEntity]
      ,[Partner]
      ,[StKZ_zw1]
      ,[VAT_CountryCode]
      ,[LegEndDate]
      ,[UpdateKonten]
		)
	SELECT (
			SELECT dd.AsOfDate_EOM
			FROM dbo.AsOfDate dd
			)
	  ,[IntDesk]
      ,[ExtDesk]
      ,[Commodity]
      ,[OrderNo]
      ,[UNIT_TO]
      ,[Unit]
      ,[Volume_new]
      ,[Deal]
      ,[OffsetDealNumber]
      ,[Reference]
      ,[Tran Status]
      ,[InstrumentType]
      ,[InternalLegalEntity]
      ,[InternalBusinessUnit]
      ,[PfID]
      ,[InternalPortfolio]
      ,[ExternalBusinessUnit]
      ,[ExternalLegalEntity]
      ,[ExternalPortfolio]
      ,[Currency]
      ,[Action]
      ,[DocumentNumber]
      ,[EventDate]
      ,[TradeDate]
      ,[DeliveryMonth]
      ,[FXRate]
      ,[Realised]
      ,[CashflowType]
      ,[InstrumentSubType]
      ,[Ticker]
      ,[SAP_Account]
      ,[LegalEntity]
      ,[Partner]
      ,[StKZ_zw1]
      ,[VAT_CountryCode]
      ,[LegEndDate]
      ,[UpdateKonten]
	FROM [FinRecon].[dbo].[table_D2D_realised_data]

	SELECT @step = @step + 1

	--#6 and inster the curent data
	IF @LogInfo >= 1
	BEGIN
		INSERT INTO [dbo].[Logfile]
		SELECT 'Archive table_D2D_with_matching_deals'
			,GETDATE()
	END

	DELETE
	FROM [FinRecon].[dbo].[table_D2D_with_matching_deals_Archive]
	WHERE [AsOfDate] = (
			SELECT AsOfDate_EOM
			FROM dbo.AsOfDate
			)

	INSERT INTO [FinRecon].[dbo].[table_D2D_with_matching_deals_Archive] (
		[AsofDate]
		,[group]
      ,[IntDesk]
      ,[ExtDesk]
      ,[Commodity]
      ,[OrderNo]
      ,[UNIT_TO]
      ,[Unit]
      ,[Volume_new]
      ,[Deal]
      ,[OffsetDealNumber]
      ,[Reference]
      ,[Tran Status]
      ,[InstrumentType]
      ,[InternalLegalEntity]
      ,[InternalBusinessUnit]
      ,[PfID]
      ,[InternalPortfolio]
      ,[ExternalBusinessUnit]
      ,[ExternalLegalEntity]
      ,[ExternalPortfolio]
      ,[Currency]
      ,[Action]
      ,[DocumentNumber]
      ,[EventDate]
      ,[TradeDate]
      ,[DeliveryMonth]
      ,[FXRate]
      ,[Realised]
      ,[CashflowType]
      ,[InstrumentSubType]
      ,[Ticker]
      ,[SAP_Account]
      ,[LegalEntity]
      ,[Partner]
      ,[StKZ_zw1]
      ,[VAT_CountryCode]
      ,[LegEndDate]
      ,[UpdateKonten]
		)
	SELECT (
			SELECT dd.AsOfDate_EOM
			FROM dbo.AsOfDate dd
			)
	  ,[group]
      ,[IntDesk]
      ,[ExtDesk]
      ,[Commodity]
      ,[OrderNo]
      ,[UNIT_TO]
      ,[Unit]
      ,[Volume_new]
      ,[Deal]
      ,[OffsetDealNumber]
      ,[Reference]
      ,[Tran Status]
      ,[InstrumentType]
      ,[InternalLegalEntity]
      ,[InternalBusinessUnit]
      ,[PfID]
      ,[InternalPortfolio]
      ,[ExternalBusinessUnit]
      ,[ExternalLegalEntity]
      ,[ExternalPortfolio]
      ,[Currency]
      ,[Action]
      ,[DocumentNumber]
      ,[EventDate]
      ,[TradeDate]
      ,[DeliveryMonth]
      ,[FXRate]
      ,[Realised]
      ,[CashflowType]
      ,[InstrumentSubType]
      ,[Ticker]
      ,[SAP_Account]
      ,[LegalEntity]
      ,[Partner]
      ,[StKZ_zw1]
      ,[VAT_CountryCode]
      ,[LegEndDate]
      ,[UpdateKonten]
	FROM [FinRecon].[dbo].[table_D2D_with_matching_deals]

	SELECT @step = @step + 1

	--#7 and inster the curent data
	IF @LogInfo >= 1
	BEGIN
		INSERT INTO [dbo].[Logfile]
		SELECT 'Archive table_D2D_without_matching_deals'
			,GETDATE()
	END

	DELETE
	FROM [FinRecon].[dbo].[table_D2D_without_matching_deals_Archive]
	WHERE [AsOfDate] = (
			SELECT AsOfDate_EOM
			FROM dbo.AsOfDate
			)

	INSERT INTO [FinRecon].[dbo].[table_D2D_without_matching_deals_Archive] (
		[AsofDate]
	  ,[group]
      ,[IntDesk]
      ,[ExtDesk]
      ,[Commodity]
      ,[OrderNo]
      ,[UNIT_TO]
      ,[Unit]
      ,[Volume_new]
      ,[Deal]
      ,[OffsetDealNumber]
      ,[Reference]
      ,[Tran Status]
      ,[InstrumentType]
      ,[InternalLegalEntity]
      ,[InternalBusinessUnit]
      ,[PfID]
      ,[InternalPortfolio]
      ,[ExternalBusinessUnit]
      ,[ExternalLegalEntity]
      ,[ExternalPortfolio]
      ,[Currency]
      ,[Action]
      ,[DocumentNumber]
      ,[EventDate]
      ,[TradeDate]
      ,[DeliveryMonth]
      ,[FXRate]
      ,[Realised]
      ,[CashflowType]
      ,[InstrumentSubType]
      ,[Ticker]
      ,[SAP_Account]
      ,[LegalEntity]
      ,[Partner]
      ,[StKZ_zw1]
      ,[VAT_CountryCode]
      ,[LegEndDate]
      ,[UpdateKonten]
		)
	SELECT (
			SELECT dd.AsOfDate_EOM
			FROM dbo.AsOfDate dd
			)
	  ,[group]
      ,[IntDesk]
      ,[ExtDesk]
      ,[Commodity]
      ,[OrderNo]
      ,[UNIT_TO]
      ,[Unit]
      ,[Volume_new]
      ,[Deal]
      ,[OffsetDealNumber]
      ,[Reference]
      ,[Tran Status]
      ,[InstrumentType]
      ,[InternalLegalEntity]
      ,[InternalBusinessUnit]
      ,[PfID]
      ,[InternalPortfolio]
      ,[ExternalBusinessUnit]
      ,[ExternalLegalEntity]
      ,[ExternalPortfolio]
      ,[Currency]
      ,[Action]
      ,[DocumentNumber]
      ,[EventDate]
      ,[TradeDate]
      ,[DeliveryMonth]
      ,[FXRate]
      ,[Realised]
      ,[CashflowType]
      ,[InstrumentSubType]
      ,[Ticker]
      ,[SAP_Account]
      ,[LegalEntity]
      ,[Partner]
      ,[StKZ_zw1]
      ,[VAT_CountryCode]
      ,[LegEndDate]
      ,[UpdateKonten]
	FROM [FinRecon].[dbo].[table_D2D_without_matching_deals]

	SELECT @step = @step + 1

		--#8 and inster the curent data
	IF @LogInfo >= 1
	BEGIN
		INSERT INTO [dbo].[Logfile]
		SELECT 'Archive table_PE2PE_realised_data'
			,GETDATE()
	END

	DELETE
	FROM [FinRecon].[dbo].[table_PE2PE_realised_data_Archive]
	WHERE [AsOfDate] = (
			SELECT AsOfDate_EOM
			FROM dbo.AsOfDate
			)

	INSERT INTO [FinRecon].[dbo].[table_PE2PE_realised_data_Archive] (
		[AsofDate]
	  ,[group]
      ,[IntDesk]
      ,[ExtDesk]
      ,[Commodity]
      ,[OrderNo]
      ,[UNIT_TO]
      ,[Unit]
      ,[Volume_new]
      ,[Deal]
      ,[OffsetDealNumber]
      ,[Reference]
      ,[Tran Status]
      ,[InstrumentType]
      ,[InternalLegalEntity]
      ,[InternalBusinessUnit]
      ,[PfID]
      ,[InternalPortfolio]
      ,[ExternalBusinessUnit]
      ,[ExternalLegalEntity]
      ,[ExternalPortfolio]
      ,[Currency]
      ,[Action]
      ,[DocumentNumber]
      ,[EventDate]
      ,[TradeDate]
      ,[DeliveryMonth]
      ,[FXRate]
      ,[Realised]
      ,[CashflowType]
      ,[InstrumentSubType]
      ,[Ticker]
      ,[SAP_Account]
      ,[LegalEntity]
      ,[Partner]
      ,[StKZ_zw1]
      ,[VAT_CountryCode]
      ,[LegEndDate]
      ,[UpdateKonten]
      ,[LZB]
		)
	SELECT (
			SELECT dd.AsOfDate_EOM
			FROM dbo.AsOfDate dd
			)
	  ,[group]
      ,[IntDesk]
      ,[ExtDesk]
      ,[Commodity]
      ,[OrderNo]
      ,[UNIT_TO]
      ,[Unit]
      ,[Volume_new]
      ,[Deal]
      ,[OffsetDealNumber]
      ,[Reference]
      ,[Tran Status]
      ,[InstrumentType]
      ,[InternalLegalEntity]
      ,[InternalBusinessUnit]
      ,[PfID]
      ,[InternalPortfolio]
      ,[ExternalBusinessUnit]
      ,[ExternalLegalEntity]
      ,[ExternalPortfolio]
      ,[Currency]
      ,[Action]
      ,[DocumentNumber]
      ,[EventDate]
      ,[TradeDate]
      ,[DeliveryMonth]
      ,[FXRate]
      ,[Realised]
      ,[CashflowType]
      ,[InstrumentSubType]
      ,[Ticker]
      ,[SAP_Account]
      ,[LegalEntity]
      ,[Partner]
      ,[StKZ_zw1]
      ,[VAT_CountryCode]
      ,[LegEndDate]
      ,[UpdateKonten]
      ,[LZB]
	FROM [FinRecon].[dbo].[table_PE2PE_realised_data]

	SELECT @step = @step + 1

			--#9 and inster the curent data
	IF @LogInfo >= 1
	BEGIN
		INSERT INTO [dbo].[Logfile]
		SELECT 'Archive table_PE2PE_with_matching_deals'
			,GETDATE()
	END

	DELETE
	FROM [FinRecon].[dbo].[table_PE2PE_with_matching_deals_Archive]
	WHERE [AsOfDate] = (
			SELECT AsOfDate_EOM
			FROM dbo.AsOfDate
			)

	INSERT INTO [FinRecon].[dbo].[table_PE2PE_with_matching_deals_Archive] (
		[AsofDate]
      ,[group]
      ,[IntDesk]
      ,[ExtDesk]
      ,[Commodity]
      ,[OrderNo]
      ,[UNIT_TO]
      ,[Unit]
      ,[Volume_new]
      ,[Deal]
      ,[OffsetDealNumber]
      ,[Reference]
      ,[Tran Status]
      ,[InstrumentType]
      ,[InternalLegalEntity]
      ,[InternalBusinessUnit]
      ,[PfID]
      ,[InternalPortfolio]
      ,[ExternalBusinessUnit]
      ,[ExternalLegalEntity]
      ,[ExternalPortfolio]
      ,[Currency]
      ,[Action]
      ,[DocumentNumber]
      ,[EventDate]
      ,[TradeDate]
      ,[DeliveryMonth]
      ,[FXRate]
      ,[Realised]
      ,[CashflowType]
      ,[InstrumentSubType]
      ,[Ticker]
      ,[SAP_Account]
      ,[LegalEntity]
      ,[Partner]
      ,[StKZ_zw1]
      ,[VAT_CountryCode]
      ,[LegEndDate]
      ,[UpdateKonten]
      ,[LZB]
		)
	SELECT (
			SELECT dd.AsOfDate_EOM
			FROM dbo.AsOfDate dd
			)
	  ,[group]
      ,[IntDesk]
      ,[ExtDesk]
      ,[Commodity]
      ,[OrderNo]
      ,[UNIT_TO]
      ,[Unit]
      ,[Volume_new]
      ,[Deal]
      ,[OffsetDealNumber]
      ,[Reference]
      ,[Tran Status]
      ,[InstrumentType]
      ,[InternalLegalEntity]
      ,[InternalBusinessUnit]
      ,[PfID]
      ,[InternalPortfolio]
      ,[ExternalBusinessUnit]
      ,[ExternalLegalEntity]
      ,[ExternalPortfolio]
      ,[Currency]
      ,[Action]
      ,[DocumentNumber]
      ,[EventDate]
      ,[TradeDate]
      ,[DeliveryMonth]
      ,[FXRate]
      ,[Realised]
      ,[CashflowType]
      ,[InstrumentSubType]
      ,[Ticker]
      ,[SAP_Account]
      ,[LegalEntity]
      ,[Partner]
      ,[StKZ_zw1]
      ,[VAT_CountryCode]
      ,[LegEndDate]
      ,[UpdateKonten]
      ,[LZB]
	FROM [FinRecon].[dbo].[table_PE2PE_with_matching_deals]

	SELECT @step = @step + 1

				--#10 and inster the curent data
	IF @LogInfo >= 1
	BEGIN
		INSERT INTO [dbo].[Logfile]
		SELECT 'Archive table_PE2PE_without_matching_deals'
			,GETDATE()
	END

	DELETE
	FROM [FinRecon].[dbo].[table_PE2PE_without_matching_deals_Archive]
	WHERE [AsOfDate] = (
			SELECT AsOfDate_EOM
			FROM dbo.AsOfDate
			)

	INSERT INTO [FinRecon].[dbo].[table_PE2PE_without_matching_deals_Archive] (
		[AsofDate]
	  ,[group]
      ,[IntDesk]
      ,[ExtDesk]
      ,[Commodity]
      ,[OrderNo]
      ,[UNIT_TO]
      ,[Unit]
      ,[Volume_new]
      ,[Deal]
      ,[OffsetDealNumber]
      ,[Reference]
      ,[Tran Status]
      ,[InstrumentType]
      ,[InternalLegalEntity]
      ,[InternalBusinessUnit]
      ,[PfID]
      ,[InternalPortfolio]
      ,[ExternalBusinessUnit]
      ,[ExternalLegalEntity]
      ,[ExternalPortfolio]
      ,[Currency]
      ,[Action]
      ,[DocumentNumber]
      ,[EventDate]
      ,[TradeDate]
      ,[DeliveryMonth]
      ,[FXRate]
      ,[Realised]
      ,[CashflowType]
      ,[InstrumentSubType]
      ,[Ticker]
      ,[SAP_Account]
      ,[LegalEntity]
      ,[Partner]
      ,[StKZ_zw1]
      ,[VAT_CountryCode]
      ,[LegEndDate]
      ,[UpdateKonten]
      ,[LZB]
		)
	SELECT (
			SELECT dd.AsOfDate_EOM
			FROM dbo.AsOfDate dd
			)
	  ,[group]
      ,[IntDesk]
      ,[ExtDesk]
      ,[Commodity]
      ,[OrderNo]
      ,[UNIT_TO]
      ,[Unit]
      ,[Volume_new]
      ,[Deal]
      ,[OffsetDealNumber]
      ,[Reference]
      ,[Tran Status]
      ,[InstrumentType]
      ,[InternalLegalEntity]
      ,[InternalBusinessUnit]
      ,[PfID]
      ,[InternalPortfolio]
      ,[ExternalBusinessUnit]
      ,[ExternalLegalEntity]
      ,[ExternalPortfolio]
      ,[Currency]
      ,[Action]
      ,[DocumentNumber]
      ,[EventDate]
      ,[TradeDate]
      ,[DeliveryMonth]
      ,[FXRate]
      ,[Realised]
      ,[CashflowType]
      ,[InstrumentSubType]
      ,[Ticker]
      ,[SAP_Account]
      ,[LegalEntity]
      ,[Partner]
      ,[StKZ_zw1]
      ,[VAT_CountryCode]
      ,[LegEndDate]
      ,[UpdateKonten]
      ,[LZB]
	FROM [FinRecon].[dbo].[table_PE2PE_without_matching_deals]

	SELECT @step = @step + 1

	IF @LogInfo >= 1
	BEGIN
		INSERT INTO [dbo].[Logfile]
		SELECT 'Archive_Clearer_DB_Tables - FINISHED'
			,GETDATE()
	END
END TRY

BEGIN CATCH
	--insert into [dbo].[Logfile] select 'ERROR-OCCURED', @TimeStamp
	BEGIN
		INSERT INTO [dbo].[Logfile]
		SELECT 'Archive_Clearer_DB_Tables - FAILED'
			,GETDATE()
	END

	EXEC [dbo].[usp_GetErrorInfo] @proc
		,@step
END CATCH

GO

