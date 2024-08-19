
/* 
 ======================================================================================================================
 Author:      YK			
 Created:     September 2022
 Description: Importing IAS39 Flags of Contract für Commodity Solutions (Failed own use)
 -----------------------------------------------------------------------------------------
 updates:
 2023-01-20, Step 8: inserted truncate of final data table before inserting new data to avoid duplicates (mkb)
 ======================================================================================================================
*/

CREATE PROCEDURE [dbo].[Import_IAS39_Flags_of_Contracts] 
AS
BEGIN TRY

	DECLARE @proc nvarchar(50)
	DECLARE @step Integer			
	DECLARE @LogInfo Integer
	
	DECLARE @FileSource nvarchar(300)
	DECLARE @PathName nvarchar (300)
	DECLARE @FileName nvarchar(300)
	DECLARE @FileID int
				
	DECLARE @counter int
	DECLARE @sql nvarchar (max)
	
	SELECT @proc = Object_Name(@@PROCID)
	
	SET @FileSource = 'ContractsImport'

  /* get Info if Logging is enabled */
	SELECT @LogInfo = [dbo].[LogInfo].[LogInfo] FROM [dbo].[LogInfo]
		
	IF @LogInfo >= 1  BEGIN INSERT INTO [dbo].[Logfile] SELECT @proc + ' - START', GETDATE () END
	IF @LogInfo >= 1  BEGIN INSERT INTO [dbo].[Logfile] SELECT @proc + ' - identify and load import file', GETDATE () END
		
	/*identify importpath*/
	SELECT @step=1	
	SELECT @PathName = [dbo].[udf_get_path](@FileSource)   
	
	/*use a counter to check if any files should get imported at all*/
	SELECT @step=2
	SELECT @counter = count(*) FROM [dbo].[FilestoImport] WHERE  [dbo].[FilestoImport].[Source] like @FileSource and ToBeImported=1
	
	/*in case there is no importfile, create a related log entry and jump out*/
	SELECT @step=3
	IF @counter=0 
	BEGIN 
		INSERT INTO [dbo].[Logfile] SELECT @proc + ' - no data found to get imported.', GETDATE () 		
		GOTO NoFurtherAction 
	END	

	/*identify name and ID of to be imported file*/
	SELECT @step=4
	SELECT 
		@FileName = [FileName], 
		@FileID = ID
	from 
		[dbo].[FilestoImport] 
	where 
		[source] = @FileSource
		and ToBeImported=1

	/*drop and re-create temp import table*/
	SELECT @step=5
	IF @LogInfo >= 1  BEGIN INSERT INTO [dbo].[Logfile] SELECT @proc + ' - create tmp_table for import', GETDATE () END
	IF (EXISTS (SELECT * FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_SCHEMA = 'dbo' AND TABLE_NAME = 'table_IAS39_Flags_of_Contracts_TMP'))
		BEGIN DROP TABLE dbo.[table_IAS39_Flags_of_Contracts_TMP] END
	
	SELECT @step=6
	CREATE TABLE [dbo].[table_IAS39_Flags_of_Contracts_TMP]
	( 
		NBAP_ID [nvarchar](200) NULL, 
		[Contract_Name] [nvarchar](200) NULL, 
		Tenant [nvarchar](200) NULL, 
		CP_ID [nvarchar](200) NULL, 
		Counterparty_Name [nvarchar](200) NULL, 
	  [Classification] [nvarchar](200) NULL, 
		Commodity [nvarchar](200) NULL, 
		Base_Contract [nvarchar](200) NULL, 
		Contract_Type [nvarchar](200) NULL, 
		Supply_from [nvarchar](200) NULL,
	  Supply_until [nvarchar](200) NULL, 
		Settlement_Date [nvarchar](200) NULL, 
		Accounting_Forwards [nvarchar](200) NULL, 
		Accounting_Open_Position [nvarchar](200) NULL, 
	  Short_Name_in_ENDUR [nvarchar](200) NULL, 
		Payment_Date_Conditions [nvarchar](200) NULL, 
		Sell_Option [nvarchar](200) NULL, 
		Is_3CP_allowed [nvarchar](200) NULL
		) ON [PRIMARY]
	
	/*bulk import data from file into just created temp table*/						
	SELECT @step=7	
	IF @LogInfo >= 1  BEGIN INSERT INTO [dbo].[Logfile] SELECT @proc + ' - importing ' + ': ' + @PathName + @filename, GETDATE () END			
	SELECT @sql = N'BULK INSERT [dbo].[table_IAS39_Flags_of_Contracts_TMP] FROM '  + '''' + @PathName + @filename + ''''  + ' WITH (CODEPAGE = 1252, FIELDTERMINATOR =''\t'', FIRSTROW = 1, ROWTERMINATOR =''\n'')';
	EXECUTE sp_executesql @sql

	SELECT @step=8	
	/*make sure the final target table is empty before we insert anything to it*/						
	truncate table [dbo].[table_IAS39_Flags_of_Contracts] 
		
	SELECT @step=9
	IF @LogInfo >= 1  BEGIN INSERT INTO [dbo].[Logfile] SELECT @proc + ' - transfer data into target table', GETDATE () END			
	INSERT INTO [dbo].[table_IAS39_Flags_of_Contracts] 
			(	
				[NBAP_ID],
				[Contract_Name],
				[Tenant],
				[CP_ID],
				[Counterparty_Name],
				[Classification],
				[Commodity],
				[Base_Contract],
				[Contract_Type],
				[Supply_from],
				[Supply_until],
				[Settlement_Date],
				[Accounting_Forwards],
				[Accounting_Open_Position],
				[Short_Name_in_ENDUR],
				[Payment_Date_Conditions],
				[Sell_Option],
				[Is_3CP_allowed]				
			)
			SELECT  
				[NBAP_ID],
				[Contract_Name],
				[Tenant],
				[CP_ID],
				[Counterparty_Name],
				[Classification],
				[Commodity],
				[Base_Contract],
				[Contract_Type],
				--CONVERT(date,Supply_from,103) as Supply_from,
				--CONVERT(date,Supply_until,103) as Supply_until,
				--CONVERT(date,Settlement_Date,103) as Settlement_Date,				
				convert(date, substring(Supply_from,7,4) + '-' + substring(Supply_from,4,2) + '-' + substring(Supply_from,1,2)),
				convert(date, substring(Supply_until,7,4) + '-' + substring(Supply_until,4,2) + '-' + substring(Supply_until,1,2)),
				convert(date, substring(Settlement_Date,7,4) + '-' + substring(Settlement_Date,4,2) + '-' + substring(Settlement_Date,1,2)),
				[Accounting_Forwards],
				[Accounting_Open_Position],
				[Short_Name_in_ENDUR],
				[Payment_Date_Conditions],
				[Sell_Option],
				[Is_3CP_allowed]
			FROM 
				[dbo].[table_IAS39_Flags_of_Contracts_TMP]
		
	/*document timestamp for last successful import*/
	SELECT @step=10
	update dbo.FilestoImport set LastImport = GETDATE() WHERE ID = @FileID 

	/*drop temp import table again*/
	SELECT @step=11
	IF @LogInfo >= 1  BEGIN INSERT INTO [dbo].[Logfile] SELECT @proc + ' - cleanup', GETDATE () END
	IF (EXISTS (SELECT * FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_SCHEMA = 'dbo' AND TABLE_NAME = 'table_IAS39_Flags_of_Contracts_TMP'))
		BEGIN DROP TABLE dbo.table_IAS39_Flags_of_Contracts_TMP END
				

NoFurtherAction:
		SELECT @step=666
		IF @LogInfo >= 1 BEGIN INSERT INTO [dbo].[Logfile] SELECT @proc + ' - FINISHED', GETDATE () END
	END TRY

	BEGIN CATCH
		EXEC [dbo].[usp_GetErrorInfo] @proc, @step		
		BEGIN INSERT INTO [dbo].[Logfile] SELECT @proc + ' - FAILED' + @step, GETDATE () END
	END CATCH

GO

