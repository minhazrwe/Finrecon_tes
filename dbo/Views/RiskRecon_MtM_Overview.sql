






/*
Change Log:
2023-09-08 (MU) - Portfolio 'NG_VANILLA_OPTIONS_EUR' has been taken out on the desk/subdesk replacement as requested by Isk and April
2024-02-29 (MK) - Added RevRecSubdesk

*/






CREATE view [dbo].[RiskRecon_MtM_Overview] as
SELECT
	CASE 
		WHEN (
				ft.internalportfolio IN (
					'NG_OPTION_DELTA_EUR'
					,'NG_OPTION_XCOMM_EUR'
					,'NG_OPTION_DELTA_GBP'
					,'NG_VANILLA_OPTIONS_GBP'
					)
				)
			THEN 'GPG - Global Options'
		ELSE ft.desk
		END AS desk
	,CASE 
		WHEN (ft.internalportfolio IN ('NG_OPTION_DELTA_EUR','NG_OPTION_XCOMM_EUR','NG_OPTION_DELTA_GBP','NG_VANILLA_OPTIONS_GBP'))	THEN
			'GLOBAL OPTIONS ' + ft.SubDeskCCY
		WHEN mpo.RevRecSubDesk <> '' THEN
			mpo.RevRecSubDesk
		ELSE
			mpo.subdesk
		END AS subdesk
	,ft.InternalPortfolio
	,AccountingTreatment
	,CASE 
		WHEN b.ExtBunit IS NOT NULL
			THEN CASE 
					WHEN ft.Instrumenttype = 'OIL-BUNKER-ROLL-P'
						THEN 'BUNKER ROLL - '
					ELSE CASE 
							WHEN ft.Instrumenttype = 'OIL-FWD'
								THEN 'BUNKER OIL - '
							ELSE CASE 
									WHEN ft.Instrumenttype = 'TC-FWD'
										THEN 'TC - '
									ELSE CASE 
											WHEN ft.Instrumenttype = 'FREIGHT-FWD'
												THEN 'VC - '
											ELSE CASE 
													WHEN ft.Instrumenttype = 'COMM-FEE'
														THEN 'FEE - '
													ELSE ''
													END
											END
									END
							END
					END + b.ReconGroup
		ELSE CASE 
				WHEN ft.strategy = 'Power Continental'
					AND (
						I.nonvalueadded = 1
						OR ft.internalportfolio LIKE 'Credit%'
						OR ft.internalportfolio LIKE 'FV_%'
						)
					THEN 'x'
				ELSE CASE 
						WHEN sbma.allocationcomment IS NULL
							THEN ''
						ELSE sbma.allocationcomment
						END
				END
		END AS nonVA
	,CASE 
		WHEN TermEnd <= dbo.asofdate.[asofdate_eom]
			THEN 'Unwind'
		ELSE CASE 
				WHEN Year(TermEnd) = Year(dbo.asofdate.[asofdate_eom])
					THEN 'CurrentYear'
				ELSE CASE 
						WHEN Year(TermEnd) = Year(dbo.asofdate.[asofdate_eom]) + 1
							THEN 'NextYear'
						ELSE 'SecondNextYear_ff'
						END
				END
		END AS unwind
	,sum(mtm_finance_total) AS mtm_finance_total_EUR
	,sum(prevYE_mtm_finance_total) AS prevYE_mtm_finance_total_EUR
	,sum(mtm_finance_OCI) AS mtm_finance_OCI_EUR
	,sum(mtm_finance_PNL) AS mtm_finance_PNL_EUR
	,sum(mtm_finance_OU) AS mtm_finance_OU_EUR
	,sum(mtm_finance_NOR) AS mtm_finance_NOR_EUR
	,sum(ytd_mtm_finance_total) AS ytd_mtm_finance_total_EUR
	,sum([ytd_mtm_finance_OCI]) AS ytd_mtm_finance_OCI_EUR
	,sum([ytd_mtm_finance_PNL]) AS ytd_mtm_finance_PNL_EUR
	,sum([ytd_mtm_finance_OU]) AS ytd_mtm_finance_OU_EUR
	,sum([ytd_mtm_finance_NOR]) AS ytd_mtm_finance_NOR_EUR
	,sum(mtm_finance_total_DeskCCY) AS mtm_finance_total_DeskCCY
	,sum(prevYE_mtm_finance_total_DeskCCY) AS prevYE_mtm_finance_total_DeskCCY
	,sum(mtm_finance_OCI_DeskCCY) AS mtm_finance_OCI_DeskCCY
	,sum(mtm_finance_PNL_DeskCCY) AS mtm_finance_PNL_DeskCCY
	,sum(mtm_finance_OU_DeskCCY) AS mtm_finance_OU_DeskCCY
	,sum(mtm_finance_NOR_DeskCCY) AS mtm_finance_NOR_DeskCCY
	,sum(ytd_mtm_finance_total_DeskCCY) AS ytd_mtm_finance_total_DeskCCY
	,sum([ytd_mtm_finance_OCI_DeskCCY]) AS ytd_mtm_finance_OCI_DeskCCY
	,sum([ytd_mtm_finance_PNL_DeskCCY]) AS ytd_mtm_finance_PNL_DeskCCY
	,sum([ytd_mtm_finance_OU_DeskCCY]) AS ytd_mtm_finance_OU_DeskCCY
	,sum([ytd_mtm_finance_NOR_DeskCCY]) AS ytd_mtm_finance_NOR_DeskCCY
FROM dbo.fastracker_ytd ft
LEFT JOIN dbo.map_instrument i ON ft.instrumenttype = i.instrumenttype
LEFT JOIN dbo.map_sbm_allocation sbma ON ft.internalportfolio = sbma.internalportfolio
	AND ft.counterpartygroup = sbma.counterpartygroup
	AND ft.instrumenttype = sbma.instrumenttype
	AND ft.projindexgroup = sbma.projectionindexgroup
LEFT JOIN dbo.map_ExtBunitExclude b ON ft.externalbusinessunit = b.ExtBunit
LEFT JOIN dbo.[map_order] mpo ON ft.InternalPortfolio = mpo.Portfolio --added 19/02/2024 - SH
	,dbo.asofdate
GROUP BY CASE 
		WHEN (
				ft.internalportfolio IN (
					'NG_OPTION_DELTA_EUR'
					,'NG_OPTION_XCOMM_EUR'
					,'NG_OPTION_DELTA_GBP'
					,'NG_VANILLA_OPTIONS_GBP'
					)
				)
			THEN 'GPG - Global Options'
		ELSE ft.desk
		END
	,CASE 
		WHEN (ft.internalportfolio IN ('NG_OPTION_DELTA_EUR','NG_OPTION_XCOMM_EUR','NG_OPTION_DELTA_GBP','NG_VANILLA_OPTIONS_GBP'))	THEN
			'GLOBAL OPTIONS ' + ft.SubDeskCCY
		WHEN mpo.RevRecSubDesk <> '' THEN
			mpo.RevRecSubDesk
		ELSE
			mpo.subdesk
		END
	,ft.InternalPortfolio
	,sbma.allocationcomment
	,AccountingTreatment
	,CASE 
		WHEN b.ExtBunit IS NOT NULL
			THEN CASE 
					WHEN ft.Instrumenttype = 'OIL-BUNKER-ROLL-P'
						THEN 'BUNKER ROLL - '
					ELSE CASE 
							WHEN ft.Instrumenttype = 'OIL-FWD'
								THEN 'BUNKER OIL - '
							ELSE CASE 
									WHEN ft.Instrumenttype = 'TC-FWD'
										THEN 'TC - '
									ELSE CASE 
											WHEN ft.Instrumenttype = 'FREIGHT-FWD'
												THEN 'VC - '
											ELSE CASE 
													WHEN ft.Instrumenttype = 'COMM-FEE'
														THEN 'FEE - '
													ELSE ''
													END
											END
									END
							END
					END + b.ReconGroup
		ELSE CASE 
				WHEN ft.strategy = 'Power Continental'
					AND (
						I.nonvalueadded = 1
						OR ft.internalportfolio LIKE 'Credit%'
						OR ft.internalportfolio LIKE 'FV_%'
						)
					THEN 'x'
				ELSE CASE 
						WHEN sbma.allocationcomment IS NULL
							THEN ''
						ELSE sbma.allocationcomment
						END
				END
		END
	,CASE 
		WHEN TermEnd <= dbo.asofdate.[asofdate_eom]
			THEN 'Unwind'
		ELSE CASE 
				WHEN Year(TermEnd) = Year(dbo.asofdate.[asofdate_eom])
					THEN 'CurrentYear'
				ELSE CASE 
						WHEN Year(TermEnd) = Year(dbo.asofdate.[asofdate_eom]) + 1
							THEN 'NextYear'
						ELSE 'SecondNextYear_ff'
						END
				END
		END

GO

