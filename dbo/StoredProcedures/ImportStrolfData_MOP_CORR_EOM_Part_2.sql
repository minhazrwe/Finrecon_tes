


















	CREATE PROCEDURE [dbo].[ImportStrolfData_MOP_CORR_EOM_Part_2] 
	AS
	BEGIN TRY

	DECLARE @proc nvarchar(40)
	DECLARE @step Integer
	DECLARE @LogInfo Integer
	DECLARE @COB_DATE as Date

	select @step = 1

	-- we need the LogInfo for Logging
	select @LogInfo = [dbo].[LogInfo].[LogInfo] from [dbo].[LogInfo]

	select @proc = '[dbo].[ImportStrolfData_MOP_CORR_EOM]'

	select @step = @step + 1
	if @LogInfo >= 1  BEGIN insert into [dbo].[Logfile] select 'Import Strolf Data_MOP_CORR EOM - Start Import Strolf Data MOP & CORR EOM', GETDATE () END

	if @LogInfo >= 1  BEGIN insert into [dbo].[Logfile] select 'Import Strolf Data_MOP_CORR EOM - fill [dbo].[Strolf_MOP_PLUS_REAL_CORR_EOM]', GETDATE () END

		truncate table [dbo].[Strolf_MOP_PLUS_REAL_CORR_EOM]

		select @COB_DATE = max(CoB) from  [ROCKCAO_CE].[CAO_CE].[XPORT].[FIN_MOP_PLUS_REAL_CORR]

		select @step = @step + 1

		--================================================================================================================================================================================
		--================================================================================================================================================================================

		/*fill table  [dbo].[Strolf_MOP_PLUS_REAL_CORR_EOM] */		
		insert into [dbo].[Strolf_MOP_PLUS_REAL_CORR_EOM] ([COB],[TRADE_DATE],[PORTFOLIO_NAME],[DESK],[REGION],[DEAL_NUM],[REALISATION_DATE],REALISATION_DATE_Original,[START_DATE],[END_DATE],[LAST_UPDATE],
					[OFFSET],[PNL_TYPE],[INS_TYPE_NAME],[EXT_BUNIT_NAME],[EXTERNAL_PORTFOLIO_NAME],[REFERENCE],[TYPE],[SUBTYPE],[DEAL_VOLUME],[PNL],[UNDISC_PNL],[UNDISC_PNL_ORIG_CCY],[LEG_CURRENCY])

		select		[COB],[TRADE_DATE],[PORTFOLIO_NAME],[DESK],[REGION],[DEAL_NUM],[REALISATION_DATE],[REAL_DATE_ORIG],[START_DATE],[END_DATE],[LAST_UPDATE],
					[OFFSET],[PNL_TYPE],[INS_TYPE_NAME],[EXT_BUNIT_NAME],[EXTERNAL_PORTFOLIO_NAME],[REFERENCE],[TYPE],[SUBTYPE],sum([DEAL_VOLUME]) as[DEAL_VOLUME] ,
					sum([PNL]) as [PNL] ,sum([UNDISC_PNL]) as [UNDISC_PNL],sum([UNDISC_PNL_ORIG_CCY]) as [UNDISC_PNL_ORIG_CCY],[LEG_CURRENCY] 

		from		[ROCKCAO_CE].[CAO_CE].[XPORT].[FIN_MOP_PLUS_REAL_CORR] where [COB] = @COB_DATE 

		group by	[COB],[TRADE_DATE],[PORTFOLIO_NAME],[DESK],[REGION],[DEAL_NUM],[REALISATION_DATE],[REAL_DATE_ORIG],[START_DATE],[END_DATE],[LAST_UPDATE],
					[OFFSET],[PNL_TYPE],[INS_TYPE_NAME],[EXT_BUNIT_NAME],[EXTERNAL_PORTFOLIO_NAME],[REFERENCE],[TYPE],[SUBTYPE],[LEG_CURRENCY]

		--================================================================================================================================================================================
		--================================================================================================================================================================================

		truncate table [dbo].[Strolf_MOP_PLUS_REAL_CORR_EOM_IS]

		insert into [dbo].[Strolf_MOP_PLUS_REAL_CORR_EOM_IS] ([COB],[TRADE_DATE],[PORTFOLIO_NAME],[DESK],[REGION],[DEAL_NUM],[REALISATION_DATE],REALISATION_DATE_Original,[START_DATE],[END_DATE],[LAST_UPDATE],
					[OFFSET],[PNL_TYPE],[INS_TYPE_NAME],[EXT_BUNIT_NAME],[EXTERNAL_PORTFOLIO_NAME],[REFERENCE],[TYPE],[SUBTYPE],[DEAL_VOLUME],[PNL],[UNDISC_PNL],[UNDISC_PNL_ORIG_CCY],[LEG_CURRENCY])
		select		[COB],[TRADE_DATE],[PORTFOLIO_NAME],[DESK],[REGION],[DEAL_NUM],[REALISATION_DATE],REALISATION_DATE_Original,[START_DATE],[END_DATE],[LAST_UPDATE],
					[OFFSET],[PNL_TYPE],[INS_TYPE_NAME],[EXT_BUNIT_NAME],[EXTERNAL_PORTFOLIO_NAME],[REFERENCE],[TYPE],[SUBTYPE],[DEAL_VOLUME],[PNL],[UNDISC_PNL],[UNDISC_PNL_ORIG_CCY],[LEG_CURRENCY]  
		from  [dbo].[Strolf_MOP_PLUS_REAL_CORR_EOM]
		where DESK  in ('CS_CFD_MM_CE','CS_CFD_MM_UK','CS_CFD_SF','CS_SPM_DUMMY','CS_SPM_LT','CS_SPM_ST','CS_SPM_TPB_BENE','CS_SPM_TPB_DE','CS_STRATEGIC','SCHED_BENE','SCHED_DE')

		delete from dbo.[Strolf_MOP_PLUS_REAL_CORR_EOM] where
		DESK  in ('CS_CFD_MM_CE','CS_CFD_MM_UK','CS_CFD_SF','CS_SPM_DUMMY','CS_SPM_LT','CS_SPM_ST','CS_SPM_TPB_BENE','CS_SPM_TPB_DE','CS_STRATEGIC','SCHED_BENE','SCHED_DE')

	if @LogInfo >= 1  BEGIN insert into [dbo].[Logfile] select 'Import Strolf Data_MOP_CORR EOM - Import Strolf Data MOP & CORR EOM has finished', GETDATE () END

END TRY

	BEGIN CATCH
		--insert into [dbo].[Logfile] select 'ERROR-OCCURED', @TimeStamp
		EXEC [dbo].[usp_GetErrorInfo] @proc, @step
	END CATCH

GO

