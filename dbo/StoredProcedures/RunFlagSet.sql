
CREATE PROCEDURE [dbo].[RunFlagSet]
	@details bit,
	@proc_name nvarchar(200)
AS
BEGIN TRY

	DECLARE @LogInfo Integer
	DECLARE @proc nvarchar (40)
	DECLARE @step Integer

	select @step = 1
	select @proc = '[dbo].[RunFlagSet]'

	select @step = @step + 1
	select @LogInfo = [dbo].[LogInfo].[LogInfo] from [dbo].[LogInfo]

	select @step = @step + 1
	--if @details  = 1
		BEGIN
			insert into [dbo].[RunFlag]([RunFlag_Job], [RunFlag_Blocked], [RunFlag_User],[RunFlag_Time]) 
				select @proc_name, [Process_to_be_blocked], current_user , getdate () from [dbo].[RunFlag_Process_Dependencies] where [Process_Running] = @proc_name
		end

	if @details = 0
		begin
			delete from [dbo].[RunFlag] where [RunFlag_Job] = @proc_name
		end

END TRY
	BEGIN CATCH
		--insert into [dbo].[Logfile] select 'ERROR-OCCURED', @TimeStamp
		EXEC [dbo].[usp_GetErrorInfo] @proc, @step
	END CATCH

GO

