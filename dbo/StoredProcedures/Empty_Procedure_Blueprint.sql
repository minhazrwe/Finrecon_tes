/* 
=====================================================================================================================================
 Author:      mkb
 Created:     2024-04
 Description:	example procedure that can be used as blueprint for any new procedure 
							as it contains the typical elements used in our procedures
-------------------------------------------------------------------------------------------------------------------------------------
Changes:
when, who, step, what (why):
2024-04, mkb, all steps, initial setup
=====================================================================================================================================
*/



/*====================
blueprint fom here on
======================*/

/*
=====================================================================================================================================
 Author:      name of author
 Created:     yyyy-MM
 Description:	describe what does this procedure does, explain the parameters (if there are any)
-------------------------------------------------------------------------------------------------------------------------------------
Changes:
when, who, step, what (why):
=====================================================================================================================================
*/

CREATE PROCEDURE dbo.Empty_Procedure_Blueprint 
		 @Input_Parameter int /* int as placeholder for the required datatype */
		,@Optional_Input_Parameter int = NULL	
AS
BEGIN TRY
	
		DECLARE @step Integer		
		DECLARE @Current_Procedure nvarchar(50)
		DECLARE @sql nvarchar (max)
		
		DECLARE @COB as date
		DECLARE @COB_MONTH_START as date
		DECLARE @COB_MONTH_END as date
		DECLARE @COB_LAST_MONTH_END as date

		DECLARE @Record_Counter as int
		DECLARE @Warning_Counter as int 
		DECLARE @Status_Text as varchar(100)	 					

		DECLARE  @your_variable as varchar
		
		SELECT @Step = 1		
		SELECT @Current_Procedure = Object_Name(@@PROCID)
		
		EXEC dbo.Write_Log 'Info', 'START', @Current_Procedure, NULL, NULL, @step, 1

		/* DESCRIPTION OF THE WRITELOG-FUNCTIONALITY 
		@Log_Level									--> Mandatory: Info, Warning, Error
		@Description								--> Mandatory: Logentry
		@Current_Procedure = NULL		-->	The actual procedure/function creating the log entry (e.g. VBA Function, Stored Procedure etc.)
		@Main_Process = NULL				--> The overarching process (e.g. Realised Recon, SAP Update, Overnight etc.)
		@Calling_Application = NULL --> Name of the calling application (e.g. Name of MS Access Application, Sql Server Manager)
		@Step = NULL								--> Step value in which the logentry occurs - new proc => 100 Steps / Insert a new step 10 steps
		@Log_Info = 1								--> 1: Write in Log | 0: Do not write in Log
		@Session_Key = NULL					--> Provided by calling application (e.g. so that it can identifiy errors)
		*/
		
		/*set + fill the required variables*/
		SET @step = 2
		SET @Record_Counter = 0
		SET @Warning_Counter = 0 
		
		SET @step = 3		
		SELECT @COB = asofdate_eom FROM dbo.AsOfDate													/* current AsofDate */
				
		SELECT @COB_MONTH_START= DATEADD(month, DATEDIFF(month, 0, @COB), 0)	/* related begin of month */
		SELECT @COB_MONTH_END = eomonth(@cob);																/* related end of month */
		SELECT @COB_LAST_MONTH_END = DATEADD(day, 0 ,@COB)										/* related end of last month */

		/*as the status text cannot be build while executing Write_log we need to create it first*/
		/* as we cannot cannot concat a number and a string, we need to cast the number first to be a string and concatenate it then...*/
		SET @Status_Text = 'text with blah ' + cast(@step as varchar) 
		EXEC dbo.Write_Log 'Info',@Status_Text, @Current_Procedure, NULL, NULL, @step, 1

		/*check for the number of if any data has been loaded at all, if not skip next step but inform user by logentry.*/
		SET @step = 14
		SET @Record_Counter = 0
		SELECT @Record_Counter = COUNT(*) FROM finrecon.dbo.[whatever_table_you_want_to_check]

		IF @Record_Counter=0 
		BEGIN
			SET @Warning_Counter = @Warning_Counter + 1
			SET @Status_Text = 'Making use of a warning counter. Warning Counter = ' + CAST(@Warning_Counter as varchar) 
			EXEC dbo.Write_Log 'WARNING', @Status_Text, @Current_Procedure, NULL, NULL, @step, 1
			GOTO A_Specified_Jump_Mark /* to skip all the steps that would have been done if there were data*/
		END 

		/*kill old data for trades and option_premium from final table*/
		DELETE FROM 
			dbo.[whatever_table_you_want_to_delete_from] 
		WHERE 
			fieldname = @your_variable /*if you want to delete selected records (no need for any quotation marks) */

		TRUNCATE TABLE dbo.[table_you_want_to_delete_from] /* if you want to delete ALL records from the table*/

		DROP TABLE IF EXISTS dbo.table_you_want_to_delete /*  check if a certain table exists, if yes: delete it completely*/
			 

A_Specified_Jump_Mark:
/*where you jumped from above*/

		/*transfer data into new data table*/				
		SET @step = 22
		SELECT
			 cast(fieldA as varchar) as fieldA 
			,cast(fieldB as date) as fieldB 
			,cast(NULL as date) as fieldC
			,cast(fieldD as float) as fieldD
		INTO 
			finrecon.dbo.[table_you want to create] /* this table must not exist !!! (if so, drop it first, see above)*/
		FROM
			table_x
--		/* finrecon table*/ finrecon.dbo.[table_you_want_to_select_from]
--		/* table on a linked server*/ [Linked Server].[Catalog].[schema].[table_or_view_name]		
			
		/*NoFurtherAction, so tell the world we're done, but inform about potential warnings.*/
		SELECT @step = 500
		SET @Status_Text = 'FINISHED'
		IF @Warning_Counter = 0
			BEGIN
					EXEC dbo.Write_Log 'Info', @Status_Text, @Current_Procedure, NULL, NULL, @step, 1 
			END
		ELSE
			BEGIN
				SET @Status_Text = @Status_Text + ' WITH ' + cast(@Warning_Counter as varchar) +  ' WARNINGS! - check log for details!'
				EXEC dbo.Write_Log 'WARNING', @Status_Text, @Current_Procedure, NULL, NULL, @step, 1 
			END
		Return 0
END TRY

BEGIN CATCH
	/*tell the world procedure failed*/
	EXEC [dbo].[usp_GetErrorInfo] @Current_Procedure, @step, NULL; 
	EXEC dbo.Write_Log 'FAILED', 'FAILED with error, check log for details', @Current_Procedure, NULL, NULL, @step, 1;
	Return @step
END CATCH

GO

