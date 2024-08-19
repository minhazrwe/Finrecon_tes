

/*
=======================================================================================================
Author:      MKB 
Created:     Feb/2021
Name:			   [dbo].[Import_FixedPrice] 

Purpose:	   imports the data from fastracker report "FixedPrice" 

Updates (when--what--who):
=======================================================================================================
*/

	CREATE PROCEDURE [dbo].[ImportFixedPrice] 

	AS
		BEGIN TRY
	
	-- define some variables that been needed
			DECLARE @LogInfo Integer
			DECLARE @proc nvarchar(40)
			DECLARE @step Integer
			
			DECLARE @FileName nvarchar (50) 
			DECLARE @PathName nvarchar (300)
			DECLARE @sql nvarchar (max)
			
			select @proc = '[dbo].[Import_FixedPrice]'
	
			select @step = 1
			select @LogInfo = [dbo].[LogInfo].[LogInfo] from [dbo].[LogInfo]

			IF @LogInfo >= 1  BEGIN insert into [dbo].[Logfile] select 'Import_FixedPrice - START', GETDATE () END

			--/*identify to be imported file and import it*/
			select @step = @step + 1 		
			select @PathName = [dbo].[udf_get_path] ('FixedPrice')
			
			select @step = @step + 1 		
			select @FileName = [FileName] from [dbo].[FilesToImport] where [source] = 'FixedPrice' and ToBeImported = 1

			--/*truncating temp_table*/
			select @step = @step + 1 		
			truncate table [dbo].[temp_table_FixedPrice]
	
			--/*now the import itself*/
			select @step = @step + 1 	
			IF @LogInfo >= 1  BEGIN insert into [dbo].[Logfile] select 'Import_FixedPrice - importing ' + @Pathname + @Filename , GETDATE () END
			select @sql = N'BULK INSERT [dbo].[temp_table_FixedPrice] FROM '  + '''' + @Pathname + @Filename + ''''  + ' WITH (FIELDTERMINATOR ='','', FIRSTROW = 2, ROWTERMINATOR =''\n'')';
			execute sp_executesql @sql
			
			--/*transfer the just imported data to final destination*/
			select @step = @step + 1	 
			IF @LogInfo >= 1  BEGIN insert into [dbo].[Logfile] select 'Import_FixedPrice - select data from temp table into data table', GETDATE () END

			INSERT INTO [dbo].[table_FixedPrice]
        ( [Strategy]
         ,[ReferenceID]
         ,[TermEnd]
         ,[FixedPrice]
         ,[DealCurrency]
         ,[FixedFloat]
			  )
				SELECT 
			     [Strategy]
          ,[Reference_ID]
          ,convert( date, [Term_End] ,104)
          ,cast([Fixed_Price] as float)
          ,[Deal_Currency]
          ,[Fixed_Float]
        FROM 
				   [dbo].[temp_table_FixedPrice]

			IF @LogInfo >= 1  BEGIN insert into [dbo].[Logfile] select 'Import_FixedPrice - FINISHED', GETDATE () END

		END TRY

		BEGIN CATCH
			EXEC [dbo].[usp_GetErrorInfo] '[dbo].[Import_FixedPrice]', @step
			BEGIN insert into [dbo].[Logfile] select 'Import_FixedPrice - FAILED', GETDATE () END
		END CATCH

GO

