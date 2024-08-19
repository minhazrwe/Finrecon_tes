




CREATE  PROCEDURE [dbo].[Archive_Risk_Recon]

AS
BEGIN TRY

	DECLARE @LogInfo Integer
	DECLARE @proc nvarchar (40)
	DECLARE @step Integer
	DECLARE @AsOfDate datetime

	select @step = 1
	select @proc = '[dbo].[Archive_Risk_Recon]'

	select @step = @step + 1
	select @LogInfo = [dbo].[LogInfo].[LogInfo] from [dbo].[LogInfo]

	select @step = @step + 1
	if @LogInfo >= 1  BEGIN insert into [dbo].[Logfile] select 'Archive_RiskRecon - start Archive Risk_Recon', GETDATE () END

	select @step = @step + 1
	select @AsOfDate = [AsOfDate_EOM] from [dbo].[AsOfDate] 

	select @step = @step + 1
	-- delete data for rerun purposes
	delete from [dbo].[RiskRecon_Archive] where [dbo].[RiskRecon_Archive].[AsOfDate] = @AsOfDate

	select @step = @step + 1
	-- and inster the curent data
	insert into [dbo].[RiskRecon_Archive] ([AsOfDate], [InternalLegalEntity]      ,[Desk]      ,[Subdesk]      ,[SubdeskCCY]      ,[Portfolio]      ,[InstrumentType]      ,[DealID], [Ticker]      ,[ExtBunitName],[ccy]      ,[TradeDate]      ,[EndDate]      ,[finance_mtm_EOM]
      ,[finance_mtm_EOY]      ,[finance_mtm_EOM_DeskCCY]      ,[finance_mtm_EOY_DeskCCY]      ,[finance_realised_CCY]      ,[finance_realised_DeskCCY]      ,[finance_realised_EUR]      ,[risk_mtm_EOM_EUR]      ,[risk_mtm_EOM_RepCCY]
      ,[risk_mtm_EOM_RepEUR]      ,[risk_mtm_EOY_EUR]      ,[risk_mtm_EOY_RepCCY]      ,[risk_mtm_EOY_RepEUR]      ,[risk_realised_disc_EUR]      ,[risk_realised_disc_RepCCY]      ,[risk_realised_disc_RepEUR]
      ,[risk_realised_undisc_CCY])
	SELECT  @AsOfDate, [InternalLegalEntity]      ,[Desk]      ,[Subdesk]      ,[SubdeskCCY]      ,[Portfolio]      ,[InstrumentType]      ,[DealID], [Ticker]      ,[ExtBunitName],[ccy]      ,[TradeDate]      ,[EndDate]      ,[finance_mtm_EOM]
      ,[finance_mtm_EOY]      ,[finance_mtm_EOM_DeskCCY]      ,[finance_mtm_EOY_DeskCCY]      ,[finance_realised_CCY]      ,[finance_realised_DeskCCY]      ,[finance_realised_EUR]      ,[risk_mtm_EOM_EUR]      ,[risk_mtm_EOM_RepCCY]
      ,[risk_mtm_EOM_RepEUR]      ,[risk_mtm_EOY_EUR]      ,[risk_mtm_EOY_RepCCY]      ,[risk_mtm_EOY_RepEUR]      ,[risk_realised_disc_EUR]      ,[risk_realised_disc_RepCCY]      ,[risk_realised_disc_RepEUR]
      ,[risk_realised_undisc_CCY]
  FROM [dbo].[RiskRecon]

	select @step = @step + 1
	if @LogInfo >= 1  BEGIN insert into [dbo].[Logfile] select 'Archive_RiskRecon - end Archive Risk_Recon', GETDATE () END

END TRY

	BEGIN CATCH
		--insert into [dbo].[Logfile] select 'ERROR-OCCURED', @TimeStamp
		EXEC [dbo].[usp_GetErrorInfo] @proc, @step
	END CATCH

GO

