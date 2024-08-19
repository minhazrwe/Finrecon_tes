
/*
 =============================================
 Author:      MK
 Created:     2023-03
 Description:	Prepare data for D2D and PE2PE Recon to create BIMs in subsequent processes
 ---------------------------------------------
 updates:
 2024/01/16: renamed procedure from "Create_D2D_n_PE2PE_BIMs" to "Prepare_D2D_and_PE2PE_BIM" as BIM creation is done in different procedures and no linger in a view. (SU/mkb)
 2024/01/17: corrected step counting. (mkb)

 ==============================================
*/
CREATE PROCEDURE [dbo].[Prepare_D2D_and_PE2PE_BIM]
AS
BEGIN TRY

	DECLARE @step Integer
	DECLARE @proc nvarchar(50)
	DECLARE @LogInfo Integer
	DECLARE @LogEntry nvarchar(50)
	DECLARE @Main_Process nvarchar(100)
	DECLARE @Calling_Application nvarchar(100)
	DECLARE @Session_Key nvarchar(100)		
	DECLARE @COB date


	SELECT @Step = 0
	SELECT @proc = Object_Name(@@PROCID)
	SELECT @COB = AsOfDate_EOM FROM dbo.AsOfDate
	
  /* get Info if Logging is enabled */
	SELECT @LogInfo = [dbo].[LogInfo].[LogInfo] FROM [dbo].[LogInfo]

	-- IF @LogInfo >= 1  BEGIN INSERT INTO [dbo].[Logfile] SELECT @proc + ' - START', GETDATE () END

	-- ################################# PE2PE Part #################################
	
	-- IF @LogInfo >= 1  BEGIN INSERT INTO [dbo].[Logfile] SELECT @proc + ' - Creating temp_destatis_report table', GETDATE () END
	SELECT @step=5
	IF (EXISTS (SELECT * FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_SCHEMA = 'dbo' AND TABLE_NAME = 'table_PE2PE_realised_data'))
	BEGIN DROP TABLE [dbo].[table_PE2PE_realised_data] END

	SELECT @step = 10
	CREATE TABLE [dbo].[table_PE2PE_realised_data]
	([group] [varchar](100) NULL, [IntDesk] [varchar](100) NULL, [ExtDesk] [varchar](50) NULL, [Commodity] [varchar](100) NULL, [OrderNo] [varchar](100) NULL, [UNIT_TO] [varchar](100) NULL, [Unit] [varchar](100) NULL, [Volume_new] [float] NULL, [Deal] [varchar](100) NULL, [OffsetDealNumber] [int] NULL, [Reference] [varchar](100) NULL, [Tran Status] [varchar](100) NULL, [InstrumentType] [varchar](100) NULL, [InternalLegalEntity] [varchar](100) NULL, [InternalBusinessUnit] [varchar](100) NULL, [PfID] [varchar](100) NULL, [InternalPortfolio] [varchar](100) NULL, [ExternalBusinessUnit] [varchar](100) NULL, [ExternalLegalEntity] [varchar](100) NULL, [ExternalPortfolio] [varchar](100) NULL, [Currency] [varchar](5) NULL, [Action] [varchar](5) NULL, [DocumentNumber] [int] NULL, [EventDate] [varchar](100) NULL, [TradeDate] [datetime] NULL, [DeliveryMonth] [varchar](100) NULL, [FXRate] [float] NULL, [Realised] [numeric](20, 2) NULL, [CashflowType] [varchar](100) NULL, [InstrumentSubType] [varchar](100) NULL, [Ticker] [varchar](100) NULL, [SAP_Account] [varchar](100) NULL, [LegalEntity] [varchar](100) NULL, [Partner] [varchar](255) NULL, [StKZ_zw1] [varchar](255) NULL, [VAT_CountryCode] [varchar](255) NULL, [LegEndDate] [datetime] NULL, [UpdateKonten] [varchar](255) NULL, [LZB] [varchar](100) NULL)

	-- -- Fill Table with sap info and customer name via mapping
	SELECT @step = 20
	INSERT INTO [dbo].[table_PE2PE_realised_data]
		([group], [IntDesk], [ExtDesk], [Commodity], [OrderNo], [UNIT_TO], [Unit], [Volume_new], [Deal], [OffsetDealNumber], [Reference], [Tran Status], [InstrumentType], [InternalLegalEntity], [InternalBusinessUnit], [PfID], [InternalPortfolio], [ExternalBusinessUnit], [ExternalLegalEntity], [ExternalPortfolio], [Currency], [Action], [DocumentNumber], [EventDate], [TradeDate], [DeliveryMonth], [FXRate], [Realised], [CashflowType], [InstrumentSubType], [Ticker], [SAP_Account], [LegalEntity], [Partner], [StKZ_zw1], [VAT_CountryCode], [LegEndDate], [UpdateKonten], [LZB])
	SELECT 
			[group]
		,[IntDesk]
		,[map_order].[Desk] AS [ExtDesk]
		,[Commodity]
		,[02_Realised_all_details].[OrderNo]
		,[UNIT_TO]
		,[Unit]
		,[Volume_new]
		,[Deal]
		,[ER].[OffsetDealNumber]
		,[02_Realised_all_details].[Reference]
		,[Tran Status]
		,[02_Realised_all_details].[InstrumentType]
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
		,[02_Realised_all_details].[CashflowType]
		,[InstrumentSubType]
		,[Ticker]
		,[SAP_Account]
		,[02_Realised_all_details].[LegalEntity]
		,[Partner]
		,[StKZ_zw1]
		,[VAT_CountryCode]
		,[LegEndDate]
		,[UpdateKonten]
		,[map_LZB].[LZB]
		--,[FileID]
	FROM 
		dbo.[02_Realised_all_details]
		/*DealTrackingNumber und OffsetDealNumber are distinct in source. By writing them beneath each other, the whole data set can be matched. Otherwise only half of it could be matched.*/
		LEFT JOIN (	SELECT [DealTrackingNumber], [OffsetDealNumber] 
								FROM [FinRecon].[dbo].[Endur_References] 
							 UNION ALL 
								SELECT [OffsetDealNumber], [DealTrackingNumber] 
								FROM [FinRecon].[dbo].[Endur_References]) AS ER
		ON CONVERT(varchar, [02_Realised_all_details].[Deal]) = CONVERT(varchar, [ER].[DealTrackingNumber])

		LEFT JOIN [dbo].[map_order] 
		ON CONVERT(varchar, [02_Realised_all_details].[ExternalPortfolio]) = CONVERT(varchar, [map_order].[Portfolio])

		LEFT JOIN [FinRecon].[dbo].[map_LZB] AS [map_LZB]
		ON CONVERT(varchar, [02_Realised_all_details].[InstrumentType]) = CONVERT(varchar, [map_LZB].[InstrumentType])
			AND CONVERT(varchar, [02_Realised_all_details].[CashflowType]) = CONVERT(varchar, [map_LZB].[CashflowType])
			AND CONVERT(varchar, [02_Realised_all_details].[SAP_Account]) = CONVERT(varchar, [map_LZB].[Konto])
	WHERE 
		DeliveryMonth = FORMAT (@COB , 'yyyy/MM')
	/*
	--This combination should be removed when showing deals with matching counter deals, but shown if no match can be achieved.
	--AND NOT ([02_Realised_all_details].[InstrumentType] = 'GAS-STOR-P' AND [02_Realised_all_details].[CashflowType] IN ('None', 'Storage Withdrawl Fee', 'Virtual Point'))
	--Remove all entries where [Volume_new] AND [Realised] = 0
	*/
	AND NOT 
	(
		Volume_new = 0 
		AND 
		Realised = 0
	)
	AND [group] = 'InterPE'

	/*
	-- Create Table with matching deals and without
	-- -- Create temp table
	-- IF @LogInfo >= 1  BEGIN INSERT INTO [dbo].[Logfile] SELECT @proc + ' - Creating temp_destatis_report table', GETDATE () END
	*/
	SELECT @step = 30
	IF (EXISTS (SELECT * FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_SCHEMA = 'dbo' AND TABLE_NAME = 'table_PE2PE_with_matching_deals'))
	BEGIN DROP TABLE [dbo].[table_PE2PE_with_matching_deals] END
		IF (EXISTS (SELECT * FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_SCHEMA = 'dbo' AND TABLE_NAME = 'table_PE2PE_without_matching_deals'))
	BEGIN DROP TABLE [dbo].[table_PE2PE_without_matching_deals] END

	SELECT @step=40
	CREATE TABLE [dbo].[table_PE2PE_with_matching_deals]
	([group] [varchar](100) NULL, [IntDesk] [varchar](100) NULL, [ExtDesk] [varchar](50) NULL, [Commodity] [varchar](100) NULL, [OrderNo] [varchar](100) NULL, [UNIT_TO] [varchar](100) NULL, [Unit] [varchar](100) NULL, [Volume_new] [float] NULL, [Deal] [varchar](100) NULL, [OffsetDealNumber] [int] NULL, [Reference] [varchar](100) NULL, [Tran Status] [varchar](100) NULL, [InstrumentType] [varchar](100) NULL, [InternalLegalEntity] [varchar](100) NULL, [InternalBusinessUnit] [varchar](100) NULL, [PfID] [varchar](100) NULL, [InternalPortfolio] [varchar](100) NULL, [ExternalBusinessUnit] [varchar](100) NULL, [ExternalLegalEntity] [varchar](100) NULL, [ExternalPortfolio] [varchar](100) NULL, [Currency] [varchar](5) NULL, [Action] [varchar](5) NULL, [DocumentNumber] [int] NULL, [EventDate] [varchar](100) NULL, [TradeDate] [datetime] NULL, [DeliveryMonth] [varchar](100) NULL, [FXRate] [float] NULL, [Realised] [numeric](20, 2) NULL, [CashflowType] [varchar](100) NULL, [InstrumentSubType] [varchar](100) NULL, [Ticker] [varchar](100) NULL, [SAP_Account] [varchar](100) NULL, [LegalEntity] [varchar](100) NULL, [Partner] [varchar](255) NULL, [StKZ_zw1] [varchar](255) NULL, [VAT_CountryCode] [varchar](255) NULL, [LegEndDate] [datetime] NULL, [UpdateKonten] [varchar](255) NULL, [LZB] [varchar](100) NULL	)

	SELECT @step=50
	CREATE TABLE [dbo].[table_PE2PE_without_matching_deals]
	([group] [varchar](100) NULL, [IntDesk] [varchar](100) NULL, [ExtDesk] [varchar](50) NULL, [Commodity] [varchar](100) NULL, [OrderNo] [varchar](100) NULL, [UNIT_TO] [varchar](100) NULL, [Unit] [varchar](100) NULL, [Volume_new] [float] NULL, [Deal] [varchar](100) NULL, [OffsetDealNumber] [int] NULL, [Reference] [varchar](100) NULL, [Tran Status] [varchar](100) NULL, [InstrumentType] [varchar](100) NULL, [InternalLegalEntity] [varchar](100) NULL, [InternalBusinessUnit] [varchar](100) NULL, [PfID] [varchar](100) NULL, [InternalPortfolio] [varchar](100) NULL, [ExternalBusinessUnit] [varchar](100) NULL, [ExternalLegalEntity] [varchar](100) NULL, [ExternalPortfolio] [varchar](100) NULL, [Currency] [varchar](5) NULL, [Action] [varchar](5) NULL, [DocumentNumber] [int] NULL, [EventDate] [varchar](100) NULL, [TradeDate] [datetime] NULL, [DeliveryMonth] [varchar](100) NULL, [FXRate] [float] NULL, [Realised] [numeric](20, 2) NULL, [CashflowType] [varchar](100) NULL, [InstrumentSubType] [varchar](100) NULL, [Ticker] [varchar](100) NULL, [SAP_Account] [varchar](100) NULL, [LegalEntity] [varchar](100) NULL, [Partner] [varchar](255) NULL, [StKZ_zw1] [varchar](255) NULL, [VAT_CountryCode] [varchar](255) NULL, [LegEndDate] [datetime] NULL, [UpdateKonten] [varchar](255) NULL, [LZB] [varchar](100) NULL	)

	-- -- Fill Table with sap info and customer name via mapping
	-- IF @LogInfo >= 1  BEGIN INSERT INTO [dbo].[Logfile] SELECT @proc + ' - Filling temp_destatis_report table with SAP data and matching customer name', GETDATE () END
	SELECT @step =60
	INSERT INTO [dbo].[table_PE2PE_with_matching_deals]
	([group], [IntDesk], [ExtDesk], [Commodity], [OrderNo], [UNIT_TO], [Unit], [Volume_new], [Deal], [OffsetDealNumber], [Reference], [Tran Status], [InstrumentType], [InternalLegalEntity], [InternalBusinessUnit], [PfID], [InternalPortfolio], [ExternalBusinessUnit], [ExternalLegalEntity], [ExternalPortfolio], [Currency], [Action], [DocumentNumber], [EventDate], [TradeDate], [DeliveryMonth], [FXRate], [Realised], [CashflowType], [InstrumentSubType], [Ticker], [SAP_Account], [LegalEntity], [Partner], [StKZ_zw1], [VAT_CountryCode], [LegEndDate], [UpdateKonten], [LZB])
	SELECT [group], [IntDesk], [ExtDesk], [Commodity], [OrderNo], [UNIT_TO], [Unit], [Volume_new], [Deal], [OffsetDealNumber], [Reference], [Tran Status], [InstrumentType], [InternalLegalEntity], [InternalBusinessUnit], [PfID], [InternalPortfolio], [ExternalBusinessUnit], [ExternalLegalEntity], [ExternalPortfolio], [Currency], [Action], [DocumentNumber], [EventDate], [TradeDate], [DeliveryMonth], [FXRate], [Realised], [CashflowType], [InstrumentSubType], [Ticker], [SAP_Account], [LegalEntity], [Partner], [StKZ_zw1], [VAT_CountryCode], [LegEndDate], [UpdateKonten], [LZB]
	FROM [FinRecon].[dbo].[table_PE2PE_realised_data]
	WHERE [OffsetDealNumber] IS NOT NULL
	--This combination should be removed when showing deals with matching counter deals, but shown if no match can be achieved.
	AND NOT ([InstrumentType] = 'GAS-STOR-P' AND [CashflowType] IN ('None', 'Settlement', 'Virtual Point'))

	SELECT @step = 70
	INSERT INTO [dbo].[table_PE2PE_without_matching_deals]
	([group], [IntDesk], [ExtDesk], [Commodity], [OrderNo], [UNIT_TO], [Unit], [Volume_new], [Deal], [OffsetDealNumber], [Reference], [Tran Status], [InstrumentType], [InternalLegalEntity], [InternalBusinessUnit], [PfID], [InternalPortfolio], [ExternalBusinessUnit], [ExternalLegalEntity], [ExternalPortfolio], [Currency], [Action], [DocumentNumber], [EventDate], [TradeDate], [DeliveryMonth], [FXRate], [Realised], [CashflowType], [InstrumentSubType], [Ticker], [SAP_Account], [LegalEntity], [Partner], [StKZ_zw1], [VAT_CountryCode], [LegEndDate], [UpdateKonten], [LZB])
	SELECT [group], [IntDesk], [ExtDesk], [Commodity], [OrderNo], [UNIT_TO], [Unit], [Volume_new], [Deal], [OffsetDealNumber], [Reference], [Tran Status], [InstrumentType], [InternalLegalEntity], [InternalBusinessUnit], [PfID], [InternalPortfolio], [ExternalBusinessUnit], [ExternalLegalEntity], [ExternalPortfolio], [Currency], [Action], [DocumentNumber], [EventDate], [TradeDate], [DeliveryMonth], [FXRate], [Realised], [CashflowType], [InstrumentSubType], [Ticker], [SAP_Account], [LegalEntity], [Partner], [StKZ_zw1], [VAT_CountryCode], [LegEndDate], [UpdateKonten], [LZB]
	FROM [FinRecon].[dbo].[table_PE2PE_realised_data]
	--Remove Deals with no match
	WHERE [OffsetDealNumber] IS NULL


	/*Create BIMs*/
	/*PRINT 'BIMs can be examined in [dbo].[view_PE2PE_BIM].'*/
	

	-- ################################# D2D Part #################################

	-- IF @LogInfo >= 1  BEGIN INSERT INTO [dbo].[Logfile] SELECT @proc + ' - Creating temp_destatis_report table', GETDATE () END
	SELECT @step=80
	IF (EXISTS (SELECT * FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_SCHEMA = 'dbo' AND TABLE_NAME = 'table_D2D_realised_data'))
	BEGIN DROP TABLE [dbo].[table_D2D_realised_data] END

	SELECT @step=90
	CREATE TABLE [dbo].[table_D2D_realised_data]
	([group] [varchar](100) NULL, [IntDesk] [varchar](100) NULL, [ExtDesk] [varchar](50) NULL, [Commodity] [varchar](100) NULL, [OrderNo] [varchar](100) NULL, [UNIT_TO] [varchar](100) NULL, [Unit] [varchar](100) NULL, [Volume_new] [float] NULL, [Deal] [varchar](100) NULL, [OffsetDealNumber] [int] NULL, [Reference] [varchar](100) NULL, [Tran Status] [varchar](100) NULL, [InstrumentType] [varchar](100) NULL, [InternalLegalEntity] [varchar](100) NULL, [InternalBusinessUnit] [varchar](100) NULL, [PfID] [varchar](100) NULL, [InternalPortfolio] [varchar](100) NULL, [ExternalBusinessUnit] [varchar](100) NULL, [ExternalLegalEntity] [varchar](100) NULL, [ExternalPortfolio] [varchar](100) NULL, [Currency] [varchar](5) NULL, [Action] [varchar](5) NULL, [DocumentNumber] [int] NULL, [EventDate] [varchar](100) NULL, [TradeDate] [datetime] NULL, [DeliveryMonth] [varchar](100) NULL, [FXRate] [float] NULL, [Realised] [numeric](20, 2) NULL, [CashflowType] [varchar](100) NULL, [InstrumentSubType] [varchar](100) NULL, [Ticker] [varchar](100) NULL, [SAP_Account] [varchar](100) NULL, [LegalEntity] [varchar](100) NULL, [Partner] [varchar](255) NULL, [StKZ_zw1] [varchar](255) NULL, [VAT_CountryCode] [varchar](255) NULL, [LegEndDate] [datetime] NULL, [UpdateKonten] [varchar](255) NULL)

	-- -- Fill Table with sap info and customer name via mapping
	-- IF @LogInfo >= 1  BEGIN INSERT INTO [dbo].[Logfile] SELECT @proc + ' - Filling temp_destatis_report table with SAP data and matching customer name', GETDATE () END
	SELECT @step = 100
	INSERT INTO [dbo].[table_D2D_realised_data]
	([group], [IntDesk], [ExtDesk], [Commodity], [OrderNo], [UNIT_TO], [Unit], [Volume_new], [Deal], [OffsetDealNumber], [Reference], [Tran Status], [InstrumentType], [InternalLegalEntity], [InternalBusinessUnit], [PfID], [InternalPortfolio], [ExternalBusinessUnit], [ExternalLegalEntity], [ExternalPortfolio], [Currency], [Action], [DocumentNumber], [EventDate], [TradeDate], [DeliveryMonth], [FXRate], [Realised], [CashflowType], [InstrumentSubType], [Ticker], [SAP_Account], [LegalEntity], [Partner], [StKZ_zw1], [VAT_CountryCode], [LegEndDate], [UpdateKonten])
	SELECT [group]
	,[IntDesk]
	,[map_order].[Desk] AS [ExtDesk]
	,[Commodity]
	,[02_Realised_all_details].[OrderNo]
	,[UNIT_TO]
	,[Unit]
	,[Volume_new]
	,[Deal]
	,[ER].[OffsetDealNumber]
	,[02_Realised_all_details].[Reference]
	,[Tran Status]
	,[02_Realised_all_details].[InstrumentType]
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
	,[02_Realised_all_details].[CashflowType]
	,[InstrumentSubType]
	,[Ticker]
	,[SAP_Account]
	,[02_Realised_all_details].[LegalEntity]
	,[Partner]
	,[StKZ_zw1]
	,[VAT_CountryCode]
	,[LegEndDate]
	,[UpdateKonten]
	--,[FileID]
	FROM 
	[FinRecon].[dbo].[02_Realised_all_details] 
	/*DealTrackingNumber und OffsetDealNumber are distinct in source. 
	By writing them beneath each other, the whole data set can be matched. 
	Otherwise only half of it could be matched.*/
	LEFT JOIN (	SELECT DealTrackingNumber, OffsetDealNumber FROM dbo.Endur_References 
						UNION ALL 
							SELECT OffsetDealNumber, DealTrackingNumber FROM dbo.Endur_References
						) AS ER
						ON CONVERT(varchar, [02_Realised_all_details].Deal) = CONVERT(varchar, ER.DealTrackingNumber)
	LEFT JOIN map_order 
	ON CONVERT(varchar, [02_Realised_all_details].[ExternalPortfolio]) = CONVERT(varchar, [map_order].[Portfolio])
	WHERE 
		DeliveryMonth = FORMAT (@COB, 'yyyy/MM')
	/*
	--This combination should be removed when showing deals with matching counter deals, but shown if no match can be achieved.
	--AND NOT ([02_Realised_all_details].[InstrumentType] = 'GAS-STOR-P' AND [02_Realised_all_details].[CashflowType] IN ('None', 'Storage Withdrawl Fee', 'Virtual Point'))
	*/
	AND NOT ([Volume_new] = 0 AND [Realised] = 0)
	AND [group] = 'Intradesk'
	AND [02_Realised_all_details].[ExternalLegalEntity] <> 'Dummy'


	--AND [InternalLegalEntity] = 'RWEST DE - PE' /* THIS LINE WAS COMMENTED FOR HARMONISATION PURPOSE */

	SELECT @step=110
	SELECT @LogEntry = 'Drop and re-create tables with matching deals and without' 
	EXECUTE dbo.Write_Log 'Info', @LogEntry, @proc , @Main_Process, @Calling_Application, @step, 1, @Session_Key	

	IF (EXISTS (SELECT * FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_SCHEMA = 'dbo' AND TABLE_NAME = 'table_D2D_with_matching_deals'))
	BEGIN DROP TABLE [dbo].[table_D2D_with_matching_deals] END
		IF (EXISTS (SELECT * FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_SCHEMA = 'dbo' AND TABLE_NAME = 'table_D2D_without_matching_deals'))
	BEGIN DROP TABLE [dbo].[table_D2D_without_matching_deals] END

	SELECT @step=120
	CREATE TABLE [dbo].[table_D2D_with_matching_deals]
	([group] [varchar](100) NULL, [IntDesk] [varchar](100) NULL, [ExtDesk] [varchar](50) NULL, [Commodity] [varchar](100) NULL, [OrderNo] [varchar](100) NULL, [UNIT_TO] [varchar](100) NULL, [Unit] [varchar](100) NULL, [Volume_new] [float] NULL, [Deal] [varchar](100) NULL, [OffsetDealNumber] [int] NULL, [Reference] [varchar](100) NULL, [Tran Status] [varchar](100) NULL, [InstrumentType] [varchar](100) NULL, [InternalLegalEntity] [varchar](100) NULL, [InternalBusinessUnit] [varchar](100) NULL, [PfID] [varchar](100) NULL, [InternalPortfolio] [varchar](100) NULL, [ExternalBusinessUnit] [varchar](100) NULL, [ExternalLegalEntity] [varchar](100) NULL, [ExternalPortfolio] [varchar](100) NULL, [Currency] [varchar](5) NULL, [Action] [varchar](5) NULL, [DocumentNumber] [int] NULL, [EventDate] [varchar](100) NULL, [TradeDate] [datetime] NULL, [DeliveryMonth] [varchar](100) NULL, [FXRate] [float] NULL, [Realised] [numeric](20, 2) NULL, [CashflowType] [varchar](100) NULL, [InstrumentSubType] [varchar](100) NULL, [Ticker] [varchar](100) NULL, [SAP_Account] [varchar](100) NULL, [LegalEntity] [varchar](100) NULL, [Partner] [varchar](255) NULL, [StKZ_zw1] [varchar](255) NULL, [VAT_CountryCode] [varchar](255) NULL, [LegEndDate] [datetime] NULL, [UpdateKonten] [varchar](255) NULL)

	SELECT @step=130
	CREATE TABLE [dbo].[table_D2D_without_matching_deals]
	([group] [varchar](100) NULL, [IntDesk] [varchar](100) NULL, [ExtDesk] [varchar](50) NULL, [Commodity] [varchar](100) NULL, [OrderNo] [varchar](100) NULL, [UNIT_TO] [varchar](100) NULL, [Unit] [varchar](100) NULL, [Volume_new] [float] NULL, [Deal] [varchar](100) NULL, [OffsetDealNumber] [int] NULL, [Reference] [varchar](100) NULL, [Tran Status] [varchar](100) NULL, [InstrumentType] [varchar](100) NULL, [InternalLegalEntity] [varchar](100) NULL, [InternalBusinessUnit] [varchar](100) NULL, [PfID] [varchar](100) NULL, [InternalPortfolio] [varchar](100) NULL, [ExternalBusinessUnit] [varchar](100) NULL, [ExternalLegalEntity] [varchar](100) NULL, [ExternalPortfolio] [varchar](100) NULL, [Currency] [varchar](5) NULL, [Action] [varchar](5) NULL, [DocumentNumber] [int] NULL, [EventDate] [varchar](100) NULL, [TradeDate] [datetime] NULL, [DeliveryMonth] [varchar](100) NULL, [FXRate] [float] NULL, [Realised] [numeric](20, 2) NULL, [CashflowType] [varchar](100) NULL, [InstrumentSubType] [varchar](100) NULL, [Ticker] [varchar](100) NULL, [SAP_Account] [varchar](100) NULL, [LegalEntity] [varchar](100) NULL, [Partner] [varchar](255) NULL, [StKZ_zw1] [varchar](255) NULL, [VAT_CountryCode] [varchar](255) NULL, [LegEndDate] [datetime] NULL, [UpdateKonten] [varchar](255) NULL)

	
	SELECT @step = 140
	SELECT @LogEntry = 'Fill Table with sap info and customer name via mapping' 
	EXECUTE [dbo].[Write_Log] 'Info', @LogEntry, @proc , @Main_Process, @Calling_Application, @step, 1, @Session_Key	

	INSERT INTO [dbo].[table_D2D_with_matching_deals]
	([group], [IntDesk], [ExtDesk], [Commodity], [OrderNo], [UNIT_TO], [Unit], [Volume_new], [Deal], [OffsetDealNumber], [Reference], [Tran Status], [InstrumentType], [InternalLegalEntity], [InternalBusinessUnit], [PfID], [InternalPortfolio], [ExternalBusinessUnit], [ExternalLegalEntity], [ExternalPortfolio], [Currency], [Action], [DocumentNumber], [EventDate], [TradeDate], [DeliveryMonth], [FXRate], [Realised], [CashflowType], [InstrumentSubType], [Ticker], [SAP_Account], [LegalEntity], [Partner], [StKZ_zw1], [VAT_CountryCode], [LegEndDate], [UpdateKonten])
	SELECT [group], [IntDesk], [ExtDesk], [Commodity], [OrderNo], [UNIT_TO], [Unit], [Volume_new], [Deal], [OffsetDealNumber], [Reference], [Tran Status], [InstrumentType], [InternalLegalEntity], [InternalBusinessUnit], [PfID], [InternalPortfolio], [ExternalBusinessUnit], [ExternalLegalEntity], [ExternalPortfolio], [Currency], [Action], [DocumentNumber], [EventDate], [TradeDate], [DeliveryMonth], [FXRate], [Realised], [CashflowType], [InstrumentSubType], [Ticker], [SAP_Account], [LegalEntity], [Partner], [StKZ_zw1], [VAT_CountryCode], [LegEndDate], [UpdateKonten]
	FROM [FinRecon].[dbo].[table_D2D_realised_data]
	WHERE [OffsetDealNumber] IS NOT NULL
	--This combination should be removed when showing deals with matching counter deals, but shown if no match can be achieved.
	AND NOT ([InstrumentType] = 'GAS-STOR-P' AND [CashflowType] IN ('None', 'Settlement', 'Virtual Point'))
	AND NOT ([OrderNo] = 'n/a' OR [SAP_Account] = 'n/a' OR [ExtDesk] = 'n/a')
	AND NOT [ExternalPortfolio] IN ('Dummy','zDontUse_PHYS_BUNKER_ROLL')

	SELECT @step = 150
	INSERT INTO [dbo].[table_D2D_without_matching_deals]
	([group], [IntDesk], [ExtDesk], [Commodity], [OrderNo], [UNIT_TO], [Unit], [Volume_new], [Deal], [OffsetDealNumber], [Reference], [Tran Status], [InstrumentType], [InternalLegalEntity], [InternalBusinessUnit], [PfID], [InternalPortfolio], [ExternalBusinessUnit], [ExternalLegalEntity], [ExternalPortfolio], [Currency], [Action], [DocumentNumber], [EventDate], [TradeDate], [DeliveryMonth], [FXRate], [Realised], [CashflowType], [InstrumentSubType], [Ticker], [SAP_Account], [LegalEntity], [Partner], [StKZ_zw1], [VAT_CountryCode], [LegEndDate], [UpdateKonten])
	SELECT [group], [IntDesk], [ExtDesk], [Commodity], [OrderNo], [UNIT_TO], [Unit], [Volume_new], [Deal], [OffsetDealNumber], [Reference], [Tran Status], [InstrumentType], [InternalLegalEntity], [InternalBusinessUnit], [PfID], [InternalPortfolio], [ExternalBusinessUnit], [ExternalLegalEntity], [ExternalPortfolio], [Currency], [Action], [DocumentNumber], [EventDate], [TradeDate], [DeliveryMonth], [FXRate], [Realised], [CashflowType], [InstrumentSubType], [Ticker], [SAP_Account], [LegalEntity], [Partner], [StKZ_zw1], [VAT_CountryCode], [LegEndDate], [UpdateKonten]
	FROM [FinRecon].[dbo].[table_D2D_realised_data]
	--Remove Deals with no match
	WHERE [OffsetDealNumber] IS NULL

	SELECT @step = 200
	SELECT @LogEntry = 'FINISHED' 
	EXECUTE [dbo].[Write_Log] 'Info', @LogEntry, @proc , @Main_Process, @Calling_Application, @step, 1, @Session_Key		
	
END TRY

BEGIN CATCH
	EXEC [dbo].[usp_GetErrorInfo] @proc , @step
	SELECT @LogEntry = 'FAILED WITH ERROR !' 
	EXECUTE [dbo].[Write_Log] 'ERROR', @LogEntry, @proc , @Main_Process, @Calling_Application, @step, 1, @Session_Key		
END CATCH

GO

