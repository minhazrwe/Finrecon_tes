






	CREATE PROCEDURE [dbo].[InsertEndurintoRecon_zw1] 
	AS
	BEGIN TRY
		/*define variables */
		DECLARE @proc nvarchar(40)
		DECLARE @step Integer	
		DECLARE @LogInfo Integer
		
		select @proc =  Object_Name(@@PROCID)
		
		select @LogInfo = [dbo].[LogInfo].[LogInfo] from [dbo].[LogInfo]
		
		select @step = 1
		if @LogInfo >= 1  BEGIN insert into [dbo].[Logfile] select 'Reconciliation - ' + @proc + ': update Ticker in Endurdata', GETDATE () END
		UPDATE 
			[dbo].[02_Realised_all_details] 
		SET 
			[dbo].[02_Realised_all_details].[Ticker] = [dbo].[map_dealid_Ticker].[Ticker]
			from 
			(
				[dbo].[02_Realised_all_details] 
				inner join [dbo].[map_dealid_Ticker] 
				on [dbo].[02_Realised_all_details].[deal] =  [dbo].[map_dealid_Ticker].[dealid]) 
		
		select @step = 2
		if @LogInfo >= 1  BEGIN insert into [dbo].[Logfile] select 'Reconciliation - ' + @proc + ': insert recon', GETDATE () END
		
		INSERT INTO Recon_zw1 
		(
			[Source]
			,ReconGroup
			,DeliveryMonth
			,DealID_Recon
			,DealID
			,portfolio
			,Portfolio_ID
			,CounterpartyGroup
			,InstrumentType
			,ExternalBusinessUnit
			,ExternalLegal
			,ExternalPortfolio
			,ProjIndexGroup
			,CurveName
			,TradeDate
			,EventDate
			,Volume_Endur
			,UOM_Endur
			,ccy
			,Deskccy
			,realised_ccy_Endur
			,realised_Deskccy_Endur
			,realised_EUR_Endur
			,[OrderNo]
			,InternalBusinessUnit
			,DocumentNumber
			,Reference
			,TranStatus
			,[Action]
			,CashflowType
			,Account_Endur
			,[Partner]
			,VAT_Script
			,VAT_CountryCode
			,InternalLegalEntity
			,Ticker
			,deliveryvesselname
			,staticticketid
		)
		SELECT 
			[Source]
			,ReconGroup
			,DeliveryMonth
			,DealID_Recon
			,DealID
			,portfolio
			,Portfolio_ID
			,CounterpartyGroup
			,InstrumentType
			,ExternalBusinessUnit
			,ExternalLegal
			,ExternalPortfolio
			,ProjIndexGroup
			,CurveName
			,TradeDate
			,EventDate
			,Volume_Endur
			,UOM_Endur
			,ccy
			,DeskCCY
			,realised_ccy_Endur
			,realised_deskccy_Endur
			,realised_EUR_Endur
			,[OrderNo]
			,InternalBusinessUnit
			,DocumentNumber
			,left(Reference, 70)
			,TranStatus
			,[Action]
			,CashflowType
			,Left(Account_Endur,20)
			,[Partner]
			,VAT_Script
			,VAT_CountryCode
			,InternalLegalEntity
			,Ticker
			,[Delivery Vessel Name]
			,[Static Ticket ID]
		FROM 
			[dbo].[base_realised_Endur_Recon_zw1]

		/*special rule for "cashflow Route Fee" which shall be treated as Brokerage, see CR2019_01*/
		select @step = 2		
		if @LogInfo >= 1  BEGIN insert into [dbo].[Logfile] select 'Reconciliation - ' + @proc + ': update recongroup 1', GETDATE () END
		
		UPDATE [dbo].[recon_zw1] 
			SET [ReconGroup] = 'Brokerage'
		where 
			CashflowType in ('Route Fee', 'DMA Exchange Fee')
	
		
		/*special rule for Coal&Freight desk1*/
		select @step = 3
		if @LogInfo >= 1  BEGIN insert into [dbo].[Logfile] select 'Reconciliation - ' + @proc + ': update recongroup 2', GETDATE () END

		UPDATE [dbo].[recon_zw1] 
		SET ReconGroup = 'Bunker Roll - External' 
		where 
			Recongroup = 'Secondary Cost' 
			AND 
			(
				[instrumenttype] = 'OIL-BUNKER-ROLL-P' 
				or 
				(
					[instrumenttype] in ('TC-FWD','OIL-FWD')  
					AND [CashflowType] = 'Bunkers'
				)
			)

		/*special rule for Coal&Freight desk2*/
		select @step = 4
		if @LogInfo >= 1  BEGIN insert into [dbo].[Logfile] select 'Reconciliation - ' + @proc + ': update recongroup 3', GETDATE () END
		
		UPDATE [dbo].[recon_zw1] 
		SET [ReconGroup] = 'TC' 
		where 
				[instrumenttype] = 'TC-FWD' 
				and Account_Endur in ('4006163', '6018012','4006164','6010164')

		/*special rule for Coal&Freight desk3*/
		select @step = 5
		if @LogInfo >= 1  BEGIN insert into [dbo].[Logfile] select 'Reconciliation - ' + @proc + ': update recongroup 4', GETDATE () END

		UPDATE [dbo].[recon_zw1] 
			SET [ReconGroup] = 'TC-Bunkers' 
			where 
				[instrumenttype] = 'OIL-FWD' 
				and recon_zw1.Account_Endur in ('4006163', '6018012','4006164','6010164')

		/*special rule for Coal&Freight desk4*/	
		select @step = 6
		if @LogInfo >= 1  BEGIN insert into [dbo].[Logfile] select 'Reconciliation - ' + @proc + ': update ReconGroup 5', GETDATE () END

		UPDATE [dbo].[recon_zw1]
			SET [ReconGroup] = 
				case when Instrumenttype = 'OIL-BUNKER-ROLL-P' then 'BUNKER ROLL - ' else 
					case when Instrumenttype = 'OIL-FWD' then 'BUNKER OIL - ' else 
					case when Instrumenttype = 'TC-FWD' then 'TC - ' else 		
					case when Instrumenttype = 'FREIGHT-FWD' then 'VC - ' else 		
					case when Instrumenttype = 'COMM-FEE' then 'FEE - ' else '' end end end end 
				end + [dbo].map_ExtBunitExclude.[ReconGroup]
			from 
				[dbo].[recon_zw1] inner join [dbo].[map_extbunitexclude] 
				on [dbo].[recon_zw1].[ExternalBusinessUnit] =  [dbo].[map_extbunitexclude].[ExtBunit]
			where 
			recon_zw1.[source] = 'realised_script'

		select @step = 7
 
		--Update [dbo].[recon_zw1] -- auskommentiert am 11.08.2023 für April / Grant
		--	Set [DealID_Recon] = 'INV_LNG' 
		--	where 
		--		ExternalBusinessUnit = 'LNG_LOCATION BU'

		/*special rule for CAO CE*/
		select @step = 8
		if @LogInfo >= 1  BEGIN insert into [dbo].[Logfile] select 'Reconciliation - ' + @proc + ': update ReconGroup 6', GETDATE () END

		UPDATE [dbo].[recon_zw1] 
		SET [ReconGroup] = 'Brokerage'
			where 
				[source] = 'realised_script' 
				and ExternalPortfolio =  'DUMMY_CE'

		select @step = 9
		if @LogInfo >= 1  BEGIN insert into [dbo].[Logfile] select 'Reconciliation - ' + @proc + ': fill map_static_deal_data', GETDATE () END		
		truncate table dbo.map_static_deal_data

		insert into dbo.[map_static_deal_data] 
			(
				[Trade Deal Number] 
				,[Trade Reference Text] 
				,[Instrument Type Name]  
				,[Internal Portfolio Name]  
				,[External Portfolio Name] 
				,[Ext Business Unit Name] 
				,[Ext Legal Entity Name]  
				,[Index Group]
				,[CountryCode]
			)
			select  
				[Trade Deal Number]
				,max(left([Trade Reference Text],99))
				,max([Instrument Type Name])
				,max([Internal Portfolio Name])
				,max([External Portfolio Name]) 
				,max([Ext Business Unit Name])
				,max([Ext Legal Entity Name])
				,max([Index Group])
				,max(country)
			from 
				dbo.[01_realised_all]  
				inner join dbo.map_counterparty c on [01_realised_all].[Ext Business Unit Name] = c.ExtBunit
			where 
				[Ext Legal Entity Name] not in ('RWEST UK - PE', 'RWEST DE - PE') 
				and 
				(
					Exchange = 0 
					or [Instrument Type Name] like '%OPT%'
				)
			group by  
				[Trade Deal Number]

             --update for CS*/
             --special rule fo Endur deals settled in EnergX
             select @step = 10
             if @LogInfo >= 1  BEGIN insert into [dbo].[Logfile] select 'Reconciliation - ' + @proc + ': fill map_static_deal_data for CS', GETDATE () END


             insert into dbo.[map_static_deal_data] 
                    (
                           [Trade Deal Number] 
                           ,[Trade Reference Text] 
                           ,[Instrument Type Name]  
                           ,[Internal Portfolio Name]  
                           ,[External Portfolio Name] 
                           ,[Ext Business Unit Name] 
                           ,[Ext Legal Entity Name]  
                           ,[Index Group]
                           ,[CountryCode]
                    )
                    select  
                           c.[DealID_Recon]
                           ,NULL
                           ,max(c.InstrumentType)
                           ,NULL
                           ,NULL
                           ,max(c.[ExternalBusinessUnit])
                           ,max(p.ExtLegalEntity)
                           ,NULL
                           ,NULL
                    from dbo.map_CS_Contract c 
                           left join dbo.map_counterparty p on c.ExternalBusinessUnit = p.ExtBunit
                           left join dbo.[map_static_deal_data] r on r.[Trade Deal Number] = c.DealID_Recon
                    where
                           r.[Trade Deal Number] is null
                    group by  
                           c.[DealID_Recon]


		/*update for April on 24.11.2021 made by MBE, extended on 31.08.2022: added "HAI KUO Shipping" */		
		select @step = 16
		if @LogInfo >= 1  BEGIN insert into [dbo].[Logfile] select 'Reconciliation - ' + @proc + ': updates for TC', GETDATE () END

		update [dbo].[recon_zw1] 
			SET ReconGroup = 'TC' 
			where 
				[ExternalBusinessUnit] in 
					(
						'SHANDONG DEYUN SHIPPING BU'
						,'SHANDONG DEGUANG SHIPPING BU'
						,''
						,'SHANDONG DEXIANG SHIPPING BU'
						,'SHANDONG DERUI SHIPPING BU'
						,'SHANDONG DECHANG SHIPPING BU'
						,'SHANDONG DEHONG SHIPPING BU'
						,'SHANDONG DELONG SHIPPING BU'
						,'SHANDONG DEYU SHIPPING BU'
						,'SHANDONG DEFENG SHIPPING BU'
						,'SHANDONG DETAI BU'
						,'HAI KUO SHIPPING 2108B'
						,'HAI KUO SHIPPING 2109B'
					) 
					and InstrumentType in ('TC-OPT-CALL-P','TC-OPT-PUT-P')

		/*update for April on 11.01.2023 made by MBE on Request in the Mail from April 20.12.2022*/
		update [dbo].[recon_zw1] SET [dbo].[recon_zw1].ReconGroup = 'ORE POSBAL' where [ExternalBusinessUnit] = 'ORE_POSBAL_ZA BU' or [ExternalBusinessUnit] like 'ORE_POSBAL%'

END TRY

	BEGIN CATCH
		EXEC [dbo].[usp_GetErrorInfo] @proc, @step		
		BEGIN INSERT INTO [dbo].[Logfile] SELECT 'Reconciliation - ' + @proc + ' - FAILED', GETDATE () END
	END CATCH

GO

