






	CREATE PROCEDURE [dbo].[ImportStrolfData_EOM] 
	AS
	BEGIN TRY

	DECLARE @proc nvarchar(40)
	DECLARE @step Integer
	DECLARE @LogInfo Integer
	DECLARE @MAX_COB Date

	select @step = 1

	-- we need the LogInfo for Logging
	select @LogInfo = [dbo].[LogInfo].[LogInfo] from [dbo].[LogInfo]

	select @proc = '[dbo].[ImportStrolfData]'

	if @LogInfo >= 1  BEGIN insert into [dbo].[Logfile] select 'Import Strolf Data Standard EOM - fill [dbo].[Strolf_GEN_PNL]', GETDATE () END

		truncate table [dbo].[Strolf_GEN_PNL]

		select @MAX_COB = MAX([COB]) from [ROCKCAO_CE].[CAO_CE].[XPORT].[FIN_GEN_PNL]

		insert into [dbo].[Strolf_GEN_PNL](	[COB],	[Desk] ,	[PORTFOLIO_ID],	[PORTFOLIO_NAME],	[DELIVERY_MONTH],	[PNL_TYPE],	[PNL] )
		select [COB],	[Desk] ,	[PORTFOLIO_ID],	[PORTFOLIO_NAME],	[Month],	[PNL_TYPE],	[PNL] 
		from [ROCKCAO_CE].[CAO_CE].[XPORT].[FIN_GEN_PNL]
		where [COB] = @MAX_COB

	if @LogInfo >= 1  BEGIN insert into [dbo].[Logfile] select 'Import Strolf Data Standard EOM - fill [dbo].[Strolf_CAO_PNL_OV]', GETDATE () END

		truncate table [dbo].[Strolf_CAO_PNL_OV]

		insert into [dbo].[Strolf_CAO_PNL_OV] ([REP_DATE],[PREV_DATE] ,[EOLM_COB_DATE],[EOLY_COB_DATE],[Desk],[PFG_NAME],[BUSINESS_TYPE],[MTM_REP],	[MTM_PREV],	[REAL_REP],	[REAL_PREV],[ALL_REP],[ALL_PREV],[DTD_PNL],[MTD_PNL],[YTD_PNL])
		select [COB],[PREV_COB] ,[EOLM_COB],[EOLY_COB],[Desk],[PFG_NAME],[BUSINESS_TYPE],[MTM_REP],	[MTM_PREV],	[REAL_REP],	[REAL_PREV],[ALL_REP],[ALL_PREV],[DTD_PNL],[MTD_PNL],[YTD_PNL] 
		from [ROCKCAO_CE].[CAO_CE].[XPORT].[FIN_CAO_PNL_OV]


	if @LogInfo >= 1  BEGIN insert into [dbo].[Logfile] select 'Import Strolf Data Standard EOM - fill [dbo].[Strolf_HIST_PNL_PORT_FIN_EOM]', GETDATE () END

		truncate table [dbo].[Strolf_HIST_PNL_PORT_FIN_EOM]

		select @MAX_COB = MAX([COB]) from [ROCKCAO_CE].[CAO_CE].[XPORT].[FIN_HIST_PNL_PORT_FIN]

		--select @step = @step + 1
		insert into [dbo].[Strolf_HIST_PNL_PORT_FIN_EOM] ([COB],[PORTFOLIO_ID],[PORTFOLIO_NAME],[PROJ_IDX],[INDEX_NAME],[COMMODITY_TYPE],[EXT_BUNIT_NAME],[MONTH],[PNL_Type],[PNL],[CURRENCY],[Month_ORIG],[INS_TYPE_NAME])
		select [COB],[PORTFOLIO_ID],[PORTFOLIO_NAME],[Index_ID],[INDEX_NAME],[COMMODITY_TYPE],[EXT_BUNIT_NAME],[MONTH],[PNL_Type],[PNL],[CURRENCY],[Month_ORIG],[INS_TYPE_NAME] 
		from [ROCKCAO_CE].[CAO_CE].[XPORT].[FIN_HIST_PNL_PORT_FIN]
		where [COB] = @MAX_COB

	if @LogInfo >= 1  BEGIN insert into [dbo].[Logfile] select 'Import Strolf Data Standard EOM - fill [dbo].[Strolf_VAL_ADJUST_EOM]', GETDATE () END

		truncate table [dbo].[Strolf_VAL_ADJUST_EOM]

		select @MAX_COB = MAX([COB]) from [ROCKCAO_CE].[CAO_CE].[XPORT].[FIN_VAL_ADJUST]
	
		--select @step = @step + 1
		insert into [dbo].[Strolf_VAL_ADJUST_EOM] ([COB],[PORTFOLIO_NAME],[PORTFOLIO_ID],[PNL_TYPE],[PNL],[CURRENCY],[INSTRUMENT],[DESCRIPTION],[START_DATE],[END_DATE],[REALISATION_DATE],[ENTRY_DATE],[CAT_NAME])
		select [COB],[PORTFOLIO_NAME],[PORTFOLIO_ID],[PNL_TYPE],[PNL],[CURRENCY],[INSTRUMENT],[DESCRIPTION],[START_DATE],[END_DATE],[REALISATION_DATE],[ENTRY_DATE],[CAT_NAME] 
		from [ROCKCAO_CE].[CAO_CE].[XPORT].[FIN_VAL_ADJUST]
		where [COB] = @MAX_COB

	if @LogInfo >= 1  BEGIN insert into [dbo].[Logfile] select 'Import Strolf Data Standard EOM - Import Strolf Data EOM has finished', GETDATE () END

END TRY

	BEGIN CATCH
		--insert into [dbo].[Logfile] select 'ERROR-OCCURED', @TimeStamp
		EXEC [dbo].[usp_GetErrorInfo] @proc, @step
	END CATCH

GO

