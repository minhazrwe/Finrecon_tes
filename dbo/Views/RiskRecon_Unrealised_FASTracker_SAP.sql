

/*
Change Log:
2023-09-08(MU) - Portfolio 'NG_VANILLA_OPTIONS_EUR' has been taken out on the desk/subdesk replacement as requested by Isk and April
*/

CREATE view [dbo].[RiskRecon_Unrealised_FASTracker_SAP] as
SELECT Desk
	,Subdesk
	,InternalPortfolio
	,InstrumetType
	,sum(ytd_mtm_finance_PNL_EUR) AS ytd_mtm_finance_PNL_EUR
	,sum(unrealised_EUR_SAP_PNL) AS unrealised_EUR_SAP_PNL
	,sum(unrealised_EUR_SAP_conv_PNL) AS unrealised_EUR_SAP_conv_PNL
	,sum(Diff_PNL_EUR) AS Diff_PNL_EUR
	,sum(ytd_mtm_finance_NOR_EUR) AS ytd_mtm_finance_NOR_EUR
	,sum(unrealised_EUR_SAP_NOR) AS unrealised_EUR_SAP_NOR
	,sum(unrealised_EUR_SAP_conv_NOR) AS unrealised_EUR_SAP_conv_NOR
	,sum(Diff_NOR_EUR) AS Diff_NOR_EUR
	,sum(ytd_mtm_finance_total_EUR) AS ytd_mtm_finance_total_EUR
	,sum(ytd_mtm_finance_OCI_EUR) AS ytd_mtm_finance_OCI_EUR
	,sum(ytd_mtm_finance_OU_EUR) AS ytd_mtm_finance_OU_EUR
	,sum(unrealised_Deskccy_SAP_PNL) AS unrealised_Deskccy_SAP_PNL
	,sum(unrealised_ccy_SAP_PNL) AS unrealised_ccy_SAP_PNL
	,sum(unrealised_Deskccy_SAP_NOR) AS unrealised_Deskccy_SAP_NOR
	,sum(unrealised_ccy_SAP_NOR) AS unrealised_ccy_SAP_NOR
	,sum(ytd_mtm_finance_total_DeskCCY) AS ytd_mtm_finance_total_DeskCCY
	,sum(ytd_mtm_finance_OCI_DeskCCY) AS ytd_mtm_finance_OCI_DeskCCY
	,sum(ytd_mtm_finance_PNL_DeskCCY) AS ytd_mtm_finance_PNL_DeskCCY
	,sum(ytd_mtm_finance_OU_DeskCCY) AS ytd_mtm_finance_OU_DeskCCY
	,sum(ytd_mtm_finance_NOR_DeskCCY) AS ytd_mtm_finance_NOR_DeskCCY
	,sum(Volume_SAP) AS Volume_SAP

FROM
(SELECT SAP.Desk
	,SAP.Subdesk
	,SAP.Portfolio AS InternalPortfolio
	,SAP.InstrumetType
	,- sum(SAP.unrealised_EUR_SAP_conv_PNL) AS Diff_PNL_EUR
	,- sum(SAP.unrealised_EUR_SAP_conv_NOR) AS Diff_NOR_EUR
	,- sum(SAP.unrealised_Deskccy_SAP_PNL) AS Diff_PNL_CCY
	,- sum(SAP.unrealised_Deskccy_SAP_NOR) AS Diff_NOR_CCY
	,sum(SAP.unrealised_EUR_SAP_PNL) AS unrealised_EUR_SAP_PNL
	,sum(SAP.unrealised_ccy_SAP_PNL) AS unrealised_ccy_SAP_PNL
	,sum(SAP.unrealised_Deskccy_SAP_PNL) AS unrealised_Deskccy_SAP_PNL
	,sum(SAP.unrealised_EUR_SAP_conv_PNL) AS unrealised_EUR_SAP_conv_PNL
	,sum(SAP.unrealised_EUR_SAP_NOR) AS unrealised_EUR_SAP_NOR
	,sum(SAP.unrealised_ccy_SAP_NOR) AS unrealised_ccy_SAP_NOR
	,sum(SAP.unrealised_Deskccy_SAP_NOR) AS unrealised_Deskccy_SAP_NOR
	,sum(SAP.unrealised_EUR_SAP_conv_NOR) AS unrealised_EUR_SAP_conv_NOR
	,sum(SAP.Volume_SAP) AS Volume_SAP
	,0 AS ytd_mtm_finance_total_EUR
	,0 AS ytd_mtm_finance_OCI_EUR
	,0 AS ytd_mtm_finance_PNL_EUR
	,0 AS ytd_mtm_finance_OU_EUR
	,0 AS ytd_mtm_finance_NOR_EUR
	,0 AS ytd_mtm_finance_total_DeskCCY
	,0 AS ytd_mtm_finance_OCI_DeskCCY
	,0 AS ytd_mtm_finance_PNL_DeskCCY
	,0 AS ytd_mtm_finance_OU_DeskCCY
	,0 AS ytd_mtm_finance_NOR_DeskCCY
FROM (
	SELECT [dbo].[00_map_order].[Desk] AS Desk
		,[dbo].[00_map_order].[Subdesk] AS Subdesk
		,[dbo].[00_map_order].[MaxvonPortfolio] AS Portfolio
		,rtrim(CASE WHEN [dbo].[SAP].[DocumentType] IN (
						'RZ'
						,'WN'
						,'KN'
						) THEN [dbo].[udf_SplitData]([dbo].[SAP].[Text], 3) ELSE CASE WHEN (
								[dbo].[SAP].[DocumentType] IN (
									'AB'
									,'RN'
									,'ZM'
									,'ZA'
									,'AZ'
									) OR desk = 'Industrial Sales'
								) AND (Replace([Text] + ',', ',', ';') LIKE '%;%;%;%' OR [dbo].[SAP].[Text] LIKE '%;%FUT%' OR [dbo].[SAP].[Text] LIKE '%,%Fut%') THEN [dbo].[udf_SplitData]([dbo].[SAP].[Text], 3) ELSE CASE WHEN [FinRecon].[dbo].[SAP].[TEXT] IS NULL THEN '' ELSE [FinRecon].[dbo].[SAP].[TEXT] END + CASE WHEN [FinRecon].[dbo].[SAP].[Account] IS NULL THEN '' ELSE [FinRecon].[dbo].[SAP].[Account] END END END) AS InstrumetType
		,'sap_blank' AS [source]
		,CASE WHEN dbo.sap.LocalCurrency = 'EUR' AND dbo.SAP.Account <> 'I5999900' THEN [dbo].[udf_NZ_FLOAT]((([dbo].[SAP].[Amountinlocalcurrency]) * - 1)) ELSE CASE WHEN dbo.SAP.Account <> 'I5999900' THEN [dbo].[udf_NZ_FLOAT]((([dbo].[SAP].[Amountinlocalcurrency]) * - 1)) / fx4.Rate ELSE 0 END END AS unrealised_EUR_SAP_PNL
		,CASE WHEN dbo.SAP.Account <> 'I5999900' THEN [dbo].[udf_NZ_FLOAT]((([dbo].[SAP].[Amountindoccurr]) * - 1)) ELSE 0 END AS unrealised_ccy_SAP_PNL
		,CASE WHEN dbo.SAP.Account <> 'I5999900' THEN [dbo].[udf_NZ_FLOAT]((([dbo].[SAP].[Amountindoccurr]) * - 1)) / fx1.RateRisk * fx2.rateRisk ELSE 0 END AS unrealised_Deskccy_SAP_PNL
		,CASE WHEN dbo.SAP.Account <> 'I5999900' THEN [dbo].[udf_NZ_FLOAT]((([dbo].[SAP].[Amountindoccurr]) * - 1) / fx1.raterisk) ELSE 0 END AS unrealised_EUR_SAP_conv_PNL
		,CASE WHEN dbo.sap.LocalCurrency = 'EUR' AND dbo.SAP.Account = 'I5999900' THEN [dbo].[udf_NZ_FLOAT]((([dbo].[SAP].[Amountinlocalcurrency]) * - 1)) ELSE CASE WHEN dbo.SAP.Account = 'I5999900' THEN [dbo].[udf_NZ_FLOAT]((([dbo].[SAP].[Amountinlocalcurrency]) * - 1)) / fx4.Rate ELSE 0 END END AS unrealised_EUR_SAP_NOR
		,CASE WHEN dbo.SAP.Account = 'I5999900' THEN [dbo].[udf_NZ_FLOAT]((([dbo].[SAP].[Amountindoccurr]) * - 1)) ELSE 0 END AS unrealised_ccy_SAP_NOR
		,CASE WHEN dbo.SAP.Account = 'I5999900' THEN [dbo].[udf_NZ_FLOAT]((([dbo].[SAP].[Amountindoccurr]) * - 1)) / fx1.RateRisk * fx2.rateRisk ELSE 0 END AS unrealised_Deskccy_SAP_NOR
		,CASE WHEN dbo.SAP.Account = 'I5999900' THEN [dbo].[udf_NZ_FLOAT]((([dbo].[SAP].[Amountindoccurr]) * - 1) / fx1.raterisk) ELSE 0 END AS unrealised_EUR_SAP_conv_NOR
		,[dbo].[udf_NZ_FLOAT](
				CASE WHEN (
							[dbo].[SAP].[BaseUnitofMeasure] IN (
								'ST'
								,'PC'
								) AND [dbo].[SAP].[Account] NOT IN (
								'4008008'
								,'4008005'
								,'4006143'
								,'6016757'
								,'6010058'
								,'6010143'
								,'4006065'
								,'6010065'
								,'6010067'
								,'4008112'
								,'6010112'
								)
							) THEN 0 ELSE [dbo].[SAP].[Quantity] * CASE WHEN [dbo].[map_UOM_conversion].[CONV] IS NULL THEN 1 ELSE [dbo].[map_UOM_conversion].[CONV] END END
				) AS Volume_SAP
	FROM [dbo].[SAP]
	LEFT JOIN [dbo].[map_UOM_conversion] ON [dbo].[SAP].[BaseUnitofMeasure] = [dbo].[map_UOM_conversion].[UNIT_FROM]
	LEFT JOIN [dbo].[map_ReconGroupAccount] ON [dbo].[SAP].[Account] = [dbo].[map_ReconGroupAccount].[Account]
	LEFT JOIN [dbo].[00_map_order] ON (CASE WHEN [dbo].[SAP].[Order] IS NULL THEN '' ELSE [dbo].[SAP].[Order] END) = [dbo].[00_map_order].[OrderNo]
	LEFT JOIN dbo.FXRates fx1 ON dbo.sap.Documentcurrency = fx1.Currency
	LEFT JOIN dbo.FXRates fx2 ON CASE WHEN ([00_map_order].repccy IS NULL OR [00_map_order].repccy = '') THEN [00_map_order].SubDeskCCY ELSE [00_map_order].repccy END = fx2.Currency
	LEFT JOIN dbo.FXRates fx3 ON dbo.[sap].LocalCurrency = fx3.Currency
	LEFT JOIN (
		SELECT currency
			,sum(rate) / count(deliverymonth) AS rate
		FROM dbo.fxrate
			,dbo.AsOfDate
		WHERE left(deliverymonth, 4) = year(dbo.asofdate.AsOfDate_EOM)
		GROUP BY currency
		) fx4 ON dbo.sap.LocalCurrency = fx4.currency
	WHERE [recon_group] = 'MtM' AND (dbo.SAP.Account LIKE 'I5%' OR dbo.SAP.Account LIKE 'I6%' OR dbo.SAP.Account LIKE 'I7%')
	) SAP
GROUP BY SAP.Desk
	,SAP.Subdesk
	,SAP.Portfolio
	,SAP.InstrumetType

UNION ALL

SELECT FT.Desk
	,FT.Subdesk
	,FT.InternalPortfolio AS InternalPortfolio
	,FT.InstrumentType
	,sum([ytd_mtm_finance_PNL_EUR]) AS Diff_PNL_EUR
	,sum([ytd_mtm_finance_NOR_EUR]) AS Diff_NOR_EUR
	,sum([ytd_mtm_finance_PNL_DeskCCY]) AS Diff_PNL_CCY
	,sum([ytd_mtm_finance_NOR_DeskCCY]) AS Diff_NOR_CCY
	,0 AS unrealised_EUR_SAP_PNL
	,0 AS unrealised_ccy_SAP_PNL
	,0 AS unrealised_Deskccy_SAP_PNL
	,0 AS unrealised_EUR_SAP_conv_PNL
	,0 AS unrealised_EUR_SAP_NOR
	,0 AS unrealised_ccy_SAP_NOR
	,0 AS unrealised_Deskccy_SAP_NOR
	,0 AS unrealised_EUR_SAP_conv_NOR
	,0 AS Volume_SAP
	,sum(ytd_mtm_finance_total_EUR) AS ytd_mtm_finance_total_EUR
	,sum([ytd_mtm_finance_OCI_EUR]) AS ytd_mtm_finance_OCI_EUR
	,sum([ytd_mtm_finance_PNL_EUR]) AS ytd_mtm_finance_PNL_EUR
	,sum([ytd_mtm_finance_OU_EUR]) AS ytd_mtm_finance_OU_EUR
	,sum([ytd_mtm_finance_NOR_EUR]) AS ytd_mtm_finance_NOR_EUR
	,sum(ytd_mtm_finance_total_DeskCCY) AS ytd_mtm_finance_total_DeskCCY
	,sum([ytd_mtm_finance_OCI_DeskCCY]) AS ytd_mtm_finance_OCI_DeskCCY
	,sum([ytd_mtm_finance_PNL_DeskCCY]) AS ytd_mtm_finance_PNL_DeskCCY
	,sum([ytd_mtm_finance_OU_DeskCCY]) AS ytd_mtm_finance_OU_DeskCCY
	,sum([ytd_mtm_finance_NOR_DeskCCY]) AS ytd_mtm_finance_NOR_DeskCCY
FROM (
	SELECT CASE WHEN (
					ft.internalportfolio IN (
						'NG_OPTION_DELTA_EUR'
						,'NG_OPTION_XCOMM_EUR'
						,'NG_OPTION_DELTA_GBP'
						,'NG_VANILLA_OPTIONS_GBP'
						)
					) THEN 'GPG - Global Options' ELSE ft.desk END AS Desk
		,CASE WHEN (
					ft.internalportfolio IN (
						'NG_OPTION_DELTA_EUR'
						,'NG_OPTION_XCOMM_EUR'
						,'NG_OPTION_DELTA_GBP'
						,'NG_VANILLA_OPTIONS_GBP'
						)
					) THEN 'GLOBAL OPTIONS ' + ft.SubDeskCCY ELSE ft.subdesk END AS Subdesk
		,ft.InternalPortfolio
		,ft.[Instrumenttype] AS [InstrumentType]
		,sum(ytd_mtm_finance_total) AS ytd_mtm_finance_total_EUR
		,sum([ytd_mtm_finance_OCI]) AS ytd_mtm_finance_OCI_EUR
		,sum([ytd_mtm_finance_PNL]) AS ytd_mtm_finance_PNL_EUR
		,sum([ytd_mtm_finance_OU]) AS ytd_mtm_finance_OU_EUR
		,sum([ytd_mtm_finance_NOR]) AS ytd_mtm_finance_NOR_EUR
		,sum(ytd_mtm_finance_total_DeskCCY) AS ytd_mtm_finance_total_DeskCCY
		,sum([ytd_mtm_finance_OCI_DeskCCY]) AS ytd_mtm_finance_OCI_DeskCCY
		,sum([ytd_mtm_finance_PNL_DeskCCY]) AS ytd_mtm_finance_PNL_DeskCCY
		,sum([ytd_mtm_finance_OU_DeskCCY]) AS ytd_mtm_finance_OU_DeskCCY
		,sum([ytd_mtm_finance_NOR_DeskCCY]) AS ytd_mtm_finance_NOR_DeskCCY
		,'FASTracker' AS [source]
	FROM (
		SELECT [Desk]
			,[Subdesk]
			,SubDeskCCY
			,[InternalPortfolio]
			,[InstrumentType]
			,total_mtm AS ytd_mtm_finance_total
			,PNL AS ytd_mtm_finance_PNL
			,OCI AS ytd_mtm_finance_OCI
			,ou AS ytd_mtm_finance_OU
			,NOR AS ytd_mtm_finance_NOR
			,total_mtm_DeskCCY AS ytd_mtm_finance_total_DeskCCY
			,PNL_deskccy AS ytd_mtm_finance_PNL_DeskCCY
			,OCI_DeskCCY AS ytd_mtm_finance_OCI_DeskCCY
			,OU_DeskCCY AS ytd_mtm_finance_OU_DeskCCY
			,NOR_DeskCCY AS ytd_mtm_finance_NOR_DeskCCY
		FROM dbo.Fastracker_eom
		
		UNION ALL
		
		SELECT [Desk]
			,[Subdesk]
			,SubDeskCCY
			,[InternalPortfolio]
			,[InstrumentType]
			,- total_mtm AS ytd_mtm_finance_total
			,- PNL AS ytd_mtm_finance_PNL
			,- OCI AS ytd_mtm_finance_OCI
			,- ou AS ytd_mtm_finance_OU
			,- nor AS ytd_mtm_finance_nor
			,- total_mtm_DeskCCY AS ytd_mtm_finance_total_DeskCCY
			,- PNL_deskccy AS ytd_mtm_finance_PNL_DeskCCY
			,- OCI_DeskCCY AS ytd_mtm_finance_OCI_DeskCCY
			,- OU_DeskCCY AS ytd_mtm_finance_OU_DeskCCY
			,- nor_DeskCCY AS ytd_mtm_finance_nor_DeskCCY
		FROM dbo.Fastracker_eoy
		) FT
	LEFT JOIN dbo.map_instrument i ON ft.instrumenttype = i.instrumenttype
		,dbo.asofdate
	GROUP BY CASE WHEN (
					ft.internalportfolio IN (
						'NG_OPTION_DELTA_EUR'
						,'NG_OPTION_XCOMM_EUR'
						,'NG_OPTION_DELTA_GBP'
						,'NG_VANILLA_OPTIONS_GBP'
						)
					) THEN 'GPG - Global Options' ELSE ft.desk END
		,CASE WHEN (
					ft.internalportfolio IN (
						'NG_OPTION_DELTA_EUR'
						,'NG_OPTION_XCOMM_EUR'
						,'NG_OPTION_DELTA_GBP'
						,'NG_VANILLA_OPTIONS_GBP'
						)
					) THEN 'GLOBAL OPTIONS ' + ft.SubDeskCCY ELSE ft.subdesk END
		,ft.InternalPortfolio
		,ft.[Instrumenttype]
	) FT
GROUP BY FT.Desk
	,FT.Subdesk
	,FT.InternalPortfolio
	,FT.InstrumentType
) Unrealised
GROUP BY Desk
	,Subdesk
	,InternalPortfolio
	,InstrumetType

GO

