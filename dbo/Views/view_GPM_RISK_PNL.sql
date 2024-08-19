/****** Script for SelectTopNRows command from SSMS  ******/
CREATE view [dbo].[view_GPM_RISK_PNL] as
SELECT 'Risk' as Query_Source
	  ,[InternalLegalEntity]
      ,[Desk]
      ,[Subdesk]
      ,[SubdeskCCY]
      ,[Portfolio]
      ,[InstrumentType]
	  ,[ExtBunitName] AS External_Business_Unit
	  ,'' AS [DocumentNumber_SAP]
	  ,0 AS [Doc_In_Reverse_Engineering]
	  ,'' AS [DocumentType_SAP]
      ,'' AS [Text_SAP]
      ,'' AS [Reference_SAP]
      ,'' AS [Account_SAP]
      ,'' AS [PostingDate]
      ,'' AS [EntryDate]
      ,[DealID] AS [DealID_Recon]
      ,[DealID]
      ,'' AS [ReconGroup]
      ,0 AS 'Finance_EUR'
      ,0 AS 'SAP_EUR'
      ,0 AS 'SAP_EUR_conv'
      ,0 AS 'Adj_EUR'
      ,0 AS [Diff_EUR]
      ,0 AS [Volume]
	  ,sum(risk_mtm_EOM_EUR) AS risk_mtm_EOM_EUR
	  ,sum(risk_mtm_EOY_EUR) AS risk_mtm_EOY_EUR
	  ,sum(risk_realised_disc_repEUR) AS risk_realised_disc_repEUR
	  ,sum(risk_mtm_EOM_EUR)-sum(risk_mtm_EOY_EUR)+sum(risk_realised_disc_repEUR) AS risk_PNL_EUR
	  ,'' AS Category
	  ,'' AS Opening_Closing
FROM RiskRecon
WHERE Desk like 'CAO G%'
GROUP BY [InternalLegalEntity]
      ,[Desk]
      ,[Subdesk]
      ,[SubdeskCCY]
      ,[Portfolio]
      ,[InstrumentType]
	  ,[ExtBunitName] 
      ,[DealID]

GO

