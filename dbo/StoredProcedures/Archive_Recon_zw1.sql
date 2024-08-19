



CREATE PROCEDURE [dbo].[Archive_Recon_zw1]

AS
BEGIN TRY

	DECLARE @LogInfo Integer
	DECLARE @proc nvarchar (40)
	DECLARE @step Integer

	select @step = 1
	select @proc = '[dbo].[Archive_Recon_zw1]'

	select @step = @step + 1
	select @LogInfo = [dbo].[LogInfo].[LogInfo] from [dbo].[LogInfo]

	select @step = @step + 1
	if @LogInfo >= 1  BEGIN insert into [dbo].[Logfile] select 'Archive_Recon_zw1 - START', GETDATE () END

	select @step = @step + 1
	-- delete data for rerun purposes
	delete from [dbo].[Recon_zw1_Archive] where [dbo].[Recon_zw1_Archive].[AsOfDate] =(Select AsOfDate_EOM from dbo.AsOfDate)

	select @step = @step + 1
	-- and inster the curent data
	insert into [dbo].[Recon_zw1_Archive] ([TimeOfArchiving]      ,[AsOfDate]       ,[Identifier]      ,[Source]      ,[InternalLegalEntity]      ,[ReconGroup]      ,[OrderNo]
      ,[DeliveryMonth]      ,[DealID_Recon]      ,[DealID]      ,[Portfolio]      ,[InternalBusinessUnit]      ,[CounterpartyGroup]      ,[InstrumentType]      ,[ProjIndexGroup]      ,[CurveName]
      ,[ExternalLegal]      ,[ExternalBusinessUnit]      ,[ExternalPortfolio]      ,[DocumentNumber]      ,[Reference]      ,[TranStatus]      ,[Action]      ,[TradeDate]      ,[EventDate]
      ,[Volume_Endur]      ,[Volume_SAP]      ,[Volume_Adj]      ,[UOM_Endur]      ,[UOM_SAP]      ,[ccy]      ,[realised_ccy_Endur]      ,[realised_ccy_SAP]      ,[realised_ccy_adj]      ,[Deskccy]
      ,[realised_Deskccy_Endur]      ,[realised_Deskccy_SAP]      ,[realised_Deskccy_adj]      ,[realised_EUR_Endur]      ,[realised_EUR_SAP]      ,[realised_EUR_SAP_conv]      ,[realised_EUR_adj]      ,[CashflowType]
      ,[Account_Endur]      ,[Account_SAP]      ,[DocumentNumber_SAP]      ,[DocumentType_SAP]      ,[Text_SAP]      ,[Reference_SAP]      ,[Adj_Category]      ,[Adj_Comment]
      ,[Partner]      ,[VAT_Script]      ,[VAT_SAP]      ,[VAT_CountryCode]      ,[Ticker]      ,[Material]      ,[DeliveryVesselName]      ,[StaticTicketID])
	select 
		GETDATE() as TimeOfArchiving, 
		convert(date,(Select [AsOfDate_EOM] from [dbo].[AsOfDate])) as AsOfDate     ,[Identifier]      ,[Source]      ,[InternalLegalEntity]      ,[ReconGroup]      ,[OrderNo]
      ,[DeliveryMonth]      ,[DealID_Recon]      ,[DealID]      ,[Portfolio]      ,[InternalBusinessUnit]      ,[CounterpartyGroup]      ,[InstrumentType]      ,[ProjIndexGroup]      ,[CurveName]
	  ,[ExternalLegal]      ,[ExternalBusinessUnit]      ,[ExternalPortfolio]      ,[DocumentNumber]      ,[Reference]      ,[TranStatus]      ,[Action]      ,[TradeDate]      ,[EventDate]
	  ,[Volume_Endur]      ,[Volume_SAP]      ,[Volume_Adj]      ,[UOM_Endur]      ,[UOM_SAP]      ,[ccy]      ,[realised_ccy_Endur]      ,[realised_ccy_SAP]      ,[realised_ccy_adj]      ,[Deskccy]
	  ,[realised_Deskccy_Endur]      ,[realised_Deskccy_SAP]      ,[realised_Deskccy_adj]      ,[realised_EUR_Endur]      ,[realised_EUR_SAP]      ,[realised_EUR_SAP_conv], [realised_EUR_adj]      ,[CashflowType]
	  ,[Account_Endur]      ,[Account_SAP]      ,[DocumentNumber_SAP],[DocumentType_SAP]      ,[Text_SAP]      ,[Reference_SAP]      ,[Adj_Category]      ,[Adj_Comment]
	  ,[Partner]      ,[VAT_Script]      ,[VAT_SAP]      ,[VAT_CountryCode],[Ticker]      ,[Material],[DeliveryVesselName],[StaticTicketID]
	from [dbo].[Recon_zw1]

	select @step = @step + 1
	if @LogInfo >= 1  BEGIN insert into [dbo].[Logfile] select 'Archive_Recon_zw1 - FINISHED', GETDATE () END

END TRY

	BEGIN CATCH
		--insert into [dbo].[Logfile] select 'ERROR-OCCURED', @TimeStamp
		BEGIN insert into [dbo].[Logfile] select 'Archive_Recon_zw1 - FAILED', GETDATE () END
		EXEC [dbo].[usp_GetErrorInfo] @proc, @step
	END CATCH

GO

