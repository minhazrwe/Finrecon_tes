






/*=================================================================================================================
	author:		?
	created:	?
	purpose:	Prepare realised data for recon_zw1 table
-----------------------------------------------------------------------------------------------------------------
	Changes:
	2024-04-30, MK, Implemented DealID_Recon made out of Ticker Info on request by Anna-Lena Maas
	2024-05-29, MK, draged DealID recon condition for Instypes 'PWR-FWD-IFA-P', 'PWR-FWD-IFA-F' up, so they have a higher priority
	2024-06-20, MK, Deactivated addition of leg info in DealID_Recon for IFA deals. Info not desired in Identifier, risk of no match against SAP records.
	2024-06-24, MK, On request of Dennis additional condition was implemented. If Ticker Like "_MMM-YY" then use ticker as DealID_Recon.
=================================================================================================================*/


CREATE view [dbo].[base_realised_Endur_Recon_zw1] 
AS
SELECT
'realised_script' AS [Source]
,CASE 
	WHEN (c.[Exchange] = 'TRUE' AND r.[InstrumentType] LIKE '%SWAP%')
		THEN 'Exchanges'
	ELSE CASE 
			WHEN r.CashflowType = 'Broker Commission' OR r.[InternalPortfolio] = 'UKP_FEES'
				THEN 'Brokerage'
			ELSE g.[recon_group]
			END
	END AS ReconGroup
,r.[DeliveryMonth] AS DeliveryMonth
,CASE
	-- This Condition is an exception for US and IFA deals. They need to have the deal id in DealID_Recon.
	WHEN r.FileID IN ('3042','3269') THEN r.[Deal] 
	WHEN r.[Ticker] <> '' AND r.[Ticker] IS NOT NULL AND r.[Ticker] NOT IN ('not assigned') AND (i.[InstrumentGroup] NOT IN ('Option') OR [group] IN ('Intradesk')) THEN
		CASE
			--If record is recongroup = Exchanges then use logic below
			WHEN c.[Exchange] = 'TRUE' AND r.[InstrumentType] LIKE '%SWAP%' OR g.[recon_group] = 'Exchanges' THEN
				-- 2024-04-30 MK: Implemented on request by Anna-Lena Maas
				CASE
					WHEN [Ticker] LIKE 'ASX_%' THEN SUBSTRING([Ticker],5,2)
					WHEN [Ticker] LIKE 'LME_%' THEN SUBSTRING([Ticker],5,2) + 'D'
					WHEN [Ticker] LIKE '%SGX%' THEN 'SIM' + SUBSTRING([Ticker],5,4) + 'F'
					WHEN [Ticker] LIKE 'SHFE_%' THEN 'INE' + SUBSTRING([Ticker],6,3) + '_F'
					WHEN [Ticker] LIKE 'EEX_%' OR [Ticker] LIKE 'PWX_%' THEN SUBSTRING([Ticker],5,4)
					WHEN [Ticker] LIKE 'CEGH%' OR [Ticker] LIKE 'HUDX_%' THEN SUBSTRING([Ticker],6,4)
					WHEN [Ticker] LIKE 'PEGAS_%' THEN SUBSTRING([Ticker],7,4)
					WHEN [Ticker] LIKE 'ICE%' THEN
						CASE
							WHEN r.[Ticker] LIKE '%[_][a-z][a-z][a-z]-[0-9][0-9]' THEN LEFT([Ticker],3) + SUBSTRING([Ticker],7,3) + '_F'
							ELSE [Ticker]
						END
					WHEN [Ticker] LIKE 'COMEX%' THEN LEFT([Ticker],3) + SUBSTRING([Ticker],7,3) + '_F'
					WHEN [Ticker] LIKE 'NYM%' OR [Ticker] LIKE 'CME%' THEN LEFT([Ticker],3) + SUBSTRING([Ticker],5,3) + '_F'
					WHEN [Ticker] LIKE 'CBOT%' THEN 'CBT' + SUBSTRING([Ticker],6,3) + '_F'
					WHEN [Ticker] LIKE 'F%' THEN LEFT([Ticker],3) + 'W'
					WHEN [Ticker] LIKE 'DB%' THEN 'DEBD'
					ELSE [Ticker]
				END			
			ELSE [Ticker]
		END	
	--then 'INV' -- geändert am 22.02.2023 MBE
	WHEN ([group] IN ('InterPE') AND (i.[InstrumentGroup] NOT IN ('Option') OR i.[InstrumentGroup] IS NULL)) OR [group] IN ('Intradesk') THEN r.InstrumentType
	-- geändert am 01-09-2022 MBE --And [dbo].[Realised_all_details].[InstrumentType] <> 'COMM-FEE' 
	WHEN c.[Exchange] = 'TRUE' AND r.[InstrumentType] NOT LIKE '%OPT%' AND r.[InstrumentType] NOT IN ('CARBON ETO') THEN r.[ExternalBusinessUnit]
	ELSE r.[Deal]
END AS DealID_Recon
,r.Deal AS DealID
,r.[InternalPortfolio] AS portfolio
,o.PortfolioID AS Portfolio_ID
,r.[ctpygroup] AS CounterpartyGroup
,r.[InstrumentType] AS InstrumentType
,r.[ExternalBusinessUnit] AS ExternalBusinessUnit
,r.[ExternalLegalEntity] AS ExternalLegal
,r.[ExternalPortfolio] AS ExternalPortfolio
,r.[Commodity] AS ProjIndexGroup
,r.[ProjectionIndex] AS CurveName
,convert(DATE, r.[TradeDate], 104) AS TradeDate
,convert(DATE, r.[EventDate], 104) AS EventDate
,CASE 
	WHEN (r.[InstrumentType] IN ('REN-FWD-P') AND r.[Commodity] IN ('Other') OR r.[CashflowType] NOT IN ('Interest', 'n/a', 'Settlement', 'None', 'Commodity', 'eTax 1', 'IFA Dummy 0','IFA Dummy 1','IFA Dummy 2','IFA Dummy 3')) OR [UNIT_TO] IN ('Days') OR r.[SAP_Account] IN ('4008020', '6018020', '4011064')
		THEN 0
	ELSE r.[volume_new]
	END AS Volume_Endur
,r.[UNIT_TO] AS UOM_Endur
,r.[Currency] AS ccy
,r.[Realised] AS realised_ccy_Endur
,isnull(r.[Desk Currency]
,CASE 
	WHEN isnull(o.repccy, '') = '' THEN o.SubDeskCCY
	ELSE o.repccy
END) AS DeskCcy
/*2023-05-22 (MU): Replaced by own fx calculation because otherwise it creates a mismatch to the SAP calc value
since Rock uses the fx fwd rate to calculate the undisc euro value (approved by Sascha,Heike,April)*/
,r.[Realised] / fx.raterisk * fx2.raterisk AS realised_Deskccy_Endur
,r.[Realised] / fx.raterisk AS realised_EUR_Endur
,r.[OrderNo] AS OrderNo
,r.[InternalBusinessUnit] AS InternalBusinessUnit
,r.[DocumentNumber] AS DocumentNumber
,r.[Reference] AS Reference
,r.[Tran Status] AS TranStatus
,r.[Action] AS [Action]
,r.[CashflowType] AS CashflowType
,r.[SAP_Account] AS Account_Endur
,r.[Partner] AS [Partner]
,r.[StKZ] AS VAT_Script
,r.[VAT_CountryCode] AS VAT_CountryCode
,r.[LegalEntity] AS InternalLegalEntity
,CASE 
	WHEN r.[Ticker] NOT IN ('not assigned') THEN [Ticker]
	ELSE ''
END AS Ticker
,r.[Delivery Vessel Name]
,r.[Static Ticket ID]
FROM dbo.[02_Realised_all_details] r
LEFT JOIN dbo.[map_ReconGroupAccount] g ON r.SAP_Account = g.Account
LEFT JOIN dbo.[map_counterparty] c ON r.ExternalBusinessUnit = c.ExtBunit
LEFT JOIN dbo.[map_Instrument] i ON r.InstrumentType = i.InstrumentType
LEFT JOIN dbo.[map_order] o ON r.InternalPortfolio = o.Portfolio
LEFT JOIN dbo.[FXRates] fx ON r.currency = fx.currency
LEFT JOIN dbo.[FXRates] fx2 ON isnull(r.[Desk Currency],
CASE 
	WHEN isnull(o.repccy, '') = '' THEN o.SubDeskCCY
	ELSE o.repccy
END) = fx2.currency
WHERE (r.SAP_Account NOT IN ('n/a') OR r.SAP_Account IS NULL) AND r.OrderNo NOT IN ('n/a')

GO

