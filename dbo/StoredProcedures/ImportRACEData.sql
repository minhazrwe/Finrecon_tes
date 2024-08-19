
/*
	Inserts data from a csv file, based on the entries in Table dbo.ImportFiles, for the passed @ImportType e.g. Endur
	which would import data into Table EndurImport.
	Calls: omly the ssis-package for import
*/
	CREATE PROCEDURE [dbo].[ImportRACEData] 

	AS
	BEGIN TRY
		-- define some variables that been needed
		DECLARE @package nvarchar(200)
		DECLARE @CurrentServer nvarchar(200)
		DECLARE @StarterParm nvarchar(500)
		DECLARE @StarterDB nvarchar(50)
		DECLARE @FileName nvarchar (50) 
		DECLARE @PathName nvarchar (300)
		DECLARE @TimeStamp datetime
		DECLARE @LogInfo Integer
		DECLARE @proc nvarchar(40)
		DECLARE @step Integer
		DECLARE @asofdate datetime
		DECLARE @sql nvarchar (max)

		select @step = 1
		select @proc = '[dbo].[ImportRACEData]'

		-- we need the LogInfo for Logging
		select @LogInfo = [dbo].[LogInfo].[LogInfo] from [dbo].[LogInfo]

		select @step = @step + 1
		select @PathName = [dbo].[udf_get_path] ('Power_Mengen_Abstimmung')

		select @step = @step + 1
		select @FileName = 'temp_RACE.csv'

		if @LogInfo >= 1  BEGIN insert into [dbo].[Logfile] select '### getdate ###', GETDATE () END
		select @step = @step + 1
		select @TimeStamp = getdate()
	
		select @step = @step + 1
		if @LogInfo >= 1  BEGIN insert into [dbo].[Logfile] select @PathName + @FileName, @TimeStamp END

		select @step = @step + 1
		truncate table [dbo].[import-RACE525]
		truncate table [dbo].[RACE525]

		select @step = @step + 1
    	select @sql = N'BULK INSERT .[dbo].[import-RACE525] FROM '  + '''' + @PathName + @FileName + ''''  + ' WITH (FIELDTERMINATOR ='','', FIRSTROW = 2, ROWTERMINATOR =''\n'')';
		execute sp_executesql @sql

		select @step = @step + 1
		insert into [FinRecon].[dbo].[RACE525] ([Kons],[RACE-Pos#],[Produkt],[Sachkonto],[Kontentext] ,[Partner],[Wert in HW],[Menge],[ME],[Status])
		SELECT [Kons],[RACE-Pos#],[Produkt],[Sachkonto],[Kontentext],[Partner],convert(float,[Wert in HW]),convert(float,[Menge]),[ME], [Status] FROM [FinRecon].[dbo].[import-RACE525]

		select @step = @step + 1
		update [dbo].FilestoImport Set LastImport = @TimeStamp where [Source] = 'Power_Mengen_Abstimmung'

	END TRY

	BEGIN CATCH
		--insert into [dbo].[Logfile] select 'ERROR-OCCURED', @TimeStamp
		EXEC [dbo].[usp_GetErrorInfo] @proc, @step
	END CATCH

GO

