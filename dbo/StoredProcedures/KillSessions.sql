



/* 
-- =============================================
-- Author: Martin Ulken
-- Create date: 2023-04-12, 
-- Description: This Procedure will kill all enduser sessions executing longrunning FinRecon queries.
--				It can only be executed by the technical RtwoDtwo FortyTwo User.
-- =============================================

*/
CREATE PROCEDURE [dbo].[KillSessions]
AS
BEGIN TRY
	
	DECLARE @LogInfo INTEGER
	DECLARE @sql NVARCHAR(max)
	DECLARE @schema nvarchar(20) = 'dbo'
	DECLARE @proc nvarchar(40) = '[dbo].[KillSessions]'
	DECLARE @step INTEGER = 1
	DECLARE @logPrefix NVARCHAR(100) = @proc + ' - '
	DECLARE @counter INTEGER = 0
	DECLARE @SessionID INTEGER
	DECLARE @session_username Nvarchar(200)
	DECLARE @current_user  Nvarchar(200)

	SELECT @LogInfo = [dbo].[LogInfo].[LogInfo]	FROM [dbo].[LogInfo]
	--SELECT @LogInfo = 0 /*Deactivate Logging for testing purposes*/

	/*Only RTWODTWO is allowed to execute this procedure*/
	select @current_user = SUSER_NAME()
	If @current_user <> 'ENERGY\UI155028'
	BEGIN
		SELECT @step = 10 IF @LogInfo >= 1 BEGIN INSERT INTO [dbo].[Logfile] SELECT @logPrefix + 'Killing of sessions not possible for user ' + @current_user ,GETDATE() END
		GOTO NoFurtherAction
	END

	SELECT @step = 20 IF @LogInfo >= 1 BEGIN INSERT INTO [dbo].[Logfile] SELECT @logPrefix + 'START detecting longrunning end-user sessions' ,GETDATE() END

	/*Get details of Enduser FinRecon queries that have been running for more than 30 minutes*/
	IF (EXISTS (SELECT * FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_SCHEMA = 'dbo' AND TABLE_NAME = 'KillSessions_Temp'))
		BEGIN DROP TABLE [dbo].[KillSessions_Temp] END
	SELECT req.session_id
		,sqltext.TEXT
		,pro.nt_username
		,pro.loginame
		,pro.hostname
		,pro.program_name
		,req.STATUS
		,sd.name DBName
		,req.command
		,req.cpu_time
		,req.total_elapsed_time
		,pro.blocked
		,blocking_session_id
	into [dbo].[KillSessions_Temp]
	FROM sys.dm_exec_requests req
	LEFT JOIN sys.sysprocesses pro ON pro.spid = req.session_id
	LEFT JOIN master.dbo.sysdatabases sd ON pro.dbid = sd.dbid
	CROSS APPLY sys.dm_exec_sql_text(req.sql_handle) AS sqltext
	WHERE 
		( pro.nt_username LIKE 'R%' OR pro.nt_username LIKE 'UI%' ) 
		AND req.total_elapsed_time > 1800000 /*divided by 60.000 results in minutes */
		AND isnull(sd.name, '') LIKE 'FinRecon'
		
	
	SELECT @step = 15

	/*Get the number of sessions to be killed*/
	SELECT @counter = count(distinct session_id) FROM [dbo].[KillSessions_Temp] 

	/*If no sessions are found exit the procedure*/
	IF @counter=0 
	BEGIN 
		SELECT @step = 19 INSERT INTO [dbo].[Logfile] SELECT @proc + ' - no sessions found to be killed. Droppting table [KillSessions_Temp]', GETDATE () 
		Drop table [dbo].[KillSessions_Temp]
		GOTO NoFurtherAction
	END		

	SELECT @step = 20 INSERT INTO [dbo].[Logfile] SELECT @proc + ' - Found ' + convert(varchar, @counter) + ' sessions to be killed', GETDATE () 
	
	/*Start killing the sessions*/
	WHILE @counter >0	
		BEGIN			
		  SELECT @step=10

			SELECT 
				 @SessionID = session_id 
				 ,@session_username = nt_username
			FROM 
			(SELECT distinct session_id,nt_username, ROW_NUMBER() OVER(ORDER BY session_id) AS ROW FROM [dbo].[KillSessions_Temp]) as TMP 
			WHERE ROW = @counter
	
		SELECT @step = 20 INSERT INTO [dbo].[Logfile] SELECT @proc + ' - Killing Session ' + convert(varchar,@SessionID) + ' from user ' + @session_username + '.', GETDATE () 
		
		SELECT @sql = N'Kill '+convert(varchar,@SessionID);
		EXECUTE sp_executesql @sql
		
		SELECT @step = 30 INSERT INTO [dbo].[Logfile] SELECT @proc + ' - Session ' + convert(varchar,@SessionID) + ' has been killed.', GETDATE () 

		/*reduce counter*/
		SELECT @counter = @counter - 1

	END /*END WHILE @counter >0*/		

	SELECT @step = 99 IF @LogInfo >= 1 BEGIN INSERT INTO [dbo].[Logfile] SELECT @logPrefix + 'FINISHED', GETDATE () END

NoFurtherAction:
		
END TRY

BEGIN CATCH
	EXEC [dbo].[usp_GetErrorInfo] @proc
		,@step
END CATCH

GO

