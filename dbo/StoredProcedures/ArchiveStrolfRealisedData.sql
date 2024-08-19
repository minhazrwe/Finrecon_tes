
/*=================================================================================================================
	Author:		MBe
	Created:	YYYY-MM-DD
	Purpose:	Archiving of Strolf data.
-----------------------------------------------------------------------------------------------------------------
	Changes:
	2024-06-04, MK, step 7, Added Strolf_realized_IFA
=================================================================================================================*/

	CREATE PROCEDURE [dbo].[ArchiveStrolfRealisedData] 
	AS
	BEGIN TRY

	DECLARE @proc nvarchar(40)
	DECLARE @step Integer
	DECLARE @LogInfo Integer
	DECLARE @path nvarchar (2000)
	DECLARE @sql VARCHAR (800)
	DECLARE @export_path VARCHAR (800)
	DECLARE @Time_of_archiving nvarchar (30)

	SELECT @proc = Object_Name(@@PROCID)

	select @step = 1
	select @LogInfo = [dbo].[LogInfo].[LogInfo] from [dbo].[LogInfo]

	
	select @step = @step + 1
	if @LogInfo >= 1  BEGIN insert into [dbo].[Logfile] select @proc + ' - START', GETDATE () END

	select @path = [dbo].[udf_get_path] ('Strolf-Archive')	
	select @Time_of_archiving =format(getdate(),'_yyyy_MM_dd_HH_mm')

/*###########################################################################################################################*/

	select @step = @step + 1
	select @sql = 'SELECT *  FROM [FinRecon].[dbo].[Strolf_REALIZED]'

	select @export_path = @path + 'Strolf_Realised' + @Time_of_archiving + '.txt' 

	select @step = @step + 1
	if @LogInfo >= 1  BEGIN insert into [dbo].[Logfile] select @proc + ' - Archiving [Strolf_Realised]' + @export_path, GETDATE () END
	exec master.filesystem.CsvExport @sql,  @export_path , TRUE, TRUE, '~'


/*###########################################################################################################################*/
	select @step = @step + 1
	select @sql = 'SELECT *  FROM [FinRecon].[dbo].[Strolf_REALIZED_CARMEN]'

	select @export_path = @path + 'Strolf_Realised_Carmen' + @Time_of_archiving + '.txt' 

	select @step = @step + 1
	if @LogInfo >= 1  BEGIN insert into [dbo].[Logfile] select @proc + ' - Archiving [Strolf_REALIZED_CARMEN]' + @export_path, GETDATE () END
	exec master.filesystem.CsvExport @sql,  @export_path , TRUE, TRUE, '~'


/*###########################################################################################################################*/
	select @step = @step + 1
	select @sql = 'SELECT *  FROM [FinRecon].[dbo].[Strolf_realized_IFA]'

	select @export_path = @path + 'Strolf_realized_IFA' + @Time_of_archiving + '.txt' 

	select @step = @step + 1
	if @LogInfo >= 1  BEGIN insert into [dbo].[Logfile] select @proc + ' - Archiving [Strolf_realized_IFA]' + @export_path, GETDATE () END
	exec master.filesystem.CsvExport @sql,  @export_path , TRUE, TRUE, '~'


/*###########################################################################################################################*/

	if @LogInfo >= 1  BEGIN insert into [dbo].[Logfile] select @proc + '- FINISHED', GETDATE () END

END TRY

	BEGIN CATCH		
		EXEC [dbo].[usp_GetErrorInfo] @proc, @step
		BEGIN insert into [dbo].[Logfile] select @proc + ' - FAILED', GETDATE () END		
	END CATCH

GO

