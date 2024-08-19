



















	CREATE PROCEDURE [dbo].[ImportStrolfData_MOP_CORR_EOM_Part_1] 
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
	if @LogInfo >= 1  BEGIN insert into [dbo].[Logfile] select 'Import Strolf Data_MOP_CORR EOM - Start Import Strolf Data MOP & CORR EOM IRS', GETDATE () END

		select @COB_DATE = max(CoB) from  [ROCKCAO_CE].[CAO_CE].[XPORT].[FIN_MOP_PLUS_REAL_CORR]

		--================================================================================================================================================================================

		--================================================================================================================================================================================
		--================================================================================================================================================================================
		--================================================================================================================================================================================

		/*same as [dbo].[Strolf_MOP_PLUS_REAL_CORR_EOM] with additional field "PNL_TYPE_Orig" */
		if (exists (SELECT * FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_NAME = 'FIN_MOP_PLUS_REAL_CORR_mit_PNL_TYPE_ORIG'))
		BEGIN
			drop table [dbo].[FIN_MOP_PLUS_REAL_CORR_mit_PNL_TYPE_ORIG]
		END
		

		select		[COB],[TRADE_DATE],[PORTFOLIO_NAME],[DESK],[REGION],[DEAL_NUM],[REALISATION_DATE],[REAL_DATE_ORIG],[START_DATE],[END_DATE],[LAST_UPDATE],
					[OFFSET],	[PNL_TYPE],[PNL_TYPE_Orig],[INS_TYPE_NAME],[EXT_BUNIT_NAME],[EXTERNAL_PORTFOLIO_NAME],[REFERENCE],[TYPE],[SUBTYPE],[DEAL_VOLUME],
					[PNL],[UNDISC_PNL],[UNDISC_PNL_ORIG_CCY],[LEG_CURRENCY] 

		into		dbo.[FIN_MOP_PLUS_REAL_CORR_mit_PNL_TYPE_ORIG]

		from		[ROCKCAO_CE].[CAO_CE].[XPORT].[FIN_MOP_PLUS_REAL_CORR] where [COB] = @COB_DATE
			

		/*update, to reflect correct setting in field "PNL_TYPE" for all instrument_types 'IRS'*/
		update dbo.[FIN_MOP_PLUS_REAL_CORR_mit_PNL_TYPE_ORIG] SET PNL_TYPE = PNL_TYPE_ORIG  WHERE ins_type_name like 'IRS' 


		--================================================================================================================================================================================
		--================================================================================================================================================================================

		/*[dbo].[FIN_MOP_PLUS_REAL_CORR_mit_PNL_TYPE_ORIG] summed up with corrected pnl_type, will later on replace "[Strolf_MOP_PLUS_REAL_CORR_EOM]"*/
		--drop table [dbo].[FIN_MOP_PLUS_REAL_CORR_mit_PNL_TYPE_ORIG_SUMMIERT]

		if (exists (SELECT * FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_NAME = 'FIN_MOP_PLUS_REAL_CORR_mit_PNL_TYPE_ORIG_SUMMIERT'))
		BEGIN
			drop table [dbo].[FIN_MOP_PLUS_REAL_CORR_mit_PNL_TYPE_ORIG_SUMMIERT]
		END

		 select [COB],[TRADE_DATE],[PORTFOLIO_NAME],[DESK],[REGION],[DEAL_NUM],[REALISATION_DATE],REAL_DATE_ORIG as REALISATION_DATE_Original,[START_DATE],[END_DATE],[LAST_UPDATE],
				[OFFSET],[PNL_TYPE],[INS_TYPE_NAME],[EXT_BUNIT_NAME],[EXTERNAL_PORTFOLIO_NAME],[REFERENCE],[TYPE],[SUBTYPE],sum([DEAL_VOLUME]) as[DEAL_VOLUME] ,
			   sum([PNL]) as [PNL] ,sum([UNDISC_PNL]) as [UNDISC_PNL],sum([UNDISC_PNL_ORIG_CCY]) as [UNDISC_PNL_ORIG_CCY],[LEG_CURRENCY] 
		into dbo.[FIN_MOP_PLUS_REAL_CORR_mit_PNL_TYPE_ORIG_SUMMIERT]
		from [ROCKCAO_CE].[CAO_CE].[XPORT].[FIN_MOP_PLUS_REAL_CORR] where [COB] = @COB_DATE 
		group by [COB],[TRADE_DATE],[PORTFOLIO_NAME],[DESK],[REGION],[DEAL_NUM],[REALISATION_DATE],[REAL_DATE_ORIG],[START_DATE],[END_DATE],[LAST_UPDATE],
				 [OFFSET],[PNL_TYPE],[INS_TYPE_NAME],[EXT_BUNIT_NAME],[EXTERNAL_PORTFOLIO_NAME],[REFERENCE],[TYPE],[SUBTYPE],[LEG_CURRENCY]
		
		delete from [FIN_MOP_PLUS_REAL_CORR_mit_PNL_TYPE_ORIG_SUMMIERT]
		where DESK  in ('CS_CFD_MM_CE','CS_CFD_MM_UK','CS_CFD_SF','CS_SPM_DUMMY','CS_SPM_LT','CS_SPM_ST','CS_SPM_TPB_BENE','CS_SPM_TPB_DE','CS_STRATEGIC','SCHED_BENE','SCHED_DE')

		--================================================================================================================================================================================

		truncate table [dbo].[Strolf_IS_EUR_EOM]
		
		insert into [dbo].[Strolf_IS_EUR_EOM] ([COB],[PORTFOLIO_NAME],[DEAL_NUM],[REALISATION_DATE],[OFFSET],[PNL_TYPE],[INS_TYPE_NAME],[EXT_BUNIT_NAME],[EXTERNAL_PORTFOLIO_NAME],[REFERENCE],[PNL],[UNDISC_PNL])

		select		COB, PORTFOLIO_NAME, DEAL_NUM,REALISATION_DATE, OFFSET, PNL_TYPE,INS_TYPE_NAME, EXT_BUNIT_NAME, EXTERNAL_PORTFOLIO_NAME, REFERENCE, PNL, UNDISC_PNL

		from		dbo.[FIN_MOP_PLUS_REAL_CORR_mit_PNL_TYPE_ORIG] where

		DESK in ('CS_CFD_MM_CE','CS_CFD_MM_UK','CS_CFD_SF','CS_SPM_DUMMY','CS_SPM_LT','CS_SPM_ST','CS_SPM_TPB_BENE','CS_SPM_TPB_DE','CS_STRATEGIC','SCHED_BENE','SCHED_DE')	

		delete from dbo.[FIN_MOP_PLUS_REAL_CORR_mit_PNL_TYPE_ORIG] where
		DESK  in ('CS_CFD_MM_CE','CS_CFD_MM_UK','CS_CFD_SF','CS_SPM_DUMMY','CS_SPM_LT','CS_SPM_ST','CS_SPM_TPB_BENE','CS_SPM_TPB_DE','CS_STRATEGIC','SCHED_BENE','SCHED_DE')

		--================================================================================================================================================================================

	if @LogInfo >= 1  BEGIN insert into [dbo].[Logfile] select 'Import Strolf Data_MOP_CORR EOM - Import Strolf Data MOP & CORR EOM has finished', GETDATE () END

END TRY

	BEGIN CATCH
		--insert into [dbo].[Logfile] select 'ERROR-OCCURED', @TimeStamp
		EXEC [dbo].[usp_GetErrorInfo] @proc, @step
	END CATCH

GO

