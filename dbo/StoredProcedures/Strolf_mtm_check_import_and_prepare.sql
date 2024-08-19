









/*
=======================================================================================================
Author:      MKB 
Created:     2021-01
Name:			   [dbo].[procedure_Strolf_mtm_check_import_and_prepare] 

Purpose:	   1) imports the data from fastracker report "x_test_volkhardt.... 
					   2) enriches data with other data from STROLF and various mappinmg tables to enable 
					      the user to query the data in an efficient way for creating the recon for CAO Power.
								("recon_diff" and "recon_fx")             

Parameter:   "COB_date", optional. It represents the COB the data gets loaded for. 
             if not specified, the parameter gets filled with value from [dbo].[AsOfDate].[AsOfDate_EOM] (default)

Updates (when--who: what):
2021-03-03--mkb: 'LTT_DE_NONP_CO2_OTHER' added to conditions to be mapped as "NE" in field "Accounting"
2021-06-02--mkb: added field "COB" to table "table_strolf_mtm_check_ReconFX" and limited records to current as of
2021-09-06--mkb: added combination of counterparty_group IN ('External'), internal_portfolio IN ('RES_DE') and Instrument_Type IN ('REN-FWD-P', 'PWR-FWD-PPA-P') to be mapped as 'NE'
2021-12-14--VP:  added instype PWR-OPT-CDS-CALL-GEN-D-P to NE rule
2022-05-03--mkb: excluded internal portfolio "RES_BE" from all queries as it belongs to CS and not to CAO power
2022-10-05--mkb: splitted query to fill test-data into three stand alone queries as union-all-approach caused conversion errors
2023-01-06--VP, mkb: added new condition in step 8 (commented accordingly)
2023-01-20--VP, mkb: added new condition in step 8 (commented accordingly)
2023-05-04--VP, mkb: added new condition in step 8 (commented accordingly)
2023-06-07--VP, mkb: added new instype  in step 8 (commented accordingly)
2024-02-15--MK: added new condition in step 8 requested by VP (commented accordingly)

=======================================================================================================
*/

	CREATE PROCEDURE [dbo].[Strolf_mtm_check_import_and_prepare] 
		@COB_date as date = NULL
	AS
		BEGIN TRY
	
	-- define some variables that been needed
	---		DECLARE @COB_date as date 
			DECLARE @LogInfo Integer
			DECLARE @proc nvarchar(40)
			DECLARE @step Integer
			
			DECLARE @FileName nvarchar (50) 
			DECLARE @PathName nvarchar (300)
			DECLARE @sql nvarchar (max)
			DECLARE @COB_date_prev_EOM as date 
			DECLARE @COB as date 

			select @proc = Object_Name(@@PROCID)
	
			select @step = 1
			select @LogInfo = [dbo].[LogInfo].[LogInfo] from [dbo].[LogInfo]

			IF @LogInfo >= 1  BEGIN insert into [dbo].[Logfile] select 'STROLF MtM Check - START', GETDATE () END

			/*check if COB-date parameter is filled, if not set it to current asofdate_eom.*/
			select @step = 2
			---IF @COB_date is null BEGIN SELECT @COB_date= cast([asofdate_eom] as date) from [dbo].[asofdate] END
			
			SELECT @COB = cast(asofdate_eom as date) from dbo.asofdate 

			/*identiy COB of previous eom (as we need to keep this data for a later comparison query).*/
			BEGIN SELECT @COB_date_prev_EOM = cast([AsOfDate_prevEOM] as date) from [dbo].[asofdate] END


			--/*identify to be imported file and import it*/
			select @step = 3
			select @PathName = [dbo].[udf_get_path] ('strolf_mtm_check')
			
			select @step = 4
			select @FileName = [FileName] from [dbo].[FilesToImport] where [source] = 'strolf_mtm_check' and ToBeImported = 1

			--/*truncating temp_table*/
			select @step = 5
			truncate table [dbo].[temp_table_strolf_mtm_check_FT_rawdata]
	
			--/*now the import itself*/
			select @step = 6
			IF @LogInfo >= 1  BEGIN insert into [dbo].[Logfile] select 'STROLF MtM Check - importing ' + @Pathname + @Filename , GETDATE () END
			select @sql = 'BULK INSERT [dbo].[temp_table_strolf_mtm_check_FT_rawdata] FROM '  + '''' + @Pathname + @Filename + ''''  + ' WITH (FIELDTERMINATOR ='','', FIRSTROW = 2, ROWTERMINATOR =''\n'')';
			execute sp_executesql @sql

					 
			--/*deleting any data from table which is not from COB_prev_EOM*/ 	
			select @step = 7
			delete from [dbo].[table_strolf_mtm_check_01_FT_data] where COB <> @COB_date_prev_EOM

			--/*prepare the just imported data and enrich it with information form dbo.map_sbm */
			select @step = 8
			IF @LogInfo >= 1  BEGIN insert into [dbo].[Logfile] select 'STROLF MtM Check - select data from temp table into data table', GETDATE () END
						
			INSERT INTO [dbo].[table_strolf_mtm_check_01_FT_data]
									 ([COB]
									 ,[Subsidiary]
									 ,[Bereich]
									 ,[Strategy]
									 ,[DealID]
									 ,[TradeDate]
									 ,[TermStart]
									 ,[TermEnd]
									 ,[InternalPortfolio]
									 ,[CounterpartyExternalBusinessUnit]
									 ,[CounterpartyGroup]
									 ,[Volume]
									 ,[BuySellHeader]
									 ,[CurveName]
									 ,[ProjectionIndexGroup]
									 ,[InstrumentType]
									 ,[InternalLegalEntity]
									 ,[InternalBusinessUnit]
									 ,[ExternalLegalEntity]
									 ,[ExternalPortfolio]
									 ,[Product]
									 ,[AccountingTreatment]
									 ,[MtM]
									 ,[UndiscountedMTM]
									 ,[Accounting]
									 ,[JahrVonTermEnd]
									 )
					SELECT convert (date, dbo.temp_table_strolf_mtm_check_FT_rawdata.cob,103) 
						,temp_table_strolf_mtm_check_FT_rawdata.Subsidiary
						,dbo.map_order.SubDesk 
						,dbo.map_order.Book 
						,temp_table_strolf_mtm_check_FT_rawdata.Reference_ID
						,convert(date, temp_table_strolf_mtm_check_FT_rawdata.Trade_Date,103) 
						,convert(date, temp_table_strolf_mtm_check_FT_rawdata.Term_Start,103) 
						,convert(date, temp_table_strolf_mtm_check_FT_rawdata.Term_End,103) 
						,temp_table_strolf_mtm_check_FT_rawdata.Internal_Portfolio
						,temp_table_strolf_mtm_check_FT_rawdata.Counterparty_Ext_Bunit
						,temp_table_strolf_mtm_check_FT_rawdata.Counterparty_Group
						,isnull([temp_table_strolf_mtm_check_FT_rawdata].[Volume],0)  
						,temp_table_strolf_mtm_check_FT_rawdata.header_Buy_Sell
						,temp_table_strolf_mtm_check_FT_rawdata.Curve_Name
						,temp_table_strolf_mtm_check_FT_rawdata.Projection_Index_Group
						,temp_table_strolf_mtm_check_FT_rawdata.Instrument_Type
						,temp_table_strolf_mtm_check_FT_rawdata.Int_Legal_Entity
						,temp_table_strolf_mtm_check_FT_rawdata.Int_Bunit
						,temp_table_strolf_mtm_check_FT_rawdata.Ext_Legal_Entity
						,temp_table_strolf_mtm_check_FT_rawdata.Ext_Portfolio
						,temp_table_strolf_mtm_check_FT_rawdata.Product
						,temp_table_strolf_mtm_check_FT_rawdata.Accounting_Treatment
						,IsNull([Discounted_PNL],0) AS mtm
						,IsNull([Undiscounted_PNL],0) AS undiscounted_mtm
						,CASE 
							WHEN temp_table_strolf_mtm_check_FT_rawdata.accounting_treatment = 'Hedging Instrument (Der)'
								THEN CASE 
										WHEN convert(DATE, temp_table_strolf_mtm_check_FT_rawdata.Term_End, 103) = eomonth(DATEADD(MONTH, 1, convert(DATE, dbo.temp_table_strolf_mtm_check_FT_rawdata.cob, 103)))
											AND temp_table_strolf_mtm_check_FT_rawdata.Projection_Index_Group = 'FX'
											AND temp_table_strolf_mtm_check_FT_rawdata.internal_portfolio NOT IN ('JBB_NL_TRANSFER')
											THEN 'PNL'
										WHEN Left([unrealizedearnings], 2) = 'I2'
											THEN 'AOCI'
										WHEN temp_table_strolf_mtm_check_FT_rawdata.internal_portfolio IN (
												'JCT_CE_STOCK_HEDGE'
												,'JCT_DE_STOCK_HEDGE'
												,'LTT_DE_CARBON_BOOK'
												)
											THEN 'PNL'
										WHEN (
												temp_table_strolf_mtm_check_FT_rawdata.Projection_Index_Group IN (
													'Natural Gas'
													,'Coal'
													,'Swap'
													,'FX'
													)
												OR temp_table_strolf_mtm_check_FT_rawdata.internal_portfolio LIKE 'RES_%'
												OR temp_table_strolf_mtm_check_FT_rawdata.internal_portfolio LIKE 'RWER_%'
												OR temp_table_strolf_mtm_check_FT_rawdata.internal_portfolio IN (
													'RWEP_LT_PURCHASE'
													,'RWEST_ERCOT_HEDGE_CERT'
													,'RWEST_PJM_HEDGE_CERT'
													,'RWEG_WIND_UPS'
													,'RWEG_WIND'
													,'LTT_FR'
													,'LTT_IT'
													,'LTT_DE_NONP_GC'
													,'RWEG_LAUFWASSER'
													,'RWER_DE_OFFSHORE'
													)
												OR temp_table_strolf_mtm_check_FT_rawdata.counterparty_group IN (
													'Intradesk_MtM'
													,'Intradesk_MtM_new'
													,'Interdesk_MtM'
													,'External_NE'
													,'External_new'
													,'InterPE_new'
													,'Interdesk_new'
													)
												)
											THEN 'NE'
										ELSE 'PNL'
										END
							ELSE 'out of scope'
							END AS Accounting
						,Year(convert(date, temp_table_strolf_mtm_check_FT_rawdata.Term_End,103)) 
					FROM (
						dbo.temp_table_strolf_mtm_check_FT_rawdata left JOIN dbo.map_SBM
							ON (temp_table_strolf_mtm_check_FT_rawdata.Projection_Index_Group = dbo.map_SBM.ProjectionIndexGroup)
								AND (temp_table_strolf_mtm_check_FT_rawdata.Instrument_Type = dbo.map_SBM.InstrumentType)
								AND (temp_table_strolf_mtm_check_FT_rawdata.Counterparty_Group = dbo.map_SBM.CounterpartyGroup)
								AND (temp_table_strolf_mtm_check_FT_rawdata.Internal_Portfolio = dbo.map_SBM.InternalPortfolio)
						)
					left JOIN dbo.map_order
						ON temp_table_strolf_mtm_check_FT_rawdata.Internal_Portfolio = dbo.map_order.Portfolio
				WHERE 
					temp_table_strolf_mtm_check_FT_rawdata.internal_portfolio not IN ('RES_BE')/*excluded 2022-05-03*/

			IF @LogInfo >= 1  BEGIN insert into [dbo].[Logfile] select 'STROLF MtM Check - Recon FX', GETDATE () END

			--/*truncate and refill table for recon FX*/
			truncate table dbo.table_strolf_mtm_check_ReconFX
						
			INSERT INTO [dbo].[table_strolf_mtm_check_ReconFX] (
				[Desk]
				,[InternalPortfolio]
				,[InstrumentType]
				,[Dealid]
				,[EventDate]
				,[Finance]
				,[Risk]
				,[MTM_Diff]
				,[COB]
				)
			SELECT sql.IntDesk AS Desk
				,sql.InternalPortfolio AS InternalPortfolio
				,sql.InstrumentType AS InstrumentType
				,sql.DealID
				,cast(sql.EventDate AS DATE) AS EventDate
				,sql.Finance AS Finance
				,sql.Risk AS Risk
				,[Finance] - [Risk] AS MTM_Diff
				,@COB
			FROM 
			(
				SELECT dbo.[02_Realised_all_details].IntDesk
					,dbo.[02_Realised_all_details].InternalPortfolio
					,dbo.[02_Realised_all_details].InstrumentType
					,dbo.[02_Realised_all_details].Deal AS dealid
					,convert(DATE, [02_Realised_all_details].EventDate, 104) AS eventdate
					,[Realised] / [raterisk] AS Finance
					,0 AS Risk
				FROM dbo.[02_Realised_all_details]
				INNER JOIN dbo.FXRates
					ON dbo.[02_Realised_all_details].Currency = dbo.FXRates.Currency
				WHERE dbo.[02_Realised_all_details].IntDesk = 'cao power'
					AND dbo.[02_Realised_all_details].InstrumentType LIKE '%fx%'	
					AND dbo.[02_Realised_all_details].InternalPortfolio not IN ('RES_BE')/*excluded 2022-05-03*/

			UNION ALL	
				
				SELECT dbo.table_strolf_mtm_check_01_FT_data.strategy AS IntDesk
					,dbo.table_strolf_mtm_check_01_FT_data.InternalPortfolio
					,dbo.table_strolf_mtm_check_01_FT_data.InstrumentType
					,dbo.table_strolf_mtm_check_01_FT_data.DealID
					,convert(DATE, dbo.table_strolf_mtm_check_01_FT_data.TermEnd, 104) AS EventDate
					,dbo.table_strolf_mtm_check_01_FT_data.mtm AS Finance
					,0 AS Risk
				FROM dbo.table_strolf_mtm_check_01_FT_data
				WHERE dbo.table_strolf_mtm_check_01_FT_data.InstrumentType LIKE '%fx%'
							AND dbo.table_strolf_mtm_check_01_FT_data.COB = @COB
							and dbo.table_strolf_mtm_check_01_FT_data.InternalPortfolio not IN ('RES_BE')/*excluded 2022-05-03*/
				
				UNION ALL
	
				SELECT 
					DESK AS IntDesk
					,portfolio_name AS InternalPortfolio
					,INS_TYPE_NAME AS InstrumentType
					,deal_num AS dealid
					,convert(DATE, end_date, 104) AS EventDate
					,0 AS Finance
					,pnl AS Risk				
				FROM 
					dbo.Strolf_MOP_PLUS_REAL_CORR_EOM					
				WHERE 
					INS_TYPE_NAME LIKE '%fx%'
				AND COB = @COB
				and PORTFOLIO_NAME not IN ('RES_BE')/*excluded 2022-05-03*/
			) AS [sql]

			
			select @step = 9
			BEGIN truncate table [dbo].[table_strolf_mtm_check_02_recon_raw] END
	
			select @step = 10
			IF @LogInfo >= 1  BEGIN insert into [dbo].[Logfile] select 'STROLF MtM Check - preparing recon diff', GETDATE () END

			--/*prepare calculation of recon_diff by selecting and joining the data from STROLF for CAO Power, 
			--/*Industrial Sales and FASTracker into one table*/
			--/*consists of three query parts (joined by UNION ALL), one for CAO POWER data, one for CS data, one for FASTRACKER data */
			
			
			
			INSERT INTO dbo.table_strolf_mtm_check_02_recon_raw 
			( DealID
				,SubDesk
				,Book
				,InternalPortfolio
				,InstrumentType
				,CounterpartyExternalBusinessUnit
				,ExternalPortfolio
				,TermEnd	
				,Product
				,RiskMTM
				,RiskRealised
				,FT
				,Kaskade
				,DiffMtM)
			SELECT 
				DEALID
				,SubDesk
				,Book
				,InternalPortfolio
				,InstrumentType
				,Max(CounterpartyExternalBusinessUnit) AS CounterpartyExternalBusinessUnit
				,Max(ExternalPortfolio) AS ExternalPortfolio
				,TermEnd
				,Product
				,Round(Sum(Risk_MtM),2) AS Risk
				,Round(Sum(Risk_realised),2) AS Risk_realised
				,Round(Sum(FT),2) AS FT
				,Round(Sum(Kaskade),2) AS Kaskade
				,Round(Sum(Risk_MtM - FT - Kaskade), 2) AS DiffMtM
			FROM
			--/*recon_zw2_finance*/
			(Select  DealID
				,InternalPortfolio
				,InstrumentType
				,CounterpartyExternalBusinessUnit
				,ExternalPortfolio
				,Format([termend],'yyyy/MM') AS TermEnd	
				,Product
				,0 AS Risk_MTM
				,0 AS Risk_Realised
				,mtm AS FT
				,0 AS Kaskade  
			FROM 
				dbo.table_strolf_mtm_check_01_FT_data
			WHERE
				dbo.table_strolf_mtm_check_01_FT_data.InternalPortfolio NOT LIKE '%_RHP_%'
				AND dbo.table_strolf_mtm_check_01_FT_data.InternalPortfolio NOT IN ('CAO_CE_LTT_POWER_RWEI','RES_BE') /* "RES_BE" excluded 2022-05-03*/
				and COB = @COB

			UNION ALL
			--/*Recon_zw1_Risk_IS*/
			SELECT 
					DEAL_NUm AS DealID
				,PORTFOLIO_NAME AS InternalPortfolio
				,INS_TYPE_NAME as InstrumentType
				,EXT_BUNIT_NAME AS CounterpartyExternalBusinessUnit
				,EXTERNAL_PORTFOLIO_NAME as ExternalPortfolio
				,Format([realisation_date],'yyyy/MM') AS TermEnd	
				,'' AS Product
				,CASE 
					WHEN [pnl_type] = 'UNREALIZED'
					THEN [PNL]
					ELSE 0
					END AS Risk_MtM
				,CASE 
					WHEN [pnl_type] <> 'UNREALIZED'
					THEN [PNL]
					ELSE 0
					END AS Risk_realised
				,0 AS Finance_MtM
				,0 AS Finance_Kaskade
			FROM 
					dbo.Strolf_IS_EUR_EOM
			WHERE 
				PORTFOLIO_NAME LIKE '%PWR_BNL_OLD'
				AND realisation_date > @COB

			UNION ALL

			--/*103_Recon_zw1_Risk*/
			SELECT 
					DEAL_NUm AS DealID
				,PORTFOLIO_NAME AS InternalPortfolio
				,INS_TYPE_NAME as InstrumentType
				,EXT_BUNIT_NAME AS CounterpartyExternalBusinessUnit
				,EXTERNAL_PORTFOLIO_NAME as ExternalPortfolio
				,Format(REALISATION_DATE_original,'yyyy/MM') AS TermEnd	
				,'' AS Product
				,CASE 
					WHEN [pnl_type] = 'UNREALIZED'
					THEN [PNL]
					ELSE 0
					END AS Risk_MtM
				,CASE 
					WHEN [pnl_type] <> 'UNREALIZED'
					THEN [PNL]
					ELSE 0
					END AS Risk_realised
					,0 AS Finance_MtM
				,0 AS Finance_Kaskade
			FROM dbo.Strolf_MOP_PLUS_REAL_CORR_EOM
			WHERE 
				(
					PORTFOLIO_NAME NOT LIKE 'RHP'
					AND PORTFOLIO_NAME NOT LIKE 'BMT%'
					AND PORTFOLIO_NAME NOT IN ('CAO_CE_LTT_POWER_RWEI', 'STT_DE_ROM', 'STT_NL_ROM','RES_BE') /* "RES_BE" excluded 2022-05-03*/
					AND dateadd(day,-10,EOMONTH([REALISATION_DATE_Original]))> @COB
				)
				OR INS_TYPE_NAME = 'em-inv-p'
				OR INS_TYPE_NAME = 'ren-inv-p'				
			) as [Recon_zw3_union]
				LEFT JOIN dbo.map_order
				ON [Recon_zw3_union].InternalPortfolio = dbo.map_order.Portfolio
				GROUP BY 
					SubDesk
					,Book
					,DealID
					,InternalPortfolio
					,InstrumentType
					,TermEnd
					,Product;
					 
			IF @LogInfo >= 1  BEGIN insert into [dbo].[Logfile] select 'STROLF MtM Check - FINISHED', GETDATE () END

			
/*==================================================================================================================================================*/
/*==================================================================================================================================================*/
/*==================================================================================================================================================*/
			/*2022-07 VP,mkb: TESTING QUERIES FÜR MODIFIED PNL_TYPE bei IRS; INFOS */
			
			/*truncate and refill table for recon FX*/
			select @step = 100			
			IF @LogInfo >= 1  BEGIN insert into [dbo].[Logfile] select 'STROLF MtM Check - preparing testdata for recon diff', GETDATE () END
				
				select @step = 101
				--truncate table dbo.table_strolf_mtm_check_ReconFX_TEST
				delete from dbo.table_strolf_mtm_check_ReconFX_TEST
				
				select @step = 102
				IF @LogInfo >= 1  BEGIN insert into [dbo].[Logfile] select 'STROLF MtM Check - load test data I/III', GETDATE () END
				INSERT INTO [dbo].[table_strolf_mtm_check_ReconFX_TEST] (
				 [Desk]
				,[InternalPortfolio]
				,[InstrumentType]
				,[Dealid]
				,[EventDate]
				,[Finance]
				,[Risk]
				,[MTM_Diff]
				,[COB]
				)
				SELECT dbo.[02_Realised_all_details].IntDesk 
				  ,dbo.[02_Realised_all_details].InternalPortfolio
					,dbo.[02_Realised_all_details].InstrumentType
					,dbo.[02_Realised_all_details].Deal AS DealID
					,convert(DATE, [02_Realised_all_details].EventDate, 104) AS EventDate
					,Realised/raterisk AS Finance
					,cast(0 as numeric) AS Risk
					,-(Realised/raterisk) AS MTM_Diff
					,@COB as COB
				FROM 
					dbo.[02_Realised_all_details] INNER JOIN 
					dbo.FXRates
					ON dbo.[02_Realised_all_details].Currency = dbo.FXRates.Currency
				WHERE dbo.[02_Realised_all_details].IntDesk = 'cao power'
					AND dbo.[02_Realised_all_details].InstrumentType LIKE '%fx%'	
					AND dbo.[02_Realised_all_details].InternalPortfolio not IN ('RES_BE')/*excluded 2022-05-03*/

				select @step = 103
				IF @LogInfo >= 1  BEGIN insert into [dbo].[Logfile] select 'STROLF MtM Check - load test data 2/3', GETDATE () END
				INSERT INTO [dbo].[table_strolf_mtm_check_ReconFX_TEST] (
				 [Desk]
				,[InternalPortfolio]
				,[InstrumentType]
				,[Dealid]
				,[EventDate]
				,[Finance]
				,[Risk]
				,[MTM_Diff]
				,[COB]
				)				
				SELECT dbo.table_strolf_mtm_check_01_FT_data.strategy AS IntDesk
					,dbo.table_strolf_mtm_check_01_FT_data.InternalPortfolio
					,dbo.table_strolf_mtm_check_01_FT_data.InstrumentType
					,dbo.table_strolf_mtm_check_01_FT_data.DealID
					,convert(DATE, dbo.table_strolf_mtm_check_01_FT_data.TermEnd, 104) AS EventDate
					,dbo.table_strolf_mtm_check_01_FT_data.mtm AS Finance
					,0 AS Risk
					,dbo.table_strolf_mtm_check_01_FT_data.mtm  as MTM_DIFF
					,@COB as COB
				FROM 
					dbo.table_strolf_mtm_check_01_FT_data
				WHERE 
					dbo.table_strolf_mtm_check_01_FT_data.InstrumentType LIKE '%fx%'
					AND dbo.table_strolf_mtm_check_01_FT_data.COB = @COB
					and dbo.table_strolf_mtm_check_01_FT_data.InternalPortfolio not IN ('RES_BE')/*excluded 2022-05-03*/
				
				select @step = 104
				IF @LogInfo >= 1  BEGIN insert into [dbo].[Logfile] select 'STROLF MtM Check - load test data 3/3', GETDATE () END
				INSERT INTO [dbo].[table_strolf_mtm_check_ReconFX_TEST] (
				 [Desk]
				,[InternalPortfolio]
				,[InstrumentType]
				,[Dealid]
				,[EventDate]
				,[Finance]
				,[Risk]
				,[MTM_Diff]
				,[COB]
				)
				SELECT 
					DESK AS IntDesk
					,portfolio_name AS InternalPortfolio
					,INS_TYPE_NAME AS InstrumentType
					,deal_num AS dealid
					,convert(DATE, end_date, 104) AS EventDate
					,0 AS Finance
					,pnl  AS Risk				
					,-pnl  AS Risk	
					,@COB as COB
				FROM 
					dbo.FIN_MOP_PLUS_REAL_CORR_mit_PNL_TYPE_ORIG_SUMMIERT
				WHERE 
					INS_TYPE_NAME LIKE '%fx%'
				AND COB = @COB
				and PORTFOLIO_NAME not IN ('RES_BE')/*excluded 2022-05-03*/
			


			select @step = 105
			--- truncate table [dbo].table_strolf_mtm_check_02_recon_raw_TEST 
			 delete from [dbo].table_strolf_mtm_check_02_recon_raw_TEST 
	
			select @step = 106
			IF @LogInfo >= 1  BEGIN insert into [dbo].[Logfile] select 'STROLF MtM Check - preparing recon diff', GETDATE () END

			--/*prepare calculation of recon_diff by selecting and joining the data from STROLF for CAO Power, 
			--/*Industrial Sales and FASTracker into one table*/
			--/*consists of three query parts (joined by UNION ALL), one for CAO POWER data, one for CS data, one for FASTRACKER data */
			INSERT INTO dbo.table_strolf_mtm_check_02_recon_raw_TEST
			( DealID
				,SubDesk
				,Book
				,InternalPortfolio
				,InstrumentType
				,CounterpartyExternalBusinessUnit
				,ExternalPortfolio
				,TermEnd	
				,Product
				,RiskMTM
				,RiskRealised
				,FT
				,Kaskade
				,DiffMtM)
			SELECT 
				DEALID
				,SubDesk
				,Book
				,InternalPortfolio
				,InstrumentType
				,Max(CounterpartyExternalBusinessUnit) AS CounterpartyExternalBusinessUnit
				,Max(ExternalPortfolio) AS ExternalPortfolio
				,TermEnd
				,Product
				,Round(Sum(Risk_MtM),2) AS RiskMTM
				,Round(Sum(Risk_realised),2) AS RiskRealised
				,Round(Sum(FT),2) AS FT
				,Round(Sum(Kaskade),2) AS Kaskade
				,Round(Sum(Risk_MtM - FT - Kaskade), 2) AS DiffMtM
			FROM
			--/*recon_zw2_finance*/
			(Select  
			cast(DealID as varchar)  as DealID 			
				,InternalPortfolio
				,InstrumentType
				,CounterpartyExternalBusinessUnit
				,ExternalPortfolio
				,Format([termend],'yyyy/MM') AS TermEnd	
				,Product
				,0 AS Risk_MTM
				,0 AS Risk_Realised
				,mtm AS FT
				,0 AS Kaskade  
			FROM 
				dbo.table_strolf_mtm_check_01_FT_data
			WHERE
				dbo.table_strolf_mtm_check_01_FT_data.InternalPortfolio NOT LIKE '%_RHP_%'
				AND dbo.table_strolf_mtm_check_01_FT_data.InternalPortfolio NOT IN ('CAO_CE_LTT_POWER_RWEI','RES_BE') /* "RES_BE" excluded 2022-05-03*/
				and COB = @COB

			UNION ALL
			--/*Recon_zw1_Risk_IS*/
			SELECT 
				cast(DEAL_NUm as varchar)  as DealID 
				,PORTFOLIO_NAME AS InternalPortfolio
				,INS_TYPE_NAME as InstrumentType
				,EXT_BUNIT_NAME AS CounterpartyExternalBusinessUnit
				,EXTERNAL_PORTFOLIO_NAME as ExternalPortfolio
				,Format([realisation_date],'yyyy/MM') AS TermEnd	
				,'' AS Product
				,CASE 
					WHEN [pnl_type] = 'UNREALIZED'
					THEN [PNL]
					ELSE 0
					END AS Risk_MtM
				,CASE 
					WHEN [pnl_type] <> 'UNREALIZED'
					THEN [PNL]
					ELSE 0
					END AS Risk_realised
				,0 AS Finance_MtM
				,0 AS Finance_Kaskade
			FROM 
					dbo.Strolf_IS_EUR_EOM
			WHERE 
				PORTFOLIO_NAME LIKE '%PWR_BNL_OLD'
				AND realisation_date > @COB

			UNION ALL

			--/*103_Recon_zw1_Risk*/
			SELECT 
				cast(DEAL_NUm as varchar)  as DealID 
				,PORTFOLIO_NAME AS InternalPortfolio
				,INS_TYPE_NAME as InstrumentType
				,EXT_BUNIT_NAME AS CounterpartyExternalBusinessUnit
				,EXTERNAL_PORTFOLIO_NAME as ExternalPortfolio
				,Format(REALISATION_DATE_original,'yyyy/MM') AS TermEnd	
				,'' AS Product
				,CASE 
					WHEN [pnl_type] = 'UNREALIZED'
					THEN [PNL]
					ELSE 0
					END AS Risk_MtM
				,CASE 
					WHEN [pnl_type] <> 'UNREALIZED'
					THEN [PNL]
					ELSE 0
					END AS Risk_realised
					,0 AS Finance_MtM
				,0 AS Finance_Kaskade
			FROM 
			--/* dbo.Strolf_MOP_PLUS_REAL_CORR_EOM */
			dbo.FIN_MOP_PLUS_REAL_CORR_mit_PNL_TYPE_ORIG_SUMMIERT
			WHERE 
				(
					PORTFOLIO_NAME NOT LIKE 'RHP'
					AND PORTFOLIO_NAME NOT LIKE 'BMT%'
					AND PORTFOLIO_NAME NOT IN ('CAO_CE_LTT_POWER_RWEI', 'STT_DE_ROM', 'STT_NL_ROM','RES_BE') /* "RES_BE" excluded 2022-05-03*/
					AND dateadd(day,-10,EOMONTH([REALISATION_DATE_Original]))> @COB
				)
				OR INS_TYPE_NAME = 'em-inv-p'
				OR INS_TYPE_NAME = 'ren-inv-p'				
			) as [Recon_zw3_union]
				LEFT JOIN dbo.map_order
				ON [Recon_zw3_union].InternalPortfolio = dbo.map_order.Portfolio
				GROUP BY 
					SubDesk
					,Book
					,DealID
					,InternalPortfolio
					,InstrumentType
					,TermEnd
					,Product;

/*==================================================================================================================================================*/
/*==================================================================================================================================================*/
/*==================================================================================================================================================*/

		END TRY

		BEGIN CATCH
			EXEC [dbo].[usp_GetErrorInfo] '[dbo].[Strolf_mtm_check_import_and_prepare]', @step
			BEGIN insert into [dbo].[Logfile] select 'STROLF MtM Check - FAILED', GETDATE () END
		END CATCH

GO

