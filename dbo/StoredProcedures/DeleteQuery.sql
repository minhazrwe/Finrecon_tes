


CREATE PROCEDURE [dbo].[DeleteQuery]

@nameofquery nvarchar(255)

AS
BEGIN TRY

	DECLARE @LogInfo Integer
	DECLARE @proc nvarchar(40)
	DECLARE @step Integer
	DECLARE @SQL nvarchar(max)

	select @step = 1
	select @proc = '[dbo].[DeleteQuery]'

	select @step = @step + 1
	select @LogInfo = [dbo].[LogInfo].[LogInfo] from [dbo].[LogInfo]

	if @LogInfo >= 1  BEGIN insert into [dbo].[Logfile] select @proc + ' query delete = started', GETDATE () END

	select @step = @step + 1
	if @LogInfo >= 1  BEGIN insert into [dbo].[Logfile] select @proc + ' Query exists ? ', GETDATE () END

	select @step = @step + 1
	IF EXISTS (SELECT * FROM dbo.sysobjects WHERE name = @nameofquery) 
		BEGIN
			select @step = @step + 1
			select @SQl = 'drop view ' + @nameofquery
			execute sp_executesql @SQL
			if @LogInfo >= 1  BEGIN insert into [dbo].[Logfile] select @proc + ' deleted => ' + @nameofquery, GETDATE () END
		END
	ELSE
		BEGIN
			select @step = @step + 1
			if @LogInfo >= 1  BEGIN insert into [dbo].[Logfile] select @proc + ' no query existent ', GETDATE () END
		END

	select @step = @step + 1
	if @LogInfo >= 1  BEGIN insert into [dbo].[Logfile] select @proc + ' query delete = finished', GETDATE () END

	select @step = @step + 1

END TRY

	BEGIN CATCH
		--insert into [dbo].[Logfile] select 'ERROR-OCCURED', @TimeStamp
		EXEC [dbo].[usp_GetErrorInfo] @proc, @step
	END CATCH

GO

