
/* 
==========================================================================================
Context:	PART OF THE NEW UNREALISED APPROACH AFTER FT EXIT
Author:   mkb
Created:  2024/02
purpose:	importing unrealised data from different sources, given by input parameter
------------------------------------------------------------------------------------------
change history: when, who, step, what, (why)
2024-02-00, mkb, all, initial setup of procedure 
2024-06-20, mkb, 30, removed "incomplete" warning for rock data
=========================================================================================
*/

CREATE PROCEDURE [dbo].[Import_Unrealised_Data] 
	@DataToImport varchar(15)
AS
BEGIN TRY
	
	DECLARE @step integer
	DECLARE @Current_Procedure nvarchar (50)
	DECLARE @Main_Process nvarchar(50)
	DECLARE @Log_Entry nvarchar (200)	
	DECLARE @Warning_Counter int 	
	DECLARE @COB date
	

	/*fill the required variables*/
	SET @step = 10
	SET @Current_Procedure = Object_Name(@@PROCID)
	SET @Main_Process = 'TESTRUN UNREALISED'
	SET @Warning_Counter = 0 	

	EXEC dbo.Write_Log 'Info', 'START', @Current_Procedure, @Main_Process, NULL, @step, 1 , NULL	

	/*identify the COB that the load should be done for*/	
	SET @step = 20		
	--SELECT @COB = AsOfDate_EOM FROM dbo.AsOfDate	/* standard cob for month end processing*/
	SELECT @COB = AsOfDate_FT_Replacement FROM dbo.AsOfDate /* date in case you want to run against another date than the "official" COB */


	SET @Log_Entry = 'Importing ' + @DataToImport +' MTM data for COB ' + cast(@COB AS varchar)
	EXEC dbo.Write_Log 'Info', @Log_Entry, @Current_Procedure, @Main_Process, NULL, @step, 1 , NULL
	
	
	/*call the relevant import procedures*/
	SET @step = 30		
	IF @DataToImport in ('ALL', 'ROCK')
	BEGIN
		EXEC dbo.Import_Unrealised_ROCK	
	END 
	
	
	SET @step = 40		
	IF @DataToImport in ('ALL', 'STROLF')
	BEGIN		
		EXEC dbo.Import_Unrealised_STROLF		
	END 
	
	
	SET @step = 50		
	IF @DataToImport in ('ALL', 'ADJUSTMENTS')	
	BEGIN
		EXEC dbo.Import_Unrealised_Adjustments
	END 
	
------------
		/*NoFurtherAction, so tell the world we're done, but inform about potential WARNINGs.*/
SELECT @step = 70
	SET @Log_Entry = 'FINISHED'
	IF @Warning_Counter = 0
			BEGIN
					EXEC dbo.Write_Log 'Info', @Log_Entry, @Current_Procedure, @Main_Process, NULL, @step, 1 , NULL
			END
		ELSE
			BEGIN
				SET @Log_Entry = @Log_Entry + ' WITH ' + cast(@Warning_Counter as varchar) +  ' WARNING(S)! - check log for details!'
				EXEC dbo.Write_Log 'WARNING', @Log_Entry, @Current_Procedure, @Main_Process, NULL, @step, 1 , NULL
			END
		Return 0
END TRY

BEGIN CATCH
	/*tell the world procedure failed*/
	EXEC [dbo].[usp_GetErrorInfo] @Current_Procedure, @step, NULL; 
	EXEC dbo.Write_Log 'FAILED', 'FAILED with error, check log for details', @Current_Procedure, @Main_Process,NULL, @step, 1;
	Return @step
END CATCH

GO

