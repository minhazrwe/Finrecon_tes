











CREATE PROCEDURE [dbo].[UpdateIdentifier] 
	AS
	BEGIN TRY
	
	-- define variables
		DECLARE @proc nvarchar(40)
		DECLARE @step Integer	
		DECLARE @LogInfo Integer
		
		select @proc =  Object_Name(@@PROCID)

		select @LogInfo = [dbo].[LogInfo].[LogInfo] from [dbo].[LogInfo]
		
		if @LogInfo >= 1 BEGIN insert into [dbo].[Logfile] select 'Reconciliation - ' + @proc + ' - START', GETDATE () END
				
		if @LogInfo >= 1 BEGIN insert into [dbo].[Logfile] select 'Reconciliation - ' + @proc + ': update statistics', GETDATE () END
		select @step =1
		exec [dbo].[UpdateStatistics] 
				
		if @LogInfo >= 1 BEGIN insert into [dbo].[Logfile] select 'Reconciliation - ' + @proc + ': update static data (EOY) - 1', GETDATE () END
		select @step =2
		update dbo.Recon_zw1
			set Recon_zw1.Reference = left(s.[Trade Reference Text],70),
					Recon_zw1.ExternalBusinessUnit = s.[Ext Business Unit Name],
					Recon_zw1.ExternalLegal = s.[Ext Legal Entity Name],
					Recon_zw1.ExternalPortfolio = s.[External Portfolio Name],
					Recon_zw1.InstrumentType = s.[Instrument Type Name],
					Recon_zw1.ProjIndexGroup = s.[Index Group],
					Recon_zw1.Portfolio = s.[Internal Portfolio Name],
					Recon_zw1.vat_countrycode = s.[countrycode]
			from 
				dbo.Recon_zw1 inner join dbo.map_static_deal_data_EOY s 
				on Recon_zw1.DealID = s.[Trade Deal Number]
			where 
				[source] in ('adj','sap_blank') 
				--or dealid_recon like 'V%'

		-- MBE 22.03.2023 to cover also the Deal_Recon ID
        if @LogInfo >= 1 BEGIN insert into [dbo].[Logfile] select 'Reconciliation - ' + @proc + ': update static data (EOY) - 2', GETDATE () END
        select @step =2
        update dbo.Recon_zw1
            set Recon_zw1.Reference = left(s.[Trade Reference Text],70),
                            Recon_zw1.ExternalBusinessUnit = s.[Ext Business Unit Name],
                            Recon_zw1.ExternalLegal = s.[Ext Legal Entity Name],
                            Recon_zw1.ExternalPortfolio = s.[External Portfolio Name],
                            Recon_zw1.InstrumentType = s.[Instrument Type Name],
                            Recon_zw1.ProjIndexGroup = s.[Index Group],
                            Recon_zw1.Portfolio = s.[Internal Portfolio Name],
                            Recon_zw1.vat_countrycode = s.[countrycode]
            from 
                    dbo.Recon_zw1 inner join dbo.map_static_deal_data_EOY s 
                    on Recon_zw1.DealID_recon = s.[Trade Deal Number]
            where 
                    [source] in ('adj','sap_blank') 
                    --or dealid_recon like 'V%'


		if @LogInfo >= 1 BEGIN insert into [dbo].[Logfile] select 'Reconciliation - ' + @proc + ': update static data - 1', GETDATE () END
		select @step =3
		update dbo.Recon_zw1
			set Recon_zw1.Reference = left(s.[Trade Reference Text],70),
					Recon_zw1.ExternalBusinessUnit = s.[Ext Business Unit Name],
					Recon_zw1.ExternalLegal = s.[Ext Legal Entity Name],
					Recon_zw1.ExternalPortfolio = s.[External Portfolio Name],
					Recon_zw1.InstrumentType = s.[Instrument Type Name],
					Recon_zw1.ProjIndexGroup = s.[Index Group],
					Recon_zw1.Portfolio = s.[Internal Portfolio Name],
					Recon_zw1.vat_countrycode = s.[countrycode]
			from 
				dbo.Recon_zw1 inner join dbo.map_static_deal_data s 
				on Recon_zw1.DealID = s.[Trade Deal Number]
			where 
				[source] in ('adj','sap_blank')  
				--or dealid_recon like 'V%'

		-- MBE 22.03.2023 to cover also the Deal_Recon ID
        if @LogInfo >= 1 BEGIN insert into [dbo].[Logfile] select 'Reconciliation - ' + @proc + ': update static data - 2', GETDATE () END
        select @step =3
        update dbo.Recon_zw1
            set Recon_zw1.Reference = left(s.[Trade Reference Text],70),
                            Recon_zw1.ExternalBusinessUnit = s.[Ext Business Unit Name],
                            Recon_zw1.ExternalLegal = s.[Ext Legal Entity Name],
                            Recon_zw1.ExternalPortfolio = s.[External Portfolio Name],
                            Recon_zw1.InstrumentType = s.[Instrument Type Name],
                            Recon_zw1.ProjIndexGroup = s.[Index Group],
                            Recon_zw1.Portfolio = s.[Internal Portfolio Name],
                            Recon_zw1.vat_countrycode = s.[countrycode]
            from 
                    dbo.Recon_zw1 inner join dbo.map_static_deal_data s 
                    on Recon_zw1.DealID_recon = s.[Trade Deal Number]
            where 
                    [source] in ('adj','sap_blank')  
                    --or dealid_recon like 'V%'

		if @LogInfo >= 1 BEGIN insert into [dbo].[Logfile] select 'Reconciliation - ' + @proc + ': update Deal ID Recon for CS', GETDATE () END
		UPDATE Recon_zw1
			SET [dbo].[Recon_zw1].[DealID_Recon] = [dbo].[map_cs_contract].[dealid_recon],
				[dbo].[Recon_zw1].[Adj_Comment] = 
							case when [dbo].[Recon_zw1].[Adj_Comment] is NULL or [dbo].[Recon_zw1].[source]  not in ('adj') then '' + '// updated dealID' 
								else [dbo].[Recon_zw1].[Adj_Comment] + '// updated Deal ID Recon for CS' end
			from [dbo].[Recon_zw1]  
				join [dbo].[map_cs_contract]  on 
							[dbo].[Recon_zw1].orderno = [dbo].[map_cs_contract].orderno and 
							[dbo].[Recon_zw1].ExternalBusinessUnit = [dbo].[map_cs_contract].ExternalBusinessUnit and 
							[dbo].[Recon_zw1].InstrumentType = [dbo].[map_cs_contract].InstrumentType

		
		/* Request from Anna Lena Maas - Change DealID_Recon for InstrumentType if the Desk is Intradesk and Instrumenttype like '%OPT%'; 26.03.2024 PG */
		if @LogInfo >= 1 BEGIN insert into [dbo].[Logfile] select 'Reconciliation - ' + @proc + ': update Deal ID Recon for Intradesk', GETDATE () END
		UPDATE Recon_zw1	
			SET [dbo].[Recon_zw1].[DealID_Recon] = [dbo].[Recon_zw1].[InstrumentType]
			FROM [dbo].[Recon_zw1]  
			WHERE [ReconGroup] = 'Intradesk' AND [InstrumentType] like '%OPT%'

        --if @LogInfo >= 1 BEGIN insert into [dbo].[Logfile] select 'Reconciliation - ' + @proc + ': update static data CS (EOY)', GETDATE () END
        --select @step =4
                           
        --update dbo.Recon_zw1
        --    set  Recon_zw1.ExternalBusinessUnit = s.[Ext Business Unit Name]
        --    from 
        --            dbo.Recon_zw1 inner join dbo.map_static_deal_data_EOY s 
        --            on Recon_zw1.DealID_Recon = s.[Trade Deal Number]
        --    where 
        --            dealid_recon like 'V%'
             
        --if @LogInfo >= 1 BEGIN insert into [dbo].[Logfile] select 'Reconciliation - ' + @proc + ': update static data CS', GETDATE () END
        --select @step =5
             
        --update dbo.Recon_zw1
        --    set  Recon_zw1.ExternalBusinessUnit = s.[Ext Business Unit Name]
        --    from 
        --            dbo.Recon_zw1 inner join dbo.map_static_deal_data s 
        --            on Recon_zw1.DealID_Recon = s.[Trade Deal Number]
        --    where 
        --            dealid_recon like 'V%'


		
		if @LogInfo >= 1  BEGIN insert into [dbo].[Logfile] select 'Reconciliation - ' + @proc + ': update InsType', GETDATE () END
		select @step =6
		UPDATE [dbo].[Recon_zw1]
			SET [InstrumentType] = 'TC-FWD'
			FROM 
				[dbo].[Recon_zw1] inner JOIN [dbo].[00_map_order] 
				ON [dbo].[Recon_zw1].[OrderNo] = [dbo].[00_map_order].[OrderNo]
			Where 
				desk in ('COAL AND FREIGHT DESK', 'BIOFUELS DESK')  
				and material in ('10154033','10154032','10148839') 
				and InstrumentType = ''

		if @LogInfo >= 1  BEGIN insert into [dbo].[Logfile] select 'Reconciliation - ' + @proc + ': update SF/BF DealID', GETDATE () END
		select @step =7
		UPDATE [dbo].[Recon_zw1]
			SET	[dealid_recon] = left(case when Desk in ('COAL AND FREIGHT DESK', 'BIOFUELS DESK') 
																				and InstrumentType in ('COAL-FWD','FREIGHT-FWD') 
																				AND ReconGroup not in ('Intradesk','InterPE','Secondary Cost') 
																				and source not in ('adj')
																			then  [dbo].[Recon_zw1].[dealid]  + ' // ' + case	when Recon_zw1.DeliveryVesselName is null 
																																															then 'Unknown' 
																																															else left(rtrim(Recon_zw1.DeliveryVesselName),12)  
																																												end  + ' // ' + case	when Recon_zw1.StaticTicketID  is null or Recon_zw1.StaticTicketID   = '' 
																																																							then '0' 
																																																							else rtrim(Recon_zw1.StaticTicketID)   
																																																				end 
																			else case when Desk in ('COAL AND FREIGHT DESK', 'BIOFUELS DESK', 'CAO UK')  
																								 AND ReconGroup in ('Secondary Cost') 
																								 and source not in ('adj')
																								then [dbo].[Recon_zw1].[dealid]  + ' // ' + cast(abs(convert(int,round(realised_ccy_Endur,2)) + convert(int,round(realised_ccy_SAP,2))) as nvarchar(50))
																								else [dbo].[Recon_zw1].[dealid_recon]  
																						end 
																			end ,80)
			FROM 
				[dbo].[Recon_zw1] inner JOIN [dbo].[00_map_order] 
				ON [dbo].[Recon_zw1].[OrderNo] = [dbo].[00_map_order].[OrderNo]

		/*special treatment for Solidfuels*/
		if @LogInfo >= 1  BEGIN insert into [dbo].[Logfile] select 'Reconciliation - ' + @proc + ': update ReconGroup', GETDATE () END
		select @step =8
		UPDATE [dbo].[Recon_zw1]
			SET	 [ReconGroup] = 'Demurrage/Dispatch'
			where 
				ReconGroup = 'Secondary Cost' 
				and (
							[Material] in ('10145240', '10145241', '10145264', '10145265', '10150680', '10150681') 
							or
							[CashflowType] in ('Coal Demurrage', 'Coal Despatch', 'Freight Demurrage', 'Freight Despatch')
						)

		/* Request from April on 15.01.2023 for Asia Pacific */
		UPDATE [dbo].[Recon_zw1]
			SET	 [ReconGroup] = 'Demurrage/Dispatch'
			where [Material] = '10287021'
			
		/*special treatment for options*/
		if @LogInfo >= 1  BEGIN insert into [dbo].[Logfile] select 'Reconciliation - ' + @proc + ': update delivery month for options', GETDATE () END
		select @step =9
		update dbo.Recon_zw1
			set deliverymonth = NewDL
			from 
				dbo.Recon_zw1 r inner join (	select 
																						dealid_recon
																						,max(deliverymonth) as NewDL 
																					from 
																						dbo.Recon_zw1 
																					where 
																						recongroup = 'Options' 
																						and source = 'SAP_blank' 
																					group by dealid_recon
																				) as dl on r.dealid_recon = dl.dealid_recon 
			where 
				r.recongroup = 'Options'

    if @LogInfo >= 1  BEGIN insert into [dbo].[Logfile] select 'Reconciliation - ' + @proc + ': Secondary Cost (CS)', GETDATE () END
		select @step =10
    UPDATE [dbo].[Recon_zw1]
			SET	[ReconGroup] = 'Secondary Cost'
      FROM 
				[dbo].[Recon_zw1] inner JOIN [dbo].[00_map_order] ON [dbo].[Recon_zw1].[OrderNo] = [dbo].[00_map_order].[OrderNo]
       where 
				desk in ('Industrial Sales') 
				and (
							Account_SAP in ('6060000') 
							or 
							Account_Endur in ('6060000')
						)

		if @LogInfo >= 1  BEGIN insert into [dbo].[Logfile] select 'Reconciliation - ' + @proc + ': Transportation (CS)', GETDATE () END
		select @step =11
    UPDATE [dbo].[Recon_zw1]
			SET [ReconGroup] = 'Transportation'
			FROM 
				[dbo].[Recon_zw1] inner JOIN [dbo].[00_map_order] 
				ON [dbo].[Recon_zw1].[OrderNo] = [dbo].[00_map_order].[OrderNo]
			where 
				desk in ('COMMODITY SOLUTIONS') 
				and (
							Account_SAP in ('6070030') 
							or Account_Endur in ('6070030')
						)

		/*this is an artificial identifier for the deals*/
		if @LogInfo >= 1  BEGIN insert into [dbo].[Logfile] select 'Reconciliation - ' + @proc + ': update Identifier', GETDATE () END	
		select @step =12	
		UPDATE  [dbo].[Recon_zw1]
			SET [Identifier]= isnull([recongroup],'')			+ ' // ' 
											+ isnull([OrderNo],'')				+ ' // ' 
											+ isnull([DeliveryMonth],'')	+ ' // ' 
											+ isnull([DealID_Recon],'')		+ ' // ' 
											+ isnull([ccy],'')						+ ' // ' 
											+ isnull([Account_Endur],[Account_SAP])	+ ' // '
											+ ISNULL([Portfolio_ID],'')


		if @LogInfo >= 1 BEGIN insert into [dbo].[Logfile] select 'Reconciliation - ' + @proc + ' - FINISHED', GETDATE () END
END TRY

	BEGIN CATCH
		EXEC [dbo].[usp_GetErrorInfo] @proc, @step		
		BEGIN insert into [dbo].[Logfile] select @proc + ' - FAILED', GETDATE () END
	END CATCH

GO

