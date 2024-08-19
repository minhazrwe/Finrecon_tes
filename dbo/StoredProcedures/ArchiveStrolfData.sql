

/*=================================================================================================================
	Author:		MBe
	Created:	YYYY-MM-DD
	Purpose:	Archiving of Strolf data.
-----------------------------------------------------------------------------------------------------------------
	Changes:
	2024-06-04, MK, step 12, Added strolf_fin_deal_to_dp
=================================================================================================================*/

	CREATE PROCEDURE [dbo].[ArchiveStrolfData] 
	AS
	BEGIN TRY

	DECLARE @proc nvarchar(40)
	DECLARE @step Integer
	DECLARE @LogInfo Integer
	DECLARE @path nvarchar (2000)
	DECLARE @sql VARCHAR (800)
	DECLARE @export_path VARCHAR (800)
	DECLARE @Time_of_archiving nvarchar (30)

	select @step = 0
	SELECT @proc = Object_Name(@@PROCID)

	select @step = 1
	select @LogInfo = [dbo].[LogInfo].[LogInfo] from [dbo].[LogInfo]

	select @step = @step + 1
	if @LogInfo >= 1  BEGIN insert into [dbo].[Logfile] select @proc + '- STARTED', GETDATE () END

	select @path = [dbo].[udf_get_path] ('Strolf-Archive')
	
	select @Time_of_archiving =format(getdate(),'_yyyy_MM_dd_HH_mm')

/*########################################################################################################################*/

	select @step = @step + 1
	if @LogInfo >= 1  BEGIN insert into [dbo].[Logfile] select @proc + ' - archiving [Strolf_GEN_PNL]', GETDATE () END

	select @sql = 'select * from [FinRecon].[dbo].[Strolf_GEN_PNL]'

	if @LogInfo >= 1  BEGIN insert into [dbo].[Logfile] select @proc + ' - archiving [Strolf_GEN_PNL] => SQL defined', GETDATE () END

	select @export_path = @path + 'Strolf_GEN_PNL' + @Time_of_archiving + '.txt' 

	if @LogInfo >= 1  BEGIN insert into [dbo].[Logfile] select @proc + ' - archiving [Strolf_GEN_PNL] => Export Path defined', GETDATE () END
	
	exec master.filesystem.CsvExport @sql,  @export_path , TRUE, TRUE, '~'
	

/*########################################################################################################################*/

	select @step = @step + 1
	if @LogInfo >= 1  BEGIN insert into [dbo].[Logfile] select @proc + ' - archiving [Strolf_CAO_PNL_OV]', GETDATE () END

	select @sql = 'select * from [FinRecon].[dbo].[Strolf_CAO_PNL_OV]'

	select @export_path = @path + 'Strolf_CAO_PNL_OV' + @Time_of_archiving + '.txt' 

	exec master.filesystem.CsvExport @sql,  @export_path , TRUE, TRUE, '~'


/*########################################################################################################################*/

	select @step = @step + 1
	if @LogInfo >= 1  BEGIN insert into [dbo].[Logfile] select @proc + ' - archiving [Strolf_HIST_PNL_PORT_FIN_EOM]', GETDATE () END

	select @sql = 'select * from [FinRecon].[dbo].[Strolf_HIST_PNL_PORT_FIN_EOM]'

	select @export_path = @path + 'Strolf_HIST_PNL_PORT_FIN_EOM' + @Time_of_archiving + '.txt' 

	exec master.filesystem.CsvExport @sql,  @export_path , TRUE, TRUE, '~'


/*########################################################################################################################*/

	select @step = @step + 1
	if @LogInfo >= 1  BEGIN insert into [dbo].[Logfile] select @proc + ' - archiving [Strolf_MOP_PLUS_REAL_CORR_EOM]', GETDATE () END

	select @sql = 'select * from [FinRecon].[dbo].[Strolf_MOP_PLUS_REAL_CORR_EOM]'

	select @export_path = @path + 'Strolf_MOP_PLUS_REAL_CORR_EOM' + @Time_of_archiving + '.txt' 

	exec master.filesystem.CsvExport @sql,  @export_path , TRUE, TRUE, '~'


/*########################################################################################################################*/

	select @step = @step + 1
	if @LogInfo >= 1  BEGIN insert into [dbo].[Logfile] select @proc + ' - archiving [Strolf_ROM_POS_BENE_EOM]', GETDATE () END

	select @sql = 'select * from [FinRecon].[dbo].[Strolf_ROM_POS_BENE_EOM]'

	select @export_path = @path + 'Strolf_ROM_POS_BENE_EOM' + @Time_of_archiving + '.txt' 

	exec master.filesystem.CsvExport @sql,  @export_path , TRUE, TRUE, '~'


/*########################################################################################################################*/

	select @step = @step + 1
	if @LogInfo >= 1  BEGIN insert into [dbo].[Logfile] select @proc + ' - archiving [Strolf_ROM_POS_DE_EOM]', GETDATE () END

	select @sql = 'select * from [FinRecon].[dbo].[Strolf_ROM_POS_DE_EOM]'

	select @export_path = @path + 'Strolf_ROM_POS_DE_EOM' + @Time_of_archiving + '.txt' 

	exec master.filesystem.CsvExport @sql,  @export_path , TRUE, TRUE, '~'


/*########################################################################################################################*/

	select @step = @step + 1
	if @LogInfo >= 1  BEGIN insert into [dbo].[Logfile] select @proc + ' - archiving [Strolf_VAL_ADJUST_EOM]', GETDATE () END

	select @sql = 'select * from [FinRecon].[dbo].[Strolf_VAL_ADJUST_EOM]'

	select @export_path = @path + 'Strolf_VAL_ADJUST_EOM' + @Time_of_archiving + '.txt' 

	exec master.filesystem.CsvExport @sql,  @export_path , TRUE, TRUE, '~'


/*########################################################################################################################*/

	select @step = @step + 1
	if @LogInfo >= 1  BEGIN insert into [dbo].[Logfile] select @proc + ' - archiving [Strolf_IS_EUR_EOM]', GETDATE () END

	select @sql = 'select * from [FinRecon].[dbo].[Strolf_IS_EUR_EOM]'

	select @export_path = @path + 'Strolf_IS_EUR_EOM' + @Time_of_archiving + '.txt' 

	exec master.filesystem.CsvExport @sql,  @export_path , TRUE, TRUE, '~'

/*########################################################################################################################*/

	select @step = @step + 1
	if @LogInfo >= 1  BEGIN insert into [dbo].[Logfile] select @proc + ' - archiving [Strolf_BMT_ROM_POS]', GETDATE () END

	select @sql = 'select * from [FinRecon].[dbo].[Strolf_BMT_ROM_POS]'

	select @export_path = @path + 'Strolf_BMT_ROM_POS' + @Time_of_archiving + '.txt' 

	exec master.filesystem.CsvExport @sql,  @export_path , TRUE, TRUE, '~'

/*########################################################################################################################*/

	select @step = @step + 1
	if @LogInfo >= 1  BEGIN insert into [dbo].[Logfile] select @proc + ' - archiving [strolf_fin_deal_to_dp]', GETDATE () END

	select @sql = 'select * from [FinRecon].[dbo].[strolf_fin_deal_to_dp]'

	select @export_path = @path + 'strolf_fin_deal_to_dp' + @Time_of_archiving + '.txt' 

	exec master.filesystem.CsvExport @sql,  @export_path , TRUE, TRUE, '~'

/*########################################################################################################################*/

	if @LogInfo >= 1  BEGIN insert into [dbo].[Logfile] select @proc + '- FINISHED', GETDATE () END

END TRY

	BEGIN CATCH		
		EXEC [dbo].[usp_GetErrorInfo] @proc, @step
		BEGIN insert into [dbo].[Logfile] select @proc + ' - FAILED', GETDATE () END		
	END CATCH

GO

