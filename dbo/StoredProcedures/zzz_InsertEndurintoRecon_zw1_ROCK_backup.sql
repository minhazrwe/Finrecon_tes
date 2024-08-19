
	create PROCEDURE [dbo].[zzz_InsertEndurintoRecon_zw1_ROCK_backup] 
	AS
	BEGIN TRY
	
	-- define some variables that been needed
	DECLARE @LogInfo Integer

	select @LogInfo = [dbo].[LogInfo].[LogInfo] from [dbo].[LogInfo]

	if @LogInfo >= 1  BEGIN insert into [dbo].[Logfile] select 'RealisedRecon_ROCK - InsertEndurintoRecon_zw1 - update Ticker in Endurdata', GETDATE () END


	UPDATE [dbo].[02_Realised_all_details_ROCK] SET [dbo].[02_Realised_all_details_ROCK].[Ticker] = [dbo].[map_dealid_Ticker].[Ticker]
		from ([dbo].[02_Realised_all_details_ROCK] inner join [dbo].[map_dealid_Ticker] on [dbo].[02_Realised_all_details_ROCK].[deal] =  [dbo].[map_dealid_Ticker].[dealid]) 
		
	if @LogInfo >= 1  BEGIN insert into [dbo].[Logfile] select 'RealisedRecon_ROCK - InsertEndurintoRecon_zw1 - insert recon', GETDATE () END

	INSERT INTO Recon_zw1_ROCK ( [Source], ReconGroup, DeliveryMonth, DealID_Recon, DealID, portfolio, CounterpartyGroup, 
		InstrumentType, ExternalBusinessUnit, ExternalLegal, ExternalPortfolio, ProjIndexGroup, CurveName, TradeDate, EventDate, Volume_Endur, 
		UOM_Endur, ccy, Deskccy, realised_ccy_Endur, realised_Deskccy_Endur, realised_EUR_Endur, [OrderNo], InternalBusinessUnit, DocumentNumber, Reference, 
		TranStatus, [Action], CashflowType, Account_Endur, [Partner], VAT_Script, VAT_CountryCode, InternalLegalEntity, Ticker, deliveryvesselname, staticticketid )

	SELECT 
		 [Source], ReconGroup, DeliveryMonth, DealID_Recon, DealID, portfolio, CounterpartyGroup, 
		InstrumentType, ExternalBusinessUnit, ExternalLegal, ExternalPortfolio, ProjIndexGroup, CurveName, TradeDate, EventDate, Volume_Endur, 
		UOM_Endur, ccy, DeskCCY, realised_ccy_Endur, realised_deskccy_Endur, realised_EUR_Endur, [OrderNo], InternalBusinessUnit, DocumentNumber, left(Reference,70), 
		TranStatus, [Action], CashflowType, Account_Endur, [Partner], VAT_Script, VAT_CountryCode, InternalLegalEntity, Ticker, [Delivery Vessel Name], [Static Ticket ID]
	
	FROM [dbo].[base_realised_Endur_Recon_zw1_ROCK]


	--special rule for cashflow Route Fee which shall be treated as Brokerage, see CR2019_01
	if @LogInfo >= 1  BEGIN insert into [dbo].[Logfile] select 'RealisedRecon_ROCK - InsertEndurintoRecon_zw1 - update recongroup 1', GETDATE () END

		UPDATE [dbo].[recon_zw1_ROCK] SET [dbo].[recon_zw1_ROCK].[ReconGroup] = 'Brokerage'
		from [dbo].[recon_zw1_ROCK] where recon_zw1_ROCK.CashflowType in ('Route Fee', 'DMA Exchange Fee')

	

	--special rule for Coal&Freight desk
	if @LogInfo >= 1  BEGIN insert into [dbo].[Logfile] select 'RealisedRecon_ROCK - InsertEndurintoRecon_zw1 - update recongroup 2', GETDATE () END

		UPDATE [dbo].[recon_zw1_ROCK] SET [dbo].[recon_zw1_ROCK].[ReconGroup] = 'Bunker Roll - External' from [dbo].[recon_zw1_ROCK] 
		where recon_zw1_ROCK.Recongroup = 'Secondary Cost' AND (dbo.[recon_zw1_ROCK].[instrumenttype] = 'OIL-BUNKER-ROLL-P' 
				or (dbo.[recon_zw1_ROCK].[instrumenttype] in ('TC-FWD','OIL-FWD')  AND dbo.[recon_zw1_ROCK].[CashflowType] = 'Bunkers'))


	--special rule for Coal&Freight desk
	if @LogInfo >= 1  BEGIN insert into [dbo].[Logfile] select 'RealisedRecon_ROCK - InsertEndurintoRecon_zw1 - SF - update recongroup 3', GETDATE () END

		UPDATE [dbo].[recon_zw1_ROCK] SET [dbo].[recon_zw1_ROCK].[ReconGroup] = 'TC' from [dbo].[recon_zw1] 
		where dbo.[recon_zw1_ROCK].[instrumenttype] = 'TC-FWD' and recon_zw1_ROCK.Account_Endur in ('4006163', '6018012','4006164','6010164')

	--special rule for Coal&Freight desk
	if @LogInfo >= 1  BEGIN insert into [dbo].[Logfile] select 'RealisedRecon_ROCK - InsertEndurintoRecon_zw1 - SF - update recongroup 4', GETDATE () END

		UPDATE [dbo].[recon_zw1_ROCK] SET [dbo].[recon_zw1_ROCK].[ReconGroup] = 'TC-Bunkers' from [dbo].[recon_zw1_ROCK] 
		where dbo.[recon_zw1_ROCK].[instrumenttype] = 'OIL-FWD' and recon_zw1_ROCK.Account_Endur in ('4006163', '6018012','4006164','6010164')


	--special rule for Coal&Freight desk	
	if @LogInfo >= 1  BEGIN insert into [dbo].[Logfile] select 'RealisedRecon_ROCK - InsertEndurintorecon_zw1_ROCK - update ReconGroup5', GETDATE () END

		UPDATE [dbo].[recon_zw1_ROCK]
			SET [dbo].[recon_zw1_ROCK].[ReconGroup] = 
				case when [dbo].[recon_zw1_ROCK].Instrumenttype = 'OIL-BUNKER-ROLL-P' then 'BUNKER ROLL - ' else 
				case when [dbo].[recon_zw1_ROCK].Instrumenttype = 'OIL-FWD' then 'BUNKER OIL - ' else 
				case when [dbo].[recon_zw1_ROCK].Instrumenttype = 'TC-FWD' then 'TC - ' else 		
				case when [dbo].[recon_zw1_ROCK].Instrumenttype = 'FREIGHT-FWD' then 'VC - ' else 		
				case when [dbo].[recon_zw1_ROCK].Instrumenttype = 'COMM-FEE' then 'FEE - ' else '' end end end end end + [dbo].[map_extbunitexclude].[ReconGroup]
		from [dbo].[recon_zw1_ROCK] inner join [dbo].[map_extbunitexclude] on [dbo].[recon_zw1_ROCK].[ExternalBusinessUnit] =  [dbo].[map_extbunitexclude].[ExtBunit]
		where recon_zw1_ROCK.source = 'realised_script'

		Update [dbo].[recon_zw1_ROCK]
			Set [dbo].[recon_zw1_ROCK].[DealID_Recon] = 'INV_LNG' where ExternalBusinessUnit = 'LNG_LOCATION BU'

	--special rule for CAO CE	
	if @LogInfo >= 1  BEGIN insert into [dbo].[Logfile] select 'RealisedRecon_ROCK - InsertEndurintorecon_zw1_ROCK - update ReconGroup6', GETDATE () END

		UPDATE [dbo].[recon_zw1_ROCK] SET [dbo].[recon_zw1_ROCK].[ReconGroup] = 'Brokerage' from [dbo].[recon_zw1_ROCK]
		where recon_zw1_ROCK.source = 'realised_script' and recon_zw1_ROCK.ExternalPortfolio =  'DUMMY_CE'


	if @LogInfo >= 1  BEGIN insert into [dbo].[Logfile] select 'RealisedRecon_ROCK - InsertEndurintorecon_zw1_ROCK - fill map_static_deal_data', GETDATE () END

	truncate table dbo.map_static_deal_data

	insert into dbo.[map_static_deal_data] ([Trade Deal Number] ,[Trade Reference Text] ,[Instrument Type Name]  ,[Internal Portfolio Name]  ,[External Portfolio Name] 
			,[Ext Business Unit Name] ,[Ext Legal Entity Name]  ,[Index Group], [CountryCode])
	select  [Trade Deal Number], max(left([Trade Reference Text],99)), max([Instrument Type Name]), max([Internal Portfolio Name]), max(r.[External Portfolio Name]), 
			 max(r.[Ext Business Unit Name]),  max(r.[Ext Legal Entity Name]), max(r.[Index Group]), max(c.country)
			from dbo.[01_realised_all] r inner join dbo.map_counterparty c on r.[Ext Business Unit Name] = c.ExtBunit
		    where r.[Ext Legal Entity Name] not in ('RWEST UK - PE', 'RWEST DE - PE') and (c.Exchange = 0 or [Instrument Type Name] like '%OPT%')
		    group by  [Trade Deal Number]


-- update for CS


--special rule to detect Commodity Solutions deals with settlement in Endur
	if @LogInfo >= 1  BEGIN insert into [dbo].[Logfile] select 'RealisedRecon_ROCK - InsertEndurintorecon_zw1_ROCK - updates for CS', GETDATE () END

	UPDATE [dbo].[recon_zw1_ROCK] SET [dbo].[recon_zw1_ROCK].[Material] = 'x' 
			from [dbo].[recon_zw1_ROCK] 
			where recon_zw1_ROCK.source = 'realised_script' 
				  and dealid in (select EndurDealID from map_CS_Settled_DealID)

	UPDATE [dbo].[recon_zw1_ROCK] SET [dbo].[recon_zw1_ROCK].[Material] = 'x' 
			from [dbo].[recon_zw1_ROCK] 
			where recon_zw1_ROCK.source = 'realised_script' 
				  and recongroup+portfolio in (select recongroup+InternalPortfolio  
											   from map_CS_Settled_Portfolio 
											   where CashflowType = '@all@' and ExternalBusinessUnit = '@all@')

	UPDATE [dbo].[recon_zw1_ROCK] SET [dbo].[recon_zw1_ROCK].[Material] = 'x' 
			from [dbo].[recon_zw1_ROCK] 
			where recon_zw1_ROCK.source = 'realised_script' 
			and recongroup+portfolio+cashflowtype in (select recongroup + InternalPortfolio + cashflowtype
													  from map_CS_Settled_Portfolio
													  where ExternalBusinessUnit = '@all@')

	UPDATE [dbo].[recon_zw1_ROCK] SET [dbo].[recon_zw1_ROCK].[Material] = 'x' 
		   from [dbo].[recon_zw1_ROCK] 
		   where recon_zw1_ROCK.source = 'realised_script' 
		   and recongroup+portfolio+ExternalBusinessUnit in (select recongroup+InternalPortfolio + ExternalBusinessUnit
														     from map_CS_Settled_Portfolio
															 where CashflowType = '@all@' )

	UPDATE [dbo].[recon_zw1_ROCK] SET [dbo].[recon_zw1_ROCK].[Material] = 'x' 
		   from [dbo].[recon_zw1_ROCK] 
		   where recon_zw1_ROCK.source = 'realised_script' 
		   and recongroup+portfolio+cashflowtype+ExternalBusinessUnit in (select recongroup+InternalPortfolio + cashflowtype + ExternalBusinessUnit    
														     from map_CS_Settled_Portfolio)

	UPDATE [dbo].[recon_zw1_ROCK] SET [dbo].[recon_zw1_ROCK].[orderno] = [dbo].[recon_zw1_ROCK].[orderno]+'x'
		from [dbo].[recon_zw1_ROCK] 
		where recon_zw1_ROCK.source = 'realised_script' 
			and [dbo].[recon_zw1_ROCK].[Material] is null 
			and dealid not like 'V%'
			and [dbo].[recon_zw1_ROCK].[ReconGroup]  in ('Physical Power','Transportation','Physical Gas','Secondary Cost')
			and [dbo].[recon_zw1_ROCK].[orderno] in (select orderno from [00_map_order] where desk = 'Industrial Sales')

-- update for April on 24.11.2021 made by MBE
-- added HAI KUO Shipping on 31.08.2022

	update [dbo].[recon_zw1_ROCK] SET [dbo].[recon_zw1_ROCK].ReconGroup = 'TC' where [ExternalBusinessUnit] in (
			'SHANDONG DEYUN SHIPPING BU','SHANDONG DEGUANG SHIPPING BU','','SHANDONG DEXIANG SHIPPING BU','SHANDONG DERUI SHIPPING BU',
			'SHANDONG DECHANG SHIPPING BU','SHANDONG DEHONG SHIPPING BU','SHANDONG DELONG SHIPPING BU','SHANDONG DEYU SHIPPING BU',
			'SHANDONG DEFENG SHIPPING BU','SHANDONG DETAI BU','HAI KUO SHIPPING 2108B','HAI KUO SHIPPING 2109B') and [dbo].[recon_zw1_ROCK].InstrumentType in ('TC-OPT-CALL-P','TC-OPT-PUT-P')


END TRY

	BEGIN CATCH
		--insert into [dbo].[Logfile] select 'ERROR-OCCURED', @TimeStamp
		EXEC [dbo].[usp_GetErrorInfo] '[dbo].[InsertEndurinrecon_zw1_ROCK]', 1
	END CATCH

GO

