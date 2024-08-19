



/* 
-- =============================================
-- Author:      MU
-- Created:     May 2022
-- Description:	Imports the endur report Finance_Options_Report which is provided as a file Finance_Options_no_PNL*.xlsx.
				The file is converted to a '~' delimited csv file in UTF-8 (without BOM) encoding and provided in folder: 
				\\energy.local\rwest\RWE-Trading\TC\CoE-AT-C\03_DailyWorkings\01_RWEST\Exchanges\ClearerOptionReport
				The data is imported into table_Clearer_map_ExpirationDate to provide a mapping deal number to expiry date.
-- Changes (when/who/what):
-- =============================================

ATTENTION (2022-09-01): This Stored Procedure is not used. It has been created as a replace ment for  [dbo].[Import_Clearer_Option_Report] by importing another report.
However, the new report has not provided the needed data. Therefore this Stored procedure can be deleted if not needed in the near future. 

*/

CREATE PROCEDURE [dbo].[Import_Clearer_ExpiryData] 
AS	
	DECLARE @ReturnValue int	
	DECLARE @proc nvarchar(50)	
	DECLARE @step Integer	
	DECLARE @LogInfo Integer
	DECLARE @counter INTEGER
	DECLARE @sql NVARCHAR(max)
	DECLARE @filename NVARCHAR(100)
	DECLARE @pathname NVARCHAR(300)
	DECLARE @source NVARCHAR(30)
		
	BEGIN TRY
		
		SELECT @proc = 'Clearer - ' + Object_Name(@@PROCID)
		Select @source = 'ClearerExpiryData' --Reference to find the file and path from PathToFiles and FilesToImport tables.

		SELECT @LogInfo = [dbo].[LogInfo].[LogInfo] FROM [dbo].[LogInfo]
		SELECT @LogInfo = 0 -- Test
		
		SELECT @step = 0 
		IF @LogInfo >= 1 BEGIN INSERT INTO [dbo].[Logfile] SELECT  @proc +' - START' ,GETDATE() END

		--Drop table table_Clearer_Option_Report_Temp if exists
		IF (EXISTS (SELECT * FROM INFORMATION_SCHEMA.TABLES WHERE table_schema = 'dbo' and TABLE_NAME = 'table_Clearer_map_ExpirationDate_Temp'))
		BEGIN
			DROP TABLE [dbo].[table_Clearer_map_ExpirationDate_Temp]
		END
		
		SELECT @step = 10
		
		CREATE TABLE [dbo].[table_Clearer_map_ExpirationDate_Temp] (
			 [Deal Number][nvarchar](255) NULL
			,[Exercise Date] [nvarchar](255) NULL
		) ON [PRIMARY]

		SELECT @pathname = dbo.udf_get_path(@source)

		SELECT @counter = count(1) FROM [dbo].[FilestoImport] WHERE [dbo].[FilestoImport].[Source] IN (@source)
		
		WHILE @counter > 0
		BEGIN
			/*Select the filename - \\energy.local\rwest\RWE-Trading\TC\CoE-AT-C\03_DailyWorkings\01_RWEST\Exchanges\ClearerOptionReport\Finance_Options_no_PNL.xlsx*/
			SELECT @filename = [FileName]
			FROM (
				SELECT *
					,ROW_NUMBER() OVER (
						ORDER BY ID
						) AS ROW
				FROM [dbo].[FilestoImport]
				WHERE [dbo].[FilestoImport].[Source] IN (@source)
				) AS TMP
			WHERE ROW = @counter
						

			/*Import CSV into temp table*/
			SELECT @step = 30 
			IF @LogInfo <= 1 BEGIN INSERT INTO [dbo].[Logfile] SELECT  @proc + ' - Read file:' + @pathname + @filename   ,GETDATE() END
			
			SELECT @sql = N' SET QUOTED_IDENTIFIER OFF BULK INSERT [dbo].[table_Clearer_map_ExpirationDate_Temp]  FROM ' + '''' + @pathname + @filename + '''' + ' WITH (DATAFILETYPE = ''widechar'', CODEPAGE = 1252, FIELDTERMINATOR =''~'', FIRSTROW = 2, ROWTERMINATOR =''\n'')'
			
			EXECUTE sp_executesql @sql

			SELECT @step = 40
			/*Merge the data into the table_Clearer_map_ExpirationDate table*/
			BEGIN 
			MERGE INTO dbo.table_Clearer_map_ExpirationDate AS target_table
				USING 				
				(
					SELECT 
						REPLACE([Deal Number],char(32),'') AS ReferenceID /*remove spaces*/						
						,dbo.udf_StringToDate(Max([Exercise Date])) AS ContractExpirationDate 
					FROM 
						[dbo].[table_Clearer_map_ExpirationDate_Temp]
					GROUP BY 
						 [Deal Number]
					) AS source_table
				ON 
				target_table.referenceID = source_table.referenceID 
				WHEN NOT MATCHED THEN 
					INSERT (ReferenceID, ContractExpirationDate)
					VALUES (source_table.ReferenceID, source_table.ContractExpirationDate);
			END
					
			SELECT @counter = @counter - 1
		END

		--DROP TABLE [dbo].[table_Clearer_map_ExpirationDate_Temp]

		SELECT @step = 100 IF @LogInfo >= 1 BEGIN INSERT INTO [dbo].[Logfile] SELECT @proc +' - FINISHED' ,GETDATE() END
	END TRY

	BEGIN CATCH
		EXEC [dbo].[usp_GetErrorInfo] @proc, @step
		BEGIN INSERT INTO [dbo].[Logfile] SELECT  @proc +' - FAILED', GETDATE () END
	END CATCH

GO

