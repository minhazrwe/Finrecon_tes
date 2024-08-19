

/* 
procedure:	Import_ROCK_GPM_PNL_AND_ILLIQUID
author:			mkb/mu
date:				2022/02
purpose:		import mtm data used for GPM PNL_AND_ILLIQUID checks
						identifies files from FT and ROCK that have been exported beforehand.
=============================================================================================================================================================
changes: 
2023-04-11, mkb, step 3:	identify maximum leg_end_date obtained from ROCK data as end of active/liquid period
2023-04-11, mkb, step 502: limited FT data to consider just the dates of active/liquid period, by comparing against @End_Of_Liquid_Period (request YN)
2023-05-10, mkb, step 440: excluded portfolios "RGM_D_DUMMY%" from being considered in FT data (request YN)
2023-05-10, mkb, step 505: inserted a hint of how to split mtm differences in liquid and illiquid 
2023-06-03, mkb, step 600: (and following), now importing as well a file directly delivered by gpm desk (Christian Köppen, therefore "the Koeppen file)" 
2024-01-08, mkb, overall: removing shift of +1 hour for any log entry.
=============================================================================================================================================================
*/

CREATE PROCEDURE [dbo].[Import_ROCK_GPM_PNL_AND_ILLIQUID] 
	@DataToImport varchar(10)
AS
BEGIN TRY

  DECLARE @step Integer		
	DECLARE @proc nvarchar(50)
	DECLARE @LogInfo Integer
	
	DECLARE @FileSource nvarchar(300)
	DECLARE @PathName nvarchar (300)
	DECLARE @FileName nvarchar(300)
	DECLARE @FileID Integer
	
	declare @COB as date
	declare @COB_MTM as date
	declare @AsOfDate_MTM_BeginningOfLastYear as date
	declare @End_Of_Liquid_Period as date
	
	DECLARE @sql nvarchar (max)
	DECLARE @counter Integer
	DECLARE @TotalRecordsInserted nvarchar(13)
	
	SELECT @proc = Object_Name(@@PROCID)
	
  /* get Info if Logging is enabled */
	SELECT @LogInfo = [dbo].[LogInfo].[LogInfo] FROM [dbo].[LogInfo]

	IF @LogInfo >= 1  
	BEGIN 
		INSERT INTO [dbo].[Logfile] SELECT @proc + ' - START', GETDATE ()   
		INSERT INTO [dbo].[Logfile] SELECT @proc + ' - identify import path and load files', GETDATE ()   
	END

	/* identify the COB that the mtm_check should be done for (needs to get checked against the datafiles before processing!) */	
	select @step = 2
	select 
		@cob = AsOfDate_EOM, 
		@COB_MTM= AsOfDate_MtM_Check, 
		@AsOfDate_MTM_BeginningOfLastYear = DATEADD(yy,-1,DATEADD(yy,DATEDIFF(yy,0,AsOfDate_MtM_Check),0))
	from 
		dbo.AsOfDate				
	
	/* identify the maximum leg end date from RiskPnl data related to GPM-desk (as this represents the end of Active/Liquid period) */
	select @step = 3
	select @End_Of_Liquid_Period = max(DEAL_PDC_END_DATE) from dbo.GloriRisk where Desk_Name like '%GPM%' and fileID<>3133
				
	/*
	-- identify the path where the files should be imported from (and replace placeholders for date & month).
	--it is the same path for all files (rock, ft, koeppen), so we can look for the source instead of the pathID related to the importfile.
	--running dbo.[udf_get_path] doesnn't work here as we get use the "AsOfDate_MtM_Check" field rather than "AsOfDate_EOM" 
	*/  
	SELECT @step = 4
	SELECT @PathName = [path] from  [dbo].[pathtofiles] where [dbo].[pathtofiles].[Source] = 'ROCK_GPM'
	SELECT @PathName  = replace (@PathName , '%YYYY%', format(@COB_MTM,'yyyy'))	
	SELECT @PathName  = replace (@PathName , '%MM%', format(@COB_MTM,'MM'))

	if @LogInfo >= 1  
	BEGIN INSERT INTO [dbo].[Logfile] select @proc + ' - Import ' + @DataToImport + ' data for COB ' + cast(@COB_mtm as varchar), GETDATE ()   	END			 		
	
	/*-- ROCK related imports*/		
	IF @DataToImport = 'ROCK' or @DataToImport = 'ALL'	/* --> parameter is "ROCK" or "ALL" */			
		BEGIN
			
			SET @FileSource = 'ROCK_GPM_ILLIQUID'
		
			--/*use a counter to get all available files*/
			SELECT @step = 100
			SELECT @counter = count(*) FROM [dbo].[FilestoImport] WHERE  [dbo].[FilestoImport].[Source] like @FileSource and ToBeImported=1

			--/*in case here is no importfile, create a reladet log entry and jump out*/
			SELECT @step = 101
			IF @counter=0 
			BEGIN 
				INSERT INTO [dbo].[Logfile] SELECT @proc + ' - no data found to get imported.', GETDATE ()   
				GOTO NoFurtherAction 
			END		
			
			IF @LogInfo >= 1  BEGIN INSERT INTO [dbo].[Logfile] SELECT @proc + ' - importing ' + cast(@counter as varchar) + ' files from ' + @PathName , GETDATE ()   END			

			/* loop over counter, reduce it at then end */ 	
			WHILE @counter >0
			BEGIN			
				--/*identify importfile*/
				SELECT @step=130
				SELECT 
					@FileName = [FileName]
					,@FileID = [ID]
				FROM (SELECT *, ROW_NUMBER() OVER(ORDER BY ID) AS ROW  
							FROM [dbo].[FilestoImport] 
							WHERE [dbo].[FilestoImport].[Source] like @FileSource and ToBeImported=1) as TMP 
				WHERE ROW = @counter
			
				SELECT @step=131
				TRUNCATE TABLE dbo.table_ROCK_GPM_Illiquid_Rawdata 

				SELECT @step=133						
				/*import data into temp table*/						
				IF @LogInfo >= 1  BEGIN INSERT INTO [dbo].[Logfile] SELECT @proc + ' - importing ' + cast(@counter as nvarchar) + ': ' + @filename, GETDATE ()   END					 

				SELECT @sql = N'BULK INSERT [dbo].[table_ROCK_GPM_Illiquid_Rawdata] FROM '  + '''' + @PathName + @filename + ''''  + ' WITH (CODEPAGE = 1252, FIELDTERMINATOR =''~'', FIRSTROW = 2, ROWTERMINATOR =''\n'')';
				EXECUTE sp_executesql @sql
		
				SELECT @step=137
				delete from dbo.table_ROCK_GPM_Illiquid_Data where fileID = @fileID

				SELECT @step=139
				INSERT INTO dbo.table_ROCK_GPM_Illiquid_Data
					(
				 		 CoB
						,Intermediate_5_Name
						,Deal_Number
						,Instrument_Type_Name
						,PnL_Disc_Unreal_BU_CCY
						,PnL_Disc_Unreal_LGBY_BU_CCY
						,PnL_Disc_Unreal_YtD_BU_CCY
						,PnL_Disc_Unreal_LtD_PH_BU_CCY
						,PnL_Disc_Unreal_LGBY_PH_BU_CCY
						,PnL_Disc_Unreal_YtD_PH_BU_CCY
						,fileID
					)
					SELECT 
							convert(date,COB,103) COB	
						,Intermediate_5_Name
						,Deal_Number
						,Instrument_Type_Name
						,cast(PnL_Disc_Unreal_BU_CCY as float) as PnL_Disc_Unreal_BU_CCY
						,cast(PnL_Disc_Unreal_LGBY_BU_CCY as float) as PnL_Disc_Unreal_LGBY_BU_CCY
						,cast(PnL_Disc_Unreal_YtD_BU_CCY as float) as PnL_Disc_Unreal_YtD_BU_CCY
						,cast(PnL_Disc_Unreal_LtD_PH_BU_CCY as float) as PnL_Disc_Unreal_LtD_PH_BU_CCY
						,cast(PnL_Disc_Unreal_LGBY_PH_BU_CCY as float) as PnL_Disc_Unreal_LGBY_PH_BU_CCY
						,cast(PnL_Disc_Unreal_YtD_PH_BU_CCY as float) as PnL_Disc_Unreal_YtD_PH_BU_CCY
						,@fileID as FileID
					FROM 
						dbo.table_ROCK_GPM_Illiquid_Rawdata
			
				/* now document the last successful import timestamp and take the file from the list of to be imported files */
				SELECT @step=140
				update [dbo].[FilestoImport] set LastImport = getdate() WHERE [Source] like @FileSource and [filename]= @filename and ToBeImported=1
			
				SELECT @step=142
				select @TotalRecordsInserted = count(*) from dbo.table_ROCK_GPM_Illiquid_Rawdata
			
				/* remove all rows, where all metrics are 0 */
				delete from dbo.table_ROCK_GPM_Illiquid_Rawdata
				where 
					(		
							abs(isnull(PnL_Disc_Unreal_BU_CCY,0))
						+ abs(isnull(PnL_Disc_Unreal_LGBY_BU_CCY,0))
						+ abs(isnull(PnL_Disc_Unreal_YtD_BU_CCY,0))
						+ abs(isnull(PnL_Disc_Unreal_LtD_PH_BU_CCY,0))
						+ abs(isnull(PnL_Disc_Unreal_LGBY_PH_BU_CCY,0))
						+ abs(isnull(PnL_Disc_Unreal_YtD_PH_BU_CCY,0))
					)=0
									 				 		
				IF @LogInfo >= 1 BEGIN INSERT INTO [dbo].[Logfile] SELECT @proc + ' - #' + cast(@counter as varchar) + ' imported: ' + @filename + ' - records: '+ cast(@TotalRecordsInserted as varchar), GETDATE ()   END	
			
				/*reduce counter*/
				SELECT @step=144
				SELECT @counter = @counter - 1
			END		
		
			SELECT @step=146
			select @TotalRecordsInserted = cast(format(count(*),'#.#') as varchar) from dbo.table_ROCK_GPM_Illiquid_Rawdata
			IF @LogInfo >= 1 BEGIN INSERT INTO [dbo].[Logfile] SELECT @proc + ' - Overall imported records: '+ cast(@TotalRecordsInserted as varchar), GETDATE ()   END
		END
		/*===================================================================================================================================================================	*/
		/*--import FasTracker data:*/
		IF @DataToImport = 'FT' or @DataToImport = 'ALL' /* means parameter is "FT" or "ALL" */
		BEGIN 
			SET @FileSource = 'ROCK_GPM_FT'
			
			/*-- identify how many file will be imported */
			select @step = 200						
			select @counter = count(1) from [dbo].[FilestoImport] where [dbo].[FilestoImport].[Source] in ('ROCK_GPM_FT') and ToBeImported=1
			
			--/*in case here is no importfile, create a related log entry and jump out*/
			select @step = 201
			IF @counter=0 
			BEGIN 
				INSERT INTO [dbo].[Logfile] SELECT @proc + ' - nothing found to get imported.', GETDATE ()   
				GOTO NoFurtherAction 
			END		
						
		
			IF @LogInfo >= 1  BEGIN INSERT INTO [dbo].[Logfile] SELECT @proc + ' - importing ' + cast(@counter as varchar) + ' file(s) from ' + @PathName  , GETDATE ()   END			
			select @step = 202
			IF (EXISTS (SELECT * FROM INFORMATION_SCHEMA.TABLES WHERE table_schema = 'dbo' and TABLE_NAME = 'table_ROCK_GPM_FT_rawdata'))
			BEGIN												
				drop table [dbo].table_ROCK_GPM_FT_Rawdata
			END
						
			select @step = 210
			/*create a temporary import-table for rawdata that gets deleted again after the data has been imported.*/
			CREATE table [dbo].table_ROCK_GPM_FT_Rawdata
			(
				[As_of_Date] [nvarchar](100) NULL,
				[Subsidiary] [nvarchar](100) NULL,
				[Strategy] [nvarchar](100) NULL,
				[Reference_ID] [nvarchar](100) NULL,
				[Trade_Date] [nvarchar](100) NULL,
				[Term_Start] [nvarchar](100) NULL,
				[Term_End] [nvarchar](100) NULL,
				[Internal_Portfolio] [nvarchar](100) NULL,
				[Counterparty_Ext_Bunit] [nvarchar](100) NULL,
				[Counterparty_Group] [nvarchar](100) NULL,
				[Volume] [nvarchar](100) NULL,
				[Header_Buy_Sell] [nvarchar](100) NULL,
				[Curve_Name] [nvarchar](100) NULL,
				[Projection_Index_Group] [nvarchar](100) NULL,
				[Instrument_Type] [nvarchar](100) NULL,
				[UOM] [nvarchar](100) NULL,
				[Int_Legal_Entity] [nvarchar](100) NULL,
				[Int_Bunit] [nvarchar](100) NULL,
				[Ext_Legal_Entity] [nvarchar](100) NULL,
				[Ext_Portfolio] [nvarchar](100) NULL,
				[Discounted_PNL] [nvarchar](100) NULL,
				[Undiscounted_PNL] [nvarchar](100) NULL,
				[Accounting_Treatment] [nvarchar](100) NULL,
				[Reference] [nvarchar](100) NULL,
				[Product] [nvarchar](100) NULL
			)
		
			select @step = 220
			/*--delete old entries in FT data table */
			truncate table [dbo].table_ROCK_GPM_FT_Data
								
			/*-- loop over all files that should be imported.*/
			select @step = 230
			while @counter > 0				
			BEGIN ---while @counter > 0
				/*-- identify the name of the file to be loaded */					
				select @step = 410		
				select  
						@filename = [FileName]
					,@FileID   = [ID]
				from 
					(select *, ROW_NUMBER() OVER(ORDER BY ID DESC) AS ROW 
						from [dbo].[FilestoImport] 
						where [dbo].[FilestoImport].[Source] in ('ROCK_GPM_FT')
					) as TMP 
				where 
					ROW = @counter
					
				select @step = 420		
				truncate table [dbo].table_ROCK_GPM_FT_rawdata
						
				select @step = 430
				BEGIN	 
					select @sql = N'BULK INSERT [dbo].[table_ROCK_GPM_FT_rawdata]  FROM '  + '''' + @PathName  + @filename + ''''  + ' WITH (CODEPAGE = 1252, FIELDTERMINATOR ='','', FIRSTROW = 2, ROWTERMINATOR =''\n'')';
					execute sp_executesql @sql 
				END

				select @step = 440		
				/*fill from tmp table into final table including needed conversions*/
				INSERT INTO [dbo].[table_ROCK_GPM_FT_Data]
				(
					 [COB]
					,[Subsidiary]
					,[Strategy]
					,[Reference_ID]
					,[Trade_Date]
					,[Term_Start]
					,[Term_End]
					,[Internal_Portfolio]
					,[Counterparty_Ext_Bunit]
					,[Counterparty_Group]
					,[Volume]
					,[Header_Buy_Sell]
					,[Curve_Name]
					,[Projection_Index_Group]
					,[Instrument_Type]
					,[UOM]
					,[Int_Legal_Entity]
					,[Int_Bunit]
					,[Ext_Legal_Entity]
					,[Ext_Portfolio]
					,[Discounted_PNL]
					,[Undiscounted_PNL]
					,[Accounting_Treatment]
					,[Reference]
					,[Product]
					,[FIleID]
				)
				SELECT
					 convert(date,[As_of_Date],103) as [COB]	
					,[Subsidiary]
					,[Strategy]
					,[Reference_ID]
					,convert(date,[Trade_Date],103) 
					,convert(date,[Term_Start],103) 
					,convert(date,[Term_End],103) 
					,[Internal_Portfolio]
					,[Counterparty_Ext_Bunit]
					,[Counterparty_Group]
					,cast([Volume] as float) 
					,[Header_Buy_Sell]
					,[Curve_Name]
					,[Projection_Index_Group]
					,[Instrument_Type]
					,[UOM]
					,[Int_Legal_Entity]
					,[Int_Bunit]
					,[Ext_Legal_Entity]
					,[Ext_Portfolio]
					,cast([Discounted_PNL] as float)
					,cast([Undiscounted_PNL] as float)
					,[Accounting_Treatment]
					,[Reference]
					,[Product]
					,@FIleID as FileID /*3004*/
				FROM
					[dbo].table_ROCK_GPM_FT_rawdata
				WHERE 
					Internal_Portfolio not like 'RGM_D_DUMMY%'
					

				select @step = 450		
				/*-- document import timestamp for just imported file*/
				update dbo.FilestoImport set LastImport = getdate() where id = @FileID
				
					
				select @step = 460		
				select @TotalRecordsInserted = count(*) from [dbo].table_ROCK_GPM_FT_rawdata
				IF @LogInfo >= 1 BEGIN INSERT INTO [dbo].[Logfile] SELECT @proc + ' - import #' + cast(@counter as varchar) + ': ' + @filename + ' - records: ' + cast(@TotalRecordsInserted as varchar), GETDATE ()   END	
					
					/*-- decrease counter for the next file to be processed*/
					select @counter = @counter - 1
	
			END ---while @counter > 0	

				select @step = 470	
				/*-- count total number of imported records*/
				select @TotalRecordsInserted = count(*) from [dbo].table_ROCK_GPM_FT_Data				
				if @LogInfo >= 1  BEGIN insert into [dbo].[Logfile] select @proc + ' - FT records imported: ' + cast(@TotalRecordsInserted as varchar), GETDATE ()   END								
		
		END---IF @DataToImport <> 'ROCK	 
		/*==============================================================================================================================================================*/
		
		/*now import just the koeppen file with illiquid data generated by GPM (not queryable from rock) */
		IF @DataToImport = 'GPM' or @DataToImport = 'ALL' /* means parameter is "GPM" or "ALL" */
		BEGIN 
		
			/*-- identify how many file will be imported */
			select @step = 475						
			select @counter = count(1) from [dbo].[FilestoImport] where [dbo].[FilestoImport].[Source] in ('GPM_RECON_Illiquid') and ToBeImported=1
			
			--/*in case here is no importfile, create a related log entry and jump out*/
			select @step = 476
			IF @counter=0 
			BEGIN 
				INSERT INTO [dbo].[Logfile] SELECT @proc + ' - nothing found to get imported.', GETDATE ()   
				GOTO NoFurtherAction 
			END		
						
			IF @LogInfo >= 1  BEGIN INSERT INTO [dbo].[Logfile] SELECT @proc + ' - importing ' + cast(@counter as varchar) + ' file(s) from ' + @PathName  , GETDATE ()   END			
			select @step = 202
			IF (EXISTS (SELECT * FROM INFORMATION_SCHEMA.TABLES WHERE table_schema = 'dbo' and TABLE_NAME = 'table_ROCK_GPM_Koeppen_Rawdata'))
			BEGIN												
				drop table [dbo].table_ROCK_GPM_Koeppen_Rawdata
			END
						
			select @step = 210
			/*create a temporary import-table for rawdata that gets deleted again after the data has been imported.*/
			CREATE table [dbo].table_ROCK_GPM_Koeppen_Rawdata
			(
				Category nvarchar(100) NULL,
				PV_in_EUR nvarchar(100) NULL,
				PV_mEUR nvarchar(100) NULL,
				Df_EUR nvarchar(100) NULL,
				NV_mEUR nvarchar(100) NULL,
				Year_x nvarchar(100) NULL,
				Market_data nvarchar(100) NULL,
				DEAL_NUM nvarchar(100) NULL,
				DEAL_LEG nvarchar(100) NULL,
				CF_TYPE nvarchar(100) NULL,
				start_date nvarchar(100) NULL,
				end_date nvarchar(100) NULL,
				pymt_date nvarchar(100) NULL,
				CURRENCY_NAME nvarchar(100) NULL,
				LEG_TYPE nvarchar(100) NULL,
				SIZE_BASE nvarchar(100) NULL,
				price nvarchar(100) NULL,
				pymt nvarchar(100) NULL,
				total_value nvarchar(100) NULL,
				PV_IN_EUR2 nvarchar(100) NULL,
				DF nvarchar(100) NULL,
				EXTERNAL_BUNIT nvarchar(100) NULL,
				INTERNAL_PORTFOLIO nvarchar(100) NULL,
				REFERENCE nvarchar(100) NULL,
				INS_TYPE nvarchar(100) NULL,
				MTD_CHG_EUR nvarchar(100) NULL,
				Pf nvarchar(100) NULL,
				xx_41607_00 nvarchar(100) NULL,
				Season nvarchar(50) NULL,
				Undisc_turnover_SY_19_20_mEUR nvarchar(100) NULL,
				phys_volume_MWh nvarchar(100) NULL,
				new_deal nvarchar(100) NULL
			) 

			WHILE @counter > 0				
			BEGIN 
				/*-- identify the name of the file to be loaded */					
				select @step = 410		
				select  
						 @filename = [FileName]
						,@FileID   = [ID]
				from 
					(select *, ROW_NUMBER() OVER(ORDER BY ID DESC) AS ROW 
						from [dbo].[FilestoImport] 
						where [dbo].[FilestoImport].[Source] in ('GPM_RECON_ILLIQUID')
					) as TMP 
				where 
					ROW = @counter

			 select @step = 415		
			/*substitute date placeholder in filename*/
				SELECT @filename  = replace (@filename , '%YYYY%', format(@COB_MTM,'yyyy'))	
				SELECT @filename  = replace (@filename , '%MM%', format(@COB_MTM,'MM'))
	
						
				select @step = 420
				BEGIN	 
					select @sql = N'BULK INSERT [dbo].[table_ROCK_GPM_Koeppen_Rawdata]  FROM '  + '''' + @PathName  + @filename + ''''  + ' WITH (CODEPAGE = 1252, FIELDTERMINATOR ='','', FIRSTROW = 4, ROWTERMINATOR =''\n'')';
					execute sp_executesql @sql 
				END

				/*in case the original excel file contained empty rows, we erase them here*/
				select @step = 430		
				delete from dbo.table_ROCK_GPM_Koeppen_Rawdata where category is null									

				select @step = 430		
				truncate table [dbo].table_ROCK_GPM_Koeppen_data

				select @step = 440		
				/*fill from tmp table into final table including needed conversions*/
				INSERT INTO [dbo].table_ROCK_GPM_Koeppen_data
				(
					 COB
					,Intermediate2Name
					,INTERNAL_PORTFOLIO
					,Instrument_Type
					,DEAL_NUMBER
					,Term_End
					,MtM
					,FileID
				)				
				select					
					@cob_mtm as cob
					,table_business_unit_hierarchy.Intermediate2Name as Intermediate2Name
					,INTERNAL_PORTFOLIO
					,INS_TYPE as Instrument_Type
					,DEAL_NUM as DEAL_NUMBER
					,convert(date, end_date,103) as Term_End
					, CAST(PV_in_EUR as float) as MtM					
					,@FileID					
				from 
					table_ROCK_GPM_Koeppen_Rawdata left outer join dbo.table_business_unit_hierarchy 
					on table_ROCK_GPM_Koeppen_Rawdata.INTERNAL_PORTFOLIO = table_business_unit_hierarchy.portfolioName

			select @step = 450		
				/*-- document import timestamp for just imported file*/
				update dbo.FilestoImport set LastImport = getdate() where id = @FileID
					
				select @step = 460		
				select @TotalRecordsInserted = count(*) from [dbo].table_ROCK_GPM_Koeppen_Rawdata
				IF @LogInfo >= 1 BEGIN INSERT INTO [dbo].[Logfile] SELECT @proc + ' - import #' + cast(@counter as varchar) + ': ' + @filename + ' - records: ' + cast(@TotalRecordsInserted as varchar), GETDATE ()   END	
					
					/*-- decrease counter for the next file to be processed*/
					select @counter = @counter - 1	
			END ---while @counter > 0	

		END
		/*=================================================================================================================================================================*/



		if @LogInfo >= 1  BEGIN insert into [dbo].[Logfile] select @proc + ' - merge data from FT and ROCK', GETDATE ()   END								
		select @step = 500
		IF (EXISTS (SELECT * FROM INFORMATION_SCHEMA.TABLES WHERE table_schema = 'dbo' and TABLE_NAME = 'table_ROCK_GPM_PNL_ALL_Data'))
		BEGIN												
			drop table [dbo].table_ROCK_GPM_PNL_ALL_Data
		END
		
		select @step = 501
		CREATE TABLE [dbo].table_ROCK_GPM_PNL_ALL_Data
		(
			[CoB] [date] NULL,
			[DealID] [nvarchar](100) NULL,
			[InternalPortfolio] [nvarchar](100) NULL,
			[CounterpartyGroup] [nvarchar](100) NULL,
			[InstrumentType] [nvarchar](100) NULL,
			[ProjectionIndexGroup] [nvarchar](100) NULL,
			[Liefermonat] [nvarchar](50) NULL,
			[Risk_MTM] [float] NULL,
			[FT_MTM] [float] NULL,	
			[FileID] [int] NULL,
			[FileSource] [nvarchar](50) NULL
		)
		
		/*now fill that new table*/

		/*first with data from FT*/
		select @step = 502
		insert into dbo.table_ROCK_GPM_PNL_ALL_Data
			SELECT 
				 CoB
				,Reference_ID as DealID
				,Internal_Portfolio as InternalPortfolio
				,Counterparty_Group as CounterpartyGroup
				,Instrument_Type as InstrumentType
				,Projection_Index_Group as ProjectionIndexGroup
				,format(Term_End,'yyyy_MM') as Liefermonat
				,cast(0 as float) as Risk_MTM
				,Discounted_PNL as FT_MTM
				,FileID
				,'FT' as FileSource
			from 
				dbo.table_ROCK_GPM_FT_Data
			where 
				Term_End<= @End_Of_Liquid_Period
		
	
		/*then with data from ROCK*/
		select @step = 503
		insert into dbo.table_ROCK_GPM_PNL_ALL_Data
			select 				
			cast(COB as datetime) as CoB
			,[Trade Deal Number] as DealID
			,[Internal Portfolio Name] as InternalPortfolio		
			,NULL as CounterpartyGroup
			,[Instrument Type Name] as InstrumentType	
			,NULL as ProjectionIndexGroup
			,NULL as Liefermonat
			,sum([Unrealised Discounted (EUR)]) as Risk_MTM	
			,cast(0 as float) as FT_MTM
			,FileId			
			,'ROCK' as FileSource			
			from 
				GloriRisk
			where 
				Desk_Name like 'GPM DESK'				
				and CASHFLOW_PAYMENT_DATE >=  @AsOfDate_MTM_BeginningOfLastYear
				and [Internal Portfolio Name] NOT IN 
					(				
						 'RGM_D_DUMMY_SENSI'
						,'RGM_CZ_DUMMY_POS'
						,'RGM_D_DUMMY_SWING'
						,'RGM_D_DUMMY_OPTIONS'
						,'RGM_D_DUMMY_SWING_1'
						,'RGM_D_DUMMY_SWING_2'
						,'RGM_D_DUMMY_POS'
						,'RGM_D_DUMMY_IRS'
					)
				AND [instrument type name] NOT LIKE '%Dummy%'
				and FileID not in (3133)
			GROUP BY 				
				COB			
				,[Trade Deal Number]	
				,[Internal Portfolio Name]
				,[Instrument Type Name]
				,FileId
		
		if @LogInfo >= 1  BEGIN insert into [dbo].[Logfile] select @proc + ' - create recon: Recon_MtM_Diff', GETDATE ()   END	
		select @step = 504
		
		/* former query "00_SBM" , here used as temp table, as we need it several times but it's not worth to keep it permanent*/
		IF (EXISTS (SELECT * FROM INFORMATION_SCHEMA.TABLES WHERE table_schema = 'dbo' and TABLE_NAME = 'tmp_table_ROCK_GPM_SBM'))
		BEGIN												
			drop table [dbo].tmp_table_ROCK_GPM_SBM
		END

		SELECT 
			 Subsidiary
			,Strategy
			,Max(Book) AS Book
			,InternalPortfolio 
		INTO
			dbo.tmp_table_ROCK_GPM_SBM
		FROM 
			dbo.map_SBM
		WHERE
			Subsidiary='RWEST DE'
			AND Strategy like 'CAO Gas%'
		GROUP BY 
			Subsidiary
			,Strategy 
			,InternalPortfolio
									
		/* former query "10_Recon_MtM_Diff" */
		select @step = 505
		truncate table dbo.table_ROCK_GPM_Recon_MTM_DIFF

		/* in case differences need to get split by liquid /Illiquid (active ( inactive) period, 
			 the following query needs to get duplicated and the sub_select need to get add the following condition:

				for liquid:
				where fileid <>3133 /* rock gpm liquid data*/
				or (FileSource = 'FT' and Liefermonat <= (select format(max(DEAL_PDC_END_DATE),'yyyy_MM') from dbo.GloriRisk where Desk_Name like '%GPM%' and fileID<>3133))/* FT illiquid data)*/

				for illiquid:
				where fileid =3133 /* rock gpm illiquid data*/
				or (FileSource = 'FT' and Liefermonat > (select format(max(DEAL_PDC_END_DATE),'yyyy_MM') from dbo.GloriRisk where Desk_Name like '%GPM%' and fileID<>3133))/* FT illiquid data)*/
		*/
		
		select @step = 506
		INSERT INTO [dbo].[table_ROCK_GPM_Recon_MTM_DIFF]
		(
			 [Strategy]
      ,[DealID]
      ,[InternalPortfolio]
      ,[CounterpartyGroup]
      ,[InstrumentType]
      ,[ProjectionIndexGroup]
      ,[Liefermonat]
      ,[Risk]
      ,[Finance]
      ,[Adj]
      ,[Dummy]
      ,[Diff]
      ,[AbsDiff]
		)
		SELECT 
			dbo.tmp_table_ROCK_GPM_SBM.Strategy
			,SubSQL.DealID
			,SubSQL.InternalPortfolio
			,Max(SubSQL.CounterpartyGroup) AS CounterpartyGroup
			,SubSQL.InstrumentType
			,Max(SubSQL.ProjectionIndexGroup) AS ProjectionIndexGroup
			,Max(SubSQL.Liefermonat) AS Liefermonat
			,Sum(SubSQL.Risk_MTM) AS Risk_MTM
			,Sum(SubSQL.FT_MTM) AS Finance
			,Sum(SubSQL.Adj) AS Adj
			,Sum(SubSQL.DUMMY) AS DUMMY
			,Sum(SubSQL.Diff) AS Diff
			,Abs(Sum(SubSQL.Diff)) AS absDiff
		FROM 
		(
			 SELECT DealID
			,InternalPortfolio
			,Max(CounterpartyGroup) AS CounterpartyGroup
			,InstrumentType AS InstrumentType
			,Max(ProjectionIndexGroup) AS ProjectionIndexGroup
			,Liefermonat
			,Sum(Risk_MtM) AS Risk_MtM
			,Sum(FT_MtM) AS FT_MTM
			,Sum(IIf(InstrumentType IN ('XVA - Provision','XVA - Adjustment','ADJUST'), Risk_MtM, 0)) AS Adj
			,Sum(IIf(InternalPortfolio LIKE '%dummy%' AND InternalPortfolio NOT IN ('RGM_D_DUMMY_SENSI'), FT_MtM, 0)) AS DUMMY
			,Sum(Risk_MtM - FT_MtM - IIf(InstrumentType IN ('XVA - Provision','XVA - Adjustment','ADJUST'), Risk_MtM, 0) + IIf(InternalPortfolio LIKE '%dummy%' AND InternalPortfolio NOT IN ('RGM_D_DUMMY_SENSI'), FT_MtM, 0)) AS Diff
			,Abs(Sum(Risk_MtM - FT_MtM - IIf(InstrumentType IN ('XVA - Provision','XVA - Adjustment','ADJUST'), Risk_MtM, 0) + IIf(InternalPortfolio LIKE '%dummy%' AND InternalPortfolio NOT IN ('RGM_D_DUMMY_SENSI'), FT_MtM, 0))) AS absDiff
		FROM 
			dbo.table_ROCK_GPM_PNL_ALL_Data
		WHERE	
			FileSource in ('FT', 'ROCK')
			and FileID not in (3133)
		GROUP BY DealID
			,InternalPortfolio
			,InstrumentType
			,Liefermonat
			) SubSQL
			LEFT JOIN dbo.tmp_table_ROCK_GPM_SBM ON SubSQL.InternalPortfolio = dbo.tmp_table_ROCK_GPM_SBM.InternalPortfolio
		WHERE 				
				SubSQL.InstrumentType NOT IN ('Dummy')			
			OR 
				SubSQL.InternalPortfolio IS NULL
		GROUP BY 
			dbo.tmp_table_ROCK_GPM_SBM.Strategy
			,SubSQL.DealID
			,SubSQL.InternalPortfolio
			,SubSQL.InstrumentType
		HAVING 
			Abs(Sum(SubSQL.Diff)) > 1	

		SELECT @STEP=507		
		/*create data table for won use data, as a view is toooo slow.*/
		truncate table dbo.table_ROCK_GPM_Own_Use
		
		SELECT @STEP=508
		insert into dbo.table_ROCK_GPM_Own_Use
		SELECT 
			 cast(COB as date) as cob
			,map_SBM.Subsidiary 
			,FT.Strategy
			,dbo.map_SBM.Book
			,FT.Internal_Portfolio
			,FT.Counterparty_Group
			,Sum(FT.Volume) AS Volume
			,Header_Buy_Sell AS BuySell
			,Curve_Name
			,FT.Projection_Index_Group
			,FT.Instrument_Type
			,FT.UOM
			,FT.Int_Legal_Entity
			,FT.Int_Bunit
			,FT.Ext_Legal_Entity
			,FT.Ext_Portfolio
			,Sum(Discounted_PNL / 1000000) AS DiscPnL_mEUR
			,FT.[Accounting_Treatment]
			,Year([Term_End]) AS [TermEndYear]
			,IIf(FT.Accounting_Treatment = 'Hedging Instrument (Der)', IIf([unrealizedearnings] LIKE 'I2339%', 'OCI', IIf([unrealizedearnings] LIKE 'I5999900%', 'NE', 'PNL')), IIf(FT.Accounting_Treatment = 'Hedged Items', 'Hedged Item', 'Own Use')) AS PNL_OCI
			,IIf(FT.counterparty_group LIKE 'RWE%' OR FT.counterparty_group LIKE 'ESS%' OR FT.counterparty_group IN ('POWERHOUSE'), 'Group Internal', IIf(FT.counterparty_group LIKE 'Interdesk%' OR FT.counterparty_group LIKE 'Intradesk%', 'Interdesk', FT.counterparty_group)) AS CtpyGroup2
			,IIf(FT.Instrument_Type IN (
					'CASH'
					,'COMM-EXCH'
					,'COMM-FEE'
					,'COMM-STOR'
					,'COMM-CAP-ENTRY'
					,'COMM-CAP-EXIT'
					,'COMM-TRANS'
					,'EO-C-Basket-Spd'
					), 'non-derivative', 'derivative') AS [Non-derivative]
			,Sum(FT.[volume] * isnull(conv, 1)) AS Volume_MWh
			,Sum(UnDiscounted_PNL / 1000000) AS UndiscPnL_mEUR
			,case when Term_End > End_Of_Active_Period then 0 else 1 End as Active_Period
		FROM 	
			(dbo.table_ROCK_GPM_FT_Data FT LEFT JOIN map_UOM_conversion 
			ON FT.UOM = map_UOM_conversion.UNIT_FROM)	LEFT JOIN dbo.map_SBM 
			ON FT.Projection_Index_Group = dbo.map_SBM.ProjectionIndexGroup 
				AND FT.Instrument_Type = dbo.map_SBM.InstrumentType
				AND FT.Counterparty_Group = dbo.map_SBM.counterpartygroup 
				AND FT.Internal_Portfolio = dbo.map_SBM.InternalPortfolio
			,(select MAX(DEAL_PDC_END_DATE) as End_Of_Active_Period from dbo.GloriRisk where Desk_Name like '%GPM%' and FileId<>3133) as subSQL
	
		WHERE
			FT.Internal_Portfolio NOT IN ('RGM_D_DUMMY_SENSI','RGM_CZ_DUMMY_POS','RGM_D_DUMMY_POS')	
		GROUP BY 
			FT.cob
			,dbo.map_SBM.Subsidiary
			,FT.Strategy
			,dbo.map_SBM.Book
			,FT.Internal_Portfolio
			,FT.Counterparty_Group
			,FT.Header_Buy_Sell
			,FT.Curve_Name
			,FT.Projection_Index_Group
			,FT.Instrument_Type
			,FT.UOM
			,FT.Int_Legal_Entity
			,FT.Int_Bunit
			,FT.[Ext_Legal_Entity]
			,FT.Ext_Portfolio
			,FT.Accounting_Treatment
			,case when Term_End > End_Of_Active_Period then 0 else 1 End 
			,Year(Term_End) 	
			,IIf(FT.Accounting_Treatment = 'Hedging Instrument (Der)', IIf([unrealizedearnings] LIKE 'I2339%', 'OCI', IIf([unrealizedearnings] LIKE 'I5999900%', 'NE', 'PNL')), IIf(FT.Accounting_Treatment = 'Hedged Items', 'Hedged Item', 'Own Use'))
			,IIf(FT.counterparty_group LIKE 'RWE%' OR [FT].[counterparty_group] LIKE 'ESS%' OR FT.counterparty_group IN ('POWERHOUSE'), 'Group Internal', IIf(FT.counterparty_group LIKE 'Interdesk%' OR FT.counterparty_group LIKE 'Intradesk%', 'Interdesk', FT.counterparty_group))
			,IIf(FT.Instrument_Type IN (
					'CASH'
					,'COMM-EXCH'
					,'COMM-FEE'
					,'COMM-STOR'
					,'COMM-CAP-ENTRY'
					,'COMM-CAP-EXIT'
					,'COMM-TRANS'
					,'EO-C-Basket-Spd'
					), 'non-derivative', 'derivative')


/*XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX*/
		
		/*remove old koeppen data from pnl_all*/
		select @step = 600				
		select @FileID = fileid from dbo.table_ROCK_GPM_Koeppen_data /*id of koppen file, should be 3139 */
	
		select @step = 605			
		delete from dbo.table_ROCK_GPM_PNL_ALL_Data where fileID = @FileID
		
		/*koeppen data into pnl_all*/
		select @step = 610			
		insert into dbo.table_ROCK_GPM_PNL_ALL_Data
		(
			COB
			,DealID
			,InternalPortfolio
			,InstrumentType
			,Liefermonat
			,Risk_MTM
			,FileID
			,FileSource
		)
		select
			COB
			,deal_number as DealID
			,internal_portfolio as InternalPortfolio
			,instrument_type as InstrumentType
			,term_end as Liefermonat
			,mtm as Risk_MTM
			,fileid
			,'GPM'
		FROM 
			dbo.table_ROCK_GPM_Koeppen_data

		/*empty table with data ft vs koeppen*/
		select @step = 620
		truncate table [dbo].[table_ROCK_GPM_Recon_MTM_DIFF_FT_Koeppen]

		/*free refill (no alcoholics!) */
		select @step = 630
		INSERT INTO [dbo].[table_ROCK_GPM_Recon_MTM_DIFF_FT_Koeppen]
		(
			Strategy
			,DealID
			,InternalPortfolio
			,CounterpartyGroup
			,InstrumentType
			,ProjectionIndexGroup
			,Liefermonat
			,GPM_MTM
			,Finance
			,Adj
			,DUMMY
			,Diff
			,AbsDiff
		)
		SELECT 
			dbo.tmp_table_ROCK_GPM_SBM.Strategy
			,SubSQL.DealID
			,SubSQL.InternalPortfolio
			,Max(SubSQL.CounterpartyGroup) AS CounterpartyGroup
			,SubSQL.InstrumentType
			,Max(SubSQL.ProjectionIndexGroup) AS ProjectionIndexGroup
			,Max(SubSQL.Liefermonat) AS Liefermonat
			,Sum(SubSQL.GPM_MTM) AS GPM_MTM
			,Sum(SubSQL.FT_MTM) AS Finance
			,Sum(SubSQL.Adj) AS Adj
			,Sum(SubSQL.DUMMY) AS DUMMY
			,Sum(SubSQL.Diff) AS Diff
			,Abs(Sum(SubSQL.Diff)) AS absDiff		
		FROM 
		(
			 SELECT DealID
			,InternalPortfolio
			,Max(CounterpartyGroup) AS CounterpartyGroup
			,InstrumentType AS InstrumentType
			,Max(ProjectionIndexGroup) AS ProjectionIndexGroup
			,Liefermonat
			,Sum(Risk_MtM) AS GPM_MTM
			,Sum(FT_MtM) AS FT_MTM
			,Sum(IIf(InstrumentType IN ('XVA - Provision','XVA - Adjustment','ADJUST'), Risk_MtM, 0)) AS Adj
			,Sum(IIf(InternalPortfolio LIKE '%dummy%' AND InternalPortfolio NOT IN ('RGM_D_DUMMY_SENSI'), FT_MtM, 0)) AS DUMMY
			,Sum(Risk_MtM - FT_MtM - IIf(InstrumentType IN ('XVA - Provision','XVA - Adjustment','ADJUST'), Risk_MtM, 0) + IIf(InternalPortfolio LIKE '%dummy%' AND InternalPortfolio NOT IN ('RGM_D_DUMMY_SENSI'), FT_MtM, 0)) AS Diff
			,Abs(Sum(Risk_MtM - FT_MtM - IIf(InstrumentType IN ('XVA - Provision','XVA - Adjustment','ADJUST'), Risk_MtM, 0) + IIf(InternalPortfolio LIKE '%dummy%' AND InternalPortfolio NOT IN ('RGM_D_DUMMY_SENSI'), FT_MtM, 0))) AS absDiff
		FROM 
			dbo.table_ROCK_GPM_PNL_ALL_Data
		WHERE	
			FileSource in ('FT', 'GPM')
		GROUP BY DealID
			,InternalPortfolio
			,InstrumentType
			,Liefermonat
		) SubSQL
			LEFT JOIN dbo.tmp_table_ROCK_GPM_SBM ON SubSQL.InternalPortfolio = dbo.tmp_table_ROCK_GPM_SBM.InternalPortfolio
		WHERE 				
				SubSQL.InstrumentType NOT IN ('Dummy')			
			OR 
				SubSQL.InternalPortfolio IS NULL
		GROUP BY 
			dbo.tmp_table_ROCK_GPM_SBM.Strategy
			,SubSQL.DealID
			,SubSQL.InternalPortfolio
			,SubSQL.InstrumentType
		HAVING 
			Abs(Sum(SubSQL.Diff)) > 1	

/*XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX*/
		/*cleanup*/
		select @step = 666
		IF (EXISTS (SELECT * FROM INFORMATION_SCHEMA.TABLES WHERE table_schema = 'dbo' and TABLE_NAME = 'tmp_ROCK_GPM_SBM'))
		BEGIN												
			drop table [dbo].tmp_table_ROCK_GPM_SBM
		END


NoFurtherAction:
		IF @LogInfo >= 1 BEGIN INSERT INTO [dbo].[Logfile] SELECT @proc + ' - FINISHED', GETDATE ()   END
		
END TRY

	BEGIN CATCH
		EXEC [dbo].[usp_GetErrorInfo] @proc, @step		
		BEGIN INSERT INTO [dbo].[Logfile] SELECT @proc + ' - FAILED', GETDATE ()   END
	END CATCH

GO

