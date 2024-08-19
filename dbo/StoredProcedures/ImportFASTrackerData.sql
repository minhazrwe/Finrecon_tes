


/* 
-- =============================================
-- Author:      MBE
-- Created:     ancient times
-- Description:	
			Inserts data from a csv file, based on the entries in Table dbo.ImportFiles, for the passed @ImportType e.g. Endur
			which would import data into Table EndurImport.
			Calls: omly the ssis-package for import
-- ========================
-- Changes (when/who/what):
-- 2024-01-10 - SU - , StepAdded create HGB valution units
-- =============================================
*/

	CREATE PROCEDURE [dbo].[ImportFASTrackerData] 

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
		select @proc = '[dbo].[ImportFASTrackerData]'

		select @step = @step + 1 
		-- we need the LogInfo for Logging
		select @LogInfo = [dbo].[LogInfo].[LogInfo] from [dbo].[LogInfo]

		if @LogInfo >= 1  BEGIN insert into [dbo].[Logfile] select 'ImportFASTrackerData - START', GETDATE () END

		-- select the source definition, means where the file is located and the name of the file
		select @step = @step + 1 		
		--select @PathName = [path] from [dbo].[PathToFiles] where [source] = 'FASTracker'
		select @PathName = [dbo].[udf_get_path] ('FASTracker')

		-- select the source definition, means where the file is located and the name of the file
		select @step = @step + 1 		
		select @FileName = [FileName] from [dbo].[FilesToImport] where [source] = 'FASTracker'

		select @step = @step + 1 
		select @TimeStamp = getdate()

		select @step = @step + 1
		delete from dbo.[import-FASTracker-Data]
		
		select @step = @step + 1
		if @LogInfo >= 1  BEGIN insert into [dbo].[Logfile] select 'ImportFASTrackerData - importing ' + @PathName + @FileName, GETDATE () END

		select @sql = N'BULK INSERT [import-FASTracker-Data]  FROM '  + '''' + @Pathname + @Filename + ''''  + ' WITH (FIELDTERMINATOR ='','', FIRSTROW = 2, ROWTERMINATOR =''\n'')';
		execute sp_executesql @sql

		select @step = @step + 1
		delete from [dbo].[FASTracker]

		select @step = @step + 1
		insert into [dbo].[FASTracker]([AsofDate],	[Sub ID],[ReferenceID],[Trade Date],[TermStart],[TermEnd],[InternalPortfolio],[SourceSystemBookID],
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

		select @step = @step + 1
		if @LogInfo >= 1  BEGIN insert into [dbo].[Logfile] select 'ImportFASTrackerData - update map_dealId_Ticker', GETDATE () END


		insert into dbo.map_dealID_ticker (dealid, instrumenttypename, ticker, deliverymonth)
		select referenceid, instrumenttype, product + '_' + [counterparty_Extbunit] as term2, 
					cast(year(termend) as nvarchar) + '/' + case when 	cast(month(termend) as varchar) in ('10','11','12') 
						then cast(month(termend) as varchar) else '0' + cast(month(termend) as varchar) end as term
			from 
			(select referenceid, instrumenttype, product, counterparty_extbunit, max(termend) as termend 
			from dbo.fastracker left join dbo.map_dealid_ticker d on referenceId = d.dealid
			where d.dealid is null 
				AND InstrumentType In ('COAL-SWAP-F','COAL-SWAP-STD-F','FREIGHT-SWAP-F','FREIGHT-SWAP-STD-F','GAS-SWAP-F','LNG-SWAP-F','OIL-B-SWAP-F','OIL-SWAP-F','SOFT-SWAP-F','TC-SWAP-F','TC-SWAP-STD-F','PWR-SWAP-F')
				AND CounterpartyGroup = 'external' 
				AND Product Is Not Null 
			group by referenceid, instrumenttype, product, counterparty_extbunit) as f 

		--insert into dbo.fastracker select * from dbo.fastracker_corr
		--delete from [FinRecon].[dbo].[FASTracker] where referenceid in ('22448554_sc','24813976_sc','24977126_sc','25227430_sc','25620639_sc','29618362_sc','34758060_sc','34982641_sc','35067170_sc')

		select @step = @step + 1
		if @LogInfo >= 1  BEGIN insert into [dbo].[Logfile] select 'ImportFASTrackerData - update Ticker in 02_realised_all_details', GETDATE () END

		UPDATE dbo.[02_Realised_all_details] 
		SET dbo.[02_Realised_all_details].Ticker = dbo.map_DealID_Ticker.[Ticker] 
		from dbo.[02_Realised_all_details]  INNER JOIN dbo.map_DealID_Ticker ON dbo.[02_Realised_all_details].Deal = dbo.map_DealID_Ticker.DealID 
		WHERE dbo.[02_Realised_all_details].Ticker Is Null
			 
		/*refill the 2 tables for recon of internal activities. comments are done within the procedure itself, mkb 10/09/2020 */
		select @step = @step + 1
		exec [dbo].[InsertIntoReconInternal]
	

	/*inserted 2024/01*/

		SELECT @step = @step + 1
		EXEC [dbo].[Write_Log] 'Info', 'HBG Valuation Units - START', @proc, @@PROCID, '', @step, @LogInfo, ''
		
		TRUNCATE TABLE [FinRecon].[dbo].[Bewertungseinheiten_pos_neg]
		INSERT INTO [FinRecon].[dbo].[Bewertungseinheiten_pos_neg]
		SELECT
			ReferenceID
			,CASE WHEN (sum(dbo.FASTracker.Discounted_MTM) > 0) THEN 'pos' ELSE 'neg' END AS posneg
		FROM dbo.FASTracker
		GROUP BY ReferenceID

		EXEC [dbo].[Write_Log] 'Info', 'HBG Valuation Units - END', @proc, @@PROCID, '', @step , @LogInfo, ''

		if @LogInfo >= 1  BEGIN insert into [dbo].[Logfile] select 'ImportFASTrackerData - FINISHED', GETDATE () END

	END TRY

	BEGIN CATCH
		--insert into [dbo].[Logfile] select 'ERROR-OCCURED', @TimeStamp
		EXEC [dbo].[usp_GetErrorInfo] @proc, @step
		BEGIN insert into [dbo].[Logfile] select 'ImportFASTrackerData - FAILED', GETDATE () END
	END CATCH

GO

