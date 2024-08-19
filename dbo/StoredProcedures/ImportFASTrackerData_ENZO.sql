

/*
	Inserts data from a csv file, based on the entries in Table dbo.ImportFiles, for the passed @ImportType e.g. Endur
	which would import data into Table EndurImport.
	Calls: omly the ssis-package for import
*/
	CREATE PROCEDURE [dbo].[ImportFASTrackerData_ENZO] 

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
		DECLARE @step Integer
		DECLARE @proc varchar(40)
		DECLARE @sql nvarchar (max)

		select @step = 1
		-- we need the prc-name for error-handling
		select @proc = '[dbo].[ImportFASTrackerData_ENZO]'

		select @step = @step + 1 
		-- we need the LogInfo for Logging
		select @LogInfo = [dbo].[LogInfo].[LogInfo] from [dbo].[LogInfo]

		if @LogInfo >= 1  BEGIN insert into [dbo].[Logfile] select 'ImportFASTrackerData_ENZO - START', GETDATE () END

		-- select the source definition, means where the file is located and the name of the file
		select @step = @step + 1 		
		select @PathName = [dbo].[udf_get_path] ('FASTracker')

		-- select the source definition, means where the file is located and the name of the file
		select @step = @step + 1 		
		select @FileName = [FileName] from [dbo].[FilesToImport] where [source] = 'FASTracker'

		select @step = @step + 1 
		select @TimeStamp = getdate()

		select @step = @step + 1
		delete from dbo.[import-FASTracker-Data]
		
		select @step = @step + 1
		if @LogInfo >= 1  BEGIN insert into [dbo].[Logfile] select 'ImportFASTrackerData_ENZO - importing ' + @PathName + @FileName, GETDATE () END

		select @sql = N'BULK INSERT [import-FASTracker-Data]  FROM '  + '''' + @Pathname + @Filename + ''''  + ' WITH (FIELDTERMINATOR ='','', FIRSTROW = 2, ROWTERMINATOR =''\n'')';
		execute sp_executesql @sql

		select @step = @step + 1
		delete from [dbo].[FASTracker_ENZO]

		select @step = @step + 1
		insert into [dbo].[FASTracker_ENZO]([AsofDate],	[Sub ID],[ReferenceID],[Trade Date],[TermStart],[TermEnd],[InternalPortfolio],[SourceSystemBookID],
			[Counterparty_ExtBunit],[CounterpartyGroup],[Volume],[FixedPrice],[CurveName],[ProjIndexGroup],	[InstrumentType],[UOM],
			[ExtLegalEntity],[ExtPortfolio],[Product], [Discounted_MTM],[Discounted_PNL],[Discounted_AOCI],[Undiscounted_MTM],	[Undiscounted_PNL],
			[Undiscounted_AOCI],[Volume Available],	[Volume Used])
		SELECT  
			CONVERT(datetime,case when [AsofDate] = '' then NULL else [AsofDate] end ,104),
			cast([Sub ID] as Integer),[ReferenceID],
			CONVERT(datetime,case when [Trade Date] = ''  then NULL else [Trade Date] end ,104),
			CONVERT(datetime,case when [TermStart] = ''  then NULL else [TermStart] end ,104),
			CONVERT(datetime,case when [TermEnd] = ''  then NULL else [TermEnd] end ,104),
			[InternalPortfolio],[SourceSystemBookID],[Counterparty_ExtBunit],[CounterpartyGroup],
			cast([Volume] as float),cast([FixedPrice] as float),
			[CurveName],[ProjIndexGroup],[InstrumentType],[UOM],[ExtLegalEntity],[ExtPortfolio], [Product],
			cast([Discounted_MTM] as float),cast([Discounted_PNL] as float),cast([Discounted_AOCI] as float),cast([Undiscounted_MTM] as float),
			cast([Undiscounted_PNL] as float),cast([Undiscounted_AOCI] as float),cast([Volume Available] as float),cast([Volume Used] as float)
		FROM [dbo].[import-FASTracker-Data]

		select @step = @step + 1
		delete from dbo.[import-FASTracker-Data]

		if @LogInfo >= 1  BEGIN insert into [dbo].[Logfile] select 'ImportFASTrackerData_ENZO - FINISHED', GETDATE () END

	END TRY

	BEGIN CATCH
		--insert into [dbo].[Logfile] select 'ERROR-OCCURED', @TimeStamp
		EXEC [dbo].[usp_GetErrorInfo] @proc, @step
		BEGIN insert into [dbo].[Logfile] select 'ImportFASTrackerData_ENZO - FAILED', GETDATE () END
	END CATCH

GO

