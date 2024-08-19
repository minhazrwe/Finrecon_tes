


--test change

/* ================================================================================
	Date:			2022/10 - 2023/01
	Author:		MBE / MKB / MU
	Purpose:	further processing/analysis of realised data imported from Risk System
	---------------------------------------------------------------------------------
	updates/changes:	
	2023-08-10, Step 6: Changed DeliveryMonth logic because OIL-OPT-EXCH-P deals got DM = 1901/01 (MK)
	2023-11-28, Step 6: Changed DeliveryMonth logic for 'GPM DESK' + IRS' records (YK/MK)
	2024-04-05, Step 10: Added exemption for instrument types having all dates in previous years but relevant PnL for current year (SH/MK)
	2024-04-22, Step 6: Changed DeliveryMonth logic for different InstrumentTypes on request by Anna Lena Maas (PG/MK)
	2024-06-24, Step 25: Added OrderNo (= WBS-element) update for RWEST Opea daeals which is dependend on profit/revenue
	2024-06-27, Step 24: Added exception for instrument type [InstrumentType] IN ('PWR-FEE-SUBSIDY') AND FileID = 3269 (MK/MBE)
	2024-06-27, Step 10: Added IntDesk = 'GPM Desk' and InstrumentType = 'GAS-FUT-AVG-EXCH-P' as exception to be deleted (PG/MBE/MK)
	2024-07-22, Step 6: Cleaned volume_new expression and added special handling of PWR-FWD-IFA-P deals (MK)
==================================================================================*/
CREATE PROCEDURE [dbo].[AnalyseData] AS
BEGIN TRY

	DECLARE @LogInfo Integer
	DECLARE @proc nvarchar(40)
	DECLARE @step integer
	DECLARE @counter integer
	
	DECLARE @COB as date
	DECLARE @COB_EOLY date
	DECLARE @AsOfDate_LastDayOfMonth date
	DECLARE @AsOfDate_BOLY date
	DECLARE @AsOfDate_EOY date
	
	DECLARE @comparison_date varchar (20)
	
	DECLARE @COB_year int
	DECLARE @COB_month int
	
	DECLARE @countUAH float
	

	select @step=1
	select @proc = Object_Name(@@PROCID)

	select @step=2
	select @LogInfo = [dbo].[LogInfo].[LogInfo] from [dbo].[LogInfo]
	if @LogInfo >= 1  BEGIN insert into [dbo].[Logfile] select @proc + ' - START', GETDATE () END

	select @step=3
	select 
		 @COB = AsOfDate_EOM
		,@COB_EOLY = EOMonth(asofdate_eoy) /*Last Calendar day of the last year*/
		,@AsOfDate_LastDayOfMonth = EOMonth(AsOfDate_EOM)
		,@AsOfDate_BOLY =  DATEADD(yy, DATEDIFF(yy, 0, asofdate_eoy), 0) /*Beginning of last year*/
		,@AsOfDate_EOY = DATEADD(yy, DATEDIFF(yy, 0, AsOfDate_EOM)+1, -1) /*Last Calendar day of COB year*/
	from 
		dbo.AsOfDate
	
	select @step=4
	/*select year and month of curent COB*/
	select @COB_year = convert(int,(year(@COB))) 
	select @COB_month = convert(int,(month(@COB))) 

	if @LogInfo >= 1  BEGIN insert into [dbo].[Logfile] select @proc + ' - AnalyseData - add FX Rates', GETDATE () END
	select @step = 44
	-- for rerun purposes delete first the current rates and add again the new rates for CoB "last of month"
	delete	from [FinRecon].[dbo].[FXRate]
			where year([FinRecon].[dbo].[FXRate].[asofdate])*100+month([FinRecon].[dbo].[FXRate].[asofdate]) in 
			(select distinct (year([FinRecon].[dbo].[FXRates].[asofdate])*100+month([FinRecon].[dbo].[FXRates].[asofdate])) from dbo.fxrates)

	select @step = 45
	-- insert the FX rates
	INSERT INTO [dbo].[FXRate]  ( AsOfDate , Currency , Rate, RateRisk, DeliveryMonth )
		SELECT [dbo].[FXRates].[AsOfDate], [dbo].[FXRates].[Currency], [dbo].[FXRates].[Rate], [dbo].[FXRates].[RateRisk],
		cast(year([asofdate])as  nvarchar) + '/' + 
		case when  cast(month([asofdate]) as varchar) in ('10','11','12') 	then  cast(month([asofdate]) as varchar)
		else '0' + cast(month([asofdate]) as varchar) end 
	 FROM [dbo].[FXRates] 

	--exec [dbo].[create_Map_order]


	select @step=5
	if @LogInfo >= 1  BEGIN insert into [dbo].[Logfile] select @proc + ' - truncate [02_Realised_all_details]', GETDATE () END
	truncate table [dbo].[02_Realised_all_details]

	select @step=6
	if @LogInfo >= 1  BEGIN insert into [dbo].[Logfile] select @proc + ' - refill [02_realised all details]', GETDATE () END
	INSERT INTO [dbo].[02_Realised_all_details] 
	(
		 ctpygroup
		,IntDesk
		,Commodity
		,OrderNo
		,UNIT_TO
		,Volume_new
		,Deal
		,Reference
		,[Tran Status]
		,Toolset
		,InstrumentType
		,InternalLegalEntity
		,InternalBusinessUnit
		,PfID
		,InternalPortfolio
		,ExternalBusinessUnit
		,ExternalLegalEntity
		,ExternalPortfolio
		,ProjectionIndex
		,[Currency]
		,[Action]
		,Volume
		,Unit
		,DocumentNumber
		,EventDate
		,TradeDate
		,DeliveryMonth
		,[Desk Currency]
		,Realised
		,RealisedBase
		,Realized_YTD_EUR_undisc
		,Realized_YTD_EUR_disc
		,[Realised_DeskCCY_Undisc]
		,[Realised_DeskCCY_Disc]
		,Realized_YTD_GBP_undisc
		,Realized_YTD_GBP_disc
		,Realized_YTD_USD_undisc
		,Realized_YTD_USD_disc
		,CashflowType
		,InstrumentSubType
		,Pipeline
		,[Delivery Vessel Name]
		,[Static Ticket ID]
		,DiscountingIndex
		,Ticker
		,TradePrice
		,[Partner]
		,Ref3
		,VAT_CountryCode
		,LegExerciseDate
		,LegEndDate
		,[CashflowDeliveryMonth]
		,LegalEntity
		,fileid
	)
	SELECT 
		case when [External Portfolio Name] like 'RGM%DUMMY%' then 'External' else 
			case when [Ext Business Unit Name] like 'LNG_Location%' or [Ext Business Unit Name] like 'LNG Location%' then 'LNG_Location' else
				case when ([Int Legal Entity Name] + [Ext Legal Entity Name]) In ('RWEST UK - PERWEST DE - PE','RWEST DE - PERWEST UK - PE') then 'InterPE' else 
					case when [Int Legal Entity Name] = [Ext Legal Entity Name] then 'Intradesk' else 
							case when [Ext Legal Entity Name] Like 'RWEST%' then [Ext Legal Entity Name] else 
								case when ctpygroup = 'Internal' then ExtLegalEntity else 'External' 
								end 
							end 
					end 
				end 
			end
		end 
		as ctpygroup 		
		,dbo.map_order.Desk 
		,case when [Index Group] is null then 'empty' else [Index Group] end as Commodity
		,OrderNo
		,case when [Unit Name (Trade Std)] is null THEN 'empty' else UNIT_TO end as UNIT_TO
		,SUM(ROUND(CASE 
			WHEN [Instrument Type Name] = 'PWR-FWD-P' AND [Index Group] NOT IN ('Electricity') AND fileid NOT IN (2210)
				THEN 0
			-- 2024-07-22 MK: PWR-FWD-IFA-P deals had wrong volume sign
			WHEN [Instrument Type Name] = 'PWR-FWD-IFA-P'
				THEN [volume] * [conv]
			WHEN InstrumentGroup = 'phys' AND ([Instrument Type Name] NOT IN ('GAS-EXCH-P', 'PWR-OPT-TRANS-H-P', 'PWR-TRANS-P')	OR ([Instrument Type Name] IN ('GAS-EXCH-P') AND [Internal Portfolio Name] = 'RGM_D_PM_WEATHER'))
				THEN [volume] * [conv] * -1
			ELSE 0
		END, 3)) AS Volume_new
		,[Trade Deal Number] 
		,left(max(isnull([Trade Reference Text],'')), 99) AS [Trade Reference Text] 
		,Max(isnull([Transaction Info Status],'')) AS [MaxvonTransaction Info Status]
		,[Instrument Toolset Name]
		,[Instrument Type Name]
		,[Int Legal Entity Name] 
		,[Int Business Unit Name] 
		,[Internal Portfolio Business Key] 
		,[Internal Portfolio Name] 
		,[Ext Business Unit Name]
		,[Ext Legal Entity Name] 
		,[External Portfolio Name] 
		,max([Index Name]) as [Index Name] 
		,[Trade Currency] 
		,[Transaction Info Buy Sell] 
		,round(Sum(isnull([volume],0)),3) AS Summevonvolume 
		,[Unit Name (Trade Std)] 
		,[Document Number]		
		,cast(format([Cashflow Payment Date],'dd.MM.yyyy') as varchar) as EventDate
		,[Trade Date] 
		,CASE 
		WHEN isnull([Delivery Month], 0) = 0
			THEN CASE 
				-- 2024-04-22 PG/MK: implemented on request by Anna-Lena Maas 
				 -- WHEN [Instrument Type Name] IN (
					--			'GAS-OPT-EXCH-P',
					--			'MTL-EXCH-OPT',
					--			'GAS-OPT-CALL-F',
					--			'GAS-OPT-PUT-F',
					--			'PWR-OPT-EXCH-P',
					--			'EM-OPT-EXCH-P',
					--			'OIL-OPT-EXCH-P',
					--			'SOFT-OPT-EXCH-M-P',
					--			'OIL-OPT-EXCH-W-P',
					--			'TC-OPT-PUT-F',
					--			'TC-OPT-CALL-F',
					--			'MTL-EXCH-OPT-FWD-P'
					--									)
					--THEN format([Leg Exercise Date], 'yyyy/MM')
					-- end request
					WHEN (
							(
								(
									instrumentgroup IN (
										'Weather'
										,'Fee'
										,'Option'
										)
									OR [Cashflow Type] NOT IN (
										'FX Forward'
										,'FX Spot'
										,'None'
										,'Commodity'
										,'Ticket Commodity CFlow'
										,'OLF Correction'
										,'Margin'
										,'Upfront'
										,'Interest'
										,'Settlement'
										,'Premium'
										,'FX Swap'
										,'Broker Fee'
										,'Prepayment Principal'
										,'Prepayment Reversal'
										,'Provisional Principal'
										,'Provisional Reversal'
										,'Broker Commission'
										,'Bunkers NOT in PnL'
										)
									) /*1*/
								AND (
									[Cashflow Payment Date] < [leg end date]
									OR (
										[InstrumentType] = 'OIL-OPT-EXCH-P'
										AND [Leg End Date] = '1900-01-01'
										)
									)
								) /*2*/
							OR [instrumentgroup] = 'FX'
							) /*3*/
						THEN format([Cashflow Payment Date], 'yyyy/MM')
					WHEN (
							[Desk Name] = 'GPM DESK'
							AND [Instrument Type Name] = 'IRS'
							AND [Cashflow Payment Date] > @COB
							)
						THEN format(@COB, 'yyyy/MM')
					WHEN (
							InstrumentGroup = 'ETD'
							AND convert(DATE, [Cashflow Delivery Month], 103) < [leg end date]
							/*--convert(datetime,[cashflow delivery month],104) < [leg end date]*/
							)
						THEN format(convert(DATE, [Cashflow Delivery Month], 103), 'yyyy/MM')
					ELSE format([Leg End Date], 'yyyy/MM')
					END
		ELSE [Delivery Month]
		END AS DeliveryMonth
		,[Desk Currency]
		,round(Sum(case when ([Instrument Type Name] = 'PWR-TRANS-P' And [Cashflow Type] = 'None') 
										then 0 
										else Realised_OrigCCY_Undisc 
								end),2) AS Realised /*CCY*/
		
		,round(Sum(case when ([Instrument Type Name] = 'PWR-TRANS-P' And [Cashflow Type] = 'None') 
										then 0 
										else Realised_EUR_Undisc 
							 end),2) AS RealisedBase /*EUR*/
		,Sum(isnull(Realised_EUR_Undisc,0)) AS SummevonRealised_EUR_Undisc1 /*Realized_YTD_EUR_undisc*/
		,Sum(isnull(Realised_EUR_Disc,0)) AS SummevonRealised_EUR_Disc /*Realized_YTD_EUR_disc*/
		,sum(isnull([Realised_DeskCCY_Undisc] ,0)) AS [Realised_DeskCCY_Undisc]
		,sum(isnull([Realised_DeskCCY_Disc] ,0)) AS [Realised_DeskCCY_Disc]
		,Sum(isnull(Realised_GBP_Undisc,0)) AS SummevonRealised_GBP_Undisc /*Realized_YTD_GBP_undisc*/
		,Sum(isnull(Realised_GBP_Disc,0)) AS SummevonRealised_GBP_Disc /*Realized_YTD_GBP_disc*/
		,Sum(isnull(Realised_USD_Undisc,0)) AS SummevonRealised_USD_Undisc/*Realized_YTD_USD_undisc*/
		,Sum(isnull(Realised_USD_Disc,0)) AS SummevonRealised_USD_Disc/*Realized_YTD_USD_disc*/ 
		,case when instrumentgroup = 'ETD' 
					then 'Interest' 
					else case when [Cashflow Type] is null 
										THEN 'empty' 
										else [Cashflow Type]  
								end 
			end AS CashflowType 
		,[Instrument Subtype Name] as InstrumentSubType
		,[Side Pipeline Name] as Pipeline
		,[Delivery Vessel Name]
		,[Static Ticket ID]
		,[Discounting Index Name] as [DiscountingIndex]
		,[Trade Instrument Reference Text] as Ticker 
		,Max([Trade Price]) AS TradePrice 
		,[Partner] 
		,[Ref3]
		,[Country] as VAT_CountryCode 
		,[Leg Exercise Date] as LegExerciseDate 
		,[Leg End Date] as LegEndDate
		,convert(datetime,[Cashflow Delivery Month],103) as [CashflowDeliveryMonth]
		,[dbo].[map_order].[LegalEntity] as [LegalEntity] 
		,FileID
	FROM 
		[dbo].[01_realised_all] 
		LEFT JOIN [dbo].[map_order] ON [dbo].[01_realised_all].[Internal Portfolio Name] = [map_order].[Portfolio] 
		LEFT JOIN [dbo].[map_UOM_conversion] ON [dbo].[01_realised_all].[Unit Name (Trade Std)] = [dbo].[map_UOM_conversion].[UNIT_FROM] 
		LEFT JOIN [dbo].[map_counterparty] ON [dbo].[01_realised_all].[Ext Business Unit Name] = [dbo].[map_counterparty].[ExtBunit] 
		LEFT JOIN [dbo].[map_Instrument] ON [dbo].[01_realised_all].[Instrument Type Name] = [dbo].[map_Instrument].[InstrumentType] 
	WHERE 
		isnull(ToBeDeleted,0) = 0
	GROUP BY 
		case when [External Portfolio Name] like 'RGM%DUMMY%' then 'External' else 
			case when [Ext Business Unit Name] like 'LNG_Location%' or [Ext Business Unit Name] like 'LNG Location%' then 'LNG_Location' else
				case when ([Int Legal Entity Name] + [Ext Legal Entity Name]) In ('RWEST UK - PERWEST DE - PE','RWEST DE - PERWEST UK - PE') then 'InterPE' else 
					case when [Int Legal Entity Name] = [Ext Legal Entity Name] then 'Intradesk' else 
						case when [Ext Legal Entity Name] Like 'RWEST%' then [Ext Legal Entity Name] else 
							case when ctpygroup = 'Internal' then ExtLegalEntity else 'External' 
							end 
						end 
					end 
				end 
			end
		end
		,[dbo].[map_order].[Desk] 
		,case when [Index Group] is null then 'empty' else [Index Group] end
		,[OrderNo]  
		,case when [Unit Name (Trade Std)] is null THEN 'empty' else UNIT_TO end 
		,[Trade Deal Number] 
		,[Instrument Toolset Name]
		,[Instrument Type Name]
		,[Int Legal Entity Name]
		,[Int Business Unit Name] 
		,[Internal Portfolio Business Key]
		,[Internal Portfolio Name]
		,[Ext Business Unit Name]
		,[Ext Legal Entity Name] 
		,[External Portfolio Name]
		,[Trade Currency]
		,[Transaction Info Buy Sell]
		,[Unit Name (Trade Std)]
		,[Document Number]
		,cast(format([Cashflow Payment Date],'dd.MM.yyyy') as varchar)
		,[Trade Date]
		,CASE 
		WHEN isnull([Delivery Month], 0) = 0
			THEN CASE 
					-- 2024-04-22 PG/MK: implemented on request by Anna-Lena Maas 
					--WHEN [Instrument Type Name] IN (
					--			'GAS-OPT-EXCH-P',
					--			'MTL-EXCH-OPT',
					--			'GAS-OPT-CALL-F',
					--			'GAS-OPT-PUT-F',
					--			'PWR-OPT-EXCH-P',
					--			'EM-OPT-EXCH-P',
					--			'OIL-OPT-EXCH-P',
					--			'SOFT-OPT-EXCH-M-P',
					--			'OIL-OPT-EXCH-W-P',
					--			'TC-OPT-PUT-F',
					--			'TC-OPT-CALL-F',
					--			'MTL-EXCH-OPT-FWD-P'
					--									)
					--THEN format([Leg Exercise Date], 'yyyy/MM')
					-- end request
					WHEN (
							(
								(
									instrumentgroup IN (
										'Weather'
										,'Fee'
										,'Option'
										)
									OR [Cashflow Type] NOT IN (
										'FX Forward'
										,'FX Spot'
										,'None'
										,'Commodity'
										,'Ticket Commodity CFlow'
										,'OLF Correction'
										,'Margin'
										,'Upfront'
										,'Interest'
										,'Settlement'
										,'Premium'
										,'FX Swap'
										,'Broker Fee'
										,'Prepayment Principal'
										,'Prepayment Reversal'
										,'Provisional Principal'
										,'Provisional Reversal'
										,'Broker Commission'
										,'Bunkers NOT in PnL'
										)
									) /*1*/
								AND (
									[Cashflow Payment Date] < [leg end date]
									OR (
										[InstrumentType] = 'OIL-OPT-EXCH-P'
										AND [Leg End Date] = '1900-01-01'
										)
									)
								) /*2*/
							OR [instrumentgroup] = 'FX'
							) /*3*/
						THEN format([Cashflow Payment Date], 'yyyy/MM')
					WHEN (
							[Desk Name] = 'GPM DESK'
							AND [Instrument Type Name] = 'IRS'
							AND [Cashflow Payment Date] > @COB
							)
						THEN format(@COB, 'yyyy/MM')
					WHEN (
							InstrumentGroup = 'ETD'
							AND convert(DATE, [Cashflow Delivery Month], 103) < [leg end date]
							/*--convert(datetime,[cashflow delivery month],104) < [leg end date]*/
							)
						THEN format(convert(DATE, [Cashflow Delivery Month], 103), 'yyyy/MM')
					ELSE format([Leg End Date], 'yyyy/MM')
					END
		ELSE [Delivery Month]
		END
		,case when [instrumentgroup] = 'ETD' then 'Interest' else 
				case when [Cashflow Type] is null THEN 'empty' else [Cashflow Type] end 
		 end 
		,[Desk Currency]
		,[Instrument Subtype Name]
		,[Side Pipeline Name]
		,[Discounting Index Name]
		,[Trade Instrument Reference Text] 
		,[Partner]
		,[Ref3]
		,[Country]
		,[Leg Exercise Date]
		,[Leg End Date]
		,[dbo].[map_order].[LegalEntity]
		,InstrumentGroup
		,[Delivery Vessel Name]
		,[Static Ticket ID]
		,[Cashflow Delivery Month]
		,FileID

	
	
	if @LogInfo >= 1  BEGIN insert into [dbo].[Logfile] select @proc + ' - delete where leg Exercise date > EoM', GETDATE () END
	select @step=7
	delete from [02_Realised_all_details] 
	where Deal in ( select distinct [Trade Deal Number] 
									from [01_realised_all] 
									where [Leg End Date] like '%1900%' and [Leg Exercise Date] > @COB  
								)

	
	if @LogInfo >= 1  BEGIN insert into [dbo].[Logfile] select @proc + ' - "Continental Power Trading" Filter', GETDATE () END
	delete from [02_Realised_all_details] 
	where ( Intdesk = 'Continental Power Trading' AND  LegExerciseDate like '%1900%' AND [CashflowDeliveryMonth] <= @COB_EOLY AND [LegEndDate] <= @COB_EOLY  and convert(DATE, EventDate, 104) <= @COB_EOLY)


	select @step=8	
	if @LogInfo >= 1  BEGIN insert into [dbo].[Logfile] select @proc + ' - delete records with future Cashflows', GETDATE () END			
	delete from [02_Realised_all_details] where convert(int,left(DeliveryMonth,4)) >  @COB_year
	
	select @step=9	
	delete from [02_Realised_all_details] where convert(int,left(DeliveryMonth,4)) =  @COB_year and convert(int,right(DeliveryMonth,2))  > @COB_month
	
	--delete from [02_Realised_all_details] where [CashflowDeliveryMonth] >  @AsOfDate_LastDayOfMonth
	
	select @step=10
	if @LogInfo >= 1  BEGIN insert into [dbo].[Logfile] select @proc + ' - delete records with Last Year Cashflows', GETDATE () END			
	
	DELETE FROM [02_Realised_all_details]
		WHERE   
			(IntDesk not in ('GPM DESK') OR (IntDesk in ('GPM DESK') AND InstrumentType = 'GAS-FUT-AVG-EXCH-P'))  -- new added by PG 27.06.2024
			--IntDesk not in ('GPM DESK')    /// uncommented by PG 27.06.2024
			AND convert(DATE, EventDate, 104) <= @COB_EOLY
			AND convert(INT, left(DeliveryMonth, 4)) < @COB_year
			AND (
						(CashflowType not in ('Premium','INT Variation Margin') AND LegEndDate <= @COB_EOLY)
							OR 
						(CashflowType in ('Premium','INT Variation Margin') AND LegExerciseDate <= @COB_EOLY)
					)
			AND FileID not in (2210,2450)
			AND NOT (IntDesk in ('Oil Trading','US GAS AND POWER DESK','MANAGEMENT BOOKS') AND InstrumentType = 'OIL-FUT-EXCH-P' AND [CashflowDeliveryMonth] > @COB_EOLY)
			AND NOT		(IntDesk in ('ASIA-PACIFIC TRADING DESK', 'Dry Bulk Origination Desk','COAL AND FREIGHT DESK','BIOFUELS Desk') 
						AND InstrumentType in ('COAL-FWD','COAL-STEV','COAL-STOR-V16','COMM-FEE','FREIGHT-FWD','OIL-BUNKER-ROLL-P','OIL-FWD','TC-FWD','BIOFUEL-FWD','BIOFUEL-TRANSIT')
						AND convert(DATE, EventDate, 104) >= @AsOfDate_BOLY)
			AND NOT (InstrumentType in ('PWR-OPT-TRANS-H-F','PWR-OPT-EXCH-P') 
						AND convert(DATE, EventDate, 104) <= @COB_EOLY 
						--AND convert(int,left(DeliveryMonth, 4)) <= @COB_year
						AND [CashflowDeliveryMonth] <= @COB_EOLY
						AND convert(DATE, LegEndDate, 104) <= @COB_EOLY
						AND convert(DATE, LegExerciseDate, 104) <= @COB_EOLY)  --added because of deals with COB vs LGBY resulted in PnL even though all dates are in previous years/ SH 2024-04-04

	select @step=11 /*clarify how long this is valid / needs to be done !!!*/
	if @LogInfo >= 1  BEGIN insert into [dbo].[Logfile] select @proc + ' - delete LNG for April / Liudmilla', GETDATE () END
	delete from [02_Realised_all_details]  
	where 
		ctpygroup = 'Intradesk' 
		and InternalPortfolio = 'LNG_FINANCIAL_USD' 
		and Ticker = 'PWX_G3BS_W-20' 
		and DeliveryMonth in ('2020/10','2020/11','2020/12') 
		and ExternalPortfolio in ('NG_PROMPT_4_EUR','NG_PROMPT_1_EUR','NG_PROMPT_EUR')
		and EventDate = '29.09.2020' 


	select @step=20
	if @LogInfo >= 1  BEGIN insert into [dbo].[Logfile] select @proc + ' - update volumes I', GETDATE () END	
  UPDATE [dbo].[02_Realised_all_details]
		SET [Volume_new] = -round([Volume]/case when ProjectionIndex = 'Index_Lohn_B1' then 2 else 1 end,3)
				,[UNIT_TO] = 'MWH'
    where 
			InstrumentType = 'PWR-FWD-P' 
			and commodity <> 'Electricity' 
			and cashflowtype = 'interest' 
			and (
						projectionindex not in ('EM_EUA','EM_EUA_LT')  
						or 
						(
							projectionindex  in ('EM_EUA_LT')  
							and 
							unit = 'MT'
						)
					)
					and fileid not in (685,2210)

			/*  fileID 685	is not a valied record in table "dbo.filestoimport"
					fileID 2210	represents file "Realised PNL aus Strolf_Realized" */ 
		
	select @step=21
	if @LogInfo >= 1  BEGIN insert into [dbo].[Logfile] select @proc + ' - update volumes II', GETDATE () END	
	UPDATE [dbo].[02_Realised_all_details]
		SET Volume_new = -round([Volume]/case when ProjectionIndex = 'Index_Lohn_B1' then 2 else 1 end,3)
				,UNIT_TO = 'MWH'
		from [dbo].[02_Realised_all_details] inner join FilestoImport 
					on [02_Realised_all_details].FileID = filestoimport.id
    where 
			InstrumentType = 'PWR-FWD-P' 
			And commodity Not In ('Electricity') 
			And Unit  In ('MWH') 
			and FilestoImport.source = 'Endur' 
			and fileid not in (2210)  
									
	select @step=22
	if @LogInfo >= 1  BEGIN insert into [dbo].[Logfile] select @proc + ' - update volumes III', GETDATE () END
	UPDATE [dbo].[02_Realised_all_details]
		SET [Volume_new] = 0 
   /*--WHERE SUBSTRING(DeliveryMonth,1,4) Not In (select year(AsOfDate_EOM) from [dbo].[AsOfDate])		*/
		WHERE 
			left(DeliveryMonth,4) not like convert(varchar,(year(@COB)))
			and ctpygroup not like 'InterPE' /*2022-02-14 - Added on request by Yvonne Neuhäuse */

	select @step=23
	if @LogInfo >= 1  BEGIN insert into [dbo].[Logfile] select @proc + ' - delete records with Volume_new = 0 and Realised = 0', GETDATE () END
	delete from [02_Realised_all_details]
		WHERE 
			(
				Volume_new=0 
				Or 
				Volume_new Is Null
			) 
			AND 
			(
				Realised=0 
				or 
				Realised is NULL
			)

	-- Please delete "AND NOT ([InstrumentType] IN ('PWR-FEE-SUBSIDY') AND FileID = 3269)" After 2025-01-01
	select @step=24
	if @LogInfo >= 1  BEGIN insert into [dbo].[Logfile] select @proc + ' - delete records with deal status Pending or Proposed', GETDATE () END
	delete from [02_Realised_all_details]
		WHERE [Tran Status] in ('Pending','Proposed') AND NOT ([InstrumentType] IN ('PWR-FEE-SUBSIDY') AND FileID = 3269)

	select @step=25
	if @LogInfo >= 1  BEGIN insert into [dbo].[Logfile] select @proc + ' - delete GAS accruals from last years', GETDATE () END
	update [dbo].[02_Realised_all_details] 
			set volume = 0 
			where 
				IntDesk = 'GPM DESK' 
				and 
				(
					left(DeliveryMonth,4) = convert(varchar,(year(@COB))-1) 
					or 
					left(DeliveryMonth,4) = convert(varchar,(year(@COB))-2) 
					or 
					left(DeliveryMonth,4) = convert(varchar,(year(@COB))-3)
				) 
				and orderno = 'HS2027000'

	select @step=17
	if @LogInfo >= 1  BEGIN insert into [dbo].[Logfile] select @proc + ' - delete unneeded buyout proceeds', GETDATE () END

	-- delete from the table where cashflow type is buyout proceed and payment date prior year
	delete from [02_Realised_all_details] 
		WHERE 
		(
			CashflowType='Buyout Proceeds' 
			AND CONVERT(datetime,case when [EventDate] = '' then NULL else [EventDate] end ,104) <= @COB_EOLY)

	select @step=22
	if @LogInfo >= 1  BEGIN insert into [dbo].[Logfile] select @proc + ' - update counterparty group, VAT_code and VAT_countrycode', GETDATE () END
	UPDATE [02_Realised_all_details] 
	SET [group] = 
			case when [ctpygroup] In ('InterPE') then 'InterPE' else 
				case when [ctpygroup] In ('Intradesk','Interdesk','Assetbook') then 'Intradesk' else
					case when [ctpygroup] Like 'External%' then 'External' else
						case when [ctpygroup] = 'LNG_Location' then 'LNG_Location' else 'Internal' 
						end
					end 
				end 
			end
		,StKZ_zw1 = 
			case when [ctpygroup] In ('InterPE') then 'InterPE' else
				case when [ctpygroup] In ('Intradesk','Interdesk','Assetbook') then 'Intradesk' else [StKZ_zw1] end 
			end
		,[VAT_CountryCode] = 
			case when [ctpygroup] In ('InterPE') then 'GB' else --South Africa fehlt noch
				case when [ctpygroup] In ('Intradesk','Interdesk','Assetbook') then 'DE' else [VAT_CountryCode] end 
			end
	
	select @step=23
	if @LogInfo >= 1  BEGIN insert into [dbo].[Logfile] select @proc + ' - update Auftrag HBR1000', GETDATE () END
	UPDATE [02_Realised_all_details] 
	SET [OrderNo] = 'HBR1000'
		WHERE     
			[InternalPortfolio] in ('SPM_LT_PWR_BNL_OLD','SPM_LT_PWR_BNL_OU') 
			AND [InstrumentType] = 'REN-FWD-P'

	select @step=24
	if @LogInfo >= 1  BEGIN insert into [dbo].[Logfile] select @proc + ' - update Auftrag HR1000', GETDATE () END
	UPDATE [02_Realised_all_details] 
	SET [OrderNo] = 'HR1000'
		WHERE     
			[InternalPortfolio] in ('SPM_LT_PWR_MP_FV','SPM_LT_CAB_ML_OU') 
			AND [InstrumentType] = 'REN-FWD-P'
	
	-- 2024-06-24 MK: Added on request of Anna Buschert. Change OrderNo (=WBS-Element = PSP-Element), if in profit.
	select @step=25
	if @LogInfo >= 1  BEGIN insert into [dbo].[Logfile] select @proc + ' - update Auftrag 8000-MARKET[...]2001', GETDATE () END
	UPDATE [02_Realised_all_details] 
	SET [OrderNo] = '8000-MARKET0101001001001'
		WHERE [02_Realised_all_details].[IntDesk] = 'RWER OPEA' AND [02_Realised_all_details].[OrderNo] = '8000-MARKET0101001002001'
		AND ([02_Realised_all_details].Realised > 0 Or ([02_Realised_all_details].Realised = 0 and [02_Realised_all_details].[Volume_new] > 0))

	select @step=26
	if @LogInfo >= 1  BEGIN insert into [dbo].[Logfile] select @proc + ' - update document number', GETDATE () END
	update dbo.[02_Realised_all_details] 
		set [documentnumber] = dbo.[map_documentnumber].[max_document_num] 
			from 
				dbo.[02_Realised_all_details] inner join dbo.[map_documentnumber] 
				on dbo.[02_Realised_all_details].[Deal] = dbo.[map_documentnumber].[deal_tracking_num]
					 and convert(datetime,dbo.[02_Realised_all_details].[EventDate],104) = convert(datetime,dbo.[map_documentnumber].[event_date],104)
					 and replace(dbo.[02_Realised_all_details].[cashflowtype],'Interest','Settlement') = dbo.[map_documentnumber].[cflow_type]
				where dbo.[02_Realised_all_details].[documentnumber] is null

	select @step=27
	if @LogInfo >= 1  BEGIN insert into [dbo].[Logfile] select @proc + ' - update Volumes for Heike', GETDATE () END
		update [FinRecon].[dbo].[02_Realised_all_details] 
			set [Volume] = 0
			,[Volume_New] = 0
			where 
				InstrumentType = 'GAS-STOR-P' 
				and 
				( 
					[group] in ('InterPE','Intradesk') 
					or 
					InternalPortfolio like '%RGM%UK%'
				)				


	select @step=28
	if @LogInfo >= 1  BEGIN insert into [dbo].[Logfile] select @proc + ' - RealisedBase Calculation', GETDATE () END
	UPDATE [dbo].[02_Realised_all_details]
		SET [dbo].[02_Realised_all_details].[RealisedBase] = round([dbo].[02_Realised_all_details].[Realised] / [dbo].[FXRate].[Rate],2), 
			[02_Realised_all_details].[FXRate] = [dbo].[FXRate].[Rate]
		from [dbo].[02_Realised_all_details] inner join [dbo].[FXRate] on [dbo].[02_Realised_all_details].[Currency] = [dbo].[FXRate].[Currency] 
			AND 
			[dbo].[02_Realised_all_details].[DeliveryMonth] = [dbo].[FXRate].[DeliveryMonth]
		where
			[dbo].[02_Realised_all_details].[Currency] Not In ('EUR')



	if @LogInfo >= 1  BEGIN insert into [dbo].[Logfile] select @proc + ' - FINISHED', GETDATE () END

END TRY

	BEGIN CATCH
		EXEC [dbo].[usp_GetErrorInfo] @proc, @step
		BEGIN insert into [dbo].[Logfile] select @proc + ' - FAILED', GETDATE () END
	END CATCH

GO

