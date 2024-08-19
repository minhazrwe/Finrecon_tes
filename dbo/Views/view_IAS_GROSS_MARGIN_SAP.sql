
--Changelog:
--2024/07/22: excluded 2 sap accounts from realised 'I5930031','I7960031' (PG)



CREATE view [dbo].[view_IAS_GROSS_MARGIN_SAP] as

-- unrealised Part

SELECT 'Unrealised_SAP' AS Query_Source, SAP.InternalLegalEntity, SAP.Desk, SAP.Subdesk, SAP.[Order], SAP.RevRecSubdesk, SAP.Portfolio, SAP.InstrumetType, SAP.recon_group AS ReconGroup, '' AS ExternalBusinessUnit, rtrim(CASE 
			WHEN (
					(
						[SAP].[DocumentType] IN ('RZ', 'WN', 'KN', 'DR', 'DG', 'AB', 'RN', 'ZM', 'ZA', 'AZ')
						OR (
							desk = 'Industrial Sales'
							AND left([sap].[text], 1) NOT IN (',', ';')
							)
						)
					AND (
						[sap].[text] NOT LIKE 'ACC%'
						AND [sap].[text] NOT LIKE 'Schätz%'
						AND [sap].[text] NOT LIKE 'Abgrenzung%'
						)
					)
				OR [recon_group] = 'Exchanges'
				THEN dbo.[udf_SplitData](Replace([SAP].[Text] + ',', ',', ';'), 1)
			ELSE CASE 
					WHEN [SAP].[Text] LIKE '%;%FUT%'
						OR [SAP].[Text] LIKE '%,%Fut%'
						THEN dbo.[udf_SplitData](Replace([SAP].[Text] + ',', ',', ';'), 1)
					ELSE CASE 
							WHEN [SAP].[TEXT] IS NULL
								THEN ''
							ELSE [SAP].[TEXT]
							END
					END
			END) + CASE 
		WHEN Desk IN ('COAL AND FREIGHT DESK')
			AND material = '10145238'
			THEN '_HandlingFees'
		ELSE ''
		END + CASE 
		WHEN Desk IN ('COAL AND FREIGHT DESK', 'BIOFUELS DESK')
			AND material = '10148926'
			THEN '_Demurrage'
		ELSE ''
		END + CASE 
		WHEN Desk IN ('COAL AND FREIGHT DESK', 'BIOFUELS DESK')
			AND material = '10063028'
			THEN '_Despatch'
		ELSE ''
		END AS DealID_Recon, DocumentNumber AS DocumentNumber_SAP, DocumentType AS DocumentType_SAP, SAP.Account AS Account_SAP, PostingDate AS PostingDate_SAP, EntryDate AS EntryDate_SAP, Reference AS Reference_SAP, [Text] AS [Text_SAP], sum(SAP.unrealised_EUR_SAP_PNL) AS SAP_EUR, sum(SAP.unrealised_EUR_SAP_conv_PNL) AS SAP_EUR_conv, sum(SAP.Volume_SAP) AS Volume_SAP
FROM (
	SELECT [00_map_order].[OrderNo] AS [Order], [00_map_order].LegalEntity AS InternalLegalEntity, [00_map_order].[Desk] AS Desk, [00_map_order].[Subdesk] AS Subdesk, [00_map_order].[RevRecSubDesk] AS RevRecSubdesk, [00_map_order].[MaxvonPortfolio] AS Portfolio, DocumentNumber, DocumentType, [Text], Reference, SAP.Account, PostingDate, EntryDate, [map_ReconGroupAccount].[recon_group], SAP.Quantity AS Volume, rtrim(CASE 
				WHEN [SAP].[DocumentType] IN ('RZ', 'WN', 'KN')
					THEN dbo.[udf_SplitData]([SAP].[Text], 3)
				ELSE CASE 
						WHEN (
								[SAP].[DocumentType] IN ('AB', 'RN', 'ZM', 'ZA', 'AZ')
								OR desk = 'Industrial Sales'
								)
							AND (
								Replace([Text] + ',', ',', ';') LIKE '%;%;%;%'
								OR [SAP].[Text] LIKE '%;%FUT%'
								OR [SAP].[Text] LIKE '%,%Fut%'
								)
							THEN dbo.[udf_SplitData]([SAP].[Text], 3)
						ELSE CASE 
								WHEN [SAP].[TEXT] IS NULL
									THEN ''
								ELSE [SAP].[TEXT]
								END + CASE 
								WHEN [SAP].[Account] IS NULL
									THEN ''
								ELSE [SAP].[Account]
								END
						END
				END) AS InstrumetType, Material, CASE 
			WHEN dbo.sap.LocalCurrency = 'EUR'
				AND dbo.SAP.Account <> 'I5999900'
				THEN dbo.[udf_NZ_FLOAT]((([SAP].[Amountinlocalcurrency]) * - 1))
			ELSE CASE 
					WHEN dbo.SAP.Account <> 'I5999900'
						THEN dbo.[udf_NZ_FLOAT]((([SAP].[Amountinlocalcurrency]) * - 1)) / fx4.Rate
					ELSE 0
					END
			END AS unrealised_EUR_SAP_PNL, CASE 
			WHEN dbo.SAP.Account <> 'I5999900'
				THEN dbo.[udf_NZ_FLOAT]((([SAP].[Amountindoccurr]) * - 1) / fx1.raterisk)
			ELSE 0
			END AS unrealised_EUR_SAP_conv_PNL, dbo.[udf_NZ_FLOAT]((
				CASE 
					WHEN (
							[SAP].[BaseUnitofMeasure] IN ('ST', 'PC')
							AND [SAP].[Account] NOT IN ('4008008', '4008005', '4006143', '6016757', '6010058', '6010143', '4006065', '6010065', '6010067', '4008112', '6010112')
							)
						THEN 0
					ELSE [SAP].[Quantity] * CASE 
							WHEN [map_UOM_conversion].[CONV] IS NULL
								THEN 1
							ELSE [map_UOM_conversion].[CONV]
							END
					END
				)) AS Volume_SAP
	FROM (
		(
			(
				(
					[SAP] LEFT JOIN [map_UOM_conversion]
						ON [SAP].[BaseUnitofMeasure] = [map_UOM_conversion].[UNIT_FROM]
					) LEFT JOIN [map_ReconGroupAccount]
					ON [SAP].[Account] = [map_ReconGroupAccount].[Account]
				) LEFT JOIN [00_map_order]
				ON (
						CASE 
							WHEN [SAP].[Order] IS NULL
								THEN ''
							ELSE [SAP].[Order]
							END
						) = [00_map_order].[OrderNo]
			) LEFT JOIN dbo.FXRates fx1
			ON dbo.sap.Documentcurrency = fx1.Currency
		)
	LEFT JOIN (
		SELECT currency, sum(rate) / count(deliverymonth) AS rate
		FROM dbo.fxrate, dbo.AsOfDate
		WHERE left(deliverymonth, 4) = year(dbo.asofdate.AsOfDate_EOM)
		GROUP BY currency
		) fx4
		ON dbo.sap.LocalCurrency = fx4.currency
	WHERE [recon_group] = 'MtM'
		AND (
			dbo.SAP.Account = 'I4006040'
			OR dbo.SAP.Account = 'I4006055'
			OR dbo.SAP.Account = 'I4006050'
			OR dbo.SAP.Account = 'I4006020'
			OR dbo.SAP.Account LIKE 'I5%'
			OR dbo.SAP.Account LIKE 'I6%'
			OR dbo.SAP.Account LIKE 'I7%'
			)
			--And dbo.SAP.Account Not IN ('I5930031','I7960031')
	) SAP
GROUP BY SAP.InternalLegalEntity, SAP.Desk, SAP.Subdesk, SAP.[Order], SAP.RevRecSubdesk, SAP.Portfolio, SAP.InstrumetType, SAP.recon_group, rtrim(CASE 
			WHEN (
					(
						[SAP].[DocumentType] IN ('RZ', 'WN', 'KN', 'DR', 'DG', 'AB', 'RN', 'ZM', 'ZA', 'AZ')
						OR (
							desk = 'Industrial Sales'
							AND left([sap].[text], 1) NOT IN (',', ';')
							)
						)
					AND (
						[sap].[text] NOT LIKE 'ACC%'
						AND [sap].[text] NOT LIKE 'Schätz%'
						AND [sap].[text] NOT LIKE 'Abgrenzung%'
						)
					)
				OR [recon_group] = 'Exchanges'
				THEN dbo.[udf_SplitData](Replace([SAP].[Text] + ',', ',', ';'), 1)
			ELSE CASE 
					WHEN [SAP].[Text] LIKE '%;%FUT%'
						OR [SAP].[Text] LIKE '%,%Fut%'
						THEN dbo.[udf_SplitData](Replace([SAP].[Text] + ',', ',', ';'), 1)
					ELSE CASE 
							WHEN [SAP].[TEXT] IS NULL
								THEN ''
							ELSE [SAP].[TEXT]
							END
					END
			END) + CASE 
		WHEN Desk IN ('COAL AND FREIGHT DESK')
			AND material = '10145238'
			THEN '_HandlingFees'
		ELSE ''
		END + CASE 
		WHEN Desk IN ('COAL AND FREIGHT DESK', 'BIOFUELS DESK')
			AND material = '10148926'
			THEN '_Demurrage'
		ELSE ''
		END + CASE 
		WHEN Desk IN ('COAL AND FREIGHT DESK', 'BIOFUELS DESK')
			AND material = '10063028'
			THEN '_Despatch'
		ELSE ''
		END, DocumentNumber, DocumentType, SAP.Account, PostingDate, EntryDate, Reference, [Text]

UNION ALL

--realised Part

--Abfrage realised_SAP direkt vom Recon_zw1 table

/*
SELECT 
	'Realised_SAP' as Query_Source
	,Max([dbo].[00_map_order].[LegalEntity]) AS InternalLegalEntity
	,Max([dbo].[00_map_order].[Desk]) AS Desk
	,Max([dbo].[00_map_order].[SubDesk]) AS SubDesk
	,Portfolio
	,InstrumentType
	,ReconGroup
	,ExternalBusinessUnit AS [External_Business_Unit]
	,DealID_Recon
	,DocumentNumber_SAP
	,DocumentType_SAP
	,Account_SAP
	,PostingDate
	,EntryDate
	,Reference_SAP
	,Text_SAP
	,sum(realised_EUR_SAP) AS realised_EUR_SAP
	,sum(realised_eur_sap_conv) AS realised_eur_sap_conv
	,sum([Volume_SAP]) AS Volume
FROM [dbo].[Recon_zw1]
LEFT JOIN [dbo].[00_map_order] ON [dbo].[Recon_zw1].[OrderNo] = [dbo].[00_map_order].[OrderNo]
LEFT JOIN (SELECT [dbo].[00_map_order].[LegalEntity] AS [InternalLegalEntity]
				  ,[DocumentNumber] 
				  ,[PostingDate]
				  ,[EntryDate]
		   FROM [dbo].[SAP] LEFT JOIN [dbo].[00_map_order] ON [dbo].[SAP].[Order] = [dbo].[00_map_order].[OrderNo]
		   GROUP BY [dbo].[00_map_order].[LegalEntity]
				    ,[DocumentNumber] 
				    ,[PostingDate]
				    ,[EntryDate]) s 
		   ON ([dbo].[Recon_zw1].[InternalLegalEntity] = s.[InternalLegalEntity]
		AND [dbo].[Recon_zw1].[DocumentNumber_SAP] = s.[DocumentNumber]
		)
LEFT join (Select distinct Document_Number from [table_GPM_Reverse_Engineering]) reverse_engineering
on [Recon_zw1].DocumentNumber_SAP = reverse_engineering.Document_Number
WHERE [source] = 'sap_blank' AND [Text_SAP] <> 'CZ FX RECLASS'
GROUP BY [LegalEntity]
    ,Desk
	,[SubDesk]
	,Portfolio
	,InstrumentType
	,ExternalBusinessUnit
	,DocumentNumber_SAP
	,DocumentType_SAP
	,Text_SAP
	,Reference_SAP
	,Account_SAP
	,PostingDate
	,EntryDate
	,DealID
	,DealID_Recon
	,ReconGroup
	,reverse_engineering.Document_Number
HAVING (abs(Sum(Recon_zw1.[Volume_Endur])) + abs(Sum(Recon_zw1.[Volume_SAP])) + abs(Sum(Recon_zw1.[Volume_Adj])) + abs(Sum(Recon_zw1.[realised_ccy_Endur])) + abs(Sum(Recon_zw1.[realised_ccy_SAP])) + abs(Sum(Recon_zw1.[realised_ccy_adj])) + abs(Sum(Recon_zw1.[realised_Deskccy_Endur])) + abs(Sum(Recon_zw1.[realised_Deskccy_SAP])) + abs(Sum(Recon_zw1.[realised_Deskccy_adj])) + abs(Sum([dbo].[Recon_zw1].[realised_EUR_Endur])) + abs(Sum([dbo].[Recon_zw1].[realised_EUR_SAP])) + abs(Sum([dbo].[Recon_zw1].[realised_EUR_adj]))) <> 0
*/


--Abfrage realised_SAP direkt vom SAP table


SELECT Query_Source, InternalLegalEntity, Desk, SubDesk, realisedSAP.[Order], Revrecsubdesk, Portfolio, InstrumentType, ReconGroup, ExternalBusinessUnit, DealID_Recon, DocumentNumber_SAP, DocumentType_SAP, Account_SAP, PostingDate_SAP, EntryDate_SAP, Reference_SAP, Text_SAP, sum(SAP_EUR) AS SAP_EUR, sum(SAP_EUR_conv) AS SAP_EUR_conv, sum(Volume_SAP) AS Volume_SAP
FROM (
	SELECT 'Realised_SAP' AS Query_Source, [dbo].[00_map_order].[OrderNo] AS [Order], [dbo].[00_map_order].[LegalEntity] AS InternalLegalEntity, [dbo].[00_map_order].[Desk] AS Desk, [dbo].[00_map_order].[SubDesk] AS SubDesk, [dbo].[00_map_order].[RevRecSubDesk] AS RevRecSubdesk, [dbo].[00_map_order].[MaxvonPortfolio] AS Portfolio, rtrim(CASE 
				WHEN [dbo].[SAP].[Text] LIKE 'DE;%;%'
					THEN [dbo].[udf_SplitData]([dbo].[SAP].[Text], 2)
				ELSE CASE 
						WHEN [dbo].[SAP].[Text] LIKE 'GB%;%;%'
							THEN [dbo].[udf_SplitData]([dbo].[SAP].[Text], 3)
						ELSE ''
						END
				END) AS InstrumentType, CASE 
			WHEN (
					[dbo].[SAP].[Text] LIKE '%brokerage%'
					OR [dbo].[SAP].[Text] LIKE '%;Commission;%'
					OR [dbo].[SAP].[Text] LIKE '%Clearingfee%'
					OR [dbo].[SAP].[Text] LIKE '%Rebate%'
					OR [dbo].[SAP].[Text] LIKE '%settlement fee%'
					OR [dbo].[SAP].[Text] LIKE '%;Fee Adj;Commission%'
					OR [dbo].[SAP].[Text] LIKE '%tradingfee%'
					OR [dbo].[SAP].[Text] LIKE '%Adj Fee adjustment%'
					)
				AND sap.Account NOT IN ('5998006', '7960006')
				OR (
					[dbo].[SAP].[Text] LIKE '%Griffin%'
					AND [dbo].[SAP].[Text] NOT LIKE '%GAZEXPORT GRIFFIN%'
					)
				THEN 'Brokerage'
			ELSE CASE 
					WHEN [dbo].[sap].[Material] IN ('10135932', '10134505', '10135931', '10135934', '10135933', '10153722', '10153721', '10153732', '10134506', '10154035', '10145269', '10289660')
						THEN 'Brokerage'
					ELSE CASE 
							WHEN [dbo].[SAP].[Text] LIKE '%Gate Cargo Losses%'
								THEN 'Gate Provision'
							ELSE CASE 
									WHEN [dbo].[sap].[Order] IN ('10052640', '10052641', '10052642', '10052961', '10052962', '10052964')
										THEN 'Non-Endur'
									ELSE CASE 
											WHEN ([dbo].[sap].[Order] IN ('10072440', '10053459'))
												OR (
													[dbo].[00_map_order].[LegalEntity] IN ('RWEST Japan', 'RWEST AP')
													AND [dbo].[SAP].[Account] IN ('6010149', '4006149')
													)
												THEN 'Brokerage'
											ELSE CASE 
													WHEN [dbo].[SAP].[Text] LIKE 'STK%'
														AND [dbo].[sap].[CompanyCode] IN (611, 632, 617, 619, 671, 634, 643, 671, 674, 646)
														THEN 'Inventories'
													ELSE CASE 
															WHEN [dbo].[SAP].[Text] LIKE 'REVAL GAIN%'
																OR [dbo].[SAP].[Text] LIKE 'REVAL LOSS%'
																OR [dbo].[SAP].[Text] LIKE 'Bewertung%'
																THEN 'Stock revaluation'
															ELSE CASE 
																	WHEN (
																			(
																				[dbo].[SAP].[Text] LIKE '%book value%'
																				AND [dbo].[sap].[CompanyCode] IN (611)
																				)
																			OR (
																				(
																					[dbo].[SAP].[Text] LIKE 'CAO,%'
																					OR [dbo].[SAP].[Text] LIKE 'CAO;%'
																					)
																				AND [dbo].[sap].[CompanyCode] IN (600)
																				)
																			)
																		THEN 'CAO cashout'
																	ELSE CASE 
																			WHEN [dbo].[SAP].[Text] LIKE 'ACC;TC Hire;%'
																				THEN 'TC - prior year'
																			ELSE [dbo].[map_ReconGroupAccount].[recon_group]
																			END
																	END
															END
													END
											END
									END
							END
					END
			END AS ReconGroup, rtrim(CASE 
				WHEN [dbo].[SAP].[DocumentType] IN ('RZ', 'WN', 'KN')
					THEN [dbo].[udf_SplitData]([dbo].[SAP].[Text], 3)
				ELSE CASE 
						WHEN (
								[dbo].[SAP].[DocumentType] IN ('AB', 'RN', 'ZM', 'ZA', 'AZ')
								OR desk = 'Industrial Sales'
								)
							AND (
								Replace([Text] + ',', ',', ';') LIKE '%;%;%;%'
								OR [dbo].[SAP].[Text] LIKE '%;%FUT%'
								OR [dbo].[SAP].[Text] LIKE '%,%Fut%'
								)
							THEN [dbo].[udf_SplitData]([dbo].[SAP].[Text], 3)
						ELSE CASE 
								WHEN [FinRecon].[dbo].[SAP].[TEXT] IS NULL
									THEN ''
								ELSE [FinRecon].[dbo].[SAP].[TEXT]
								END + CASE 
								WHEN [FinRecon].[dbo].[SAP].[Account] IS NULL
									THEN ''
								ELSE [FinRecon].[dbo].[SAP].[Account]
								END
						END
				END) AS ExternalBusinessUnit, rtrim(CASE 
				WHEN (
						(
							[dbo].[SAP].[DocumentType] IN ('RZ', 'WN', 'KN', 'DR', 'DG', 'AB', 'RN', 'ZM', 'ZA', 'AZ')
							OR (
								desk = 'Industrial Sales'
								AND left([dbo].[sap].[text], 1) NOT IN (',', ';')
								)
							)
						AND (
							[dbo].[sap].[text] NOT LIKE 'ACC%'
							AND [dbo].[sap].[text] NOT LIKE 'Schätz%'
							AND [dbo].[sap].[text] NOT LIKE 'Abgrenzung%'
							)
						)
					OR [dbo].[map_ReconGroupAccount].[recon_group] = 'Exchanges'
					THEN [dbo].[udf_SplitData](Replace([dbo].[SAP].[Text] + ',', ',', ';'), 1)
				ELSE CASE 
						WHEN [dbo].[SAP].[Text] LIKE '%;%FUT%'
							OR [dbo].[SAP].[Text] LIKE '%,%Fut%'
							THEN [dbo].[udf_SplitData](Replace([dbo].[SAP].[Text] + ',', ',', ';'), 1)
						ELSE CASE 
								WHEN [FinRecon].[dbo].[SAP].[TEXT] IS NULL
									THEN ''
								ELSE [FinRecon].[dbo].[SAP].[TEXT]
								END
						END
				END) + CASE 
			WHEN [dbo].[00_map_order].Desk IN ('SOLIDFUELS')
				AND material = '10145238'
				THEN '_HandlingFees'
			ELSE ''
			END + CASE 
			WHEN [dbo].[00_map_order].Desk IN ('SOLIDFUELS', 'BIOFUELS')
				AND material = '10148926'
				THEN '_Demurrage'
			ELSE ''
			END + CASE 
			WHEN [dbo].[00_map_order].Desk IN ('SOLIDFUELS', 'BIOFUELS')
				AND material = '10063028'
				THEN '_Despatch'
			ELSE ''
			END AS DealID_Recon, [dbo].[SAP].[DocumentNumber] AS DocumentNumber_SAP, left(dbo.sap.DocumentType, 2) AS DocumentType_SAP, [dbo].[SAP].[Account] AS [Account_SAP], dbo.sap.postingdate AS PostingDate_SAP, dbo.sap.[EntryDate] AS EntryDate_SAP, [dbo].[SAP].[Reference] AS Reference_SAP, [dbo].[SAP].[Text] AS Text_SAP, CASE 
			WHEN dbo.sap.LocalCurrency = 'EUR'
				THEN [dbo].[udf_NZ_FLOAT]((([dbo].[SAP].[Amountinlocalcurrency]) * - 1))
			ELSE [dbo].[udf_NZ_FLOAT]((([dbo].[SAP].[Amountinlocalcurrency]) * - 1)) / fx4.Rate
			END AS SAP_EUR, [dbo].[udf_NZ_FLOAT]((([dbo].[SAP].[Amountindoccurr]) * - 1) / fx1.raterisk) AS SAP_EUR_conv, [dbo].[udf_NZ_FLOAT]((
				CASE 
					WHEN (
							[dbo].[SAP].[BaseUnitofMeasure] IN ('ST', 'PC')
							AND [dbo].[SAP].[Account] NOT IN ('4008008', '4008005', '4006143', '6016757', '6010058', '6010143', '4006065', '6010065', '6010067', '4008112', '6010112')
							)
						THEN 0
					ELSE [dbo].[SAP].[Quantity] * CASE 
							WHEN [dbo].[map_UOM_conversion].[CONV] IS NULL
								THEN 1
							ELSE [dbo].[map_UOM_conversion].[CONV]
							END
					END
				)) AS Volume_SAP
	FROM (
		(
			(
				(
					[dbo].[SAP] LEFT JOIN [dbo].[map_UOM_conversion]
						ON [dbo].[SAP].[BaseUnitofMeasure] = [dbo].[map_UOM_conversion].[UNIT_FROM]
					) LEFT JOIN [dbo].[map_ReconGroupAccount]
					ON [dbo].[SAP].[Account] = [dbo].[map_ReconGroupAccount].[Account]
				) LEFT JOIN [dbo].[00_map_order]
				ON (isnull([dbo].[SAP].[Order], isnull([dbo].[SAP].[CostCenter], ''))) = [dbo].[00_map_order].[OrderNo]
			) LEFT JOIN dbo.FXRates fx1
			ON dbo.sap.Documentcurrency = fx1.Currency
		)
	LEFT JOIN (
		SELECT currency, sum(rate) / count(deliverymonth) AS rate
		FROM dbo.fxrate, dbo.AsOfDate
		WHERE left(deliverymonth, 4) = year(dbo.asofdate.AsOfDate_EOM)
		GROUP BY currency
		) fx4
		ON dbo.sap.LocalCurrency = fx4.currency
	WHERE (
			[recon_group] NOT IN ('zz - other - non trading', 'MtM')
			OR [recon_group] IS NULL
			OR TEXT LIKE 'REVAL GAIN%'
			OR TEXT LIKE 'REVAL LOSS%'
			)
		AND [dbo].[SAP].[account] NOT IN ('7960090')
		And dbo.SAP.Account Not IN ('I5930031','I7960031') -- new by PG 22/07/2024
	) realisedSAP
GROUP BY Query_Source, InternalLegalEntity, Desk, SubDesk, [Order], RevRecSubdesk, Portfolio, InstrumentType, ReconGroup, ExternalBusinessUnit, DealID_Recon, DocumentNumber_SAP, DocumentType_SAP, Account_SAP, PostingDate_SAP, EntryDate_SAP, Reference_SAP, Text_SAP

GO

