

/* 
-- =============================================
-- Author:      MKB			
-- Created:     07/2022
-- Description:	importing data from Fastracker Report "KID FX RECON"
-- =============================================
*/

---drop PROCEDURE [dbo].[Import_KIDFX_RECON] 
CREATE PROCEDURE [dbo].[Import_KIDFX_RECON] 
AS
BEGIN TRY

  DECLARE @step Integer		
	DECLARE @proc nvarchar(50)
	DECLARE @LogInfo Integer
	
	DECLARE @FileSource nvarchar(300)
	DECLARE @PathSource nvarchar(300)
	DECLARE @PathName nvarchar (300)
	DECLARE @FileName nvarchar(300)
				
	DECLARE @sql nvarchar (max)
	DECLARE @counter Integer
	DECLARE @TotalRecordsInserted nvarchar(13)
	
	SELECT @proc = Object_Name(@@PROCID)
	
	SET @FileSource = 'KIDFX_RECON'
	SET @PathSource = 'KIDFX'

  --/* get Info if Logging is enabled */
	SELECT @LogInfo = [dbo].[LogInfo].[LogInfo] FROM [dbo].[LogInfo]

	IF @LogInfo >= 1  BEGIN INSERT INTO [dbo].[Logfile] SELECT @proc + ' - START', GETDATE () END
	IF @LogInfo >= 1  BEGIN INSERT INTO [dbo].[Logfile] SELECT @proc + ' - identify and load import files', GETDATE () END

	--/*use a counter to get all available files*/
	SELECT @step = 10
	SELECT @counter = count(*) FROM [dbo].[FilestoImport] WHERE  [dbo].[FilestoImport].[Source] like @FileSource and ToBeImported=1
	 	
	SELECT @step=20
	IF (EXISTS (SELECT * FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_SCHEMA = 'dbo' AND TABLE_NAME = 'table_KIDFX_Recon_tmp'))
	BEGIN DROP TABLE dbo.table_KIDFX_Recon_tmp END
	
	SELECT @step=25
	CREATE TABLE [dbo].[table_KIDFX_Recon_tmp]
	(
		[Reference_ID] [nvarchar](50) NULL,
		[Trade_Date] [date] NULL,
		[Term_End] [date] NULL,
		[Internal_Portfolio] [nvarchar](50) NULL,
		[Counterparty] [nvarchar](50) NULL,
		[Counterparty_Group] [nvarchar](50) NULL,
		[Volume] [float] NULL,
		[Curve_Name] [nvarchar](50) NULL,
		[Projection_Index_Group] [nvarchar](50) NULL,
		[Instrument_Type] [nvarchar](50) NULL,
		[Fixed_Price_CCY] [nvarchar](50) NULL,
		[Discounted_PNL] [float] NULL,
		[Subsidiary] [nvarchar](50) NULL,
		[Transaction_Type] [nvarchar](50) NULL,
		[Reference] [nvarchar](50) NULL
	) ON [PRIMARY]
	
		--/*identify importpath*/
	SELECT @PathName = [dbo].[udf_get_path](@PathSource)      

	--/*loop over counter, reduce it at then end*/ 	
	WHILE @counter >0
		BEGIN			
			--/*identify importfile*/
		  SELECT @step=30
			SELECT 
				@FileName = [FileName]
			FROM (SELECT *, ROW_NUMBER() OVER(ORDER BY ID) AS ROW  
            FROM [dbo].[FilestoImport] 
            WHERE [dbo].[FilestoImport].[Source] like @FileSource and ToBeImported=1) as TMP 
      WHERE ROW = @counter
			
			SELECT @step=40						
			--/*import data into temp table*/						
			IF @LogInfo >= 1  BEGIN INSERT INTO [dbo].[Logfile] SELECT @proc + ' - importing ' + cast(@counter as varchar) + ': ' + @PathName + @filename, GETDATE () END			
			SELECT @sql = N'BULK INSERT [dbo].[table_KIDFX_Recon_tmp] FROM '  + '''' + @PathName + @filename + ''''  + ' WITH (CODEPAGE = 1252, FIELDTERMINATOR =''~'', FIRSTROW = 2, ROWTERMINATOR =''0x0a'')';
			--SELECT @sql = N'BULK INSERT [dbo].[table_KIDFX_Recon_tmp] FROM '  + '''' + @PathName + @filename + ''''  + ' WITH (CODEPAGE = 1252, FIELDTERMINATOR =''~'', FIRSTROW = 2, ROWTERMINATOR =''\n'')';
			
			EXECUTE sp_executesql @sql
		
			--/*now document the last successful import timestamp and take the file from the list of to be imported files*/
			SELECT @step=50
			update [dbo].[FilestoImport] set LastImport = getdate() WHERE [Source] like @FileSource and [filename]= @filename 
		
		 --	/*reduce counter*/
			SELECT @step=60
			SELECT @counter = @counter - 1
		END				

/********************************************************************************************************************************************************/
		--/*delete old data from target table*/
		SELECT @step=70
		truncate TABLE dbo.[table_KIDFX_Recon]
		
		SELECT @step=75
		INSERT INTO [dbo].[table_KIDFX_Recon]
           ([Reference_ID]
           ,[Trade_Date]
           ,[Term_End]
           ,[Internal_Portfolio]
           ,[Counterparty]
           ,[Counterparty_Group]
           ,[Volume]
           ,[Curve_Name]
           ,[Projection_Index_Group]
           ,[Instrument_Type]
           ,[Fixed_Price_CCY]
           ,[Discounted_PNL]
           ,[Subsidiary]
           ,[Transaction_Type]
           ,[Reference])
			 SELECT 
				[Reference_ID]
				,[Trade_Date]
				,[Term_End]
				,[Internal_Portfolio]
				,[Counterparty]
				,[Counterparty_Group]
				,[Volume]
				,[Curve_Name]
				,[Projection_Index_Group]
				,[Instrument_Type]
				,[Fixed_Price_CCY]
				,[Discounted_PNL]
				,[Subsidiary]
				,[Transaction_Type]
				,[Reference]
			FROM 
				[dbo].[table_KIDFX_Recon_tmp]
		
		SELECT @step=90
		IF @LogInfo >= 1 BEGIN INSERT INTO [dbo].[Logfile] SELECT @proc + ' - imported records: '+ @TotalRecordsInserted, GETDATE () END

		/*procedure was successful*/
		RETURN 1

	END TRY

	BEGIN CATCH
		EXEC [dbo].[usp_GetErrorInfo] @proc, @step		
		BEGIN INSERT INTO [dbo].[Logfile] SELECT @proc + ' - FAILED', GETDATE () END
		
		/*procedure failed*/
		Return 0
	END CATCH

GO

