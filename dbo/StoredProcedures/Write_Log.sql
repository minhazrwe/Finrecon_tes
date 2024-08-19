






/* 
-- =============================================
-- Author:      MU
-- Created:     Oct 2022
-- Description:	Write an entry in table_Log
-- ========================
-- Changes (when/who/what):
-- =============================================

--Example for inserting a logentry:
EXEC [dbo].[Write_Log] 'Info', 'This is the text of the logentry', '[dbo].[Procedure_Mustermann]', 'Mustermann Process', 'Mustermann_DB.accdb', 1 /*Step*/, 1 /*Log_Info*/, 'Muster_Session_Key'
*/
CREATE PROCEDURE [dbo].[Write_Log] 
	@Log_Level [varchar](20),										/*Mandatory: Info, Warning, Error*/
	@Description [varchar](2000),								/*Mandatory: Logentry*/
	@Current_Procedure [varchar](100) = NULL,		/*The actual procedure/function creating the log entry (e.g. VBA Function, Stored Procedure etc.)*/
	@Main_Process [varchar](100) = NULL,				/*The overarching process (e.g. Realised Recon, SAP Update, Overnight etc.)*/
	@Calling_Application [varchar](100) = NULL, /*Name of the calling application (e.g. Name of MS Access Application, Sql Server Manager)*/
	@Step [int] = NULL,													/*@Step value in which the logentry occurs - new proc => 100 Steps / Insert a new step 10 steps*/
	@Log_Info [int] = 1,												/*1: Write in Log | 0: Do not write in Log*/
	@Session_Key [varchar](100) = NULL					/*Provided by calling application (e.g. so that it can identifiy errors)*/
AS	
	/*Do nothing if Log_Info = 0*/
	IF @Log_Info = 0 GOTO NoFurtherAction

	DECLARE @Time_Stamp_CET datetime
	DECLARE @Time_Stamp datetime
	DECLARE @User varchar(100)

	/*Set Time_Stamp to the current CET date and time*/
	SELECT @Time_Stamp_CET = [dbo].[udf_Get_Current_Timestamp]()
	SELECT @Time_Stamp = CURRENT_TIMESTAMP
	
	/*Identify the user (R2D2 is identified as dbo)*/
	SELECT @User = [dbo].[udf_Get_Current_User] ()
		
	IF isnull(ERROR_NUMBER(),0) = 0 
		BEGIN
			IF @Log_Info is null 
				SELECT @Log_Level = 'Error'
			IF @Description is null
				SELECT @Description = '''' + convert(varchar(1000), ERROR_MESSAGE()) + ''' in line ' +  convert(varchar(1000), ERROR_LINE())
			IF @Current_Procedure is null
				SELECT @Current_Procedure = ERROR_PROCEDURE()
		END


	INSERT INTO [dbo].[table_Log]
           ([Time_Stamp_CET]
           ,[Log_Level]
		   ,[Current_Procedure]
           ,[Description]
		   ,[Main_Process]
           ,[Calling_Application]
           ,[Step]
		   ,[User]
		   ,[Time_Stamp]
           ,[Session_Key])
     VALUES
           (@Time_Stamp_CET
           ,@Log_Level
		   ,@Current_Procedure
           ,@Description
		   ,@Main_Process
           ,@Calling_Application
           ,@Step
		   ,@User
		   ,@Time_Stamp
           ,@Session_Key)
		
	if @Calling_Application <> 'Logfile' 	
		INSERT INTO [dbo].[Logfile] 
			SELECT	@Current_Procedure + ' - ' + @Log_Level + ': ' + @Description + ' (Step '+ convert(varchar(100),@step) +')' + ' #Write_Log#' as Job, @Time_Stamp_CET as [Timestamp]
	
	NoFurtherAction:
		--No further action means no further action!

GO

