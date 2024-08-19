
/*=================================================================================================================
	procedure:	COLLECT_OVERNIGHT_ISSUES
	author:			mkb/PG
	created:		2024-04-08
	purpose:		collects all errors and warnings for a procedure (currently hard coded) 
							which was run by the current user or r2d2
							identified records from logfile (all columns) are written in a temp_table, 
							rumber of found issues is retuned by procedure.
-----------------------------------------------------------------------------------------------------------------
Changes (when, who, step, what, why):
2024-04-08,		initial setup
2024-08-05,	PG,	added "and Description NOT LIKE ('SKIPPED (ERROR)%')" to ignore that revrec errors are shown 2 times
=================================================================================================================*/

CREATE PROCEDURE [dbo].[Check_Overnight_Issues]
AS
BEGIN TRY

		DECLARE @Current_Procedure nvarchar (40)
		DECLARE @step integer
		DECLARE @sql nvarchar (max)
		DECLARE @return_value integer

		DECLARE @Status_Text nvarchar(300)		
		DECLARE @startdate datetime
		DECLARE @finishdate datetime

		DECLARE @ProcNameToCheck nvarchar(100)		
		DECLARE @StartEntryToSearch nvarchar(100)		
		DECLARE @FinishEntryToSearch nvarchar(100)		
		
		
		SET @step = 1
		SET @Current_Procedure = Object_Name(@@PROCID)
		
		/*parameterize these three and the procedure can be use commonly for any other procedure*/
		SET @ProcNameToCheck = 'Over Night' 
		SET @StartEntryToSearch = '%STARTED on Access DB%'
		SET @FinishEntryToSearch  = '%FINALLY FINISHED%'

		SET @Status_Text = 'START'
		EXEC dbo.Write_Log 'Info', 'START', @Current_Procedure, NULL, NULL, @step, 1 


		/*identify start time of procedure*/
		SET @step = 2
		SELECT
			@startdate = max(time_stamp_cet)	
		FROM 
			dbo.table_log 
		WHERE
			current_procedure like @ProcNameToCheck 
			and [description] LIKE @StartEntryToSearch
	

		/*identify finish time of procedure*/
		SET @step = 3
		SELECT
			@finishdate = max(time_stamp_cet)	
		FROM 
			table_log 
		WHERE
			current_procedure like @ProcNameToCheck  
			and [description] LIKE @FinishEntryToSearch 
	
		/*kill temp table in case it exists*/
		SET @step = 4
		DROP TABLE IF EXISTS dbo.tmp_table_warning_errors

		/* identify warnings and errors and write them to temp table*/
		SET @step = 5
		SELECT 
			* 
		INTO
			dbo.tmp_table_warning_errors
		FROM
			dbo.table_log
		WHERE
			time_stamp_cet between @startdate and @finishdate
			and log_level in ('warning', 'error', 'Error') 
			and Description NOT LIKE ('SKIPPED (ERROR)%')	--added on 05/08/2024 PG
			and 
			(
				[user] = current_user 
				or 
				[user] = 'dbo_R2D2' 
				--or 
				--[user] = 'ENERGY\UI555471'
			)

		/*count the identified errors and warnings*/
		SET @step = 6
		SELECT @return_value  = count(*) from dbo.tmp_table_warning_errors

		SET @Status_Text = 'Identified ' + cast (@return_value as varchar) + ' warnings or errors'
		EXEC dbo.Write_Log 'Info',@Status_Text, @Current_Procedure, NULL, NULL, @step, 1 
		
		/*we're done*/
		SELECT @step = 10
		SET @Status_Text = 'FINISHED'
		EXEC dbo.Write_Log 'Info', @Status_Text, @Current_Procedure, NULL, NULL, @step, 1 
		
		RETURN @return_value
		
END TRY

BEGIN CATCH
	/*tell the world procedure failed*/
	EXEC [dbo].[usp_GetErrorInfo] @Current_Procedure, @step, NULL; 
	SET @Status_Text = 'FAILED with error, check log for details'
	EXEC dbo.Write_Log 'FAILED', @Status_Text, @Current_Procedure, NULL, NULL, @step, 1;
	Return @Step
END CATCH

GO

