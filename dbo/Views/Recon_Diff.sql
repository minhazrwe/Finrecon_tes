



/*changes: 
2022/06/10: added 'RWE RENEWABLES' 
2023/04/06: added Entities 'RWE Kaskasi GmbH', 'WIND FARM ALLE' und 'WINDPARK EMME'
2024-01-09 MK: Changed Entities to list provided by Thomas Weber and Vincenzo Profeta
2024-07-22 MK: Added ';GAS-FEE;' for Desk = 'GPM Desk' AND [recongroup] = 'Secondary Cost'. Requested by Yvonne Neuhaeuser

*/
CREATE VIEW [dbo].[Recon_Diff]
AS
SELECT InternalLegalEntity
	,Desk
	,Subdesk
	,RevRecSubdesk
	,ReconGroup
	,[dbo].[recon].[OrderNo]
	,DeliveryMonth
	,DealID_Recon
	,Account
	,ccy
	,Portfolio
	,Portfolio_ID
	,CounterpartyGroup
	,InstrumentType
	,CashflowType
	,ProjIndexGroup
	,CurveName
	,ExternalLegal
	,ltrim(rtrim(ExternalBusinessUnit)) AS ExternalBusinessUnit
	,ExternalPortfolio
	,DocumentNumber
	,Reference
	,CASE 
		WHEN dbo.recon.Partner IS NULL
			THEN '/'
		ELSE dbo.recon.Partner
		END AS partner
	,[Ref3]
	+ CASE 
		WHEN [recongroup] IN ('Physical Gas','Swaps') THEN ';GAS;'
		WHEN Desk = 'GPM Desk' AND [recongroup] = 'Secondary Cost' THEN ';GAS-FEE;'
		ELSE ';PWR;'
	END
	+ CASE 
		WHEN c.[ctpygroup] = 'Internal' THEN 'INT'
		ELSE 'EXT'
	END AS RefFeld3
	,CASE 
		WHEN len(day(TradeDate)) = 1
			THEN '0' + convert(VARCHAR, day(TradeDate))
		ELSE convert(VARCHAR, day(TradeDate))
		END + '.' + CASE 
		WHEN len(month(TradeDate)) = 1
			THEN '0' + convert(VARCHAR, month(TradeDate))
		ELSE convert(VARCHAR, month(TradeDate))
		END + '.' + convert(VARCHAR, year(TradeDate)) AS TradeDate
	,CASE 
		WHEN len(day(EventDate)) = 1
			THEN '0' + convert(VARCHAR, day(EventDate))
		ELSE convert(VARCHAR, day(EventDate))
		END + '.' + CASE 
		WHEN len(month(EventDate)) = 1
			THEN '0' + convert(VARCHAR, month(EventDate))
		ELSE convert(VARCHAR, month(EventDate))
		END + '.' + convert(VARCHAR, year(EventDate)) AS EventDate
	,SAP_DocumentNumber
	,Volume_Endur
	,Volume_SAP
	,Volume_Adj
	,UOM_Endur
	,UOM_SAP
	,realised_ccy_Endur
	,realised_ccy_SAP
	,realised_ccy_adj
	,realised_EUR_Endur
	,realised_EUR_SAP
	,realised_EUR_adj
	,Account_Endur
	,Account_SAP
	,round(Diff_Volume, 3) AS Diff_Volume
	,round(Diff_Realised_CCY, 2) AS Diff_CCY
	,round(Diff_Realised_DeskCCY, 2) AS Diff_DeskCCY
	,round(Diff_Realised_EUR, 2) AS Diff_EUR
	,Round(Abs([diff_realised_EUR]), 2) AS abs_diff_EUR
	,CASE 
		WHEN eventdate > (
				SELECT [asofdate_eom]
				FROM dbo.asofdate
				)
			THEN 'future payment date'
		ELSE ''
		END AS PaymentDateInfo
	,CASE 
		WHEN recongroup = 'Exchanges'
			THEN [DealID_Recon]
		ELSE 'Schätz ' + CASE 
				WHEN [InstrumentType] IS NULL
					THEN ''
				ELSE replace([InstrumentType], '-STD', '')
				END
		END + ';' + CASE 
		WHEN [VAT_CountryCode] IS NULL
			THEN ''
		ELSE [VAT_CountryCode]
		END + ';' + CASE 
		WHEN [ExternalBusinessUnit] IS NULL
			THEN ''
		ELSE [ExternalBusinessUnit]
		END + ';' + CASE 
		WHEN [DeliveryMonth] IS NULL
			THEN ''
		ELSE [DeliveryMonth]
		END AS AccrualPostingText
	,VAT_CountryCode AS CountryCode
	,CASE 
		WHEN recon.recongroup = 'Exchanges'
			THEN CASE 
					WHEN recon.account LIKE '4%'
						THEN CASE 
								WHEN recon.InternalLegalEntity = 'RWEST DE'
									THEN 'N5'
								ELSE CASE 
										WHEN recon.InternalLegalEntity = 'RWEST UK'
											THEN '28'
										ELSE 'AN'
										END
								END
					ELSE CASE 
							WHEN recon.InternalLegalEntity = 'RWEST DE'
								THEN 'VM'
							ELSE CASE 
									WHEN recon.InternalLegalEntity = 'RWEST UK'
										THEN '88'
									ELSE 'VN'
									END
							END
					END
		ELSE CASE 
				WHEN InternalLegalEntity = 'RWEST CZ'
					THEN CASE 
							WHEN Diff_Realised_CCY < 0
								THEN 'VN'
							ELSE 'AN'
							END
				ELSE CASE 
						WHEN (
								[VAT_Script] IS NULL
								AND [vat_sap] IS NULL
								)
							THEN '/'
						ELSE CASE 
								WHEN [account] LIKE '4%'
									THEN CASE 
											WHEN (
													[vat_sap] IS NULL
													OR [realised_EUR_SAP] = 0
													)
												THEN [vat_script]
											ELSE [vat_sap]
											END
								ELSE CASE 
										WHEN c.[ctpygroup] = 'Internal'
											AND [vat_countrycode] = 'DE'
											THEN 'V4'
										ELSE 'VN'
										END
								END
						END
				END
		END AS StKZ
	,CASE 
		WHEN [diff_realised_ccy] > 0
			THEN '50'
		ELSE CASE 
				WHEN [diff_realised_ccy] < 0
					THEN '40'
				ELSE CASE 
						WHEN [diff_volume] < 0
							THEN '40'
						ELSE '50'
						END
				END
		END AS [BS_GUV]
	,CASE 
		WHEN [ReconGroup] = 'Physical Power'
			AND (
				d.[ExtLegalEntity] NOT IN (
					'Amrum-Offshore West GmbH'
					,'INNOGY SPAIN'
					,'INNOGY WINDPOWER NL'
					,'RWE GENERATION LE'
					,'RWE Kaskasi GmbH'
					,'RWE POWER'
					,'RWE RENEWABLES'
					,'RWE RENEWABLES EUROPE & AUSTRALIA'
					,'RWE RENEWABLES EUROPE & AUSTRALIA PE'
					,'RWE RENEWABLES IBERIA'
					,'RWE RENEWABLES ITALIA'
					,'RWE RENEWABLES POLAND'
					,'RWE TS DE PE'
					,'RWE TS UK PE'
					,'RWE WINDPOWER NL'
					,'RWEST ASIA PACIFIC PE'
					,'RWEST CZ PE'
					,'RWEST DE - PE'
					,'RWEST PARTICIPATIONS PE'
					,'RWEST UK - PE'
					,'WIND FARM ALLE'
					,'WINDPARK EMME'
					)
				OR d.[ExtLegalEntity] IS NULL
				)
			AND Month((
					SELECT [asofdate_eom]
					FROM dbo.asofdate
					)) IN (
				3
				,6
				,9
				,12
				)
			THEN Replace([account], '04', '01')
		ELSE [account]
		END AS [Konto_GUV]
	,CASE 
		WHEN (
				[internallegalentity] NOT IN ('RWEST CZ')
				AND (d.[AccrualOnDebitor] = 1)
				AND (
					(
						d.ctpygroup = 'External'
						OR (
							d.[ExtLegalEntity] IN (
								'Amrum-Offshore West GmbH'
								,'INNOGY SPAIN'
								,'INNOGY WINDPOWER NL'
								,'RWE GENERATION LE'
								,'RWE Kaskasi GmbH'
								,'RWE POWER'
								,'RWE RENEWABLES'
								,'RWE RENEWABLES EUROPE & AUSTRALIA'
								,'RWE RENEWABLES EUROPE & AUSTRALIA PE'
								,'RWE RENEWABLES IBERIA'
								,'RWE RENEWABLES ITALIA'
								,'RWE RENEWABLES POLAND'
								,'RWE TS DE PE'
								,'RWE TS UK PE'
								,'RWE WINDPOWER NL'
								,'RWEST ASIA PACIFIC PE'
								,'RWEST CZ PE'
								,'RWEST DE - PE'
								,'RWEST PARTICIPATIONS PE'
								,'RWEST UK - PE'
								,'WIND FARM ALLE'
								,'WINDPARK EMME'
								)
							)
						)
					OR (
						Month((
								SELECT [asofdate_eom]
								FROM dbo.asofdate
								)) NOT IN (
							3
							,6
							,9
							,12
							)
						)
					)
				)
			THEN (
					CASE 
						WHEN [diff_realised_ccy] > 0
							THEN '04'
						ELSE CASE 
								WHEN [diff_realised_ccy] < 0
									THEN '14'
								ELSE CASE 
										WHEN [diff_volume] < 0
											THEN '04'
										ELSE '14'
										END
								END
						END
					)
		ELSE (
				CASE 
					WHEN [diff_realised_ccy] > 0
						THEN '40'
					ELSE CASE 
							WHEN [diff_realised_ccy] < 0
								THEN '50'
							ELSE CASE 
									WHEN [diff_volume] < 0
										THEN '50'
									ELSE '40'
									END
							END
					END
				)
		END AS [BS_Bilanz]
	,CASE 
		WHEN InternalLegalEntity = 'RWEST CZ'
			THEN CASE 
					WHEN d.ctpygroup = 'Internal'
						THEN CASE 
								WHEN [diff_realised_ccy] > 0
									THEN '1320221'
								ELSE CASE 
										WHEN [diff_realised_ccy] < 0
											THEN '3540207'
										ELSE CASE 
												WHEN [diff_volume] < 0
													THEN '3540207'
												ELSE '1320221'
												END
										END
								END
					ELSE CASE 
							WHEN [diff_realised_ccy] > 0
								THEN '1319907'
							ELSE CASE 
									WHEN [diff_realised_ccy] < 0
										THEN '3500012'
									ELSE CASE 
											WHEN [diff_volume] < 0
												THEN '3500012'
											ELSE '1319907'
											END
									END
							END
					END
		ELSE CASE 
				WHEN (
						(d.[AccrualOnDebitor] = 1)
						AND (
							(
								d.ctpygroup = 'External'
								OR (
									d.[ExtLegalEntity] IN (
										'Amrum-Offshore West GmbH'
										,'INNOGY SPAIN'
										,'INNOGY WINDPOWER NL'
										,'RWE GENERATION LE'
										,'RWE Kaskasi GmbH'
										,'RWE POWER'
										,'RWE RENEWABLES'
										,'RWE RENEWABLES EUROPE & AUSTRALIA'
										,'RWE RENEWABLES EUROPE & AUSTRALIA PE'
										,'RWE RENEWABLES IBERIA'
										,'RWE RENEWABLES ITALIA'
										,'RWE RENEWABLES POLAND'
										,'RWE TS DE PE'
										,'RWE TS UK PE'
										,'RWE WINDPOWER NL'
										,'RWEST ASIA PACIFIC PE'
										,'RWEST CZ PE'
										,'RWEST DE - PE'
										,'RWEST PARTICIPATIONS PE'
										,'RWEST UK - PE'
										,'WIND FARM ALLE'
										,'WINDPARK EMME'
										)
									)
								)
							OR (
								Month((
										SELECT [asofdate_eom]
										FROM dbo.asofdate
										)) NOT IN (
									3
									,6
									,9
									,12
									)
								)
							)
						)
					THEN d.Debitor
				ELSE (
						CASE 
							WHEN [diff_realised_ccy] > 0
								THEN '1319901'
							ELSE CASE 
									WHEN [diff_realised_ccy] < 0
										THEN '3500008'
									ELSE CASE 
											WHEN [diff_volume] < 0
												THEN '3500008'
											ELSE '1319901'
											END
									END
							END
						)
				END
		END AS [Konto_Bilanz]
	,CASE 
		WHEN d.UstID IS NULL
			THEN '/'
		ELSE d.ustid
		END AS UStID
	,recon.VAT_CountryCode
	,Identifier
FROM (
	(
		dbo.recon LEFT JOIN (
			SELECT OrderNo
				,Max(Ref3) AS Ref3
			FROM dbo.map_order
			GROUP BY OrderNo
			) AS r ON dbo.recon.orderno = r.orderno
		) LEFT JOIN (
		SELECT partner
			,max(ctpygroup) AS ctpygroup
		FROM dbo.map_counterparty
		GROUP BY partner
		) AS c ON dbo.recon.partner = c.partner
	)
LEFT JOIN dbo.map_counterparty AS d ON dbo.recon.externalbusinessunit = d.extbunit
WHERE ReconGroup NOT IN (
		'prüfen'
		,'MTM'
		,'not relevant'
		)
	AND ReconGroup NOT LIKE 'non-IAS%'
	AND (
		(
			(
				abs([Diff_Volume]) > 1
				OR abs([Diff_realised_ccy]) > 1
				OR abs([Diff_realised_eur]) > 1
				)
			AND InternalLegalEntity NOT IN ('n/a')
			AND InternalLegalEntity NOT IN ('RWEST UK')
			)
		OR (
			(
				abs([Diff_Volume]) > 1
				OR abs([Diff_realised_ccy]) > 1
				OR abs([Diff_realised_Deskccy]) > 1
				OR abs([Diff_realised_eur]) > 1
				)
			AND InternalLegalEntity IN ('RWEST UK')
			)
		OR (SAP_DocumentNumber = '1100208687')
		)

GO

