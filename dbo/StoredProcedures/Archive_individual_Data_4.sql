



	CREATE PROCEDURE [dbo].[Archive_individual_Data_4] 
	AS
	BEGIN TRY

	DECLARE @proc nvarchar(40)
	DECLARE @step Integer
	DECLARE @path nvarchar (2000)
	DECLARE @sql VARCHAR (800)
	DECLARE @export_path VARCHAR (800)
	DECLARE @Time_of_archiving nvarchar (30)


	select @step = 1
	BEGIN insert into [dbo].[Logfile] select @step, GETDATE () END
	select @path = '\\energy.local\rwest\RWE-Trading\TC\MFA-X\08_Development\Archive von Archiven\'

	Select @step = @step +1
	BEGIN insert into [dbo].[Logfile] select @step, GETDATE () END

	select @Time_of_archiving = '_' + rtrim(ltrim(convert(varchar,year(getdate())) + '_' + convert(varchar,month(getdate())) + '_' + convert(varchar,day(getdate())) +  '_' + convert(varchar,DATEPART(HOUR, GETDATE())) +  '_' + convert(varchar,DATEPART(Minute, GETDATE()))))

	Select @step = @step +1
	BEGIN insert into [dbo].[Logfile] select @step, GETDATE () END

	select @sql = 'SELECT *  FROM [FinRecon].[dbo].[Archive_individual_data_sql_4]'

	Select @step = @step +1
	BEGIN insert into [dbo].[Logfile] select @step, GETDATE () END

	select @export_path = @path + 'FASTracker_Archive_2023_07_08_10_11--' + @Time_of_archiving + '.txt' 

	Select @step = @step +1
	BEGIN insert into [dbo].[Logfile] select @step, GETDATE () END

	exec master.filesystem.CsvExport @sql,  @export_path , TRUE, TRUE, '~'

	Select @step = @step +1
	BEGIN insert into [dbo].[Logfile] select @step, GETDATE () END
END TRY

	BEGIN CATCH
		--insert into [dbo].[Logfile] select 'ERROR-OCCURED', @TimeStamp
		EXEC [dbo].[usp_GetErrorInfo] @proc, @step
	END CATCH

GO

