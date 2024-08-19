
/*=============================================================================================================================================
created:	2023/04
author:		mkb
purpose:	Procedure to import the fx rate timeseries downloaded from ecb website.
					to avoid loading the complete same data again and again, only the data since previous EOM will get loeded into this table (again)
hint:			in case a new column is added to the ecb source file you need to extend the raw_data_table file accordingly.
================================
changes:	(when/who/why/what)

=============================================================================================================================================*/


CREATE PROCEDURE [dbo].[Process_FX_Rates_Timeseries_ECB]
AS
BEGIN TRY

		DECLARE @step integer
		DECLARE @proc nvarchar (50)
		DECLARE @File_Source nvarchar (200)
		DECLARE @Import_Path nvarchar (300)
		DECLARE @LogInfo integer
		DECLARE @column_counter integer
		DECLARE @COB date
		DECLARE @COB_previous_EOM date
		DECLARE @sql as nvarchar(max)
		DECLARE @Column_Name nvarchar (10)
		DECLARE @Import_File  nvarchar (100)
		DECLARE @File_ID integer

		SELECT @step = 100
		SELECT @proc = Object_Name(@@PROCID)
		
		/*fill variables */
		SELECT @step = 200
		SELECT @LogInfo = [dbo].[LogInfo].[LogInfo] from [dbo].[LogInfo]
		IF @LogInfo >= 1  BEGIN INSERT INTO [dbo].[Logfile] SELECT @proc + ' - START', GETDATE () END
		IF @LogInfo >= 1  BEGIN INSERT INTO [dbo].[Logfile] SELECT @proc + ' - identifying values for variables', GETDATE () END
		
		/*define file source */
		SELECT @step = 300
		SELECT @File_Source = 'FX_RATES_ECB'

		/*identify path to import from */
		SELECT @step = 400
		SELECT @Import_Path = [dbo].[udf_get_path] (@File_Source)

		/*identify file to get imported (it is just ONE) */
		SELECT @step = 500
		SELECT @Import_File = [FileName], @File_ID=ID from dbo.FilestoImport where [Source] = @File_Source

		/*identify month end dates */
		SELECT @step = 600
		SELECT @COB = AsOfDate_eom
				 , @COB_previous_EOM = AsOfDate_prevEOM FROM dbo.AsOfDate

		/*count the columns of the raw_data table*/
		SELECT @step = 700
		SELECT @column_counter = count(syscolumns.name) FROM	syscolumns INNER JOIN sysobjects ON syscolumns.id = sysobjects .id WHERE sysobjects.name = 'table_FX_Rates_Timeseries_ECB_raw'

		/*remove old month's data from final_table*/
		SELECT @step = 800
		DELETE FROM dbo.Table_FX_Rates_Timeseries_ECB where COB > @COB_previous_EOM

		/*prepare raw data table */
		SELECT @step = 900
		TRUNCATE TABLE dbo.table_FX_Rates_Timeseries_ECB_raw
		
		/*now import the new data into raw data table*/			 
		SELECT @step = 1000		
		IF @LogInfo >= 1  BEGIN INSERT INTO [dbo].[Logfile] SELECT @proc + ' - import from ' + @Import_Path + @Import_File , GETDATE () END
		SELECT @sql = N'BULK INSERT dbo.table_FX_Rates_Timeseries_ECB_raw FROM '  + '''' + @Import_Path + @Import_File + ''''  + ' WITH (CODEPAGE = 1252, FIELDTERMINATOR ='','', FIRSTROW = 2, ROWTERMINATOR =''0x0a'')';
		EXECUTE sp_executesql @sql
		
		/*transfer the raw data transponed into final data table */			 
		SELECT @step = 1100
		IF @LogInfo >= 1  BEGIN INSERT INTO [dbo].[Logfile] SELECT @proc + ' - transpond raw data for ' + cast(@column_counter as nvarchar) +' currencies into final table', GETDATE () END
		while @column_counter>0
		BEGIN		
			/*identify all columns from the temp table*/
			SELECT @step = 1200
			SELECT 
				  @Column_Name = Column_Name
			FROM 
				(SELECT syscolumns.name as Column_Name, ROW_NUMBER() OVER(ORDER BY sysobjects.ID) AS ROW 
				FROM 
				 syscolumns INNER JOIN sysobjects ON syscolumns.id = sysobjects.id WHERE sysobjects.name = 'table_FX_Rates_Timeseries_ECB_raw'				 
				) as TMP 
			WHERE ROW = @column_counter

			
			/*insert Data for identified into final table*/
			SELECT @step = 1300		
			IF  @Column_Name <> 'Column_43' and @Column_Name <> 'COB' 
				BEGIN
					IF @LogInfo >= 1  BEGIN INSERT INTO [dbo].[Logfile] SELECT @proc + ' - #' + cast(@column_counter as nvarchar) + ': ' + @Column_Name, GETDATE () END
					SET @sql = 'INSERT into dbo.table_FX_Rates_Timeseries_ECB (COB, CCY, FX_RATE,FX_Rate_Comment) 
					SELECT cob, 
					''' + @Column_Name + ''' as CCY, 
					isnull(case when ' + @Column_Name + '=''N/A''then null else ' + @Column_Name + ' end,0) as FX_RATE, 
					case when ' + @Column_Name + '=''N/A'' then ''value from ECB was N/A'' else null end as FX_RATE_comment 
					FROM dbo.table_FX_Rates_Timeseries_ECB_raw 
					WHERE cob > ''' + cast(@COB_previous_EOM as varchar) + ''''
					
					EXEC sp_executesql @sql;		
				END
			ELSE 
				BEGIN 
					IF @LogInfo >= 1  BEGIN INSERT INTO [dbo].[Logfile] SELECT @proc + ' - #' + cast(@column_counter as nvarchar) + ': skipped column ' + @Column_Name, GETDATE () END					
				END	
			
			/*set 0-rates to a value different fom 0 to avoid later division by zero*/
			SELECT @step = 1400
			update dbo.Table_FX_Rates_Timeseries_ECB set fx_rate = 0.0001 where fx_rate_comment ='value from ECB was N/A'
			

			/*reduce column_counter*/
			SELECT @step = 1500
			SELECT @column_counter = @column_counter - 1
		END	

		/*set lastImport timestamp for imported file*/
		SELECT @step = 1600
		UPDATE dbo.filestoimport set LastImport = GETDATE() where ID = @File_ID 
		
		SELECT @step = 1700
		BEGIN insert into [dbo].[Logfile] select @proc + ' - FINISHED' , GETDATE () END
END TRY

	BEGIN CATCH
		EXEC [dbo].[usp_GetErrorInfo] @proc, @step
		BEGIN insert into [dbo].[Logfile] select @proc + ' - FAILED' , GETDATE () END
	END CATCH

GO

