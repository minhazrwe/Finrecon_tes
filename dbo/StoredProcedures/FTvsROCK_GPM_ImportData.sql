
/*purpose:
1) import the mtm_report files from ROCK and FT for GPM into the database.
2) run queries to fill prepare mtm check
parameter @DataToImport can bei either 
"FT"		--> only data from FT file gets imported
"ROCK"	--> only data from ROCK files get imported
"ALL"   --> ALL data files will get imported
*/

CREATE PROCEDURE dbo.FTvsROCK_GPM_ImportData
	@DataToImport varchar(10)
AS
BEGIN TRY

/*============ part I: declare some variables that are needed for processing============================================================*/

		DECLARE @proc nvarchar (40)
		DECLARE @step integer
		DECLARE @sql nvarchar (max)
		DECLARE @return_value integer
		DECLARE @LogInfo Integer
		DECLARE @counter Integer
		
		DECLARE @file_line_counter Integer
		DECLARE @filename nvarchar (200)
		DECLARE @FileID integer
		DECLARE @FileSource nvarchar (40)
		DECLARE @importpath nvarchar (400)
			
		declare @recordcount as numeric
		declare @COB as date
		declare @COBdata as date
		
/*============ part II: collecting general information ===================================================================================*/
 
		select @step = 1
		select @proc = Object_Name(@@PROCID)

		IF @LogInfo >= 1  BEGIN insert into [dbo].[Logfile] select @proc + ': ' + @DataToImport, GETDATE () END
		
		/*-- check if logging is globally enabled*/
		select @LogInfo = [dbo].[LogInfo].[LogInfo] from [dbo].[LogInfo]
	
		/*--identify the COB that the mtm_check should be done for (needs to get checked against the datafiles before processing!)*/	
		select @step = 2
		select @cob = AsOfDate_MtM_Check from dbo.AsOfDate

		/*-- identify the path where the files should be imported from (and replace placeholders for date & month).*/
		/* it is the same path for rock related and ft related files, so we can look for the source instead of the pathID related to the importfile.*/

		/* running dbo.[udf_get_path] doesnn't work here as we get use the "AsOfDate_MtM_Check" field rather than "AsOfDate_EOM" */  
		select @step = 3						
		SELECT @importpath = [path] from  [dbo].[pathtofiles] where [dbo].[pathtofiles].[Source] = 'FTvsROCK_GPM'
		SELECT @importpath = replace (@importpath, '%YYYY%', format(@cob,'yyyy'))	
		SELECT @importpath = replace (@importpath, '%MM%', format(@cob,'MM'))
	
	select @importpath 

/*============ part III: data load from specified sources ===================================================================================*/
		if @LogInfo >= 1  
		BEGIN 
			insert into [dbo].[Logfile] select @proc + ' - START', GETDATE () 			
			insert into [dbo].[Logfile] select @proc + ' - Import ' + @DataToImport + ' data for COB ' + cast(@COB as varchar), GETDATE () 
		END			 	

/*-- ROCK related imports*/		
		IF @DataToImport <>'FT'	/* --> parameter is "ROCK" or "ALL" */			
		BEGIN
			select @FileSource	='FTvsROCK_GPM_ROCK'

			/*-- identify how many file will be imported */
			select @counter = count(1) from [dbo].[FilestoImport] where [dbo].[FilestoImport].[Source] in (@FileSource) and ToBeImported=1
			
			--/*in case here is no importfile, create a reladed log entry and jump out*/
			IF @counter=0 
			BEGIN 
				INSERT INTO [dbo].[Logfile] SELECT @proc + ' - nothing found to get imported.', GETDATE () 
				GOTO NoFurtherAction 
			END		
						
			select @step = 100
			IF @LogInfo >= 1  BEGIN insert into [dbo].[Logfile] select @proc + ' - importing ROCK data' , GETDATE () END

			SELECT @step=110		
			IF (EXISTS (SELECT * FROM INFORMATION_SCHEMA.TABLES WHERE table_schema = 'dbo' and TABLE_NAME ='table_FTvsROCK_GPM_ROCK_Data_tmp'))
			BEGIN truncate table [dbo].[table_FTvsROCK_GPM_ROCK_Data_tmp] END

			--SELECT @step=120
			--	/*--create a temporary table for imports that gets deleted again after the data has been imported (done at the end of this procedure).*/
			--CREATE TABLE [dbo].[table_FTvsROCK_GPM_ROCK_Data_tmp](
			--	[CoB] [nvarchar](50) NOT NULL,
			--	[Intermediate_5_Name] [nvarchar](50) NULL,
			--	[Book_Name] [nvarchar](50) NULL,
			--	[Portfolio_Name] [nvarchar](50) NULL,
			--	[Instrument_Type_Name] [nvarchar](50) NULL,
			--	[Deal_Number] [nvarchar](50) NULL,
			--	[Cashflow_Type_Name] [nvarchar](50) NULL,
			--	[Cashflow_Currency] [nvarchar](10) NULL,
			--	[PnL_Undisc_Real_CF_CCY] [float] NULL,
			--	[PnL_Undisc_Real_LGBY_CF_CCY] [float] NULL,
			--	[PnL_Disc_Total_YtD_PH_BU_CCY] [float] NULL,
			--	[PnL_Disc_Unreal_LtD_PH_BU_CCY] [float] NULL,
			--	[PnL_Disc_Unreal_LGBY_PH_BU_CCY] [float] NULL,
			--	[PnL_Disc_Unreal_YtD_PH_BU_CCY] [float] NULL,
			--	[PnL_Disc_Real_LtD_PH_BU_CCY] [float] NULL,
			--	[PnL_Undisc_Real_BU_CCY] [float] NULL,
			--	[PnL_Disc_Real_LGBY_PH_BU_CCY] [float] NULL,
			--	[PnL_Disc_Real_YtD_PH_BU_CCY] [float] NULL,
			--	[PnL_Disc_Total_YtD_BU_CCY] [float] NULL,
			--	[PnL_Disc_Unreal_BU_CCY] [float] NULL,
			--	[PnL_Disc_Unreal_LGBY_BU_CCY] [float] NULL,
			--	[PnL_Disc_Unreal_YtD_BU_CCY] [float] NULL,
			--	[PnL_Disc_Real_BU_CCY] [float] NULL,
			--	[PnL_Disc_Real_LGBY_BU_CCY] [float] NULL,
			--	[PnL_Disc_Real_YtD_BU_CCY] [float] NULL
			--) ON [PRIMARY]

			IF @LogInfo >= 1  BEGIN INSERT INTO [dbo].[Logfile] SELECT @proc + ' - importing ' + cast(@counter as varchar) + ' files from ' + @importpath , GETDATE () END			
			--/*loop over counter, reduce it at then end*/ 	
			WHILE @counter >0
				BEGIN			
				SELECT @step=200
					/*in case it's not the first round we come through here:*/
					truncate table [dbo].[table_FTvsROCK_GPM_ROCK_Data_tmp]
					
					SELECT @step=210
					/*-- identify the name of the file to be loaded */					
					select  
							@filename = [FileName]
						,@FileID   = [ID]
					from 
						(select *, ROW_NUMBER() OVER(ORDER BY ID DESC) AS ROW 
							from [dbo].[FilestoImport] 
							where [dbo].[FilestoImport].[Source] in ('FTvsROCK_GPM_ROCK') and ToBeImported=1
						) as TMP 
					where 
						ROW = @counter
					
					SELECT @step=220
					--SELECT @sql = N'BULK INSERT [dbo].[table_FTvsROCK_GPM_ROCK_Data_tmp] FROM '  + '''' + @importpath + @filename + ''''  + ' WITH (CODEPAGE = 1252, FIELDTERMINATOR =''~'', FIRSTROW = 2, ROWTERMINATOR =''0x0a'')';
					SELECT @sql = N'BULK INSERT [dbo].[table_FTvsROCK_GPM_ROCK_Data_tmp] FROM '  + '''' + @importpath + @filename + ''''  + ' WITH (CODEPAGE = 1252, FIELDTERMINATOR =''~'', FIRSTROW = 2, ROWTERMINATOR =''\n'')';
					EXECUTE sp_executesql @sql
			
					SELECT @step=230
					/*delete old entries in ROCK data table */
					delete from [dbo].[table_FTvsROCK_GPM_ROCKData] where fileID=@FileID
					
					SELECT @step=240

					INSERT INTO [dbo].[table_FTvsROCK_GPM_ROCKData]
					(
						COB 
						,Intermediate_5_Name 
						,Book_Name 
						,Portfolio_Name 
						,Instrument_Type_Name 
						,Deal_Number 
						,Cashflow_Type 
						,Cashflow_Settlement_Type 
						,Cashflow_Currency 
						,Realised_Undiscounted_CF_CCY				/* PnL_Undisc_Real_CF_CCY					*/
						,Realised_Undiscounted_CF_CCY_EOLY	/* PnL_Undisc_Real_LGBY_CF_CCY		*/
						,Total_Discounted_YtD_EUR						/* PnL_Disc_Total_YtD_PH_BU_CCY		*/
						,Unrealised_Discounted_EUR					/* PnL_Disc_Unreal_LtD_PH_BU_CCY	*/
						,Unrealised_Discounted_EUR_EOLY			/* PnL_Disc_Unreal_LGBY_PH_BU_CCY */
						,Unrealised_Discounted_YtD_EUR			/* PnL_Disc_Real_LtD_PH_BU_CCY		*/
						,Realised_Discounted_EUR						/* PnL_Disc_Real_LtD_PH_BU_CCY		*/
						,Realised_Undiscounted_EUR					/* PnL_Undisc_Real_BU_CCY					*/
						,Realised_Discounted_EUR_EOLY				/* PnL_Disc_Real_LGBY_PH_BU_CCY		*/
						,Realised_Discounted_YtD_EUR				/* PnL_Disc_Real_YtD_PH_BU_CCY*/
						,fileID 
					)
						SELECT
								convert(date,COB,103) COB
							,Intermediate_5_Name
							,Book_Name
							,Portfolio_Name 
							,Instrument_Type_Name 
							,Deal_Number
							,Cashflow_Type_Name
							,Cashflow_Settlement_Type_Name 
							,Cashflow_Currency
							,convert(float, PnL_Undisc_Real_CF_ccy)
							,convert(float, PnL_Undisc_Real_LGBY_CF_ccy)
							,convert(float, PnL_Disc_Total_YtD_PH_BU_ccy)
							,convert(float, PnL_Disc_Unreal_LtD_PH_BU_ccy) 
							,convert(float, PnL_Disc_Unreal_LGBY_PH_BU_ccy)
							,convert(float, PnL_Disc_Unreal_YtD_PH_BU_ccy)
							,convert(float, PnL_Disc_Real_LtD_PH_BU_ccy) 
							,convert(float, PnL_Undisc_Real_BU_ccy) 
							,convert(float, PnL_Disc_Real_LGBY_PH_BU_ccy)
							,convert(float, PnL_Disc_Real_YtD_PH_BU_ccy)
							,@FileID
						FROM 
							dbo.table_FTvsROCK_GPM_ROCK_Data_tmp

						SELECT @step=250
						select @recordcount =count(*) from dbo.table_FTvsROCK_GPM_ROCK_Data_tmp						
						IF @LogInfo >= 1 BEGIN INSERT INTO [dbo].[Logfile] SELECT @proc + ' - import #' + cast(@counter as varchar) + ': ' + @filename + ' - records: '+ cast(format(@recordcount,'###,###') as varchar), GETDATE () END	
						
						SELECT @step=260
						/*-- document import timestamp fpor just imported file*/
						update dbo.FilestoImport set LastImport = getdate() where id = @FileID

						SELECT @step=270
						/*delete just imported data from helper table*/
						Truncate TABLE dbo.table_ROCK_MTM_Rawdata_tmp

						/*reduce counter*/
						SELECT @step=280
						select @counter = @counter - 1		
		
				END ---while @counter > 0

				SELECT @step=290
				/*-- count total number of imported records*/
				select @recordcount = count(*) from [dbo].[table_FTvsROCK_GPM_ROCKData]
				if @LogInfo >= 1  BEGIN insert into [dbo].[Logfile] select @proc + ' - ROCK records imported: ' + cast(format(@recordcount,'###,###') as varchar), GETDATE () END
								
		END ---IF @DataToImport <> 'FT'
/*****************************************************************************************************************************************************************************/	 


/*--import FasTracker data:*/
		IF @DataToImport <> 'ROCK' /* means parameter is "FT" or "ALL" */
		BEGIN 
			select @step = 300
			
			/*-- identify how many file will be imported */
			select @counter = count(1) from [dbo].[FilestoImport] where [dbo].[FilestoImport].[Source] in ('FTvsROCK_GPM_FT') 
					--/*in case here is no importfile, create a reladed log entry and jump out*/
			IF @counter=0 
			BEGIN 
				INSERT INTO [dbo].[Logfile] SELECT @proc + ' - nothing found to get imported.', GETDATE () 
				GOTO NoFurtherAction 
			END		
						
			select @step = 310
			--IF @LogInfo >= 1  BEGIN insert into [dbo].[Logfile] select @proc + ' - importing FT data', GETDATE () END
			IF @LogInfo >= 1  BEGIN INSERT INTO [dbo].[Logfile] SELECT @proc + ' - importing ' + cast(@counter as varchar) + ' file(s) from ' + @importpath , GETDATE () END			

			IF (EXISTS (SELECT * FROM INFORMATION_SCHEMA.TABLES WHERE table_schema = 'dbo' and TABLE_NAME = 'table_FTvsROCK_GPM_FT_Data_tmp'))
			BEGIN												
				drop table [dbo].[table_FTvsROCK_GPM_FT_Data_tmp]
			END
						
			select @step = 320
			--create a temporary table for imports that gets deleted again after the data has been imported.
			CREATE table [dbo].[table_FTvsROCK_GPM_FT_Data_tmp]
			(
				[COB] [nvarchar](100) NULL,
				[Subsidiary] [nvarchar](200) NULL,
				[Strategy] [nvarchar](200) NULL,
				[Book] [nvarchar](100) NULL,
				[AccountingTreatment] [nvarchar](100) NULL,	
				[ReferenceID] [nvarchar](100) NULL,
				[TermEnd]  [nvarchar](100) NULL,
				[InternalPortfolio] [nvarchar](100) NULL,
				[CounterpartyGroup]  [nvarchar](100) NULL,
				[CurveName]  [nvarchar](100) NULL,
				[ProjetionIndexGroup] [nvarchar](100) NULL,
				[InstrumentType] [nvarchar](100) NULL,
				[Product] [nvarchar](100) NULL,
				[DiscountedPNL] [nvarchar](100) NULL,
				[UndiscountedPNL] [nvarchar](100) NULL
			) ON [PRIMARY]
		
			select @step = 330
			/*--delete old entries in FT data table */
			truncate table [dbo].[table_FTvsROCK_GPM_FastrackerData]
				
				
			/*-- loop over all files that should be imported.*/
			select @step = 400
			while @counter > 0				
					BEGIN ---while @counter > 0
					
						select @step = 410		
						/*-- identify the name of the file to be loaded */					
						select  
								@filename = [FileName]
							,@FileID   = [ID]
						from 
							(select *, ROW_NUMBER() OVER(ORDER BY ID DESC) AS ROW 
								from [dbo].[FilestoImport] 
								where [dbo].[FilestoImport].[Source] in ('FTvsROCK_GPM_FT')
							) as TMP 
						where 
							ROW = @counter
					
					select @step = 420		
					truncate table [dbo].[table_FTvsROCK_GPM_FT_Data_tmp]
						
					select @step = 430
					----import the data from the identified file & path.
					--if @LogInfo >= 1  BEGIN insert into [dbo].[Logfile] select @proc + ' - now importing: ' + @filename , GETDATE () END

					BEGIN	 
						select @sql = N'BULK INSERT [dbo].[table_FTvsROCK_GPM_FT_Data_tmp]  FROM '  + '''' + @importpath + @filename + ''''  + ' WITH (CODEPAGE = 1252, FIELDTERMINATOR ='','', FIRSTROW = 2, ROWTERMINATOR =''\n'')';
						execute sp_executesql @sql 
					END

					select @step = 440		
					--fill from tmp table into final table including needed conversions.					
					BEGIN
						--beinhaltet auch die alte Abfrage "02_fastracker"
						insert into [dbo].[table_FTvsROCK_GPM_FastrackerData]
							(
								[COB]
								,[Subsidiary]
								,[Strategy]
								,[Book]
								,[AccountingTreatment]
								,[ReferenceID]
								,[TermEnd]
								,[InternalPortfolio]
								,[CounterpartyGroup]
								,[CurveName]
								,[ProjetionIndexGroup]
								,[InstrumentType]
								,[Product]
								,[DiscountedPNL]
								,[UndiscountedPNL]
								,[FileID]
							)
							select 
								convert(date,[COB],103)
								,[Subsidiary]
								,[Strategy]
								,[Book]
								,[AccountingTreatment]
								,[ReferenceID]
								,convert(date,[TermEnd],103)
								,[InternalPortfolio]
								,[CounterpartyGroup]
								,[CurveName]
								,[ProjetionIndexGroup]
								,[InstrumentType]
								,[Product]
								,convert(float,[DiscountedPNL])
								,convert(float,[UndiscountedPNL]) 
								,@FileID
							from 
								[dbo].[table_FTvsROCK_GPM_FT_Data_tmp]
							where 
								Strategy not In ('CAO Power','Sales & Origination') 
								OR Strategy Is Null
					END								
						
					select @step = 450		
					/*-- document import timestamp fpor just imported file*/
					update dbo.FilestoImport set LastImport = getdate() where id = @FileID
					
					select @step = 460		
					select @recordcount = count(*) from [dbo].[table_FTvsROCK_GPM_FT_Data_tmp]
					IF @LogInfo >= 1 BEGIN INSERT INTO [dbo].[Logfile] SELECT @proc + ' - import #' + cast(@counter as varchar) + ': ' + @filename + ' - records: '+ cast(format(@recordcount,'###,###') as varchar), GETDATE () END	
					
					/*-- decrease counter for the next file to be processed*/
					select @counter = @counter - 1
	
				END ---while @counter > 0	

				select @step = 470	
				/*-- count total number of imported records*/
				select @recordcount = count(*) from [dbo].[table_FTvsROCK_GPM_FastrackerData]				
				if @LogInfo >= 1  BEGIN insert into [dbo].[Logfile] select @proc + ' - FT records imported: ' + cast(format(@recordcount,'###,###') as varchar), GETDATE () END								

				select @step = 480	
				if @LogInfo >= 1  BEGIN insert into [dbo].[Logfile] select @proc + ' - delete manual adjustments from FT data', GETDATE () END								
				delete from dbo.table_FTvsROCK_GPM_FastrackerData where isnumeric(ReferenceID) = 0


			END---IF @DataToImport <> 'ROCK	 

/*============ part IV:	preparing data for manual check steps ============================================================*/

		/*--cleanup: delete the tmp tables used for initial data import again*/
		select @step = 500
		if @LogInfo >= 1  BEGIN insert into [dbo].[Logfile] select @proc + ' - cleanup', GETDATE () END								

		select @step = 510
		IF (EXISTS (SELECT * FROM INFORMATION_SCHEMA.TABLES WHERE table_schema = 'dbo' and TABLE_NAME ='table_FTvsROCK_GPM_ROCKData_temp'))
		BEGIN
			drop table [dbo].[table_FTvsROCK_GPM_ROCKData_temp]
		END

		select @step = 520
		IF (EXISTS (SELECT * FROM INFORMATION_SCHEMA.TABLES WHERE table_schema = 'dbo' and TABLE_NAME = 'table_FTvsROCK_GPM_FastrackerData_tmp'))
		BEGIN												
			drop table [dbo].[table_FTvsROCK_GPM_FastrackerData_tmp]
		END

NoFurtherAction:
		select @step = 600
		IF @LogInfo >= 1 BEGIN INSERT INTO [dbo].[Logfile] SELECT @proc + ' - FINISHED', GETDATE () END		
		/*tell the world procedure was succesful*/
		RETURN 1	
		
END TRY

BEGIN CATCH
	EXEC [dbo].[usp_GetErrorInfo] @proc, @step
	BEGIN insert into [dbo].[Logfile] select @proc + ' - FAILED at step: ' + cast(@step as varchar), GETDATE () END
	
	/*tell the world procedure failed*/
	RETURN @step

END CATCH

GO

