






CREATE VIEW [dbo].[view_VM_NETTING_5_Report_VM_for_LiquidityAndRisk]
AS
SELECT 
	BODataType
	,[HedgeExtern] As [Accounting]			--Hedge/Extern
	,[FTSubsidiary] AS [Subsidiary]
	,FTStrategy AS Strategy
	,FTProductYearTermEnd AS Productyear
	,[FTInternalPortfolio] AS id1
	,FTCounterpartyGroup AS id2
	,FTInstrumentType AS id3
	,FTProjIndexGroup AS id4 
	,CASE 
		WHEN [FTExtlegalentity] IN (
				'BNP PARIBAS(CLEAR)'
				,'BNP PARIBAS'
				)
			THEN 'BNP PARIBAS CLEAR'
		ELSE CASE 
				WHEN [FTExtlegalentity] IN ('SGNUK","CME GROUP","SGIL')
					THEN 'SOCGEN'
				ELSE CASE 
						WHEN [FTExtlegalentity] IN ('NASDAQ CLEARING AB')
							THEN 'NASDAQ OMX'
						ELSE [FTExtlegalentity] + '_' + [BOCurrency]
						END
				END
		END AS Extlegal                          --Logik aus alter Report_for_Controlling übernommen um ExtLEs umzubennennn
	,FTExtBusinessUnit AS ExtBusinessUnit
	,BOProduct AS InsReference
	,FTSummeVolumefinal AS Position
	,SUM([FinMtMtoNet]) AS MtM_gesamt                    
FROM [FinRecon].[dbo].[table_VM_NETTING_4_Analysis_incl_FT]
WHERE BONettingtype IN ('VM Netting') 
GROUP BY
	BODataType
	,[HedgeExtern]
	,[FTSubsidiary]
	,FTStrategy
	,FTProductYearTermEnd
	,[FTInternalPortfolio]
	,FTCounterpartyGroup
	,FTInstrumentType
	,FTProjIndexGroup
	,FTExtLegalEntity
	,FTExtBusinessUnit
	,BOProduct
	,FTSummeVolumefinal
	,[BOCurrency]

GO

