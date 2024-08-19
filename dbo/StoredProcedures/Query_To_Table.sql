


/* 
=======================================================================================================================================
Author:				Martin Ulken
Created:			2023-06-01 
Description:		This procedure executes a given SQL statement or a statement from Queries table and inserts the result in a temp table.
					The temp table is called 'Temp_'+@query_name and can then be queried by the calling process.
================================
changes:	(when/who/why/
==========================================================================================
*/

CREATE PROCEDURE [dbo].[Query_To_Table]
	@query_name varchar(200), /*Name of the query*/
	@sql_statement varchar(max) = '', /*When SQL statement is not provided the query from the queries table is executed.*/
	@delete_table int = 0 /*When set to 1 the temp table is deleted. No query is executed.*/
AS
BEGIN TRY
	
	DECLARE @LogInfo INTEGER
	DECLARE @schema NVARCHAR(20)
	DECLARE @proc NVARCHAR(40) 
	DECLARE @step INTEGER 
	DECLARE @tablename as NVARCHAR(200)
	DECLARE @username as NVARCHAR(200)
	DECLARE @sql as NVARCHAR(max)
	DECLARE @sql_order_by_statement varchar(max)
	DECLARE @number_of_written_entries INTEGER
	DECLARE @Log_Entry as NVARCHAR(max)
	DECLARE @Main_Process NVARCHAR(100)
	DECLARE @Calling_Application NVARCHAR(100)
	DECLARE @Session_Key NVARCHAR(100)
	
	/*Get Data from the calling application from the table_log*/
	select @Calling_Application = isnull(a.Calling_Application,''), @Session_Key = isnull(Session_Key,''), @Main_Process = isnull(Main_Process,'') from (select top 1 * from [dbo].[table_log] where [User] = [dbo].[udf_Get_Current_User]() and Time_Stamp_CET > [dbo].[udf_Get_Current_Timestamp]()-0.00005 /*ca. 6 Sec*/ ) a 

	/* fill variables with initial values*/
	SELECT @step = 100
	SELECT @schema = 'dbo'
	SELECT @proc =  '[' + OBJECT_SCHEMA_NAME(@@PROCID) + '].[' + Object_Name(@@PROCID) + ']'
	SELECT @LogInfo = [dbo].[LogInfo].[LogInfo]	FROM [dbo].[LogInfo]
	/*Define the name of the temporary table to select the data*/
	SELECT @tablename = 'Temp_Query_To_Table_' + @query_name

	SELECT @step = 200
	/*Drop the temporary table if it already exists*/
	IF (EXISTS (SELECT * FROM INFORMATION_SCHEMA.TABLES WHERE table_schema = 'dbo' and TABLE_NAME = @tablename))
	BEGIN		
		select @sql = 'Drop table [dbo].[' + @tablename + ']'
		EXECUTE sp_executesql @sql
	END

	SELECT @step = 300
	/*If the table just needs to be dropped do nothing more*/
	IF @delete_table = 1
	BEGIN
		GOTO NoFurtherAction
	END

	SELECT @Log_Entry =  'START - Insert data from query "' + @query_name + '" into table ' + @tablename
	EXEC [dbo].[Write_Log] 'Info', @Log_Entry, @proc, @Main_Process, @Calling_Application, @Step, @Loginfo, @Session_Key
	
	SELECT @step = 400
	/*Get sql statement from the queries table if no explicit sql is provided*/
	IF @sql_statement = ''
		select @sql_statement=Statement from Queries where name = @query_name

	/*Remove a potential order by statement from the sql_statement since it is not allowed within a subquery*/
	select @sql_order_by_statement = ''
	if charindex('order by',@sql_statement) > 0 
	BEGIN
		select @sql_order_by_statement = SUBSTRING(@sql_statement,charindex('order by',@sql_statement),len(@sql_statement))
		select @sql_statement = left(@sql_statement,charindex('order by',@sql_statement)-1)
	END

	SELECT @step = 500
	/*Define and Execute the sql statement to insert the the result into the temporary table (The top 99* part is necessary to preserve the order when inserting)*/
	select @sql = 'Select top 999999999999999999 * into ' + '[dbo].[' + @tablename + '] from (' + @sql_statement + ') query ' + @sql_order_by_statement
	EXECUTE sp_executesql @sql

	SELECT @step = 600
	
	select  @number_of_written_entries = 0
	select @sql = 'select @number_of_written_entries = count(*) from [dbo].[' + @tablename + ']'
	EXECUTE sp_executesql @sql,  N'@number_of_written_entries int OUTPUT', @number_of_written_entries = @number_of_written_entries OUTPUT

	SELECT @step = 700

	SELECT @Log_Entry =  'FINISHED - Number of written entries: ' + convert(varchar,@number_of_written_entries)
	EXEC [dbo].[Write_Log] 'Info', @Log_Entry, @proc, @Main_Process, @Calling_Application, @Step, @Loginfo, @Session_Key
	
	NoFurtherAction:

END TRY
BEGIN CATCH
		EXEC [dbo].[usp_GetErrorInfo] @proc, @step, @Main_Process, @Calling_Application, @Session_Key	
		--BEGIN INSERT INTO [dbo].[Logfile] SELECT @proc + ' - FAILED', GETDATE () END
END CATCH

GO

