


CREATE view [dbo].[base_realised_SAP_Recon_zw1] (
		Portfolio
		, portfolio_ID
		, InternalLegalEntity
		, DealID_Recon
		, Dealid
		, ExternalBusinessUnit
		, ExternalPortfolio
		, [source]
		, [Account_SAP]
		, ReconGroup
		, OrderNo
		, ccy
		, DeskCcy
		, [Partner]
		, UOM_SAP
		, DeliveryMonth
		, realised_EUR_SAP
		, realised_ccy_SAP
		, realised_Deskccy_SAP
		, realised_EUR_SAP_conv
		, Volume_SAP
		, InstrumentType
		, Text_SAP
		, Reference_SAP
		, DocumentNumber_SAP
		, VAT_SAP
		, postingdate
		, Material
		, refkey1
		, refkey2
		, refkey3
		, DocType
		, CountryCode ) AS 
	SELECT 
	[dbo].[00_map_order].[MaxvonPortfolio] as Portfolio, 

	iif(left(RefKey2,7) = '0000000',right(RefKey2,5), 
			iif(right(RefKey2,7) = '.000000',left(RefKey2,5),
				iif(left(RefKey2,1) ='V','',
					iif(ascii(left(RefKey2,1)) < 48 or ascii(left(RefKey2,1)) > 57  , '',
						iif( LEFT(refkey2,1) ='''', right(RefKey2,5),RefKey2 ))))) as  portfolio_ID,

	[dbo].[00_map_order].[LegalEntity]  AS InternalLegalEntity, 

	rtrim(case when (([dbo].[SAP].[DocumentType] In ('RZ','WN','KN','DR','DG','AB','RN','ZM', 'ZA', 'AZ') 
						or (desk = 'COMMODITY SOLUTIONS' and left([dbo].[sap].[text],1) not in (',',';')))
									and ([dbo].[sap].[text] not like 'ACC%' 
											and [dbo].[sap].[text] not like 'Schätz%' 
											and [dbo].[sap].[text] not like 'Abgrenzung%' 
											--and ([dbo].[sap].[Reference] not like '%SCHÄTZ%' 
													--or [dbo].[sap].[Reference] is null
													--)
											)
									)  
									or [dbo].[map_ReconGroupAccount].[recon_group] = 'Exchanges' 
							then [dbo].[udf_SplitData](Replace([dbo].[SAP].[Text] + ',', ',', ';'), 1) 
							
							else case when [dbo].[map_ReconGroupAccount].[recon_group] = 'Physical Exchange' then	--added 12.08.2024 by PG for Dennis and Edith
								[dbo].[udf_SplitData](Replace([dbo].[SAP].[Text] + ',', ',', ';'), 3)				--added 12.08.2024 by PG for Dennis and Edith

							else case when  [dbo].[SAP].[Text] Like '%;%FUT%' 
															Or [dbo].[SAP].[Text] Like '%,%Fut%' 
												then [dbo].[udf_SplitData](Replace([dbo].[SAP].[Text] + ',', ',', ';'), 1) 
												else case when [FinRecon].[dbo].[SAP].[TEXT] is NULL 
																	then '' 
																	else [FinRecon].[dbo].[SAP].[TEXT] 
																	end 
												end 
							end
				end																									--added 12.08.2024 by PG for Dennis and Edith
				)
			+ case when [dbo].[00_map_order].Desk in ('COAL AND FREIGHT DESK') AND  material = '10145238' then '_HandlingFees' else '' end
			+ case when [dbo].[00_map_order].Desk in ('COAL AND FREIGHT DESK','BIOFUELS DESK') AND  material = '10148926' then '_Demurrage' else '' end
			+ case when [dbo].[00_map_order].Desk in ('COAL AND FREIGHT DESK','BIOFUELS DESK') AND  material = '10063028' then '_Despatch' else '' end
			AS DealID_Recon, 

	rtrim(case when ([dbo].[SAP].[DocumentType] In ('RZ','WN','KN','DR','DG','AB','RN') and [dbo].[sap].[text] not like 'ACC%') or  [dbo].[map_ReconGroupAccount].[recon_group] = 'Exchanges' then [dbo].[udf_SplitData](Replace([dbo].[SAP].[Text] + ',', ',', ';'), 1) else
			case when  [dbo].[SAP].[Text] Like '%;%FUT%' Or [dbo].[SAP].[Text] Like '%,%Fut%' then [dbo].[udf_SplitData](Replace([dbo].[SAP].[Text] + ',', ',', ';'), 1) else 
			case when [FinRecon].[dbo].[SAP].[TEXT] is NULL then '' else [FinRecon].[dbo].[SAP].[TEXT] end end end) AS Dealid, 

	rtrim(case when [dbo].[SAP].[DocumentType] In ('RZ','WN','KN') then [dbo].[udf_SplitData]([dbo].[SAP].[Text],3) else
		case when ([dbo].[SAP].[DocumentType] In ('AB','RN','ZM', 'ZA','AZ') or desk = 'COMMODITY SOLUTIONS') And (Replace([Text] + ',',',',';') Like '%;%;%;%' 
			Or [dbo].[SAP].[Text] Like '%;%FUT%' Or [dbo].[SAP].[Text] Like '%,%Fut%') then [dbo].[udf_SplitData]([dbo].[SAP].[Text],3) else 
			case when [FinRecon].[dbo].[SAP].[TEXT] is NULL then '' else [FinRecon].[dbo].[SAP].[TEXT] end 
	+ case when [FinRecon].[dbo].[SAP].[Account] is NULL then '' else [FinRecon].[dbo].[SAP].[Account] end end end) AS ExternalBusinessUnit, 

	rtrim(case when [dbo].[SAP].[DocumentType] In ('AB','RN','KN') And (Replace([dbo].[SAP].[Text] + ',',',',';') Like '%;%;%;%') then [dbo].[udf_SplitData]([dbo].[SAP].[Text],4) end) AS ExternalPortfolio, 

	'sap_blank' AS [source], 
	[dbo].[SAP].[Account] as [Account_SAP], 

	case when ([dbo].[SAP].[Text] Like '%brokerage%' or [dbo].[SAP].[Text] Like '%;Commission;%' or [dbo].[SAP].[Text] Like '%Clearingfee%' or [dbo].[SAP].[Text] Like '%Rebate%' or [dbo].[SAP].[Text] Like '%settlement fee%' or [dbo].[SAP].[Text] Like '%;Fee Adj;Commission%' or [dbo].[SAP].[Text] Like '%tradingfee%' or [dbo].[SAP].[Text] Like '%Adj Fee adjustment%') and sap.Account not in ('5998006','7960006')
			 or ([dbo].[SAP].[Text] Like '%Griffin%' and [dbo].[SAP].[Text] not like '%GAZEXPORT GRIFFIN%') then 'Brokerage'  /* For some reason Counterparty Griffin should be always marked as brokerage; as it is part of a longer text Gazexport Griffin was included by mistake - this is corrected here (DS, MKB; 11/12/2020) */
	    else case when [dbo].[sap].[Material] in ('10135932', '10134505', '10135931', '10135934', '10135933', '10153722', '10153721', '10153732', '10134506','10154035','10145269','10289660') then 'Brokerage'
		else case when [dbo].[SAP].[Text] Like '%Gate Cargo Losses%' then 'Gate Provision' 
		else case when [dbo].[sap].[Order] in ('10052640', '10052641', '10052642', '10052961', '10052962', '10052964') then 'Non-Endur'
		-- MBE / SH geändert am 01.10.2021 für Brokerage ( Stefanie / April)
		else case when ([dbo].[sap].[Order] in ('10072440','10053459')) or ([dbo].[00_map_order].[LegalEntity] in ('RWEST Japan','RWEST AP') and [dbo].[SAP].[Account] in ('6010149','4006149') ) then 'Brokerage'
		--bis hierher
		else case when [dbo].[SAP].[Text] Like 'STK%' and [dbo].[sap].[CompanyCode] in (611, 632,617, 619, 671,634, 643, 671, 674, 646) then 'Inventories' 
		else case when [dbo].[SAP].[Text] Like 'REVAL GAIN%' or [dbo].[SAP].[Text] Like 'REVAL LOSS%' or [dbo].[SAP].[Text] Like 'Bewertung%' then 'Stock revaluation'
		else case when (([dbo].[SAP].[Text] like '%book value%' and [dbo].[sap].[CompanyCode] in (611)) or  (([dbo].[SAP].[Text] like 'CAO,%' or [dbo].[SAP].[Text] like 'CAO;%') and [dbo].[sap].[CompanyCode] in (600))) then 'CAO cashout'
		else case when [dbo].[SAP].[Text] Like 'ACC;TC Hire;%' then 'TC - prior year' 
		else case when [dbo].[SAP].[RefKey3] Like 'HOEGH ESPERANZ%' then 'Hoegh Esperanza BS'   /* added Hoegh Esperanza BS as Recong group , 2024-05-16 (MT) */
		else [dbo].[map_ReconGroupAccount].[recon_group]  end end end end end end end end end end AS ReconGroup, 

		case when [dbo].[SAP].[Order] = '10062183' then 'HS2027000' 
			else isnull([dbo].[SAP].[Order],isnull([dbo].[SAP].[CostCenter],''))
			end AS OrderNo, 

		[dbo].[SAP].[Documentcurrency] as ccy, 
		case when ([00_map_order].repccy is null or [00_map_order].repccy  = '') then [00_map_order].SubDeskCCY else [00_map_order].repccy end as Deskccy,

		([dbo].[SAP].[TradingPartner]) AS [Partner], 

		case when [dbo].[SAP].[BaseUnitofMeasure] in ('ST','PC') And [dbo].[SAP].[Account] Not In ('4011064', '4008008','4008005','4006143','6016757','6010058','6010143','4006065','6010065','6010067','4008112','6010112') 
			then '' else case when [dbo].[map_UOM_conversion].[CONV] is NULL then [dbo].[SAP].[BaseUnitofMeasure] else [dbo].[map_UOM_conversion].[Unit_to] end end AS UOM_SAP, 

		rtrim([dbo].[SAP].[Assignment]) as DeliveryMonth, 

		case when dbo.sap.LocalCurrency = 'EUR' then [dbo].[udf_NZ_FLOAT]((([dbo].[SAP].[Amountinlocalcurrency])*-1)) 
		else [dbo].[udf_NZ_FLOAT]((([dbo].[SAP].[Amountinlocalcurrency])*-1)) / fx4.Rate end AS realised_EUR_SAP, 

		[dbo].[udf_NZ_FLOAT]((([dbo].[SAP].[Amountindoccurr])*-1)) AS realised_ccy_SAP, 

		--case when SubDeskCCY='EUR' then [dbo].[udf_NZ_FLOAT]((([dbo].[SAP].[Amountinlocalcurrency])*-1)) / case when LocalCurrency <> 'EUR' then fx3.Rate else 1 end else
		--case when (LocalCurrency ='USD' and SubDeskCCY = 'USD') then [dbo].[udf_NZ_FLOAT]((([dbo].[SAP].[Amountinlocalcurrency])*-1)) else 
		[dbo].[udf_NZ_FLOAT]((([dbo].[SAP].[Amountindoccurr])*-1))/fx1.RateRisk*fx2.rateRisk   AS realised_Deskccy_SAP,

		[dbo].[udf_NZ_FLOAT]((([dbo].[SAP].[Amountindoccurr])*-1)/fx1.raterisk) AS realised_EUR_SAP_conv, 

				[dbo].[udf_NZ_FLOAT]((case when ([dbo].[SAP].[BaseUnitofMeasure] in ('ST','PC') And [dbo].[SAP].[Account] Not In ('4008008','4008005','4006143','6016757','6010058','6010143','4006065','6010065','6010067','4008112','6010112')) 
		then 0 else [dbo].[SAP].[Quantity] * case when [dbo].[map_UOM_conversion].[CONV] is NULL then 1 else [dbo].[map_UOM_conversion].[CONV] end end )) AS Volume_SAP, 

		rtrim(case when [dbo].[SAP].[Text] Like 'DE;%;%' then [dbo].[udf_SplitData]([dbo].[SAP].[Text],2) else case when [dbo].[SAP].[Text] Like 'GB%;%;%' then [dbo].[udf_SplitData]([dbo].[SAP].[Text],3) else '' end end)  AS InstrumentType, 

		[dbo].[SAP].[Text] as Text_SAP, 

		[dbo].[SAP].[Reference] as Reference_SAP, 

		[dbo].[SAP].[DocumentNumber] as DocumentNumber_SAP, 

		(case when [dbo].[SAP].[Taxcode] = 'VN' then '' else [dbo].[SAP].[Taxcode] end ) AS VAT_SAP,

		dbo.sap.postingdate, 
		
		dbo.sap.Material, 

		case when refkey1 is null then null else [dbo].[udf_SplitData](Replace(dbo.sap.RefKey1 + ',,', ',', ';'), 2)  end as refkey1,
		
		dbo.sap.RefKey2, 
		
		case when refkey3 is null then null else [dbo].[udf_SplitData](Replace(dbo.sap.RefKey3 + ',,', ',', ';'), 2)  end as refkey3,
		
		left(dbo.sap.DocumentType,2) as DocType,

				left([dbo].[udf_SplitData](Replace([dbo].[SAP].[Text] + ',,', ',', ';'), 2),2) as CountryCode

	FROM (
				(
					(
						(
							(
								([dbo].[SAP] LEFT JOIN [dbo].[map_UOM_conversion] 
									ON [dbo].[SAP].[BaseUnitofMeasure] = [dbo].[map_UOM_conversion].[UNIT_FROM]
								) LEFT JOIN [dbo].[map_ReconGroupAccount] 
									ON [dbo].[SAP].[Account] = [dbo].[map_ReconGroupAccount].[Account]
							) LEFT JOIN [dbo].[00_map_order] 
							--2023-07-17 (MU): Cost Center is needed for the brokerage report. 
							--2023-07-17 (MU): Some Costcenters are in the OrderNo column of map_order!
								ON (isnull([dbo].[SAP].[Order],isnull([dbo].[SAP].[CostCenter],''))) = [dbo].[00_map_order].[OrderNo]
						
						) LEFT JOIN dbo.FXRates fx1 
							ON  dbo.sap.Documentcurrency = fx1.Currency
					) LEFT JOIN dbo.FXRates fx2 
						ON  case when ([00_map_order].repccy is null 
												or [00_map_order].repccy  = '') 
											then [00_map_order].SubDeskCCY 
											else [00_map_order].repccy 
											end = fx2.Currency
					) LEFT JOIN dbo.FXRates fx3 
						ON  dbo.[sap].LocalCurrency = fx3.Currency
	     ) LEFT JOIN (
										select 
											currency, 
											sum(rate)/count(deliverymonth) as rate 
										from 
											dbo.fxrate, dbo.AsOfDate 
										where 
											left(deliverymonth,4) = year(dbo.asofdate.AsOfDate_EOM) 
										group by 
											currency
										) fx4 
										on dbo.sap.LocalCurrency = fx4.currency

	where 
		([recon_group] not in ('zz - other - non trading','MtM') 
		or [recon_group] is null 
		or text like 'REVAL GAIN%' 
		or text like 'REVAL LOSS%')
		AND [dbo].[SAP].[account] NOT IN ('7960090') -- MK: Added on 2023-09-15 by request of April

GO

