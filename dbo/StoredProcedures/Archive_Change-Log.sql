




CREATE PROCEDURE [dbo].[Archive_Change-Log]

AS
BEGIN TRY

	DECLARE @LogInfo Integer
	DECLARE @proc nvarchar (40)
	DECLARE @step Integer

	select @step = 1
	select @proc = '[dbo].[Archive_Change-Log]'

	select @step = @step + 1
	select @LogInfo = [dbo].[LogInfo].[LogInfo] from [dbo].[LogInfo]

	select @step = @step + 1
	if @LogInfo >= 1  BEGIN insert into [dbo].[Logfile] select 'Archive_Change-Log - START', GETDATE () END

	select @step = @step + 1
	-- delete data for rerun purposes
	delete from [dbo].[Change-Log_Archive] where [dbo].[Change-Log_Archive].[AsOfDate] =(Select AsOfDate_EOM from dbo.AsOfDate)

	select @step = @step + 1
	-- and inster the curent data
	insert into [dbo].[Change-Log_Archive] ([TimeOfArchiving] ,AsOfDate, [ID] ,[Change-Table] ,[Change-Entry] ,[Change-Type] ,[Change-User] ,[Change-Datetime])
	select 
		GETDATE() as TimeOfArchiving, convert(date,(Select [AsOfDate_EOM] from [dbo].[AsOfDate])) as AsOfDate  ,ID,[Change-Table] ,[Change-Entry] ,[Change-Type] ,[Change-User] ,[Change-Datetime] FROM [FinRecon].[dbo].[Change-Log]

	select @step = @step + 1
	if @LogInfo >= 1  BEGIN insert into [dbo].[Logfile] select 'Archive_Change-Log - FINISHED', GETDATE () END

END TRY

	BEGIN CATCH
		--insert into [dbo].[Logfile] select 'ERROR-OCCURED', @TimeStamp
		BEGIN insert into [dbo].[Logfile] select 'Archive_Change-Log - FAILED', GETDATE () END
		EXEC [dbo].[usp_GetErrorInfo] @proc, @step
	END CATCH

GO

