



CREATE PROCEDURE [dbo].[Delete_AWV_Import]

AS
BEGIN TRY

	DECLARE @LogInfo Integer
	DECLARE @proc nvarchar(40)
	DECLARE @step Integer
	DECLARE @SQL nvarchar(max)

	select @step = 1
	select @proc = '[dbo].[Delete_AWV_IMPORT]'

	select @step = @step + 1
	truncate table [dbo].[AWV_Import]

END TRY

	BEGIN CATCH
		--insert into [dbo].[Logfile] select 'ERROR-OCCURED', @TimeStamp
		EXEC [dbo].[usp_GetErrorInfo] @proc, @step
	END CATCH

GO

