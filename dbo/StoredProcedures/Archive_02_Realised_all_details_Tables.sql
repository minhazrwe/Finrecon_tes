




CREATE PROCEDURE [dbo].[Archive_02_Realised_all_details_Tables]

AS
BEGIN TRY

	DECLARE @LogInfo Integer
	DECLARE @proc nvarchar (40)
	DECLARE @step Integer

	select @step = 1
	select @proc = '[dbo].[Archive_02_Realised_all_details_Tables]'

	select @step = @step + 1
	select @LogInfo = [dbo].[LogInfo].[LogInfo] from [dbo].[LogInfo]

	select @step = @step + 1
	if @LogInfo >= 1  BEGIN insert into [dbo].[Logfile] select @proc + ' - START', GETDATE () END

	select @step = @step + 1
	-- delete data for rerun purposes
	delete from [dbo].[02_Realised_all_details_Archive] where [dbo].[02_Realised_all_details_Archive].[AsOfDate] =(Select AsOfDate_EOM from dbo.AsOfDate)

	select @step = @step + 1
	-- and inster the curent data
	insert into [dbo].[02_Realised_all_details_Archive] ([TimeOfArchiving],[AsOfDate],[group],[ctpygroup],[IntDesk],[Commodity],[OrderNo],[UNIT_TO],[Volume_new],[Deal],[Reference],[Tran Status],[Toolset],[InstrumentType],[Group ID],[InternalLegalEntity],[InternalBusinessUnit],[PfID],[InternalPortfolio],[Pf Group],[ExternalBusinessUnit],[ExternalLegalEntity],[ExternalPortfolio],[ProjectionIndex],[Currency],[Action],[Volume],[Unit],[DocumentNumber],[EventDate],[TradeDate],[CashflowDeliveryMonth],[DeliveryMonth],[FXRate],[Realised],[RealisedBase],[CashflowType],[InstrumentSubType],[PowerRegion],[Pipeline],[Delivery Vessel Name],[Static Ticket ID],[DiscountingIndex],[Ticker],[TradePrice],[LiquidityReport_ccy],[SAP_Account],[Realized_CCY_Futures],[Ref3],[LegalEntity],[Partner],[StKZ_zw1],[StKZ],[VAT_CountryCode],[Desk Currency],[Realized_YTD_EUR_disc],[Realised_DeskCCY_disc],[Realized_YTD_GBP_disc],[Realized_YTD_USD_disc],[Realized_YTD_EUR_undisc],[Realised_DeskCCY_Undisc],[Realized_YTD_GBP_undisc],[Realized_YTD_USD_undisc],[LegExerciseDate],[LegEndDate],[UpdateKonten],[FileID])
	select 
		GETDATE() as TimeOfArchiving, 
		convert(date,(Select [AsOfDate_EOM] from [dbo].[AsOfDate])) as AsOfDate     ,[group],[ctpygroup],[IntDesk],[Commodity],[OrderNo],[UNIT_TO],[Volume_new],[Deal],[Reference],[Tran Status],[Toolset],[InstrumentType],[Group ID],[InternalLegalEntity],[InternalBusinessUnit],[PfID],[InternalPortfolio],[Pf Group],[ExternalBusinessUnit],[ExternalLegalEntity],[ExternalPortfolio],[ProjectionIndex],[Currency],[Action],[Volume],[Unit],[DocumentNumber],[EventDate],[TradeDate],[CashflowDeliveryMonth],[DeliveryMonth],[FXRate],[Realised],[RealisedBase],[CashflowType],[InstrumentSubType],[PowerRegion],[Pipeline],[Delivery Vessel Name],[Static Ticket ID],[DiscountingIndex],[Ticker],[TradePrice],[LiquidityReport_ccy],[SAP_Account],[Realized_CCY_Futures],[Ref3],[LegalEntity],[Partner],[StKZ_zw1],[StKZ],[VAT_CountryCode],[Desk Currency],[Realized_YTD_EUR_disc],[Realised_DeskCCY_disc],[Realized_YTD_GBP_disc],[Realized_YTD_USD_disc],[Realized_YTD_EUR_undisc],[Realised_DeskCCY_Undisc],[Realized_YTD_GBP_undisc],[Realized_YTD_USD_undisc],[LegExerciseDate],[LegEndDate],[UpdateKonten],[FileID]	
	from [dbo].[02_Realised_all_details]

	select @step = @step + 1
	if @LogInfo >= 1  BEGIN insert into [dbo].[Logfile] select @proc + ' - FINISHED', GETDATE () END

END TRY

	BEGIN CATCH
		--insert into [dbo].[Logfile] select 'ERROR-OCCURED', @TimeStamp
		BEGIN insert into [dbo].[Logfile] select @proc + ' - FAILED', GETDATE () END
		EXEC [dbo].[usp_GetErrorInfo] @proc, @step
	END CATCH

GO

