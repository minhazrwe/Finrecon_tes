








/* 
-- =============================================
-- Author:      DS, MKB
-- Created:     Sep 2021
-- Description:	execute clearer import routines for trade data, option premiums and settlement data, 
								run some "global" update scripts on the imported data afterwards, 
								prepare the data to query BIMs of it.
-- Changes (when/who/what):
-- =============================================
*/

CREATE PROCEDURE [dbo].[Import_Clearer_Option_Report] 
AS	
	DECLARE @ReturnValue int	
	DECLARE @proc nvarchar(50)	
	DECLARE @step Integer	
	DECLARE @LogInfo Integer
	DECLARE @counter INTEGER
	DECLARE @sql NVARCHAR(max)
	DECLARE @filename NVARCHAR(100)
	DECLARE @pathname NVARCHAR(300)
		
	BEGIN TRY
		
		SELECT @proc = 'Clearer - ' + Object_Name(@@PROCID)

		SELECT @LogInfo = [dbo].[LogInfo].[LogInfo] FROM [dbo].[LogInfo]
		---SELECT @LogInfo = 0 -- Test
		
		SELECT @step = 0 
		IF @LogInfo >= 1 BEGIN INSERT INTO [dbo].[Logfile] SELECT  @proc +' - START' ,GETDATE() END

		--Drop table table_Clearer_Option_Report_Temp if exists
		IF (EXISTS (SELECT * FROM INFORMATION_SCHEMA.TABLES WHERE table_schema = 'dbo' and TABLE_NAME = 'table_Clearer_Option_Report_Temp'))
		BEGIN
			DROP TABLE [dbo].[table_Clearer_Option_Report_Temp]
		END
		
		SELECT @step = 10
		
		CREATE TABLE [dbo].[table_Clearer_Option_Report_Temp] (
			 [Deal Number][nvarchar](255) NULL
			,[External Business Unit][nvarchar](255) NULL
			,[Internal Business Unit][nvarchar](255) NULL
			,[Internal Legal Entity][nvarchar](255) NULL
			,[Internal Portfolio][nvarchar](255) NULL
			,[Instrument Type][nvarchar](255) NULL
			,[Currency Name][nvarchar](255) NULL
			,[Realized Value][nvarchar](255) NULL
			,[Start Exercise Date][nvarchar](255) NULL
			,[End Exercise Date] [nvarchar](255) NULL
		) ON [PRIMARY]

		SELECT @pathname = dbo.udf_get_path('ClearerOptionReport')

		SELECT @counter = count(1) FROM [dbo].[FilestoImport] WHERE [dbo].[FilestoImport].[Source] IN ('ClearerOptionReport')
		
		WHILE @counter > 0
		BEGIN
			/*Select the filename - It should be just one single file in this case*/
			SELECT @filename = [FileName]
			FROM (
				SELECT *
					,ROW_NUMBER() OVER (
						ORDER BY ID
						) AS ROW
				FROM [dbo].[FilestoImport]
				WHERE [dbo].[FilestoImport].[Source] IN ('ClearerOptionReport')
				) AS TMP
			WHERE ROW = @counter
						

			/*Import CSV into temp table*/
			SELECT @step = 30 
			IF @LogInfo >= 1 BEGIN INSERT INTO [dbo].[Logfile] SELECT 'Import_Clearer_Option_Report - Read file:' + @pathname + @filename   ,GETDATE() END
			
			SELECT @sql = N' SET QUOTED_IDENTIFIER OFF BULK INSERT [dbo].[table_Clearer_Option_Report_Temp]  FROM ' + '''' + @pathname + @filename + '''' + ' WITH (DATAFILETYPE = ''widechar'', CODEPAGE = 1252, FIELDTERMINATOR =''\t'', FIRSTROW = 2, ROWTERMINATOR =''\n'')'
			
			EXECUTE sp_executesql @sql

			SELECT @step = 40
			/*Merge the data into the table_Clearer_map_ExpirationDate table*/
			BEGIN 
				MERGE INTO dbo.table_Clearer_map_ExpirationDate AS target_table
				USING 				
				(
					SELECT 
						REPLACE([Deal Number],char(32),'') AS ReferenceID /*remove spaces*/						
						,Max(dbo.udf_StringToDate([End Exercise Date])) AS ContractExpirationDate 
					FROM 
						[dbo].[table_Clearer_Option_Report_Temp]
					GROUP BY 
						 [Deal Number]
					having Max(dbo.udf_StringToDate([End Exercise Date])) is not null
					) AS source_table
				ON 
				target_table.referenceID = source_table.referenceID 
				WHEN MATCHED THEN 
					UPDATE SET target_table.ContractExpirationDate = source_table.ContractExpirationDate  
				WHEN NOT MATCHED THEN 
					INSERT (ReferenceID, ContractExpirationDate)
					VALUES (source_table.ReferenceID, source_table.ContractExpirationDate);
			END
					
			SELECT @counter = @counter - 1
		END

		SELECT @step = 100 IF @LogInfo >= 1 BEGIN INSERT INTO [dbo].[Logfile] SELECT @proc +' - FINISHED' ,GETDATE() END
	END TRY

	BEGIN CATCH
		EXEC [dbo].[usp_GetErrorInfo] @proc, @step
		BEGIN INSERT INTO [dbo].[Logfile] SELECT  @proc +' - FAILED', GETDATE () END
	END CATCH

GO

