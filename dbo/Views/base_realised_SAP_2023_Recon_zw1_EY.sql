












CREATE view [dbo].[base_realised_SAP_2023_Recon_zw1_EY] (
		Desk
		,Portfolio
		, portfolio_ID
		, InternalLegalEntity
		, DealID_Recon
		, Dealid
		, ExternalBusinessUnit
		, ExternalPortfolio
		, [source]
		, [Account_SAP_2023]
		, ReconGroup
		, OrderNo
		, ccy
		, DeskCcy
		, [Partner]
		, UOM_SAP_2023
		, DeliveryMonth
		, realised_EUR_SAP_2023
		, realised_ccy_SAP_2023
		, realised_Deskccy_SAP_2023
		, realised_EUR_SAP_2023_conv
		, Volume_SAP_2023
		, InstrumentType
		, Text_SAP_2023
		, Reference_SAP_2023
		, DocumentNumber_SAP_2023
		, VAT_SAP_2023
		, postingdate
		, Material
		, refkey1
		, refkey2
		, refkey3
		, DocType
		, CountryCode ) AS 
	SELECT 
	[dbo].[00_map_order_EOY].[Desk] as Desk, 
	[dbo].[00_map_order_EOY].[MaxvonPortfolio] as Portfolio, 

	iif(left(RefKey2,7) = '0000000',right(RefKey2,5), 
			iif(right(RefKey2,7) = '.000000',left(RefKey2,5),
				iif(left(RefKey2,1) ='V','',
					iif(ascii(left(RefKey2,1)) < 48 or ascii(left(RefKey2,1)) > 57  , '',
						iif( LEFT(refkey2,1) ='''', right(RefKey2,5),RefKey2 ))))) as  portfolio_ID,

	[dbo].[00_map_order_EOY].[LegalEntity]  AS InternalLegalEntity, 

	rtrim(case when (([dbo].[SAP_2023].[DocumentType] In ('RZ','WN','KN','DR','DG','AB','RN','ZM', 'ZA', 'AZ') 
						or (desk = 'COMMODITY SOLUTIONS' and left([dbo].[SAP_2023].[text],1) not in (',',';')))
									and ([dbo].[SAP_2023].[text] not like 'ACC%' 
											and [dbo].[SAP_2023].[text] not like 'Schätz%' 
											and [dbo].[SAP_2023].[text] not like 'Abgrenzung%' 
											--and ([dbo].[SAP_2023].[Reference] not like '%SCHÄTZ%' 
													--or [dbo].[SAP_2023].[Reference] is null
													--)
											)
									)  
									or [dbo].[map_ReconGroupAccount].[recon_group] = 'Exchanges' 
							then [dbo].[udf_SplitData](Replace([dbo].[SAP_2023].[Text] + ',', ',', ';'), 1) 
							else case when  [dbo].[SAP_2023].[Text] Like '%;%FUT%' 
															Or [dbo].[SAP_2023].[Text] Like '%,%Fut%' 
												then [dbo].[udf_SplitData](Replace([dbo].[SAP_2023].[Text] + ',', ',', ';'), 1) 
												else case when [FinRecon].[dbo].[SAP_2023].[TEXT] is NULL 
																	then '' 
																	else [FinRecon].[dbo].[SAP_2023].[TEXT] 
																	end 
												end 
							end
				) 
			+ case when [dbo].[00_map_order_EOY].Desk in ('COAL AND FREIGHT DESK') AND  material = '10145238' then '_HandlingFees' else '' end
			+ case when [dbo].[00_map_order_EOY].Desk in ('COAL AND FREIGHT DESK','BIOFUELS DESK') AND  material = '10148926' then '_Demurrage' else '' end
			+ case when [dbo].[00_map_order_EOY].Desk in ('COAL AND FREIGHT DESK','BIOFUELS DESK') AND  material = '10063028' then '_Despatch' else '' end
			AS DealID_Recon, 

	rtrim(case when ([dbo].[SAP_2023].[DocumentType] In ('RZ','WN','KN','DR','DG','AB','RN') and [dbo].[SAP_2023].[text] not like 'ACC%') or  [dbo].[map_ReconGroupAccount].[recon_group] = 'Exchanges' then [dbo].[udf_SplitData](Replace([dbo].[SAP_2023].[Text] + ',', ',', ';'), 1) else
			case when  [dbo].[SAP_2023].[Text] Like '%;%FUT%' Or [dbo].[SAP_2023].[Text] Like '%,%Fut%' then [dbo].[udf_SplitData](Replace([dbo].[SAP_2023].[Text] + ',', ',', ';'), 1) else 
			case when [FinRecon].[dbo].[SAP_2023].[TEXT] is NULL then '' else [FinRecon].[dbo].[SAP_2023].[TEXT] end end end) AS Dealid, 

	rtrim(case when [dbo].[SAP_2023].[DocumentType] In ('RZ','WN','KN') then [dbo].[udf_SplitData]([dbo].[SAP_2023].[Text],3) else
		case when ([dbo].[SAP_2023].[DocumentType] In ('AB','RN','ZM', 'ZA','AZ') or desk = 'COMMODITY SOLUTIONS') And (Replace([Text] + ',',',',';') Like '%;%;%;%' 
			Or [dbo].[SAP_2023].[Text] Like '%;%FUT%' Or [dbo].[SAP_2023].[Text] Like '%,%Fut%') then [dbo].[udf_SplitData]([dbo].[SAP_2023].[Text],3) else 
			case when [FinRecon].[dbo].[SAP_2023].[TEXT] is NULL then '' else [FinRecon].[dbo].[SAP_2023].[TEXT] end 
	+ case when [FinRecon].[dbo].[SAP_2023].[Account] is NULL then '' else [FinRecon].[dbo].[SAP_2023].[Account] end end end) AS ExternalBusinessUnit, 

	rtrim(case when [dbo].[SAP_2023].[DocumentType] In ('AB','RN','KN') And (Replace([dbo].[SAP_2023].[Text] + ',',',',';') Like '%;%;%;%') then [dbo].[udf_SplitData]([dbo].[SAP_2023].[Text],4) end) AS ExternalPortfolio, 

	'SAP_2023_blank' AS [source], 
	[dbo].[SAP_2023].[Account] as [Account_SAP_2023], 

	case when ([dbo].[SAP_2023].[Text] Like '%brokerage%' or [dbo].[SAP_2023].[Text] Like '%;Commission;%' or [dbo].[SAP_2023].[Text] Like '%Clearingfee%' or [dbo].[SAP_2023].[Text] Like '%Rebate%' or [dbo].[SAP_2023].[Text] Like '%settlement fee%' or [dbo].[SAP_2023].[Text] Like '%;Fee Adj;Commission%' or [dbo].[SAP_2023].[Text] Like '%tradingfee%' or [dbo].[SAP_2023].[Text] Like '%Adj Fee adjustment%') and SAP_2023.Account not in ('5998006','7960006')
			 or ([dbo].[SAP_2023].[Text] Like '%Griffin%' and [dbo].[SAP_2023].[Text] not like '%GAZEXPORT GRIFFIN%') then 'Brokerage'  /* For some reason Counterparty Griffin should be always marked as brokerage; as it is part of a longer text Gazexport Griffin was included by mistake - this is corrected here (DS, MKB; 11/12/2020) */
	    else case when [dbo].[SAP_2023].[Material] in ('10135932', '10134505', '10135931', '10135934', '10135933', '10153722', '10153721', '10153732', '10134506','10154035','10145269','10289660') then 'Brokerage'
		else case when [dbo].[SAP_2023].[Text] Like '%Gate Cargo Losses%' then 'Gate Provision' 
		else case when [dbo].[SAP_2023].[Order] in ('10052640', '10052641', '10052642', '10052961', '10052962', '10052964') then 'Non-Endur'
		-- MBE / SH geändert am 01.10.2021 für Brokerage ( Stefanie / April)
		else case when ([dbo].[SAP_2023].[Order] in ('10072440','10053459')) or ([dbo].[00_map_order_EOY].[LegalEntity] in ('RWEST Japan','RWEST AP') and [dbo].[SAP_2023].[Account] in ('6010149','4006149') ) then 'Brokerage'
		--bis hierher
		else case when [dbo].[SAP_2023].[Text] Like 'STK%' and [dbo].[SAP_2023].[CompanyCode] in (611, 632,617, 619, 671,634, 643, 671, 674, 646) then 'Inventories' 
		else case when [dbo].[SAP_2023].[Text] Like 'REVAL GAIN%' or [dbo].[SAP_2023].[Text] Like 'REVAL LOSS%' or [dbo].[SAP_2023].[Text] Like 'Bewertung%' then 'Stock revaluation'
		else case when (([dbo].[SAP_2023].[Text] like '%book value%' and [dbo].[SAP_2023].[CompanyCode] in (611)) or  (([dbo].[SAP_2023].[Text] like 'CAO,%' or [dbo].[SAP_2023].[Text] like 'CAO;%') and [dbo].[SAP_2023].[CompanyCode] in (600))) then 'CAO cashout'
		else case when [dbo].[SAP_2023].[Text] Like 'ACC;TC Hire;%' then 'TC - prior year' 
		else [dbo].[map_ReconGroupAccount].[recon_group]  end end end end end end end end end AS ReconGroup, 

		case when [dbo].[SAP_2023].[Order] = '10062183' then 'HS2027000' 
			else isnull([dbo].[SAP_2023].[Order],isnull([dbo].[SAP_2023].[CostCenter],''))
			end AS OrderNo, 

		[dbo].[SAP_2023].[Documentcurrency] as ccy, 
		case when ([00_map_order_EOY].repccy is null or [00_map_order_EOY].repccy  = '') then [00_map_order_EOY].SubDeskCCY else [00_map_order_EOY].repccy end as Deskccy,

		([dbo].[SAP_2023].[TradingPartner]) AS [Partner], 

		case when [dbo].[SAP_2023].[BaseUnitofMeasure] in ('ST','PC') And [dbo].[SAP_2023].[Account] Not In ('4011064', '4008008','4008005','4006143','6016757','6010058','6010143','4006065','6010065','6010067','4008112','6010112') 
			then '' else case when [dbo].[map_UOM_conversion].[CONV] is NULL then [dbo].[SAP_2023].[BaseUnitofMeasure] else [dbo].[map_UOM_conversion].[Unit_to] end end AS UOM_SAP_2023, 

		rtrim([dbo].[SAP_2023].[Assignment]) as DeliveryMonth, 

		case when dbo.SAP_2023.LocalCurrency = 'EUR' then [dbo].[udf_NZ_FLOAT]((([dbo].[SAP_2023].[Amountinlocalcurrency])*-1)) 
		else [dbo].[udf_NZ_FLOAT]((([dbo].[SAP_2023].[Amountinlocalcurrency])*-1)) / fx4.Rate end AS realised_EUR_SAP_2023, 

		[dbo].[udf_NZ_FLOAT]((([dbo].[SAP_2023].[Amountindoccurr])*-1)) AS realised_ccy_SAP_2023, 

		--case when SubDeskCCY='EUR' then [dbo].[udf_NZ_FLOAT]((([dbo].[SAP_2023].[Amountinlocalcurrency])*-1)) / case when LocalCurrency <> 'EUR' then fx3.Rate else 1 end else
		--case when (LocalCurrency ='USD' and SubDeskCCY = 'USD') then [dbo].[udf_NZ_FLOAT]((([dbo].[SAP_2023].[Amountinlocalcurrency])*-1)) else 
		[dbo].[udf_NZ_FLOAT]((([dbo].[SAP_2023].[Amountindoccurr])*-1))/fx1.RateRisk*fx2.rateRisk   AS realised_Deskccy_SAP_2023,

		[dbo].[udf_NZ_FLOAT]((([dbo].[SAP_2023].[Amountindoccurr])*-1)/fx1.raterisk) AS realised_EUR_SAP_2023_conv, 

				[dbo].[udf_NZ_FLOAT]((case when ([dbo].[SAP_2023].[BaseUnitofMeasure] in ('ST','PC') And [dbo].[SAP_2023].[Account] Not In ('4008008','4008005','4006143','6016757','6010058','6010143','4006065','6010065','6010067','4008112','6010112')) 
		then 0 else [dbo].[SAP_2023].[Quantity] * case when [dbo].[map_UOM_conversion].[CONV] is NULL then 1 else [dbo].[map_UOM_conversion].[CONV] end end )) AS Volume_SAP_2023, 

		rtrim(case when [dbo].[SAP_2023].[Text] Like 'DE;%;%' then [dbo].[udf_SplitData]([dbo].[SAP_2023].[Text],2) else case when [dbo].[SAP_2023].[Text] Like 'GB%;%;%' then [dbo].[udf_SplitData]([dbo].[SAP_2023].[Text],3) else '' end end)  AS InstrumentType, 

		[dbo].[SAP_2023].[Text] as Text_SAP_2023, 

		[dbo].[SAP_2023].[Reference] as Reference_SAP_2023, 

		[dbo].[SAP_2023].[DocumentNumber] as DocumentNumber_SAP_2023, 

		(case when [dbo].[SAP_2023].[Taxcode] = 'VN' then '' else [dbo].[SAP_2023].[Taxcode] end ) AS VAT_SAP_2023,

		dbo.SAP_2023.postingdate, 
		
		dbo.SAP_2023.Material, 

		case when refkey1 is null then null else [dbo].[udf_SplitData](Replace(dbo.SAP_2023.RefKey1 + ',,', ',', ';'), 2)  end as refkey1,
		
		dbo.SAP_2023.RefKey2, 
		
		case when refkey3 is null then null else [dbo].[udf_SplitData](Replace(dbo.SAP_2023.RefKey3 + ',,', ',', ';'), 2)  end as refkey3,
		
		left(dbo.SAP_2023.DocumentType,2) as DocType,

				left([dbo].[udf_SplitData](Replace([dbo].[SAP_2023].[Text] + ',,', ',', ';'), 2),2) as CountryCode

	FROM (
				(
					(
						(
							(
								([dbo].[SAP_2023] LEFT JOIN [dbo].[map_UOM_conversion] 
									ON [dbo].[SAP_2023].[BaseUnitofMeasure] = [dbo].[map_UOM_conversion].[UNIT_FROM]
								) LEFT JOIN [dbo].[map_ReconGroupAccount] 
									ON [dbo].[SAP_2023].[Account] = [dbo].[map_ReconGroupAccount].[Account]
							) LEFT JOIN [dbo].[00_map_order_EOY] 
							--2023-07-17 (MU): Cost Center is needed for the brokerage report. 
							--2023-07-17 (MU): Some Costcenters are in the OrderNo column of map_order_EOY!
								ON (isnull([dbo].[SAP_2023].[Order],isnull([dbo].[SAP_2023].[CostCenter],''))) = [dbo].[00_map_order_EOY].[OrderNo]
						
						) LEFT JOIN dbo.FXRates fx1 
							ON  dbo.SAP_2023.Documentcurrency = fx1.Currency
					) LEFT JOIN dbo.FXRates fx2 
						ON  case when ([00_map_order_EOY].repccy is null 
												or [00_map_order_EOY].repccy  = '') 
											then [00_map_order_EOY].SubDeskCCY 
											else [00_map_order_EOY].repccy 
											end = fx2.Currency
					) LEFT JOIN dbo.FXRates fx3 
						ON  dbo.[SAP_2023].LocalCurrency = fx3.Currency
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
										on dbo.SAP_2023.LocalCurrency = fx4.currency

	where 
		([recon_group] not in ('zz - other - non trading','MtM') 
		or [recon_group] is null 
		or text like 'REVAL GAIN%' 
		or text like 'REVAL LOSS%')
		AND [dbo].[SAP_2023].[account] NOT IN ('7960090') -- MK: Added on 2023-09-15 by request of April

GO

