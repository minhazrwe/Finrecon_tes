

CREATE PROCEDURE [dbo].[switchFiles]
	@details varchar(20)
AS
BEGIN TRY

	--a proc to (de) - activate the import for files that have been exported by Endur or Glori

	DECLARE @LogInfo Integer
	DECLARE @proc nvarchar (40)
	DECLARE @step Integer

	select @step = 1
	select @proc = '[dbo].[switchFiles]'

	select @step = @step + 1
	select @LogInfo = [dbo].[LogInfo].[LogInfo] from [dbo].[LogInfo]

	select @step = @step + 1
	if @details = 'deactivateUKEndur'
		Begin
			if @LogInfo >= 1  BEGIN insert into [dbo].[Logfile] select 'deactivateUKEndurFiles', GETDATE () END
			update [dbo].[FilestoImport] set ToBeImported = 0 where [Source] = 'Endur' and [FileName] like '%UKNEW%'
		END
	select @step = @step + 1
	if @details = 'activateUKEndur'
		Begin
			if @LogInfo >= 1  BEGIN insert into [dbo].[Logfile] select 'activateUKEndurFiles', GETDATE () END
			update [dbo].[FilestoImport] set ToBeImported = 1 where [Source] = 'Endur' and [FileName] like '%UKNEW%'
		END
	select @step = @step + 1
	if @details = 'deactivateDEEndur'
		Begin
			if @LogInfo >= 1  BEGIN insert into [dbo].[Logfile] select 'deactivateDEEndurFiles', GETDATE () END
			update [dbo].[FilestoImport] set ToBeImported = 0 where [Source] = 'Endur' and [FileName] like '%DENEW%'
		END
	select @step = @step + 1
	if @details = 'activateDEEndur'
		Begin
			if @LogInfo >= 1  BEGIN insert into [dbo].[Logfile] select 'activateDEEndurFiles', GETDATE () END
			update [dbo].[FilestoImport] set ToBeImported = 1 where [Source] = 'Endur' and [FileName] like '%DENEW%'
		END
	select @step = @step + 1
	if @details = 'deactivateGlori'
		Begin
			if @LogInfo >= 1  BEGIN insert into [dbo].[Logfile] select 'deactivateGloriFiles', GETDATE () END
			update [dbo].[FilestoImport] set ToBeImported = 0 where [Source] = 'Glori'
		END
	select @step = @step + 1
	if @details = 'activateGlori'
		Begin
			if @LogInfo >= 1  BEGIN insert into [dbo].[Logfile] select 'activateGloriFiles', GETDATE () END
			update [dbo].[FilestoImport] set ToBeImported = 1 where [Source] = 'Glori'
		END
END TRY

	BEGIN CATCH
		--insert into [dbo].[Logfile] select 'ERROR-OCCURED', @TimeStamp
		EXEC [dbo].[usp_GetErrorInfo] @proc, @step
	END CATCH

GO

