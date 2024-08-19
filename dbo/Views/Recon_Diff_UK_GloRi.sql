

CREATE view [dbo].[Recon_Diff_UK_GloRi] as 
SELECT InternalLegalEntity
	,Desk
	,Subdesk
	,ReconGroup
	,[dbo].[recon].[OrderNo]
	,DeliveryMonth
	,DealID_Recon
	,DealID
	,Account
	,ccy
	,Portfolio
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
	,CASE WHEN dbo.recon.Partner IS NULL THEN '/' ELSE dbo.recon.Partner END AS partner
	,CASE WHEN len(day(TradeDate)) = 1 THEN '0' + convert(VARCHAR, day(TradeDate)) ELSE convert(VARCHAR, day(TradeDate)) END + '.' + CASE WHEN len(month(TradeDate)) = 1 THEN '0' + convert(VARCHAR, month(TradeDate)) ELSE convert(VARCHAR, month(TradeDate)) END + '.' + convert(VARCHAR, year(TradeDate)) AS TradeDate
	,CASE WHEN len(day(EventDate)) = 1 THEN '0' + convert(VARCHAR, day(EventDate)) ELSE convert(VARCHAR, day(EventDate)) END + '.' + CASE WHEN len(month(EventDate)) = 1 THEN '0' + convert(VARCHAR, month(EventDate)) ELSE convert(VARCHAR, month(EventDate)) END + '.' + convert(VARCHAR, year(EventDate)) AS EventDate
	,SAP_DocumentNumber
	,Volume_Endur
	,Volume_SAP
	,Volume_Adj
	,UOM_Endur
	,UOM_SAP
	,realised_ccy_Endur
	,realised_ccy_SAP
	,realised_ccy_adj
	,DeskCcy
	,realised_deskccy_endur
	,realised_Deskccy_SAP
	,realised_deskccy_adj
	,realised_EUR_Endur
	,realised_EUR_SAP
	,realised_EUR_adj
	,Account_Endur
	,Account_SAP
	,round(Diff_Volume, 3) AS [Diff_Volume]
	,round(Diff_Realised_CCY, 2) AS [Diff_CCY]
	,round(Diff_Realised_DeskCCY, 2) AS [Diff_DeskCCY]
	,round(Diff_Realised_EUR, 2) AS [Diff_EUR]
	,Round(Abs([diff_realised_CCY]), 2) AS abs_diff_CCY
	,CASE WHEN eventdate > (
				SELECT [asofdate_eom]
				FROM dbo.asofdate
				) THEN 'future payment date' ELSE '' END AS PaymentDateInfo
	,'ACC ' + CASE WHEN [InstrumentType] IS NULL THEN '' ELSE replace([InstrumentType], '-STD', '') END + ';' + CASE WHEN [VAT_CountryCode] IS NULL THEN '' ELSE [VAT_CountryCode] END + ';' + CASE WHEN [ExternalBusinessUnit] IS NULL THEN '' ELSE [ExternalBusinessUnit] END + ';' + CASE WHEN [DeliveryMonth] IS NULL THEN '' ELSE [DeliveryMonth] END AS AccrualPostingText
	,VAT_CountryCode AS CountryCode
	,CASE WHEN [VAT_Script] IS NULL THEN '/' ELSE CASE WHEN [account] LIKE '4%'
					AND vat_script = 'D6' THEN [vat_script] ELSE '/' END END AS StKZ
	,CASE WHEN [diff_realised_ccy] > 0 THEN '50' ELSE CASE WHEN [diff_realised_ccy] < 0 THEN '40' ELSE CASE WHEN [diff_volume] < 0 THEN '40' ELSE '50' END END END AS [PK_PNL]
	,CASE WHEN [ReconGroup] = 'Physical Power'
			AND Month((
					SELECT [asofdate_eom]
					FROM dbo.asofdate
					)) IN (
				3
				,6
				,9
				,12
				)
			AND (
				d.[ExtLegalEntity] NOT IN (
					'RWEST CZ PE'
					,'RWEST DE - PE'
					,'RWEST UK - PE'
					,'RWEST ASIA PACIFIC PE'
					,'RWEST PARTICIPATIONS PE'
					,'RWE TS DE PE'
					,'RWE TS UK PE'
					,'RWE POWER'
					,'RWE GENERATION'
					,'INNOGY SPAIN'
					)
				OR d.[ExtLegalEntity] IS NULL
				) THEN Replace([account], '04', '01') ELSE [account] END AS [Account_PNL]
	,CASE WHEN (
				(d.[AccrualOnDebitor] = 1)
				AND (
					(
						d.ctpygroup = 'External'
						OR (
							d.[ExtLegalEntity] IN (
								'RWEST CZ PE'
								,'RWEST DE - PE'
								,'RWEST UK - PE'
								,'RWEST ASIA PACIFIC PE'
								,'RWEST PARTICIPATIONS PE'
								,'RWE TS DE PE'
								,'RWE TS UK PE'
								,'RWE POWER'
								,'RWE GENERATION'
								,'INNOGY SPAIN'
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
				) THEN (CASE WHEN [diff_realised_ccy] > 0 THEN '04' ELSE CASE WHEN [diff_realised_ccy] < 0 THEN '14' ELSE CASE WHEN [diff_volume] < 0 THEN '04' ELSE '14' END END END) ELSE (CASE WHEN [diff_realised_ccy] > 0 THEN '40' ELSE CASE WHEN [diff_realised_ccy] < 0 THEN '50' ELSE CASE WHEN [diff_volume] < 0 THEN '50' ELSE '40' END END END) END AS [PK_BS]
	,CASE WHEN (
				(d.[AccrualOnDebitor] = 1)
				AND (
					(
						d.ctpygroup = 'External'
						OR (
							d.[ExtLegalEntity] IN (
								'RWEST CZ PE'
								,'RWEST DE - PE'
								,'RWEST UK - PE'
								,'RWEST ASIA PACIFIC PE'
								,'RWEST PARTICIPATIONS PE'
								,'RWE TS DE PE'
								,'RWE TS UK PE'
								,'RWE POWER'
								,'RWE GENERATION'
								,'INNOGY SPAIN'
								)
							)
						)
					OR (
						Month((SELECT [asofdate_eom] FROM dbo.asofdate)) NOT IN (3,6,9,12)
						)
					)
				) THEN d.Debitor ELSE (CASE WHEN [diff_realised_ccy] > 0 THEN '1319901' ELSE CASE WHEN [diff_realised_ccy] < 0 THEN '3500008' ELSE CASE WHEN [diff_volume] < 0 THEN '3500008' ELSE '1319901' END END END) END AS [Account_BS]
	,d.UstID
	,recon.Material
	,MaterialDescription
	,Identifier
FROM (
	dbo.recon LEFT JOIN (
		SELECT partner
			,max(ctpygroup) AS ctpygroup
		FROM dbo.map_counterparty
		GROUP BY partner
		) AS c ON dbo.recon.partner = c.partner
	)
LEFT JOIN dbo.map_counterparty AS d ON dbo.recon.externalbusinessunit = d.extbunit
LEFT JOIN dbo.map_materialcode AS m ON dbo.recon.material = m.material
WHERE ReconGroup NOT IN ('prüfen','MTM','not relevant')
	AND ReconGroup NOT LIKE 'non-IAS%'
	AND InternalLegalentity NOT IN ('RWEST DE','RWEST CZ')
	AND (
				(
				abs([Diff_realised_ccy]) > 1
				OR 
				abs([Diff_realised_eur]) > 1
				)
			OR		 
				(
				--ExternalBusinessUnit like 'Umbuchung Menge%'
					abs([Diff_Volume])>1 and ReconGroup in ('Physical Exchange')
				)
			OR 
				(
					(
						eventdate > (
							SELECT [asofdate_eom]
							FROM dbo.asofdate
							)
						)
				)
				AND abs([Diff_realised_ccy]) <> 0
				AND abs([Diff_volume]) <> 0
			)

GO

