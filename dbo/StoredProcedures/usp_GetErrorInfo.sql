




-- =============================================
-- Author:				<Author,Beckmann, Markus>
-- Create/Change date:	<Date,08.01.2018>
-- Description:			<Description, Get the relevant data out of the error description>
-- =============================================
/*
-- UPDATES (when, who, what):
-- 20.05.2020, MKB, simplified procedure, reduced return string and corrected declaration and conversion of variables 
-- =============================================
*/

-- Create procedure to retrieve error information.  
CREATE PROCEDURE [dbo].[usp_GetErrorInfo]
	@proc varchar(500),
	@step int,
	@Main_Process [varchar](100) = '',
	@Calling_Application [varchar](100) = '',
	@Session_Key [varchar](100) = ''

AS
	BEGIN 
		DECLARE @error_message_text VARCHAR (2000)

		--read and collect information
		SET @error_message_text = 'ERROR in: ' + convert(varchar(200),@proc) +  
								', STEP: ' + convert(varchar(4),@step) +
								--', LINE: ' + convert(varchar(5),ERROR_LINE()) +  
								', MESSAGE: ' + convert(varchar(1000),ERROR_MESSAGE())  
								
		--write info into table_log
		EXEC [dbo].[Write_Log] 'ERROR', @error_message_text, @proc, @Main_Process, @Calling_Application, @step, 1 /*Log_Info*/, @Session_Key
		--INSERT INTO [dbo].[Logfile] SELECT @error_message_text, GETDATE ()
	END

GO

