



/*
	Inserts data from a csv file, based on the entries in Table dbo.ImportFiles, for the passed @ImportType e.g. Endur
	which would import data into Table EndurImport.
	Calls: omly the ssis-package for import
*/
	CREATE PROCEDURE [dbo].[ImportSBMData] 

	AS
	BEGIN TRY
		-- define some variables that been needed
		DECLARE @package nvarchar(200)
		DECLARE @CurrentServer nvarchar(200)
		DECLARE @StarterParm nvarchar(500)
		DECLARE @StarterDB nvarchar(50)
		DECLARE @FileName nvarchar (50) 
		DECLARE @PathName nvarchar (300)
		DECLARE @machineName nvarchar(255)
		DECLARE @FileID Integer
		DECLARE @TimeStamp datetime
		DECLARE @LogInfo Integer
		DECLARE @proc nvarchar(40)
		DECLARE @step Integer
		DECLARE @asofdate datetime
		DECLARE @sql nvarchar (max)

		select @step = 1
		select @proc =  Object_Name(@@PROCID)
		select  TOP 1 @machineName = HOST_NAME()
		select @LogInfo = [dbo].[LogInfo].[LogInfo] from [dbo].[LogInfo]
		
		select @asofdate = [AsOfDate_EOM] from [dbo].[AsOfDate]



		if @LogInfo >= 1  BEGIN insert into [dbo].[Logfile] select @proc + ' - START', GETDATE () END

		select @step = 2
		-- Wait for 30 Seconds to ensure excel is closed.
		WAITFOR DELAY '00:00:30'; 
		

		select @step = 3
		-- select path and filename 		
		select @PathName = [dbo].[udf_get_path] ('SBM')
		select @FileName = [FileName],@FileID = [ID] from [dbo].[FilesToImport] where [source] = 'SBM'
			

		select @step = 4
		-- log the start of the procedure with the source file definitions		
		select @TimeStamp = getdate()
		if @LogInfo >= 1  BEGIN insert into [dbo].[Logfile] select @proc + ' - importing: ' + @PathName + @FileName, @TimeStamp END

		select @step = 5
		--truncate import table 		
		delete from [dbo].[Import-SBM-Data]

		select @step = 6
		--Starting IMPORT		
		select @sql = N'BULK INSERT [dbo].[Import-SBM-Data]  FROM '  + '''' + @pathname + @filename + ''''  + ' WITH (FIELDTERMINATOR ='','', FIRSTROW = 2, ROWTERMINATOR =''\n'')';
		execute sp_executesql @sql

		select @step = 7
		--delete from final table 		
		delete from [dbo].[map_SBM]

		select @step = 8
		--truncate final table 
		delete from [dbo].[map_SBM]

		select @step = 9
		--fill final table
		insert into [dbo].[map_SBM] ([AsOfDate],[Subsidiary],[Strategy],[Book],[InternalPortfolio],[CounterpartyGroup],
				[InstrumentType],[ProjectionIndexGroup],[AccountingTreatment],[HedgeSTAsset],[HedgeLTAsset],
				[HedgeSTLiability],[HedgeLTLiability],[UnhedgedSTAsset],[UnhedgedLTAsset],[UnhedgedSTLiability],
				[UnhedgedLTLiability],[AOCI_Hedge Reserve],[UnrealizedEarnings],[PortfolioID])
		select @asofdate, isnull([Subsidiary],''),isnull([Strategy],''),isnull([Book],''),isnull([Internal Portfolio],''),isnull([Counterparty Group],''),
				isnull([Instrument Type],''),isnull([Projection Index Group],''),isnull([Accounting Treatment],''),isnull([Hedge ST Asset],''),isnull([Hedge LT Asset],''),
				isnull([Hedge ST Liability],''),isnull([Hedge LT Liability],''),isnull([Unhedged ST Asset],''),isnull([Unhedged LT Asset],''),isnull([Unhedged ST Liability],''),
				isnull([Unhedged LT Liability],''),isnull([AOCI Hedge Reserve],''),isnull([Unrealized Earnings],''),isnull([Internal Portfolio ID],'')
			from [dbo].[Import-SBM-Data]

		select @step = 10
			---statistics
	  update [dbo].[FilestoImport] SET 
			[dbo].[FilestoImport].[LastImport] =GETDATE ()
		WHERE 
			[dbo].[FilestoImport].[ID] = @FileID
		
		if @LogInfo >= 1  BEGIN insert into [dbo].[Logfile] select @proc + ' - FINISHED', GETDATE () END

	END TRY

	BEGIN CATCH
		EXEC [dbo].[usp_GetErrorInfo] @proc, @step
		BEGIN insert into [dbo].[Logfile] select @proc + ' - FAILED: ' + CURRENT_USER + ' on ' + @machineName + ' on server: ' + @@SERVERNAME, GETDATE () END
	END CATCH

GO

