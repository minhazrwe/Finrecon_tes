









/*
 =============================================
 Author:      mkb
 Created:     2022/10
 Description:	importing Realised Data from dumped files
 ---------------------------------------------
 updates: (when, step, what and why, who)
 2022-11-25, Step 32: excluded physical settlements for instype "GAS-FWD-STD-P" (MBE)
 2022-11-28, Step 32: excluded physical settlements for instype "PWR-FWD-P", "PWR-FWD-STD-P"  (MU)
 2022-11-29, Step 32: excluded physical settlements for instype "GAS-FWD-P"  (MU)
 2022-11-28, Step 25: excluded adding of unrealised LtD to realised YtD (mkb)
 2023-02-28,					removed AsOfDate_EOM and AsOfDate_EOY as they are not needed (MBE)
 2023-05-04, step 4+5: removed drop & create of table_REALISED_Rawdata  (mkb)
						 step 11: truncate table_REALISED_Rawdata in loop instead of delete/re-create  (mkb)
						 step 12+13:	switched, to ensure data is not deleted from rawdata before the import into importdata was successful
 2023-06-13, step 45: added new manual filter for a certain deal (YK/mkb)
 2023-10-27, step 45: added filtering for CAO US data (MK/MBE)
 2023-11-28, step 41 + 45: added exception for 'GPM DESK' + IRS' for metric definition and filtering (YK/MK)
 2024-02-28, step 45: Removed GPM Desk from 5th filter by request of April Xin (MK)
 2024-03-13, Step 45: Added PWR-HR-EXCH-P instrument type to 'Delete Physical Cashflows for specific Instruments'-filter. CAO US requirement. (MK)
 2024-03-20, Step 45: Added Exception for ADM INVESTOR SERVICES INC with certain Insturment Types on request of Geoff (MK)
 2024-04-03, Step 45: Added Exception for FIFTH STANDARD SOLAR PV with Insturment Type = 'PWR-FEE' on request of Geoff (MK)
 2024-04-08, Step 45: Added Exception for SOFT-FUT-EXCH-P, which have a Cashflow Payment Date on 2nd Jan but have been reported in 2024, (SH)
 2024-04-11, Step 45: Excluded 'RWEST_ERCOT_HEDGE_CERT', 'RWEST_PJM_HEDGE_CERT' from filter (MK)
 2024-04-29, Step 45: Added FileID = 3269 (IFA Deals) in Strolf exclusion and new filter to exclude IFA deals from rock provision (MK)
 2024-05-06, Step 45: Added Desk = "STRUCTURED ORIGINATION DESK" and InsType = 'WTH-SWAP-F' to "'Delete Cashflow with Leg End Date > Reporting Month for EUROPEAN GAS DESK (Instrument specific)'" (MT+MK)
 2024-05-29, Step 0: Added optional Parameter @USOnly (MK)
			Step 3: Set of counter = 1 in case of @USOnly = 1, so just US realised is imported (MK)
			Step 10: Set Filename and ID in case of @USOnly = 1, so just US realised is imported (MK)
 2024-06-05, Step 45: Removed [Int Legal Entity Name] condition from IFA filter, because it needs periodic updates and is not necessary (MK)
 2024-06-24, Step 45: Changed US filters according to Geoffs wishes (MK)
 ==============================================
*/


-- @USOnly optional variable (default = 0) is used to import US realised data only, to make CAO US data import as userfriendly as possible without interference with global data import.

CREATE PROCEDURE [dbo].[Import_Realised_Data] @USOnly BIT = 0
AS
BEGIN TRY

	DECLARE @step Integer
	DECLARE @proc nvarchar(50)
	DECLARE @LogInfo Integer

	DECLARE @FileSource nvarchar(300)
	DECLARE @PathName nvarchar (300)
	DECLARE @FileName nvarchar(300)
	DECLARE @FileID Integer

	DECLARE @AsOfDate_EOLY date /*End of last year*/
	DECLARE @AsOfDate_BOLY date /*Beginning of last year*/
	DECLARE @AsOfDate_LastDayOfMonth date /*Last calendar day of the reporting month*/
	DECLARE @AsOfDate_BOCY date /*Beginning of current year*/
	DECLARE @AsOfDate_BOCYS date /*Beginning of current year day2*/

	DECLARE @sql nvarchar (max)
	DECLARE @counter Integer

	DECLARE	@RecordCount1 Integer
	DECLARE @RecordCount2 Integer
	DECLARE @RecordCount3 Integer

	SELECT @proc = Object_Name(@@PROCID)

	SET @FileSource = 'Realised'

  /* get Info if Logging is enabled */
	SELECT @LogInfo = [dbo].[LogInfo].[LogInfo] FROM [dbo].[LogInfo]

	IF @LogInfo >= 1  BEGIN INSERT INTO [dbo].[Logfile] SELECT @proc + ' - START', GETDATE () END

	SELECT @step = 1
	select
		 @AsOfDate_EOLY = EOMonth(asofdate_eoy) /*End of Last year*/
		,@AsOfDate_BOLY =  DATEADD(yy, DATEDIFF(yy, 0, asofdate_eoy), 0) /*Beginning of Last Year*/
		,@AsOfDate_LastDayOfMonth = EOMonth(AsOfDate_EOM)

		--,@AsOfDate_BOCY = CAST((SELECT year([AsOfDate_EOM]) FROM [FinRecon].[dbo].[AsOfDate]) AS varchar) + '-01-01'
		--,@AsOfDate_BOCYS = CAST((SELECT year([AsOfDate_EOM]) FROM [FinRecon].[dbo].[AsOfDate]) AS varchar) + '-01-02'

		/*better, as  [Cashflow Payment Date] is a date and no varchar !!!:*/
		,@AsOfDate_BOCY = dateadd(day,1,eomonth(asofdate_eoy))
		,@AsOfDate_BOCYS =dateadd(day,2,eomonth(asofdate_eoy))
	from
		dbo.AsOfDate

	/*identify importpath (same for all files)*/
	SELECT @step = 2
	IF @LogInfo >= 1  BEGIN INSERT INTO [dbo].[Logfile] SELECT @proc + ' - identify and load import files', GETDATE () END
	SELECT @PathName = [dbo].[udf_get_path](@FileSource)


	/*count the number of files that should get imported*/
	SELECT @step = 3
	IF @USOnly = 0
		BEGIN
			SELECT @counter = count(*) FROM [dbo].[FilestoImport] WHERE  [dbo].[FilestoImport].[Source] like @FileSource and ToBeImported=1
			/*in case here is no importfile, just refill the 01_realised table and set DeleteFlags*/
			IF @counter=0
			BEGIN
				INSERT INTO [dbo].[Logfile] SELECT @proc + ' - no data found to get imported. ', GETDATE ()
				GOTO CopyDataAndSetDeleteFlag
			END
		END
	-- Exception for just importing US data (@USOnly = 1) -> Set counter = 1.
	ELSE
		BEGIN
			SET @counter = 1
		END

	/*preparing raw_data table*/
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

			-- Exception for just importing US data (@USOnly = 1) -> Overwrite fileName and FileID.
			IF @USOnly = 1
			BEGIN
				SET @FileName = 'Fin_Realised_CAOUS.csv'
				SELECT @FileID = [ID] FROM [dbo].[FilestoImport] WHERE [FileName] = @FileName and [Source] =  @FileSource
			END

			/*prepare data tables*/
			SELECT @step=11
			TRUNCATE TABLE dbo.table_REALISED_Importdata

			SELECT @step=12
			/*import data into import table*/
			IF @LogInfo >= 1  BEGIN INSERT INTO [dbo].[Logfile] SELECT @proc + ' - importing ' + cast(@counter as varchar) + ': ' + @filename, GETDATE () END
			SELECT @sql = N'BULK INSERT [dbo].[table_REALISED_Importdata] FROM '  + '''' + @PathName + @filename + ''''  + ' WITH (CODEPAGE = 1252, FIELDTERMINATOR =''~'', FIRSTROW = 2, ROWTERMINATOR =''0x0a'')';
			EXECUTE sp_executesql @sql

			/*remove empty rawdata table*/
			SELECT @step=13
			delete from dbo.table_Realised_Rawdata where FileID = @FileID

			/*transfer data into rawdata table*/
			SELECT @step=14
			INSERT INTO [dbo].table_REALISED_Rawdata
			(
			 [COB]
			,[Trade Deal Number]
			,[Trade Reference Text]
			,[Transaction Info Status]
			,[Instrument Toolset Name]
			,[Instrument Type Name]
			,[Int Legal Entity Name]
			,[Int Business Unit Name]
			,[Internal Portfolio Business Key]
			,[Internal Portfolio Name]
			,[External Portfolio Name]
			,[Ext Business Unit Name]
			,[Ext Legal Entity Name]
			,[Index Name]
			,[Trade Currency]
			,[Transaction Info Buy Sell]
			,[Cashflow Type]
			,[Side Pipeline Name]
			,[Instrument Subtype Name]
			,[Discounting Index Name]
			,[Trade Price]
			,[Cashflow Delivery Month]
			,[Trade Date]
			,[Index Contract Size]
			,[Discounting Index Contract Size]
			,[Trade Instrument Reference Text]
			,[Unit Name (Trade Std)]
			,[Leg Exercise Date]
			,[Cashflow Payment Date]
			,[Leg End Date]
			,[Index Group]
			,[Delivery Vessel Name]
			,[Static Ticket ID]
			,SETTLEMENT_TYPE_NAME
			,[Volume]
			,[PnL YtD Realised Undiscounted Original Currency]
			,[PnL YtD Realised Discounted EUR]
			,[PnL YtD Realised Undiscounted EUR]
			,[PnL YtD Realised Discounted GBP]
			,[PnL YtD Realised Undiscounted GBP]
			,[PnL YtD Realised Discounted USD]
			,[PnL YtD Realised Undiscounted USD]
			,[Unrealised Discounted EUR]
			,[Unrealised Undiscounted EUR]
			,[Unrealised Discounted GBP]
			,[Unrealised Undiscounted GBP]
			,[Unrealised Discounted Original Currency]
			,[Unrealised Undiscounted Original Currency]
			,[Unrealised Discounted USD]
			,[Unrealised Undiscounted USD]
			,[DESK_NAME]
			,[INTERMEDIATE1_NAME]
			,[BOOK_NAME]
			,INTERMEDIATE1_CURRENCY
			,[REAL_DISC_CASHFLOW_CCY_YTD]
			,[REAL_UNDISC_PH_IM1_CCY_YTD]
			,[REAL_DISC_PH_IM1_CCY_YTD]
			,[UNREAL_UNDISC_PH_IM1_CCY]
			,[UNREAL_DISC_PH_IM1_CCY]
			,SOURCE_OF_ROW
			,[Fileid]
			)
			SELECT
				 convert(date, COB,103) as COB
				,[DEAL_NUMBER] as [Trade Deal Number]
				,[REFERENCE_TEXT] as [Trade Reference Text]
				,[TRANSACTION_STATUS_NAME] as [Transaction Info Status]
				,[INSTRUMENT_TOOLSET_NAME]
				,[INSTRUMENT_TYPE_NAME]
				,[INTERNAL_LEGAL_ENTITY_PARTY_NAME] as [Int Legal Entity Name]
				,[INT_BUSINESS_UNIT_NAME] as [Int Business Unit Name]
				,[DIM_INTERNAL_PORTFOLIO_CURRENT_ID] as [Internal Portfolio Business Key]
				,[PORTFOLIO_NAME] as [Internal Portfolio Name]
				,[EXTERNAL_PORTFOLIO_NAME]
				,[EXT_BUSINESS_UNIT_NAME] as [Ext Business Unit Name]
				,[EXTERNAL_LEGAL_ENTITY_PARTY_NAME] as [Ext Legal Entity Name]
				,[INDEX_NAME]
				,[CASHFLOW_CURRENCY] as [Trade Currency]
				,[BUY_SELL_NAME] as [Transaction Info Buy Sell]
				,[CASHFLOW_TYPE]
				,[PIPELINE_NAME] as [Side Pipeline Name]
				,[INSTRUMENT_SUBTYPE_NAME]
				,[DISCOUNTING_INDEX_NAME]
				,case when TRADE_PRICE  like '\\N' then cast(0 as float) else cast(trade_price as float) end as [Trade Price]
				,convert(date,DELIVERY_MONTH,103) as [Cashflow Delivery Month]
				,convert(date,TRADE_DATE,103) as [Trade Date]
				,NULL as [Index Contract Size]
				,NULL as [Discounting Index Contract Size]
				,[INSTRUMENT_REFERENCE_TEXT] as [Trade Instrument Reference Text]
				,[SOURCE_UNIT_NAME] as [Unit Name (Trade Std)]
				,convert(date, [PDC_EXERCISE_DATE],103) as [Leg Exercise Date]
				,convert(date,[PAYMENT_DATE],103) as [Cashflow Payment Date]
				,convert(date,[DEAL_PDC_END_DATE],103) AS [Leg End Date]
				,[INDEX_GROUP_NAME] as [Index Group]
				,[DELIVERY_VESSEL_NAME] as [Delivery Vessel Name]
				,NULL as [Static Ticket ID]
				,SETTLEMENT_TYPE_NAME
				,cast([Volume] as float) AS [VOLUME]
				,cast([REAL_UNDISC_CASHFLOW_CCY_YTD] as float) AS [PnL YtD Realised Undiscounted Original Currency]
				,cast([REAL_DISC_PH_BL_CCY_YTD] as float) AS [PnL YtD Realised Discounted EUR]
				,cast([REAL_UNDISC_PH_BL_CCY_YTD] as float) AS [PnL YtD Realised Undiscounted EUR]
				,IIF(INTERMEDIATE1_CURRENCY = 'GBP', cast([REAL_DISC_PH_IM1_CCY_YTD] as float),0) as [PnL YtD Realised Discounted GBP]
				,IIF(INTERMEDIATE1_CURRENCY  = 'GBP',cast([REAL_UNDISC_PH_IM1_CCY_YTD] as float),0) as [PnL YtD Realised Undiscounted GBP]
				,IIF(INTERMEDIATE1_CURRENCY  = 'USD',cast([REAL_DISC_PH_IM1_CCY_YTD] as float),0) as [PnL YtD Realised Discounted USD]
				,IIF(INTERMEDIATE1_CURRENCY  = 'USD',cast([REAL_UNDISC_PH_IM1_CCY_YTD] as float),0) as [PnL YtD Realised Undiscounted USD]
				,cast([UNREAL_DISC_PH_BL_CCY] as float) AS [Unrealised Discounted EUR]
				,cast([UNREAL_UNDISC_PH_BL_CCY] as float) AS [Unrealised Undiscounted EUR]
				,IIF(INTERMEDIATE1_CURRENCY  = 'GBP',cast([UNREAL_DISC_PH_IM1_CCY] as float),0) AS [Unrealised Discounted GBP]
				,IIF(INTERMEDIATE1_CURRENCY  = 'GBP',cast([UNREAL_UNDISC_PH_IM1_CCY] as float),0) AS [Unrealised Undiscounted GBP]
				,cast([UNREAL_DISC_CASHFLOW_CCY] as float) AS [Unrealised Discounted Original Currency]
				,cast([UNREAL_UNDISC_CASHFLOW_CCY] as float) AS [Unrealised Undiscounted Original Currency]
				,IIF(INTERMEDIATE1_CURRENCY  = 'USD',cast([UNREAL_DISC_PH_IM1_CCY] as float),0) AS [Unrealised Discounted USD]
				,IIF(INTERMEDIATE1_CURRENCY  = 'USD',cast([UNREAL_DISC_PH_IM1_CCY] as float),0) AS [Unrealised Undiscounted USD]
				,[DESK_NAME]
				,[INTERMEDIATE1_NAME]
				,[BOOK_NAME]
				,INTERMEDIATE1_CURRENCY
				,cast([REAL_DISC_CASHFLOW_CCY_YTD] as float) as [REAL_DISC_CASHFLOW_CCY_YTD]
				,cast([REAL_UNDISC_PH_IM1_CCY_YTD] as float)  as [REAL_UNDISC_PH_IM1_CCY_YTD]
				,cast([REAL_DISC_PH_IM1_CCY_YTD] as float) as  [REAL_DISC_PH_IM1_CCY_YTD]
				,cast([UNREAL_UNDISC_PH_IM1_CCY] as float) as [UNREAL_UNDISC_PH_IM1_CCY]
				,cast([UNREAL_DISC_PH_IM1_CCY] as float) as [UNREAL_DISC_PH_IM1_CCY]
				,SOURCE_OF_ROW
				,@Fileid as FileID
			FROM
				[FinRecon].[dbo].table_REALISED_Importdata

				/*now document the last successful import timestamp*/
				SELECT @step=28
				update [dbo].[FilestoImport] set LastImport = getdate() WHERE [Source] like @FileSource and [filename]= @filename and ToBeImported=1

				SELECT @recordcount1 = COUNT(*) from dbo.table_REALISED_Rawdata where FileID=@fileid
				IF @LogInfo >= 1  BEGIN INSERT INTO [dbo].[Logfile] SELECT @proc + ' - imported ' + cast(@counter as varchar) + ': ' + @filename + ' - records imported: '+ cast(format(@recordcount1,'#,#') as varchar), GETDATE () END

		 		/*reduce counter*/
				SELECT @step=29
				SELECT @counter = @counter - 1
		END

		/*number of records before we start hte updates and deletes on the import data*/
		SELECT @step=30
		select @RecordCount1 = count(*) from [dbo].table_REALISED_Rawdata

CopyDataAndSetDeleteFlag:

		/*now transfer data into final table [01_realised_all]*/
		IF @LogInfo >= 1  BEGIN INSERT INTO [dbo].[Logfile] SELECT @proc + ' - transfer data into final table [01_realised_all]', GETDATE () END
		SELECT @step=40
		delete from dbo.[01_realised_all] where FileID not in ('2210','2450','3269') /*empty final table*/

		SELECT @step=41
		INSERT INTO [dbo].[01_realised_all]
			(
				[Trade Deal Number]
				,[Trade Reference Text]
				,[Transaction Info Status]
				,[Instrument Toolset Name]
				,[Instrument Type Name]
				,[Int Legal Entity Name]
				,[Int Business Unit Name]
				,[Internal Portfolio Business Key]
				,[Desk Name]
				,[Intermediate1 Name]
				,[Book Name]
				,[Internal Portfolio Name]
				,[External Portfolio Name]
				,[Ext Business Unit Name]
				,[Ext Legal Entity Name]
				,[Index Name]
				,[Trade Currency]
				,[Transaction Info Buy Sell]
				,[Cashflow Type]
				,[Cashflow Settlement Type]
				,[Side Pipeline Name]
				,[Instrument Subtype Name]
				,[Discounting Index Name]
				,[Trade Price]
				,[Document Number]
				,[Cashflow Delivery Month]
				,[Trade Date]
				,[Index Contract Size]
				,[Discounting Index Contract Size]
				,[Trade Instrument Reference Text]
				,[Unit Name (Trade Std)]
				,[Leg Exercise Date]
				,[Cashflow Payment Date]
				,[Leg End Date]
				,[Index Group]
				,[Delivery Vessel Name]
				,[Static Ticket ID]
				,[Source Of Row]
				,[COB]
				,[Desk Currency]
				,[volume]
				,[Realised_OrigCCY_Undisc]
				,[Realised_OrigCCY_Disc]
				,[Realised_DeskCCY_Undisc]
				,[Realised_DeskCCY_Disc]
				,[Realised_EUR_Undisc]
				,[Realised_EUR_Disc]
				,[Realised_GBP_Undisc]
				,[Realised_GBP_Disc]
				,[Realised_USD_Undisc]
				,[Realised_USD_Disc]
				,[Delivery Month]
				,[ToBeDeleted]
				,[Comment]
				,[FileID]
			)
			SELECT
				 [Trade Deal Number]
				,[Trade Reference Text]
				,[Transaction Info Status]
				,[Instrument Toolset Name]
				,[Instrument Type Name]
				,[Int Legal Entity Name]
				,[Int Business Unit Name]
				,[Internal Portfolio Business Key]
				,[DESK_NAME]
				,[INTERMEDIATE1_NAME]
				,[BOOK_NAME]
				,[Internal Portfolio Name]
				,[External Portfolio Name]
				,CASE
																			WHEN [Ext Business Unit Name] like '%Ã„%' THEN replace([Ext Business Unit Name],'Ã„','Ä')
																			WHEN [Ext Business Unit Name] like '%Â %' THEN replace([Ext Business Unit Name],'Â ','')
																			WHEN [Ext Business Unit Name] like '%Ãœ%' THEN replace([Ext Business Unit Name],'Ãœ','Ü')
																			WHEN [Ext Business Unit Name] like '%Ã–%' THEN replace([Ext Business Unit Name],'Ã–','Ö')
																			WHEN [Ext Business Unit Name] like '%Ã‡%' THEN replace([Ext Business Unit Name],'Ã‡','Ç')
																			WHEN [Ext Business Unit Name] like '%Ã%'  THEN replace([Ext Business Unit Name],'Ã','Á')
																			WHEN [Ext Business Unit Name] like '%Ã“%' THEN replace([Ext Business Unit Name],'Ã“','Ó')
																			WHEN [Ext Business Unit Name] like '%Ã‘%' THEN replace([Ext Business Unit Name],'Ã‘','Ñ')
																			WHEN [Ext Business Unit Name] like '%Á“%' THEN replace([Ext Business Unit Name],'Á“','Ó')
																			WHEN [Ext Business Unit Name] like '%Ã–%' THEN replace([Ext Business Unit Name],'Ã–','ö')
																			WHEN [Ext Business Unit Name] like '%Ãœ%' THEN replace([Ext Business Unit Name],'Ãœ','ü')
																			ELSE [Ext Business Unit Name]  /*keep the original value in case no special character appears*/
																		END as [Ext Business Unit Name]
				,CASE
																		WHEN [Ext Legal Entity Name] like '%Ã„%' THEN replace([Ext Legal Entity Name],'Ã„','Ä')
																		WHEN [Ext Legal Entity Name] like '%Â %' THEN replace([Ext Legal Entity Name],'Â ','')
																		WHEN [Ext Legal Entity Name] like '%Ãœ%' THEN replace([Ext Legal Entity Name],'Ãœ','Ü')
																		WHEN [Ext Legal Entity Name] like '%Ã–%' THEN replace([Ext Legal Entity Name],'Ã–','Ö')
																		WHEN [Ext Legal Entity Name] like '%Ã‡%' THEN replace([Ext Legal Entity Name],'Ã‡','Ç')
																		WHEN [Ext Legal Entity Name] like '%Ã%'  THEN replace([Ext Legal Entity Name],'Ã','Á')
																		WHEN [Ext Legal Entity Name] like '%Ã“%' THEN replace([Ext Legal Entity Name],'Ã“','Ó')
																		WHEN [Ext Legal Entity Name] like '%Ã‘%' THEN replace([Ext Legal Entity Name],'Ã‘','Ñ')
																		WHEN [Ext Legal Entity Name] like '%Á“%' THEN replace([Ext Legal Entity Name],'Á“','Ó')
																		WHEN [Ext Legal Entity Name] like '%Ã–%' THEN replace([Ext Legal Entity Name],'Ã–','ö')
																		WHEN [Ext Legal Entity Name] like '%Ãœ%' THEN replace([Ext Legal Entity Name],'Ãœ','ü')
																		ELSE [Ext Legal Entity Name] /*keep the original value in case no special character appears*/
																	END as [Ext Legal Entity Name]
				,[Index Name]
				,[Trade Currency]
				,[Transaction Info Buy Sell]
				,[Cashflow Type]
				,[SETTLEMENT_TYPE_NAME]
				,[Side Pipeline Name]
				,[Instrument Subtype Name]
				,[Discounting Index Name]
				,[Trade Price]
				,NULL as [Document Number]
				,convert(varchar,[Cashflow Delivery Month],103)
				,[Trade Date]
				,[Index Contract Size]
				,[Discounting Index Contract Size]
				,[Trade Instrument Reference Text]
				,[Unit Name (Trade Std)]
				,[Leg Exercise Date]
				,[Cashflow Payment Date]
				,[Leg End Date]
				,[Index Group]
				,[Delivery Vessel Name]
				,[Static Ticket ID]
				,[SOURCE_OF_ROW]
				,[COB]
				,[INTERMEDIATE1_CURRENCY]
				,[volume]
				,IIF([DESK_NAME] = 'GPM DESK' AND [Instrument Type Name] = 'IRS', [PnL YtD Realised Undiscounted Original Currency], [PnL YtD Realised Undiscounted Original Currency] + [Unrealised Undiscounted Original Currency]) as [Realised_OrigCCY_Undisc]
				,IIF([DESK_NAME] = 'GPM DESK' AND [Instrument Type Name] = 'IRS', [REAL_DISC_CASHFLOW_CCY_YTD], [REAL_DISC_CASHFLOW_CCY_YTD] + [Unrealised Discounted Original Currency]) as [Realised_OrigCCY_Disc]
				,IIF([DESK_NAME] = 'GPM DESK' AND [Instrument Type Name] = 'IRS', [REAL_UNDISC_PH_IM1_CCY_YTD], [REAL_UNDISC_PH_IM1_CCY_YTD] + [UNREAL_UNDISC_PH_IM1_CCY]) as [Realised_DeskCCY_Undisc]
				,IIF([DESK_NAME] = 'GPM DESK' AND [Instrument Type Name] = 'IRS', [REAL_DISC_PH_IM1_CCY_YTD], [REAL_DISC_PH_IM1_CCY_YTD]   + [UNREAL_DISC_PH_IM1_CCY]) as [Realised_DeskCCY_Disc]
				,IIF([DESK_NAME] = 'GPM DESK' AND [Instrument Type Name] = 'IRS', [PnL YtD Realised Undiscounted EUR], [PnL YtD Realised Undiscounted EUR] + [Unrealised Undiscounted EUR]) as [Realised_EUR_Undisc]
				,IIF([DESK_NAME] = 'GPM DESK' AND [Instrument Type Name] = 'IRS', [PnL YtD Realised Discounted EUR], [PnL YtD Realised Discounted EUR] + [Unrealised Discounted EUR]) as [Realised_EUR_Disc]
				,IIF([DESK_NAME] = 'GPM DESK' AND [Instrument Type Name] = 'IRS', [PnL YtD Realised Undiscounted GBP], [PnL YtD Realised Undiscounted GBP] + [Unrealised Undiscounted GBP]) as [Realised_GBP_Undisc]
				,IIF([DESK_NAME] = 'GPM DESK' AND [Instrument Type Name] = 'IRS', [PnL YtD Realised Discounted GBP], [PnL YtD Realised Discounted GBP] + [Unrealised Discounted GBP]) as [Realised_GBP_Disc]
				,IIF([DESK_NAME] = 'GPM DESK' AND [Instrument Type Name] = 'IRS', [PnL YtD Realised Undiscounted USD], [PnL YtD Realised Undiscounted USD] + [Unrealised Undiscounted USD]) as [Realised_USD_Undisc]
				,IIF([DESK_NAME] = 'GPM DESK' AND [Instrument Type Name] = 'IRS', [PnL YtD Realised Discounted USD], [PnL YtD Realised Discounted USD]+  [Unrealised Discounted USD]) as [Realised_USD_Disc]
				,NULL as [Delivery Month] /*Attention: The logic for Delivery Month is implemented in AnalyseData*/
				,0 as [ToBeDeleted]
				,NULL as [Comment]
				,[FileID]
			FROM
				dbo.table_REALISED_Rawdata

		--Truncate table dbo.table_REALISED_Rawdata

		/*Set ToBeDeleted Flag and add a comment*/
		/*ATTENTION the conditions in the Case-Statement need to match the Where-Statement*/
		SELECT @step=45
		Update [01_realised_all]
		Set [Comment] =
			Case
			when abs(isnull([volume],0)) + abs(isnull([Realised_OrigCCY_Undisc],0)) + abs(isnull([Realised_OrigCCY_Disc],0)) + abs(isnull([Realised_EUR_Undisc],0)) + abs(isnull([Realised_EUR_Disc],0)) + abs(isnull([Realised_GBP_Undisc],0)) + abs(isnull([Realised_GBP_Disc],0)) + abs(isnull([Realised_USD_Undisc],0)) + abs(isnull([Realised_USD_Disc],0)) = 0
				then 'Delete Cashflow when volume and Realised PnL is 0'
			when [Internal Portfolio Business Key] in (select Portfolio_Key from dbo.map_not_needed_Portfolios)
				then 'Delete Cashflow when Pfolio is listed in table "map_not_needed_Portfolios"'
			when [Cashflow Type] in ('Broker Fee', 'Buyout Proceeds')
				then 'Delete Cashflows "Broker Fee" and "Buyout Proceeds"'
			when [Cashflow Settlement Type] = 'Physical Settlement' and [Instrument Type Name] in ('BIOFUEL-FWD','BIOFUEL-STOR','BIOFUEL-STOR-V12','BIOFUEL-TRANSIT','COAL-FWD','COAL-STEV','COAL-STOR','COAL-STOR-V12','COAL-TRANSIT','EM-FWD-P','EM-FWD-VAL-P','FERT-FWD-P','FERT-TRANSIT-P','FREIGHT-FWD','GAS-FWD-IMB-P','GAS-FWD-P','GAS-FWD-STD-P','GAS-FWD-VAL-P','GAS-SWING-P','LNG-FWD-P','LNG-REGAS-P','LNG-STOR-P','LNG-TC-FWD-P','LNG-TRANS-P','OIL-FWD','ORE-FWD-P','PWR-ASSET-P','PWR-CAP-P','PWR-HR-EXCH-P','PWR-FWD-P','PWR-FWD-PPA-P','PWR-FWD-STD-P','PWR-FWD-VAL-P','PWR-FWD-WD-P','PWR-OPT-TRANS-H-P','PWR-TRANS-P','REN-FWD-P','TC-FWD', 'OIL-BUNKER-ROLL-P')
				then 'Delete Physical Cashflows for specific Instruments'
			when [Cashflow Settlement Type] = 'Physical Settlement' and [Desk Name] not in ('COAL AND FREIGHT DESK','CONTINENTAL TRADING DESK','EUROPEAN GAS DESK','UK TRADING DESK','LNG DESK') and [Instrument Type Name] in ('OIL-BUNKER-ROLL-P','MTL-FWD-EXCH-P','GAS-EXCH-P','GAS-STOR-P','GAS-FWD-MAKEUP-P')
				then 'Delete Physical Cashflows for specific Instruments and Desks'
			when [Instrument Type Name] = 'FX' and [Cashflow Type] not like 'FX Swap' and [Cashflow Payment Date] > @AsOfDate_LastDayOfMonth
				then 'Delete FX Cashflows (non swap) where Cashflow Payment Date > AsOfDate'
			when [Instrument Type Name] = 'FX' and [Leg End Date] > @AsOfDate_LastDayOfMonth
				then 'Delete FX Cashflows where Leg End Date > AsOfDate'
			when [Cashflow Payment Date] < @AsOfDate_BOLY and [Desk Name] not in ('CAO UK')
				then 'Delete Cashflows with a Cashflow Payment Date < Beginning of Last Business Year'
			when [Instrument Type Name] like '%OPT%' and [Cashflow Payment Date] > @AsOfDate_LastDayOfMonth and [Leg End Date] > @AsOfDate_LastDayOfMonth
				then 'Delete Option Cashflows with Cashflow Payment Date and Leg End Date > Reporting Month'
			when [Desk Name] = 'GPM DESK' and [Cashflow Type] = 'Cleaning Materials'
				then 'Delete Cashflow Type "Cleaning Materials" for GPM Desk'
			when [Desk Name] IN ('EUROPEAN GAS DESK','STRUCTURED ORIGINATION DESK') and [Leg End Date] > @AsOfDate_LastDayOfMonth and [Instrument Type Name] in ('GAS-SWING-P','GAS-FWD-STD-P','WTH-SWAP-F')
				then 'Delete Cashflow with Leg End Date > Reporting Month for EUROPEAN GAS DESK and SO (Instrument specific)'
			when [Desk Name] in ('EUROPEAN GAS DESK','UK TRADING DESK') and convert(date,[Cashflow Delivery Month],103) <= @AsOfDate_EOLY and [Cashflow Payment Date] <= @AsOfDate_EOLY and [Instrument Type Name] in ('GAS-FUT-AVG-EXCH-P' )
				then 'Delete Cashflow for EUROPEAN GAS DESK which are old (GAS-FWD-P,GAS-FUT-AVG-EXCH-P)'
			when [Desk Name] in ('EUROPEAN GAS DESK','MANAGEMENT BOOKS','LNG DESK') and convert(date,[Cashflow Delivery Month],103) > @AsOfDate_EOLY and [Cashflow Payment Date] > @AsOfDate_EOLY and  [Leg End Date] > @AsOfDate_EOLY and [Trade Date] <= @AsOfDate_EOLY and [Instrument Type Name]  in ('GAS-FUT-AVG-EXCH-P','GAS-FUT-AVG-EXCH-F') AND [Source Of Row] = 'LGBY'
				then 'Delete LGBY Cashflows for EUROPEAN GAS DESK and MANAGEMENT BOOKS (GAS-FUT-AVG-EXCH-P)'
			when [Desk Name] in ('STRUCTURED ORIGINATION DESK') and [Cashflow Payment Date] <= @AsOfDate_EOLY and [Instrument Type Name]  in ('WTH-SWAP-F')
				then 'Delete Cashflow for Structured Origination (GPG - Power) with type WTH-SWAP-F and payment date last year'
			when [Desk Name] IN ('STRUCTURED ORIGINATION DESK','MANAGEMENT BOOKS','CONTINENTAL TRADING DESK') AND [Leg Exercise Date] like '%1900%' and [Leg End Date] > @AsOfDate_LastDayOfMonth AND convert(date,[Cashflow Delivery Month],103) > @AsOfDate_LastDayOfMonth  AND ([Instrument Toolset Name] = 'ComFut' )
				then 'Delete Cashflow for Structured Origination, Management Books and Conti with Leg End Date in the future (ComFut)'
			when [Desk Name] in ('GENERATION UK DA DESK','GENERATION UK DESK')
				then 'Delete Cashflows for CAO UK which are coming from Generation Desks (becky)'
			when [Desk Name] in ('BIOFUELS DESK','ASIA-PACIFIC TRADING DESK') and [Leg End Date] > @AsOfDate_LastDayOfMonth and convert(date,[Cashflow Delivery Month],103) > @AsOfDate_LastDayOfMonth and [Leg Exercise Date] like '%1900%' and [Instrument Type Name] NOT in ('COMM-FEE' )
				then 'Delete Cashflows for BIOFUELS DESK / ASIA-PACIFIC TRADING DESK when LegEndDate and Delivery Month > COB Month'
			when [Desk Name] IN ('LNG DESK') AND [Instrument Type Name] in ('COMM-FEE') and convert(datetime,[Cashflow Delivery Month],103) <= @AsOfDate_EOLY and  [Cashflow Payment Date] <=  @AsOfDate_EOLY
				then 'Delete Cashflows for LNG Desks and Instrument COMM-FEE when Deliv and Pay in previous year'
			when [Desk Name] IN ('CONTINENTAL TRADING DESK') AND [Instrument Type Name] like '%OPT%' and convert(datetime,[Cashflow Delivery Month],103) <= @AsOfDate_EOLY and  [Cashflow Payment Date] <=  @AsOfDate_EOLY
				then 'Delete Cashflows for CONTINENTAL TRADING DESK when Delivery and Payment in previous year (%OPT%)'
			when [Instrument Type Name] not like '%OPT%' and  [Instrument Toolset Name] not In  ('FX', 'Swap', 'ComFut') and [Cashflow Payment Date] > @AsOfDate_LastDayOfMonth and [Leg End Date] > @AsOfDate_LastDayOfMonth
				then 'Delete Cashflows with Leg End Date and Cashflow Payment Date > Reporting Month (Instrument specific)'
			when [Instrument Type Name] In ('EM-INV-P','REN-INV-P')
				then 'Delete Cashflows for instruments "EM-INV-P" and "REN-INV-P"'
			when [Instrument Type Name] = 'GAS-STOR-P' and [Cashflow Type] in ('Administration Charge','Storage Service Fee','Storage Withdrawl Fee') and [Cashflow Payment Date] <= @AsOfDate_EOLY and convert(date,[Cashflow Delivery Month],103) <= @AsOfDate_EOLY
				then 'Delete Cashflows for Instrument "GAS-STOR-P" (Casfhflow Type specific)'
			when [Cashflow Payment Date] <= @AsOfDate_EOLY
				AND (convert(date,[Cashflow Delivery Month],103) > @AsOfDate_EOLY OR [Leg End Date] > @AsOfDate_EOLY)
				AND [Source Of Row] = 'LGBY'
				AND (
				([Desk Name] in ('GPM DESK','COAL AND FREIGHT DESK','CAO UK','ASIA-PACIFIC TRADING DESK','LNG DESK','OIL TRADING','MANAGEMENT BOOKS','UK TRADING DESK','US GAS AND POWER DESK','CONTINENTAL TRADING DESK','EUROPEAN GAS DESK','QUANTITATIVE TRADING DESK') AND [Instrument Type Name] in ('GAS-FWD-P','PWR-FUT-EXCH-F','COAL-FWD','OIL-FUT-EXCH-P','GAS-FUT-EXCH-P','OIL-FUT-EXCH-F','GAS-FUT-EXCH-F','LNG-FUT-AVG-EXCH-F'))
				OR
				([Instrument Type Name] in ('GAS-FUT-AVG-EXCH-P') and convert(date,[Cashflow Delivery Month],103) > @AsOfDate_EOLY)
				OR
				([Desk Name] in ('EUROPEAN GAS DESK') and [Instrument Type Name] in ('GAS-FWD-STD-P'))
				)
				then 'Delete LGBY Cashflows because of the former x-files logic'
			when [Desk Name] = 'ASIA-PACIFIC TRADING DESK' and [Source Of Row] = 'LGBY' and [Instrument Type Name] = 'PWR-FUT-EXCH-F' and [Cashflow Payment Date] > @AsOfDate_EOLY and ([Trade Instrument Reference Text] like 'EEX_%_W52-%' or [Trade Instrument Reference Text] like 'EEX_%_DEC-%')
				then 'DELETE LGBY Cashflows for ASIA PACIFIC and Instrument PWR-FUT-EXCH-F (DEC and W52 Trade Instrument Reference Text)'
			when [Desk Name] = 'CONTINENTAL TRADING DESK' and [Source Of Row] = 'LGBY'  and [Cashflow Payment Date] > @AsOfDate_EOLY and convert(date,[Cashflow Delivery Month],103) > @AsOfDate_EOLY and ([Trade Instrument Reference Text] like 'EEX_%_W52-%' or [Trade Instrument Reference Text] like 'EEX_%_DEC-%' ) /*and [Instrument Type Name] = 'PWR-FUT-EXCH-F'*/
				then 'DELETE LGBY Cashflows for CONTINENTAL TRADING DESK (DEC and W52 Trade Instrument Reference Text)'
			when [Trade Deal Number] in ('60306730') AND [Source Of Row] = 'LGBY'
				then 'DELETE Manual Filtered Deals Weather Swap wrong LGBY Value'
			when [Trade Deal Number] in ('57083415') and [Cashflow Delivery Month] = '30/11/2022'
				then 'DELETE Manual Filtered Deals GPM THE realised last year'/*added 2023-06-13 YK/mkb */
			when [Desk Name] IN ('CAO US','OPERATIONS AMERICA') AND [Internal Portfolio Name] NOT LIKE '%ASSET_PPA' AND [Ext Legal Entity Name] NOT IN ('ERCOT','CAISO','MISO') AND ([Instrument Type Name] IN ('PWR-FEE-ANC','PWR-ASSET-P','PWR-P2P-OBL-F','CERT-ASSET-P') OR [External Portfolio Name] IN ('CAO US AESO ASSET CAP BU','CAO US AESO CONGESTION BU','CAO US AESO EAP BU','CAO US AESO HEDGE CAP BU','CAO US AESO RHP BU','CAO US AESO THP BU','CAO US CAISO ASSET CAP BU','CAO US CAISO CONGESTION BU','CAO US CAISO EAP BU','CAO US CAISO HEDGE CAP BU','CAO US CAISO RHP BU','CAO US CAISO THP BU','CAO US ERCOT ASSET CAP BU','CAO US ERCOT CONGESTION BU','CAO US ERCOT EAP BU','CAO US ERCOT HEDGE CAP BU','CAO US ERCOT MGMT BU','CAO US ERCOT RHP BU','CAO US ERCOT THP BU','CAO US MISO ASSET CAP BU','CAO US MISO CONGESTION BU','CAO US MISO EAP BU','CAO US MISO HEDGE CAP BU','CAO US MISO RHP BU','CAO US MISO THP BU','CAO US NEISO ASSET CAP BU','CAO US NEISO CONGESTION BU','CAO US NEISO EAP BU','CAO US NEISO HEDGE CAP BU','CAO US NEISO RHP BU','CAO US NEISO THP BU','CAO US NON ISO ASSET CAP BU','CAO US NON ISO CONGESTION BU','CAO US NON ISO EAP BU','CAO US NON ISO HEDGE CAP BU','CAO US NON ISO RHP BU','CAO US NON ISO THP BU','CAO US NYISO ASSET CAP BU','CAO US NYISO CONGESTION BU','CAO US NYISO EAP BU','CAO US NYISO HEDGE CAP BU','CAO US NYISO RHP BU','CAO US NYISO THP BU','CAO US PJM ASSET CAP BU','CAO US PJM CONGESTION BU','CAO US PJM EAP BU','CAO US PJM HEDGE CAP BU','CAO US PJM RHP BU','CAO US PJM THP BU','CAO US SPP ASSET CAP BU','CAO US SPP CONGESTION BU','CAO US SPP EAP BU','CAO US SPP HEDGE CAP BU','CAO US SPP RHP BU','CAO US SPP THP BU','CAO US THP DUMMY BU','ADM INVESTOR SERVICES INC BU','ANACACHO WIND FARM BU','ANACACHO WIND FARM EAP BU','ASHWOOD SOLAR I BU','ASHWOOD SOLAR I EAP BU','BARON WINDS BU','BARON WINDS EAP BU','BIG STAR SOLAR BU','BIG STAR SOLAR EAP BU','BLACKJACK CREEK WIND FARM BU','BLACKJACK CREEK WIND FARM EAP BU','BOILING SPRINGS BU','BOILING SPRINGS EAP BU','BRIGHT ARROW SOLAR BU','BRIGHT ARROW SOLAR EAP BU','BRUENNINGS BREEZE WIND FARM BU','BRUENNINGS BREEZE WIND FARM EAP BU','CASSADAGA WIND BU','CASSADAGA WIND EAP BU','CHAMPION WIND FARM BU','CHAMPION WIND FARM EAP BU','COLBECKS CORNER BU','COLBECKS CORNER EAP BU','CONRAD SOLAR BU','CONRAD SOLAR EAP BU','CRANELL WIND FARM BU','CRANELL WIND FARM EAP BU','EL ALGODON ALTO WIND FARM BU','EL ALGODON ALTO WIND FARM EAP BU','FIFTH STANDARD SOLAR PV BU','FIFTH STANDARD SOLAR PV EAP BU','FOREST CREEK BU','FOREST CREEK EAP BU','GRANDVIEW WIND FARM BU','GRANDVIEW WIND FARM EAP BU','HARDIN WIND BU','HARDIN WIND EAP BU','HICKORY PARK SOLAR BU','HICKORY PARK SOLAR EAP BU','INADALE WIND FARM BU','INADALE WIND FARM EAP BU','MAGIC VALLEY WIND FARM I BU','MAGIC VALLEY WIND FARM I EAP BU','MONTGOMERY RANCH WIND FARM BU','MONTGOMERY RANCH WIND FARM EAP BU','MUNNSVILLE WIND FARM BU','MUNNSVILLE WIND FARM EAP BU','PANTHER CREEK I&II EAP BU','PANTHER CREEK II BU','PANTHER CREEK WIND FARM III BU','PANTHER CREEK WIND FARM III EAP BU','PAPALOTE CREEK II BU','PAPALOTE CREEK II EAP BU','PAPALOTE WIND FARM I BU','PAPALOTE WIND FARM I EAP BU','PEYTON CREEK WIND FARM BU','PEYTON CREEK WIND FARM EAP BU','PIONEER TRAIL WIND FARM BU','PIONEER TRAIL WIND FARM EAP BU','PYRON WIND FARM BU','PYRON WIND FARM EAP BU','RADFORDS RUN WIND FARM BU','RADFORDS RUN WIND FARM EAP BU','RAYMOND WIND FARM BU','RAYMOND WIND FARM EAP BU','ROSCOE WIND FARM BU','ROSCOE WIND FARM EAP BU','SAND BLUFF WIND FARM BU','SAND BLUFF WIND FARM EAP BU','SETTLERS TRAIL BU','SETTLERS TRAIL EAP BU','STELLA WIND FARM BU','STELLA WIND FARM EAP BU','STONY CREEK BU','STONY CREEK EAP BU','TABER SOLAR 2 BU','TABER SOLAR 2 EAP BU','TAMWORTH HOLDINGS BU','TAMWORTH HOLDINGS EAP BU','TANAGER HOLDINGS BU','TANAGER HOLDINGS EAP BU','TECH PARK SOLAR BU','TECH PARK SOLAR EAP BU','VALENCIA SOLAR BU','VALENCIA SOLAR EAP BU','WEST OF THE PECOS SOLAR BU','WEST OF THE PECOS SOLAR EAP BU','WEST RAYMOND WIND FARM BU','WEST RAYMOND WIND FARM EAP BU','WILDCAT WIND FARM I BU','WILDCAT WIND FARM I EAP BU','WILLOWBROOK SOLAR 1 BU','WILLOWBROOK SOLAR 1 EAP BU','WR GRACELAND SOLAR BU','WR GRACELAND SOLAR EAP BU','CAO US MISO PPA BU','CAO US ERCOT PPA BU','CAO US PJM PPA BU','CAO US SPP ASSET BU','CAO US ERCOT ASSET BU','CAO US MISO ASSET BU','CAO US PJM ASSET BU','TABER SOLAR 1 BU','TABER SOLAR 1 EAP BU','ERCOT BU','MISO BU','CAISO BU','NYISO BU','PJM Interconnection BU','SPP BU')) AND NOT ([Internal Portfolio Name] IN ('RWEST_ERCOT_HEDGE_CERT','RWEST_PJM_HEDGE_CERT'))
				then 'DELETE external portfolios and instrument types for CAO US' --added 2023-10-27 by MK. Requirement by Mayank Omar. Updated 2024-03-20 on request of Geoff (ADM INVESTOR SERVICES INC with certain Insturment Types). Updated 2024-06-24 on request of Geoff
			when [Desk Name] = 'ASIA-PACIFIC TRADING DESK' AND [Instrument Type Name] = 'OIL-FUT-EXCH-P' AND [Source of Row] = 'LGBY' AND [Cashflow Payment Date] = @AsOfDate_BOCY
				then 'DELETE LGBY leg for OIL-FUT-EXCH-P of ASIA PACIFIC for first day of the actual year' /*added 2024-04-11 by PG. Requirement by Sascha/April */
			when [Desk Name] in ('ASIA-PACIFIC TRADING DESK','CONTINENTAL TRADING DESK') AND [Instrument Type Name] = 'SOFT-FUT-EXCH-P' AND [Source of Row] = 'LGBY' AND [Cashflow Payment Date] = @AsOfDate_BOCYS
				then 'DELETE LGBY leg for SOFT-FUT-EXCH-P of AP and CT for second day of the actual year' /*added 2024-04-08 by SH. Requirement by April */
			when [Instrument Type Name] IN ('PWR-FWD-IFA-F','PWR-FWD-IFA-P')
				then 'DELETE IFA deals, because already provided by Strolf' /*added 2024-04-29 by MK. Removal of IFA deals from Rock, because they are coming in via Strolf.*/
			when [Cashflow Type] = 'Working Capital Charge'
				then 'Delete Cashflows "Working Capital Charge"'
			end

			,[ToBeDeleted] = 1
		where
		(
			( abs(isnull([volume],0)) + abs(isnull([Realised_OrigCCY_Undisc],0)) + abs(isnull([Realised_OrigCCY_Disc],0)) + abs(isnull([Realised_EUR_Undisc],0)) + abs(isnull([Realised_EUR_Disc],0)) + abs(isnull([Realised_GBP_Undisc],0)) + abs(isnull([Realised_GBP_Disc],0)) + abs(isnull([Realised_USD_Undisc],0)) + abs(isnull([Realised_USD_Disc],0)) = 0 )
			or ( [Internal Portfolio Business Key] in (select Portfolio_Key from dbo.map_not_needed_Portfolios))
			or ( [Cashflow Type] in ('Broker Fee', 'Buyout Proceeds','Working Capital Charge') )
			or ( [Cashflow Settlement Type] = 'Physical Settlement' and [Instrument Type Name] in ('BIOFUEL-FWD','BIOFUEL-STOR','BIOFUEL-STOR-V12','BIOFUEL-TRANSIT','COAL-FWD','COAL-STEV','COAL-STOR','COAL-STOR-V12','COAL-TRANSIT','EM-FWD-P','EM-FWD-VAL-P','FERT-FWD-P','FERT-TRANSIT-P','FREIGHT-FWD','GAS-FWD-IMB-P','GAS-FWD-P','GAS-FWD-STD-P','GAS-FWD-VAL-P','GAS-SWING-P','LNG-FWD-P','LNG-REGAS-P','LNG-STOR-P','LNG-TC-FWD-P','LNG-TRANS-P','OIL-FWD','ORE-FWD-P','PWR-ASSET-P','PWR-CAP-P','PWR-HR-EXCH-P','PWR-FWD-P','PWR-FWD-PPA-P','PWR-FWD-STD-P','PWR-FWD-VAL-P','PWR-FWD-WD-P','PWR-OPT-TRANS-H-P','PWR-TRANS-P','REN-FWD-P','TC-FWD', 'OIL-BUNKER-ROLL-P'))
			or ( [Cashflow Settlement Type] = 'Physical Settlement' and [Desk Name] not in ('COAL AND FREIGHT DESK','CONTINENTAL TRADING DESK','EUROPEAN GAS DESK','UK TRADING DESK','LNG DESK') and [Instrument Type Name] in ('OIL-BUNKER-ROLL-P','MTL-FWD-EXCH-P','GAS-EXCH-P','GAS-STOR-P','GAS-FWD-MAKEUP-P'))
			or ( [Instrument Type Name] = 'FX' and [Cashflow Type] not like 'FX Swap' and [Cashflow Payment Date] > @AsOfDate_LastDayOfMonth)
			or ( [Instrument Type Name] = 'FX' and [Leg End Date] > @AsOfDate_LastDayOfMonth)
			or ( [Cashflow Payment Date] < @AsOfDate_BOLY and [Desk Name] not in ('CAO UK') )
			or ( [Instrument Type Name] like '%OPT%' and [Cashflow Payment Date] > @AsOfDate_LastDayOfMonth and [Leg End Date] > @AsOfDate_LastDayOfMonth)
			or ( [Desk Name] = 'GPM DESK' and [Cashflow Type] = 'Cleaning Materials')
			or ( [Desk Name] IN ('EUROPEAN GAS DESK','STRUCTURED ORIGINATION DESK') and [Leg End Date] > @AsOfDate_LastDayOfMonth and [Instrument Type Name] in ('GAS-SWING-P','GAS-FWD-STD-P','WTH-SWAP-F') )
			or ( [Desk Name] in ('EUROPEAN GAS DESK','UK TRADING DESK') and convert(date,[Cashflow Delivery Month],103) <= @AsOfDate_EOLY and [Cashflow Payment Date] <= @AsOfDate_EOLY and [Instrument Type Name] in ('GAS-FUT-AVG-EXCH-P' ))
			or ( [Desk Name] in ('EUROPEAN GAS DESK','MANAGEMENT BOOKS','LNG DESK') and convert(date,[Cashflow Delivery Month],103) > @AsOfDate_EOLY and [Cashflow Payment Date] > @AsOfDate_EOLY and  [Leg End Date] > @AsOfDate_EOLY and [Trade Date] <= @AsOfDate_EOLY and [Instrument Type Name]  in ('GAS-FUT-AVG-EXCH-P','GAS-FUT-AVG-EXCH-F') AND [Source Of Row] = 'LGBY')
			or ( [Desk Name] in ('STRUCTURED ORIGINATION DESK') and [Cashflow Payment Date] <= @AsOfDate_EOLY and [Instrument Type Name]  in ('WTH-SWAP-F'))
			or ( [Desk Name] IN ('STRUCTURED ORIGINATION DESK','MANAGEMENT BOOKS','CONTINENTAL TRADING DESK') AND [Leg Exercise Date] like '%1900%' and [Leg End Date] > @AsOfDate_LastDayOfMonth AND convert(date,[Cashflow Delivery Month],103) > @AsOfDate_LastDayOfMonth AND ([Instrument Toolset Name] = 'ComFut' ) )
			or ( [Desk Name] in ('GENERATION UK DA DESK','GENERATION UK DESK'))
			or ( [Desk Name] in ('BIOFUELS DESK','ASIA-PACIFIC TRADING DESK') and [Leg End Date] > @AsOfDate_LastDayOfMonth and convert(date,[Cashflow Delivery Month],103) > @AsOfDate_LastDayOfMonth and [Leg Exercise Date] like '%1900%' and [Instrument Type Name] NOT in ('COMM-FEE' ) )
			or ( [Desk Name] IN ('LNG DESK') AND [Instrument Type Name] in ('COMM-FEE') and convert(datetime,[Cashflow Delivery Month],103) <= @AsOfDate_EOLY and  [Cashflow Payment Date] <=  @AsOfDate_EOLY  )
			or ( [Desk Name] IN ('CONTINENTAL TRADING DESK') AND [Instrument Type Name] like '%OPT%' and convert(datetime,[Cashflow Delivery Month],103) <= @AsOfDate_EOLY and  [Cashflow Payment Date] <=  @AsOfDate_EOLY )
			or ( [Instrument Type Name] not like '%OPT%' and  [Instrument Toolset Name] not In  ('FX', 'Swap', 'ComFut') and [Cashflow Payment Date] > @AsOfDate_LastDayOfMonth and [Leg End Date] > @AsOfDate_LastDayOfMonth)
			or ( [Instrument Type Name] In ('EM-INV-P','REN-INV-P'))
			or ( [Instrument Type Name] = 'GAS-STOR-P' and [Cashflow Type] in ('Administration Charge','Storage Service Fee','Storage Withdrawl Fee') and [Cashflow Payment Date] <= @AsOfDate_EOLY and convert(date,[Cashflow Delivery Month],103) <= @AsOfDate_EOLY)
			or ( [Cashflow Payment Date] <= @AsOfDate_EOLY AND (convert(date,[Cashflow Delivery Month],103) > @AsOfDate_EOLY OR [Leg End Date] > @AsOfDate_EOLY) AND [Source Of Row] = 'LGBY'AND (([Desk Name] in ('GPM DESK','COAL AND FREIGHT DESK','CAO UK','ASIA-PACIFIC TRADING DESK','LNG DESK','OIL TRADING','MANAGEMENT BOOKS','UK TRADING DESK','US GAS AND POWER DESK','CONTINENTAL TRADING DESK','EUROPEAN GAS DESK','QUANTITATIVE TRADING DESK') AND [Instrument Type Name] in ('GAS-FWD-P','PWR-FUT-EXCH-F','COAL-FWD','OIL-FUT-EXCH-P','GAS-FUT-EXCH-P','OIL-FUT-EXCH-F','GAS-FUT-EXCH-F','LNG-FUT-AVG-EXCH-F'))OR([Instrument Type Name] in ('GAS-FUT-AVG-EXCH-P') and convert(date,[Cashflow Delivery Month],103) > @AsOfDate_EOLY)OR([Desk Name] in ('EUROPEAN GAS DESK') and [Instrument Type Name] in ('GAS-FWD-STD-P'))))
			or ( [Desk Name] = 'ASIA-PACIFIC TRADING DESK' and [Source Of Row] = 'LGBY' and [Instrument Type Name] = 'PWR-FUT-EXCH-F' and [Cashflow Payment Date] > @AsOfDate_EOLY and ([Trade Instrument Reference Text] like 'EEX_%_W52-%' or [Trade Instrument Reference Text] like 'EEX_%_DEC-%'))
			or ( [Desk Name] = 'CONTINENTAL TRADING DESK' and [Source Of Row] = 'LGBY'  and [Cashflow Payment Date] > @AsOfDate_EOLY and convert(date,[Cashflow Delivery Month],103) > @AsOfDate_EOLY and ([Trade Instrument Reference Text] like 'EEX_%_W52-%' or [Trade Instrument Reference Text] like 'EEX_%_DEC-%') /*and [Instrument Type Name] = 'PWR-FUT-EXCH-F'*/ )
			or ( [Trade Deal Number] in ('60306730') AND [Source Of Row] = 'LGBY' )
			or ( [Trade Deal Number] in ('57083415') and [Cashflow Delivery Month] = '30/11/2022' )
			or ( [Desk Name] IN ('CAO US','OPERATIONS AMERICA') AND [Internal Portfolio Name] NOT LIKE '%ASSET_PPA' AND [Ext Legal Entity Name] NOT IN ('ERCOT','CAISO','MISO') AND ([Instrument Type Name] IN ('PWR-FEE-ANC','PWR-ASSET-P','PWR-P2P-OBL-F','CERT-ASSET-P') OR [External Portfolio Name] IN ('CAO US AESO ASSET CAP BU','CAO US AESO CONGESTION BU','CAO US AESO EAP BU','CAO US AESO HEDGE CAP BU','CAO US AESO RHP BU','CAO US AESO THP BU','CAO US CAISO ASSET CAP BU','CAO US CAISO CONGESTION BU','CAO US CAISO EAP BU','CAO US CAISO HEDGE CAP BU','CAO US CAISO RHP BU','CAO US CAISO THP BU','CAO US ERCOT ASSET CAP BU','CAO US ERCOT CONGESTION BU','CAO US ERCOT EAP BU','CAO US ERCOT HEDGE CAP BU','CAO US ERCOT MGMT BU','CAO US ERCOT RHP BU','CAO US ERCOT THP BU','CAO US MISO ASSET CAP BU','CAO US MISO CONGESTION BU','CAO US MISO EAP BU','CAO US MISO HEDGE CAP BU','CAO US MISO RHP BU','CAO US MISO THP BU','CAO US NEISO ASSET CAP BU','CAO US NEISO CONGESTION BU','CAO US NEISO EAP BU','CAO US NEISO HEDGE CAP BU','CAO US NEISO RHP BU','CAO US NEISO THP BU','CAO US NON ISO ASSET CAP BU','CAO US NON ISO CONGESTION BU','CAO US NON ISO EAP BU','CAO US NON ISO HEDGE CAP BU','CAO US NON ISO RHP BU','CAO US NON ISO THP BU','CAO US NYISO ASSET CAP BU','CAO US NYISO CONGESTION BU','CAO US NYISO EAP BU','CAO US NYISO HEDGE CAP BU','CAO US NYISO RHP BU','CAO US NYISO THP BU','CAO US PJM ASSET CAP BU','CAO US PJM CONGESTION BU','CAO US PJM EAP BU','CAO US PJM HEDGE CAP BU','CAO US PJM RHP BU','CAO US PJM THP BU','CAO US SPP ASSET CAP BU','CAO US SPP CONGESTION BU','CAO US SPP EAP BU','CAO US SPP HEDGE CAP BU','CAO US SPP RHP BU','CAO US SPP THP BU','CAO US THP DUMMY BU','ADM INVESTOR SERVICES INC BU','ANACACHO WIND FARM BU','ANACACHO WIND FARM EAP BU','ASHWOOD SOLAR I BU','ASHWOOD SOLAR I EAP BU','BARON WINDS BU','BARON WINDS EAP BU','BIG STAR SOLAR BU','BIG STAR SOLAR EAP BU','BLACKJACK CREEK WIND FARM BU','BLACKJACK CREEK WIND FARM EAP BU','BOILING SPRINGS BU','BOILING SPRINGS EAP BU','BRIGHT ARROW SOLAR BU','BRIGHT ARROW SOLAR EAP BU','BRUENNINGS BREEZE WIND FARM BU','BRUENNINGS BREEZE WIND FARM EAP BU','CASSADAGA WIND BU','CASSADAGA WIND EAP BU','CHAMPION WIND FARM BU','CHAMPION WIND FARM EAP BU','COLBECKS CORNER BU','COLBECKS CORNER EAP BU','CONRAD SOLAR BU','CONRAD SOLAR EAP BU','CRANELL WIND FARM BU','CRANELL WIND FARM EAP BU','EL ALGODON ALTO WIND FARM BU','EL ALGODON ALTO WIND FARM EAP BU','FIFTH STANDARD SOLAR PV BU','FIFTH STANDARD SOLAR PV EAP BU','FOREST CREEK BU','FOREST CREEK EAP BU','GRANDVIEW WIND FARM BU','GRANDVIEW WIND FARM EAP BU','HARDIN WIND BU','HARDIN WIND EAP BU','HICKORY PARK SOLAR BU','HICKORY PARK SOLAR EAP BU','INADALE WIND FARM BU','INADALE WIND FARM EAP BU','MAGIC VALLEY WIND FARM I BU','MAGIC VALLEY WIND FARM I EAP BU','MONTGOMERY RANCH WIND FARM BU','MONTGOMERY RANCH WIND FARM EAP BU','MUNNSVILLE WIND FARM BU','MUNNSVILLE WIND FARM EAP BU','PANTHER CREEK I&II EAP BU','PANTHER CREEK II BU','PANTHER CREEK WIND FARM III BU','PANTHER CREEK WIND FARM III EAP BU','PAPALOTE CREEK II BU','PAPALOTE CREEK II EAP BU','PAPALOTE WIND FARM I BU','PAPALOTE WIND FARM I EAP BU','PEYTON CREEK WIND FARM BU','PEYTON CREEK WIND FARM EAP BU','PIONEER TRAIL WIND FARM BU','PIONEER TRAIL WIND FARM EAP BU','PYRON WIND FARM BU','PYRON WIND FARM EAP BU','RADFORDS RUN WIND FARM BU','RADFORDS RUN WIND FARM EAP BU','RAYMOND WIND FARM BU','RAYMOND WIND FARM EAP BU','ROSCOE WIND FARM BU','ROSCOE WIND FARM EAP BU','SAND BLUFF WIND FARM BU','SAND BLUFF WIND FARM EAP BU','SETTLERS TRAIL BU','SETTLERS TRAIL EAP BU','STELLA WIND FARM BU','STELLA WIND FARM EAP BU','STONY CREEK BU','STONY CREEK EAP BU','TABER SOLAR 2 BU','TABER SOLAR 2 EAP BU','TAMWORTH HOLDINGS BU','TAMWORTH HOLDINGS EAP BU','TANAGER HOLDINGS BU','TANAGER HOLDINGS EAP BU','TECH PARK SOLAR BU','TECH PARK SOLAR EAP BU','VALENCIA SOLAR BU','VALENCIA SOLAR EAP BU','WEST OF THE PECOS SOLAR BU','WEST OF THE PECOS SOLAR EAP BU','WEST RAYMOND WIND FARM BU','WEST RAYMOND WIND FARM EAP BU','WILDCAT WIND FARM I BU','WILDCAT WIND FARM I EAP BU','WILLOWBROOK SOLAR 1 BU','WILLOWBROOK SOLAR 1 EAP BU','WR GRACELAND SOLAR BU','WR GRACELAND SOLAR EAP BU','CAO US MISO PPA BU','CAO US ERCOT PPA BU','CAO US PJM PPA BU','CAO US SPP ASSET BU','CAO US ERCOT ASSET BU','CAO US MISO ASSET BU','CAO US PJM ASSET BU','TABER SOLAR 1 BU','TABER SOLAR 1 EAP BU','ERCOT BU','MISO BU','CAISO BU','NYISO BU','PJM Interconnection BU','SPP BU')) AND NOT ([Internal Portfolio Name] IN ('RWEST_ERCOT_HEDGE_CERT','RWEST_PJM_HEDGE_CERT')) )
			or ( [Desk Name] = 'ASIA-PACIFIC TRADING DESK' AND [Instrument Type Name] = 'OIL-FUT-EXCH-P' AND [Source of Row] = 'LGBY' AND [Cashflow Payment Date] = @AsOfDate_BOCY)
			or ( [Desk Name] in ('ASIA-PACIFIC TRADING DESK','CONTINENTAL TRADING DESK') AND [Instrument Type Name] = 'SOFT-FUT-EXCH-P' AND [Source of Row] = 'LGBY' AND [Cashflow Payment Date] = @AsOfDate_BOCYS)
			or ( [Instrument Type Name] IN ('PWR-FWD-IFA-F','PWR-FWD-IFA-P') )
		)
		AND (FileID not in (2210,2450,3269) or [Instrument Type Name] In ('EM-INV-P','REN-INV-P'))
		AND NOT ([Desk Name] = 'GPM DESK' AND [Instrument Type Name] = 'IRS')


		SELECT @step=50
		select @RecordCount2 = count(*) from [dbo].table_REALISED_Rawdata
		select @RecordCount3 = @RecordCount1 - @RecordCount2



		if @LogInfo >= 1  BEGIN insert into [dbo].[Logfile] select @proc + ' - records, totally imported vs deleted 0-value: ' + cast(format(@RecordCount1,'#,#') as varchar) + ' / '+ cast(format(@RecordCount3,'#,#') as varchar), GETDATE () END

NoFurtherAction:
		IF @LogInfo >= 1 BEGIN INSERT INTO [dbo].[Logfile] SELECT @proc + ' - FINISHED', GETDATE () END
	END TRY

	BEGIN CATCH
		EXEC [dbo].[usp_GetErrorInfo] @proc, @step
		BEGIN INSERT INTO [dbo].[Logfile] SELECT @proc + ' - FAILED', GETDATE () END
	END CATCH

GO

