
/*=================================================================================================================
	author:		mkb
	created:	2022/09
	purpose:	import the mtm_report files from ROCK and FT into the database.
						parameter @DataToImport can either be 
						"FT"		--> only data from FT file gets imported
						"ROCK"	--> only data from ROCK files get imported
						"ALL"   --> ALL data files will get imported
-----------------------------------------------------------------------------------------------------------------
Changes:
2023-04-06,		steps 120+240,	mkb/YK:		removed unneeded attributes/metrics from import process, as not used at all during the process

=================================================================================================================*/

CREATE PROCEDURE [dbo].[FTvsROCK_ImportData]
	@DataToImport varchar(10)
AS
BEGIN TRY

/*============ part I: declare variables that are needed for processing============================================================*/

		DECLARE @Current_Procedure nvarchar (40)
		DECLARE @step integer
		DECLARE @sql nvarchar (max)
		DECLARE @return_value integer

		--variables for logging
		Declare @LogEntry nvarchar(100)
		Declare @Main_Process [varchar](100)
		Declare @Calling_Application [varchar](100)
		DECLARE @Session_Key NVARCHAR(100)
		DECLARE @Warning_Counter as int 
		DECLARE @Status_Text as varchar(100)

		DECLARE @LogInfo Integer
		DECLARE @counter Integer
		
		DECLARE @file_line_counter Integer
		DECLARE @filename nvarchar (200)
		DECLARE @FileID integer
		DECLARE @FileSource nvarchar (200)
		DECLARE @importpath nvarchar (400)
			
		declare @recordcount as numeric
		declare @COB as date
		declare @COBdata as date



		
/*============ part II: collecting general information ===================================================================================*/
 
		SET @step = 1
		SET @Current_Procedure = Object_Name(@@PROCID)
		SET @Warning_Counter = 0
	
		/*--identify the COB that the mtm_check should be done for (needs to get checked against the datafiles before processing!)*/	
		select @step = 2
		select @cob = AsOfDate_MtM_Check from dbo.AsOfDate

		/*-- identify the path where the files should be imported from (and replace placeholders for date & month).*/
		/* it is the same path for rock related and ft related files, so we can look for the source instead of the pathID related to the importfile.*/

		/* running dbo.[udf_get_path] doesnn't work here as we get use the "AsOfDate_MtM_Check" field rather than "AsOfDate_EOM" */  
		select @step = 3						
		SELECT @importpath = [path] from  [dbo].[pathtofiles] where [dbo].[pathtofiles].[Source] = 'FTvsROCK'
		SELECT @importpath = replace (@importpath, '%YYYY%', format(@cob,'yyyy'))	
		SELECT @importpath = replace (@importpath, '%MM%', format(@cob,'MM'))
	
/*============ part III: data load from specified sources ===================================================================================*/
		EXEC dbo.Write_Log 'Info', 'START', @Current_Procedure, NULL, NULL, @step, 1

		SET @Status_Text = 'Import ' + @DataToImport + ' data for COB ' + cast(@COB as varchar)
		EXEC dbo.Write_Log 'Info', @Status_Text, @Current_Procedure, NULL, NULL, @step, 1

/*-- ROCK related imports*/		
		IF @DataToImport <>'FT'	/* --> parameter is "ROCK" or "ALL" */			
		BEGIN
			select @FileSource	='FTvsROCK_ROCK'

			/*-- identify how many file will be imported */
			select @counter = count(1) from [dbo].[FilestoImport] where [dbo].[FilestoImport].[Source] in (@FileSource) and ToBeImported=1
			
			--/*in case here is no importfile, create a reladed log entry and jump out*/
			IF @counter=0 
			BEGIN 
				SET @Status_Text = 'Nothing found to get imported from ROCK'
				EXEC dbo.Write_Log 'WARNING', @Status_Text, @Current_Procedure, NULL, NULL, @step, 1
				SET @Warning_Counter = @Warning_Counter +1
				GOTO NoFurtherAction 
			END		
						
			select @step = 100
			EXEC dbo.Write_Log 'Info', 'Importing ROCK data', @Current_Procedure, NULL, NULL, @step, 1

			SELECT @step=110		
			DROP TABLE IF EXISTS [dbo].[table_FTvsROCK_ROCKData_tmp] 
			
			SELECT @step=120
				/*--create a temporary table for imports that gets deleted again after the data has been imported (done at the end of this procedure).*/
			CREATE TABLE [dbo].[table_FTvsROCK_ROCKData_tmp]			
			(
				COB [nvarchar](200) NULL
				,DESK_NAME [nvarchar](200) NULL
				,TRADE_DEAL_NUMBER [nvarchar](200)  NULL
				,PORTFOLIO_NAME [nvarchar](200)  NULL
				,INSTRUMENT_TYPE_NAME [nvarchar](200) NULL
				,CASHFLOW_MONTH [nvarchar](200) NULL
				,PDC_END_DATE [nvarchar](200) NULL
				--,EXTERNAL_LEGAL_ENTITY_PARTY_NAME [nvarchar](200) NULL/*removed 2023/04 MKB/YK*/
				--,EXT_BUSINESS_UNIT_NAME [nvarchar](200) NULL					/*removed 2023/04 MKB/YK*/
				,EXTERNAL_PORTFOLIO_NAME [nvarchar](200) NULL
				--,BUSINESS_LINE_CURRENCY  [nvarchar](200) NULL					/*removed 2023/04 MKB/YK*/
				,UNREAL_DISC_PH_BL_CCY  [nvarchar](200) NULL
				,REAL_DISC_PH_BL_CCY  [nvarchar](200) NULL
				--,UNREAL_DISC_BL_CCY  [nvarchar](200) NULL							/*removed 2023/04 MKB/YK*/
				--,REAL_DISC_BL_CCY  [nvarchar](200)NULL								/*removed 2023/04 MKB/YK*/
			) ON [PRIMARY]
					 
			
			SET @Status_Text = 'Importing ' + cast(@counter as varchar) + ' file(s) from ' + @importpath 
			EXEC dbo.Write_Log 'Info', @Status_Text, @Current_Procedure, NULL, NULL, @step, 1


			/*loop over counter, reduce it at then end*/ 	
			WHILE @counter >0
				BEGIN			
				SELECT @step=200
					/*in case it's not the first round we come through here:*/
					truncate table [dbo].[table_FTvsROCK_ROCKData_tmp]
					
					SELECT @step=210
					/*identify the name of the file to be loaded */					
					select  
							@filename = [FileName]
						,@FileID   = [ID]
					from 
						(select *, ROW_NUMBER() OVER(ORDER BY ID DESC) AS ROW 
							from [dbo].[FilestoImport] 
							where [dbo].[FilestoImport].[Source] in ('FTvsROCK_ROCK') and ToBeImported=1
						) as TMP 
					where 
						ROW = @counter
					
					SELECT @step=220
					SELECT @sql = N'BULK INSERT [dbo].[table_FTvsROCK_ROCKData_tmp] FROM '  + '''' + @importpath + @filename + ''''  + ' WITH (CODEPAGE = 1252, FIELDTERMINATOR =''~'', FIRSTROW = 2, ROWTERMINATOR =''0x0a'')';
					EXECUTE sp_executesql @sql
			
					SELECT @step=230
					/*delete old entries in ROCK data table */
					delete from [dbo].[table_FTvsROCK_ROCKData] where fileID=@FileID
					
					SELECT @step=240
					INSERT INTO [dbo].[table_FTvsROCK_ROCKData]
									(
								COB,
								DeskName,
								TradeDealNumber,
								InternalPortfolio,
								InstrumentType,
								CashflowDeliveryMonth,
								LegEndDate,
								--ExternalLegalEntity,  /*removed 2023/04 MKB/YK*/
								--ExternalBU,						/*removed 2023/04 MKB/YK*/
								ExternalPortfolio,
								UnrealisedDiscounted,
								RealisedDiscounted,
								FileID
							)
							SELECT
								convert(date,COB,103) COB								
							 ,DESK_NAME
							 ,TRADE_DEAL_NUMBER
							 ,PORTFOLIO_NAME
							 ,INSTRUMENT_TYPE_NAME
							 ,convert(date, CASHFLOW_MONTH ,103) CASHFLOW_MONTH 
							 ,convert(date, PDC_END_DATE,103) PDC_END_DATE
							 --,EXTERNAL_LEGAL_ENTITY_PARTY_NAME								/*removed 2023/04 MKB/YK*/
							 --,EXT_BUSINESS_UNIT_NAME													/*removed 2023/04 MKB/YK*/
 						 	 ,EXTERNAL_PORTFOLIO_NAME
							 ,try_convert(float, UNREAL_DISC_PH_BL_CCY)
							 --,try_convert(float, REAL_DISC_PH_BL_CCY)
							 ,try_convert(float, REPLACE(REPLACE(REAL_DISC_PH_BL_CCY, CHAR(13), ''), CHAR(10), '')) as REAL_DISC_PH_BL_CCY1
							 ,@FileID
						FROM 
								dbo.table_FTvsROCK_ROCKData_tmp

						SELECT @step=250
						select @recordcount =count(*) from dbo.table_FTvsROCK_ROCKData_tmp						
						
						SET @Status_Text = 'Import #' + cast(@counter as varchar) + ': ' + @filename + ' - records: '+ cast(format(@recordcount,'###,###') as varchar)
						EXEC dbo.Write_Log 'Info', @Status_Text, @Current_Procedure, NULL, NULL, @step, 1

						
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
				select @recordcount = count(*) from [dbo].[table_FTvsROCK_ROCKData]

				SET @Status_Text = 'ROCK records imported: ' + cast(format(@recordcount,'###,###') as varchar)
				EXEC dbo.Write_Log 'Info', @Status_Text, @Current_Procedure, NULL, NULL, @step, 1
												
		END ---IF @DataToImport <> 'FT'
/*****************************************************************************************************************************************************************************/	 


/*--import FasTracker data:*/
		IF @DataToImport <> 'ROCK' /* means parameter is "FT" or "ALL" */
		BEGIN 
			select @step = 300
			
			/*-- identify how many file will be imported */
			select @counter = count(1) from [dbo].[FilestoImport] where [dbo].[FilestoImport].[Source] in ('FTvsROCK_FT') 
					--/*in case here is no importfile, create a reladed log entry and jump out*/
			IF @counter=0 
			BEGIN 
				EXEC dbo.Write_Log 'WARNING', 'Nothing found to get imported from FT.', @Current_Procedure, NULL, NULL, @step, 1
				SET @Warning_Counter = @Warning_Counter+1
				GOTO NoFurtherAction 
			END		
						
			select @step = 310
			SET @Status_Text = 'Importing ' + cast(@counter as varchar) + ' file(s) from ' + @importpath
			EXEC dbo.Write_Log 'Info', @Status_Text, @Current_Procedure, NULL, NULL, @step, 1

			DROP TABLE IF EXISTS [dbo].[table_FTvsROCK_FT_Data_tmp]
			
			select @step = 320
			--create a temporary table for imports that gets deleted again after the data has been imported.
			CREATE table [dbo].[table_FTvsROCK_FT_Data_tmp]
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
				[ProjectionIndexGroup] [nvarchar](100) NULL,
				[InstrumentType] [nvarchar](100) NULL,
				[Product] [nvarchar](100) NULL,
				[DiscountedPNL] [nvarchar](100) NULL,
				[UndiscountedPNL] [nvarchar](100) NULL
			) ON [PRIMARY]
		
			select @step = 330
			/*--delete old entries in FT data table */
			truncate table [dbo].[table_FTvsROCK_FastrackerData]
				
				
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
								where [dbo].[FilestoImport].[Source] in ('FTvsROCK_FT')
							) as TMP 
						where 
							ROW = @counter
					
					select @step = 420		
					truncate table [dbo].[table_FTvsROCK_FT_Data_tmp]
						
					select @step = 430
					/* import the data from the identified file & path. */
					BEGIN	 
						select @sql = N'BULK INSERT [dbo].[table_FTvsROCK_FT_Data_tmp]  FROM '  + '''' + @importpath + @filename + ''''  + ' WITH (CODEPAGE = 1252, FIELDTERMINATOR ='','', FIRSTROW = 2, ROWTERMINATOR =''\n'')';
						execute sp_executesql @sql 
					END

					select @step = 440		
					/* fill from tmp table into final table including needed conversions. */
					BEGIN
						insert into [dbo].[table_FTvsROCK_FastrackerData]
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
								,[ProjectionIndexGroup]
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
								,ProjectionIndexGroup
								,[InstrumentType]
								,[Product]
								,convert(float,[DiscountedPNL])
								,convert(float,[UndiscountedPNL]) 
								,@FileID
							from 
								[dbo].[table_FTvsROCK_FT_Data_tmp]
							where 
								Strategy not In ('CAO Power','Sales & Origination') 
								OR Strategy Is Null
								---or InternalPortfolio in ('RWEST_ERCOT_HEDGE_CERT','RWEST_PJM_HEDGE_CERT') 
								
					END								
						
					select @step = 450		
					/*document import timestamp fpor just imported file*/
					update dbo.FilestoImport set LastImport = getdate() where id = @FileID
					
					SET @step = 460		
					SELECT @recordcount = count(*) from [dbo].[table_FTvsROCK_FT_Data_tmp]
					
					SET @Status_Text = 'Import #' + cast(@counter as varchar) + ': ' + @filename + ' - records: '+ cast(format(@recordcount,'###,###') as varchar)
					EXEC dbo.Write_Log 'Info', @Status_Text, @Current_Procedure, NULL, NULL, @step, 1

					/* decrease counter for the next file to be processed*/
					select @counter = @counter - 1
	
				END while @counter > 0	

				select @step = 470	
				/* count total number of imported records*/
				select @recordcount = count(*) from [dbo].[table_FTvsROCK_FastrackerData]				
				
				SET @Status_Text = 'FT records imported: ' + cast(format(@recordcount,'###,###') as varchar)
				EXEC dbo.Write_Log 'Info', @Status_Text, @Current_Procedure, NULL, NULL, @step, 1


				SET @step = 480	
				SET @Status_Text = 'Delete manual adjustments from FT data'
				EXEC dbo.Write_Log 'Info', @Status_Text, @Current_Procedure, NULL, NULL, @step, 1
				delete from dbo.table_FTvsROCK_FastrackerData where isnumeric(ReferenceID) = 0


			END /* ... of "IF @DataToImport <> 'ROCK' " */

/*============ part IV:	preparing data for manual check steps ============================================================*/

			/*cleanup: delete the tmp tables used for initial data import again*/
			select @step = 500
			EXEC dbo.Write_Log 'Info', 'Cleanup (remove tmp tables)', @Current_Procedure, NULL, NULL, @step, 1

			DROP TABLE IF EXISTS [dbo].[table_FTvsROCK_ROCK_Data_temp]
			DROP TABLE IF EXISTS [dbo].[table_FTvsROCK_FastrackerData_tmp]

NoFurtherAction:
			/*NoFurtherAction, so tell the world we're done, but inform about potential warnings.*/
			SELECT @step = 520
			SET @Status_Text = 'FINISHED'
			IF @Warning_Counter = 0
				BEGIN
						EXEC dbo.Write_Log 'Info', @Status_Text, @Current_Procedure, NULL, NULL, @step, 1 
				END
			ELSE
				BEGIN
					SET @Status_Text = @Status_Text + ' WITH ' + cast(@Warning_Counter as varchar) +  ' WARNINGS - check log for details!'
					EXEC dbo.Write_Log 'WARNING', @Status_Text, @Current_Procedure, NULL, NULL, @step, 1 
				END
			Return 0
END TRY

BEGIN CATCH
	/*tell the world procedure failed*/
	EXEC [dbo].[usp_GetErrorInfo] @Current_Procedure, @step, NULL; 
	EXEC dbo.Write_Log 'FAILED', 'FAILED with error, check log for details', @Current_Procedure, NULL, NULL, @step, 1;
	Return @Step
END CATCH

GO

