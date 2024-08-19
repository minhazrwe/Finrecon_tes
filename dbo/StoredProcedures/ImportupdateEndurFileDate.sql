

CREATE PROCEDURE [dbo].[ImportupdateEndurFileDate]

AS
BEGIN TRY

	DECLARE @LogInfo Integer
	DECLARE @proc nvarchar (40)
	DECLARE @step Integer
	DECLARE @output integer
	DECLARE @newdate nvarchar (10)

	select @step = 1
	select @proc = Object_Name(@@PROCID)--'[dbo].[updateEndurFileDate]'

	select @step = 2
	select @LogInfo = [dbo].[LogInfo].[LogInfo] from [dbo].[LogInfo]
	if @LogInfo >= 1  BEGIN insert into [dbo].[Logfile] select 'Import - START updateEndurFileDate', GETDATE () END

	select @step = 3
	select @newdate = [date] from [dbo].[import-DateForEndurFileName]

	select @step = 4
	update [dbo].[FilestoImport] set Filename = LEFT(Filename, 22) + rtrim(ltrim(@newdate)) + Right(Filename, Len(Filename)- 29) where Source = 'Endur' --and filename like 'RealizedCashPNLDENEW%'

	--select @step = 5
	--update [dbo].[FilestoImport] set Filename = LEFT(Filename, 21) + rtrim(ltrim(@newdate)) + Right(Filename, Len(Filename)- 28) where Source = 'Endur' and filename like 'RealizedCashPNLUKNEW%' 

	select @step = 6
	if @LogInfo >= 1  BEGIN insert into [dbo].[Logfile] select 'Import - FINISHED updateEndurFileDate', GETDATE () END
	
END TRY

	BEGIN CATCH
		--insert into [dbo].[Logfile] select 'ERROR-OCCURED', @TimeStamp
		EXEC [dbo].[usp_GetErrorInfo] @proc, @step
	END CATCH

GO

