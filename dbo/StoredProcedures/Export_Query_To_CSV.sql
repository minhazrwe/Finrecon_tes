

/*2023-07-12 (MU) - Only in Test therefore the procedure is not doing anything!
Aim was to create a csv file from a query. But maybe another approach will be used...
If the development is not continued it can be deleted!
*/
	CREATE PROCEDURE [dbo].[Export_Query_To_CSV] 
		 @Query_Name nvarchar(200) 	/*Name of the query from table dbo.queries*/
		,@Export_Path nvarchar(400) = ''  /*Optional - Path where to export the query. If not provided, the ExportPath from dbo.queries is used.*/
	AS
	BEGIN TRY
	Goto DoNothing

	/*
	--To Test
	DECLARE @Query_Name nvarchar(200) 	/*Name of the query from table dbo.queries*/
	Select @Query_Name = 'RevRec_VER_TRADING_Recon_MTM_Overview'

	DECLARE @Export_Path nvarchar(400)  /*Optional - Path where to export the query. If not provided, the ExportPath from dbo.queries is used.*/
	Select @Export_Path = ''
	*/
	
	DECLARE @Step Integer
	DECLARE @Proc_Name nvarchar (30)
	DECLARE @Export_Filename nvarchar (200)
	DECLARE @Export_Filepath nvarchar (400)
	DECLARE @Query_SQL nvarchar(max)
	DECLARE @Query_SQL_Order_By_Part nvarchar(max)
	DECLARE @View_Name nvarchar(max)
	DECLARE @SQL nvarchar(max)
	DECLARE @Log nvarchar(max)
	DECLARE @Main_Process nvarchar(100)
	DECLARE @Calling_Application nvarchar(100)
	DECLARE @Session_Key nvarchar(100)
	
	

	SELECT @Step = 100
	SELECT @Proc_Name = '[dbo].[Export_Query_To_CSV]'
	SELECT @Main_Process = ''
	SELECT @Calling_Application = ''
	SELECT @Session_Key = ''

	SELECT @Log = 'START - Export query "' + @Query_Name + '" to CSV' 
	EXECUTE [dbo].[Write_Log] 'Info', @Log, @Proc_Name, @Main_Process, @Calling_Application, @Step /*Step*/, 1 /*Log_Info*/, @Session_Key
	
	/*Get Export path from PathToFiles table*/
	IF @Export_Path = '' 
		BEGIN
			Select @Export_Path = [Path] from PathToFiles where ID in (select ExportPath from dbo.queries where name = @Query_Name)
		END
	Select @Export_Path = rtrim([dbo].[udf_Resolve_Date_Placeholder](@Export_Path))
	/*Add a trailing backslash if not available*/
	IF right(@Export_Path,1) <> '\' and @Export_Path <> '' 
		BEGIN
			Select @Export_Path = @Export_Path + '\'
		END
	
	Select @Query_SQL = [Statement] from dbo.queries where [name] = @Query_Name

	Select @View_Name = 'View_Export_Query_' + @Query_Name + '_To_CSV_Temp'

	IF OBJECT_ID(@View_Name, 'V') IS NOT NULL
		BEGIN
			Select @SQL = 'DROP VIEW '+ @View_Name
			EXEC sp_executesql @sql
		END

	/*Remove the "Order by" part of the @Query_SQL and put it into a separate variable*/
	Select @Query_SQL = Substring(@Query_SQL,1,Charindex('order by',  @Query_SQL)-1)
	Select @Query_SQL_Order_By_Part = Substring(@Query_SQL,Charindex('order by',  @Query_SQL),len(@Query_SQL))
	
	/*Create a view based on Query_SQL*/
	Select @SQL = 'CREATE VIEW [dbo].[' + @View_Name + '] as ' + @Query_SQL
	EXEC sp_executesql @SQL

	Select @Export_Filename = 'Export_' + @Query_Name + '.csv'
	Select @Export_Filepath = @Export_Path + @Export_Filename
	
	Select @SQL = 'exec master.filesystem.CsvExport ''Select * from [FinRecon].[dbo].[' + @View_Name + ']' + ''', ''' + @Export_Filepath + ''' , TRUE, TRUE, ''~'''
	EXEC sp_executesql @SQL

	

	/*
	select * from PathToFiles where id = 660
	select * from queries where name like '%_VER_TRADING%'
	
	RevRec_VER_TRADING_Recon_MTM_Overview
	\\energy.local\rwest\RWE-Trading\TC\COE-AT-C\01_MonthEnd\%YYYY%\%YYYY%_%MM%\01_RWEST\03_RiskRecon\VER Trading\

	EXEC [dbo].[Export_Query_To_CSV] 'RevRec_VER_TRADING_Recon_MTM_Overview'  
	*/
	/*
	select @path = '\\energy.local\rwest\RWE-Trading\TC\COE-AT-DATABASE\Archive von Archiven\'

	Select @step = @step +1
	BEGIN insert into [dbo].[Logfile] select @step, GETDATE () END

	select @Time_of_archiving = '_' + rtrim(ltrim(convert(varchar,year(getdate())) + '_' + convert(varchar,month(getdate())) + '_' + convert(varchar,day(getdate())) +  '_' + convert(varchar,DATEPART(HOUR, GETDATE())) +  '_' + convert(varchar,DATEPART(Minute, GETDATE()))))

	Select @step = @step +1
	BEGIN insert into [dbo].[Logfile] select @step, GETDATE () END

	select @sql = 'SELECT *  FROM [FinRecon].[dbo].[Archive_individual_data_sql_2]'

	Select @step = @step +1
	BEGIN insert into [dbo].[Logfile] select @step, GETDATE () END

	select @export_path = @path + 'Recon_zw1_2022_11--' + @Time_of_archiving + '.txt' 

	Select @step = @step +1
	BEGIN insert into [dbo].[Logfile] select @step, GETDATE () END

	exec master.filesystem.CsvExport @sql,  @export_path , TRUE, TRUE, '~'
	exec master.fileSystem.
	Select @step = @step +1
	BEGIN insert into [dbo].[Logfile] select @step, GETDATE () END*/

	DoNothing:

END TRY

	BEGIN CATCH
		SELECT @Log = 'Error occured while exporting query "' + @Query_Name + '" to CSV' 
		EXECUTE [dbo].[Write_Log] 'Error', @Log, @Proc_Name, @Main_Process, @Calling_Application, @Step /*Step*/, 1 /*Log_Info*/, @Session_Key
		EXEC [dbo].[usp_GetErrorInfo] @Proc_Name, @Step
	END CATCH

GO

