









/*
=============================================
Author:			MK
Created:		2024/03
Description:	Importing Rock realised dumps to update data of exisitng records
---------------------------------------------
updates:
DATE, STEP: Description (Person)


==============================================
*/

CREATE PROCEDURE [dbo].[Update_US_Realised_Data]
AS
BEGIN TRY

	DECLARE @step Integer
	DECLARE @proc nvarchar(50)
	DECLARE @LogInfo Integer
	DECLARE @LogRowCount nvarchar(10)

	DECLARE @FileSource nvarchar(300)
	DECLARE @PathName nvarchar (300)
	DECLARE @FileName nvarchar(300)
	DECLARE @FileID Integer

	DECLARE @sql nvarchar (max)
	DECLARE @counter Integer

	SELECT @proc = Object_Name(@@PROCID)

	SET @FileSource = 'US_Realised_Update'

	/* get Info if Logging is enabled */
	SELECT @LogInfo = [dbo].[LogInfo].[LogInfo] FROM [dbo].[LogInfo]

	IF @LogInfo >= 1  BEGIN INSERT INTO [dbo].[Logfile] SELECT @proc + ' - START', GETDATE () END

	/*identify importpath (same for all files)*/
	SELECT @step = 2
	IF @LogInfo >= 1  BEGIN INSERT INTO [dbo].[Logfile] SELECT @proc + ' - identify and load import files', GETDATE () END
	SELECT @PathName = [dbo].[udf_get_path](@FileSource)

	/*count the number of files that should get imported*/
	SELECT @step = 3
	SELECT @counter = count(*) FROM [dbo].[FilestoImport] WHERE  [dbo].[FilestoImport].[Source] like @FileSource and ToBeImported=1

	-- in case here is no importfile, just refill the 01_realised table and set DeleteFlags
	IF @counter=0
	BEGIN
		INSERT INTO [dbo].[Logfile] SELECT @proc + ' - No data found to import. ', GETDATE ()
		GOTO NoFurtherAction
	END

	
	SELECT @step=4
	IF @LogInfo >= 1  BEGIN INSERT INTO [dbo].[Logfile] SELECT @proc + ' - start to import ' + cast(@counter as varchar) + ' files from: ' + @PathName, GETDATE () END

	/*loop over counter, reduce it at then end*/
	WHILE @counter >0
		BEGIN
		  SELECT @step=10
			SELECT
				 @FileName = [FileName]
				,@FileID = [ID]
			FROM
			(SELECT *, ROW_NUMBER() OVER(ORDER BY ID) AS ROW FROM [dbo].[FilestoImport] WHERE [dbo].[FilestoImport].[Source] like @FileSource and ToBeImported=1) as TMP WHERE ROW = @counter

			/*prepare data tables*/
			SELECT @step=11
			TRUNCATE TABLE dbo.table_US_Realised_Data_Update_Importdata

			SELECT @step=12
			/*import data into import table*/
			IF @LogInfo >= 1  BEGIN INSERT INTO [dbo].[Logfile] SELECT @proc + ' - importing ' + cast(@counter as varchar) + ': ' + @filename, GETDATE () END
			SELECT @sql = N'BULK INSERT [dbo].[table_US_Realised_Data_Update_Importdata] FROM '  + '''' + @PathName + @filename + ''''  + ' WITH (CODEPAGE = 1252, FIELDTERMINATOR =''~'', FIRSTROW = 2, ROWTERMINATOR =''0x0a'')';
			EXECUTE sp_executesql @sql

			/*now document the last successful import timestamp*/
			SELECT @step=13
			update [dbo].[FilestoImport] set LastImport = getdate() WHERE [Source] like @FileSource and [filename]= @filename and ToBeImported=1

			-- Update volumes for PWR-FWD-PPA-P if leg is in reporting month (only these records have outdated volumes)
			IF @LogInfo >= 1  BEGIN INSERT INTO [dbo].[Logfile] SELECT @proc + ' - Overwriting data in 01_realised_all', GETDATE () END

			UPDATE [dbo].[01_realised_all]
			SET [dbo].[01_realised_all].[Volume] = cast(UpDa.[Volume] as float)
			,[dbo].[01_realised_all].[Realised_OrigCCY_Undisc] = cast(UpDa.[REAL_UNDISC_CASHFLOW_CCY_YTD] as float)+cast(UpDa.[UNREAL_UNDISC_CASHFLOW_CCY] as float)
			,[dbo].[01_realised_all].[Realised_OrigCCY_Disc] = cast(UpDa.[REAL_DISC_CASHFLOW_CCY_YTD] as float) + cast(UpDa.[UNREAL_DISC_CASHFLOW_CCY] as float)
			,[dbo].[01_realised_all].[Realised_DeskCCY_Undisc] = cast(UpDa.[REAL_UNDISC_PH_IM1_CCY_YTD] as float) +cast(UpDa.[UNREAL_UNDISC_PH_IM1_CCY] as float)
			,[dbo].[01_realised_all].[Realised_DeskCCY_Disc] = cast(UpDa.[REAL_DISC_PH_IM1_CCY_YTD] as float) +cast(UpDa.[UNREAL_DISC_PH_IM1_CCY] as float)
			,[dbo].[01_realised_all].[Realised_EUR_Undisc] = cast(UpDa.[REAL_UNDISC_PH_BL_CCY_YTD] as float)+cast(UpDa.[UNREAL_UNDISC_PH_BL_CCY] as float)
			,[dbo].[01_realised_all].[Realised_EUR_Disc] = cast(UpDa.[REAL_DISC_PH_BL_CCY_YTD] as float) +cast(UpDa.[UNREAL_DISC_PH_BL_CCY] as float)
			,[dbo].[01_realised_all].[Realised_GBP_Undisc] = IIF(UpDa.INTERMEDIATE1_CURRENCY  = 'GBP',cast(UpDa.[REAL_UNDISC_PH_IM1_CCY_YTD] as float),0)+IIF(UpDa.INTERMEDIATE1_CURRENCY  = 'GBP',cast(UpDa.[UNREAL_UNDISC_PH_IM1_CCY] as float),0)
			,[dbo].[01_realised_all].[Realised_GBP_Disc] = IIF(UpDa.INTERMEDIATE1_CURRENCY = 'GBP', cast(UpDa.[REAL_DISC_PH_IM1_CCY_YTD] as float),0)+IIF(UpDa.INTERMEDIATE1_CURRENCY  = 'GBP',cast(UpDa.[UNREAL_DISC_PH_IM1_CCY] as float),0)
			,[dbo].[01_realised_all].[Realised_USD_Undisc] = IIF(UpDa.INTERMEDIATE1_CURRENCY  = 'USD',cast(UpDa.[REAL_UNDISC_PH_IM1_CCY_YTD] as float),0) +IIF(UpDa.INTERMEDIATE1_CURRENCY  = 'USD',cast(UpDa.[UNREAL_DISC_PH_IM1_CCY] as float),0)
			,[dbo].[01_realised_all].[Realised_USD_Disc] = IIF(UpDa.INTERMEDIATE1_CURRENCY  = 'USD',cast(UpDa.[REAL_DISC_PH_IM1_CCY_YTD] as float),0) +IIF(UpDa.INTERMEDIATE1_CURRENCY  = 'USD',cast(UpDa.[UNREAL_DISC_PH_IM1_CCY] as float),0)
			,[dbo].[01_realised_all].[Comment] = left(isnull([dbo].[01_realised_all].[Comment],'') + '§Data Updated',255)
			FROM [dbo].[01_realised_all]
			INNER JOIN [dbo].[table_US_Realised_Data_Update_Importdata] AS UpDa
			ON [dbo].[01_realised_all].[Trade Deal Number] = UpDa.[DEAL_NUMBER]
			AND [dbo].[01_realised_all].[Leg End Date] = convert(date,UpDa.[DEAL_PDC_END_DATE],103)
			AND [dbo].[01_realised_all].[Cashflow Settlement Type] = UpDa.[SETTLEMENT_TYPE_NAME]
			WHERE [dbo].[01_realised_all].[Leg End Date] = EOMonth((SELECT AsOfDate_EOM FROM AsOfDate))
			AND [dbo].[01_realised_all].[Instrument Type Name] IN ('PWR-FWD-PPA-P')

			SET @LogRowCount = CAST(@@ROWCOUNT AS nvarchar(10))

			IF @LogInfo >= 1  BEGIN INSERT INTO [dbo].[Logfile] SELECT @proc + ' - ' + @LogRowCount + ' data overwritten in 01_realised_all', GETDATE () END

			/*reduce counter*/
			SELECT @step=14
			SELECT @counter = @counter - 1
		END

		-- Empty help tables
		Truncate table dbo.table_US_Realised_Data_Update_Importdata

NoFurtherAction:
		IF @LogInfo >= 1 BEGIN INSERT INTO [dbo].[Logfile] SELECT @proc + ' - FINISHED', GETDATE () END
	END TRY

	BEGIN CATCH
		EXEC [dbo].[usp_GetErrorInfo] @proc, @step
		BEGIN INSERT INTO [dbo].[Logfile] SELECT @proc + ' - FAILED', GETDATE () END
	END CATCH

GO

