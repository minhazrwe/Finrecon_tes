








--Erstellt von MU für einen GPM Test mit Jan Sporing (2023-08-30)
CREATE view [dbo].[view_GPM_ALL_SAP] as
select [Query_Source]
      ,InternalLegalEntity
	  ,[Desk]
      ,[SubDesk]
      ,[Portfolio]
      ,[InstrumentType]
	  ,External_Business_Unit
      ,[DocumentNumber_SAP]
      ,[Doc_In_Reverse_Engineering]
      ,[DocumentType_SAP]
      ,[Text_SAP]
      ,[Reference_SAP]
      ,[Account_SAP]
      ,[PostingDate]
      ,[EntryDate]
      ,[DealID_Recon]
      ,[DealID]
      ,[ReconGroup]
      ,[realised_EUR_Endur] AS 'Finance_EUR'
      ,[realised_EUR_SAP] AS 'SAP_EUR'
      ,[realised_eur_sap_conv] AS 'SAP_EUR_conv'
      ,[realised_EUR_adj] AS 'Adj_EUR'
      ,[Diff_EUR]
      ,[Volume]
	  ,risk_mtm_EOM_EUR
	  ,risk_mtm_EOY_EUR
	  ,risk_realised_disc_repEUR
	  ,risk_PNL_EUR
	  ,Category
	  ,Opening_Closing
from view_GPM_Realised_SAP

union all

select [Query_Source]
	  ,InternalLegalEntity
      ,[Desk]
      ,[Subdesk]
      ,[InternalPortfolio]
      ,[InstrumetType]
	  ,External_Business_Unit
      ,[DocumentNumber]
      ,[Doc_In_Reverse_Engineering]
      ,[DocumentType]
      ,[Text]
      ,[Reference]
      ,[Account]
      ,[PostingDate]
      ,[EntryDate]
      ,[DealID_Recon]
      ,[DealID]
      ,[ReconGroup]
      ,[ytd_mtm_finance_PNL_EUR] AS 'Finance_EUR'
      ,[unrealised_EUR_SAP_PNL] AS 'SAP_EUR'
      ,[unrealised_EUR_SAP_conv_PNL] AS 'SAP_EUR_conv'
	  ,0 AS 'Adj_EUR'
      ,[Diff_PNL_EUR] AS [Diff_EUR]
      ,[Volume] 
	  ,risk_mtm_EOM_EUR
	  ,risk_mtm_EOY_EUR
	  ,risk_realised_disc_repEUR
	  ,risk_PNL_EUR
	  ,Category
	  ,Opening_Closing
from view_GPM_Unrealised_SAP

UNION ALL

select [Query_Source]
      ,InternalLegalEntity
	  ,[Desk]
      ,[SubDesk]
      ,[Portfolio]
      ,[InstrumentType]
	  ,External_Business_Unit
      ,[DocumentNumber_SAP]
      ,[Doc_In_Reverse_Engineering]
      ,[DocumentType_SAP]
      ,[Text_SAP]
      ,[Reference_SAP]
      ,[Account_SAP]
      ,[PostingDate]
      ,[EntryDate]
      ,[DealID_Recon]
      ,[DealID]
      ,[ReconGroup]
      ,Finance_EUR
      ,SAP_EUR
      ,SAP_EUR_conv
      ,Adj_EUR
      ,[Diff_EUR]
      ,[Volume]
	  ,risk_mtm_EOM_EUR
	  ,risk_mtm_EOY_EUR
	  ,risk_realised_disc_repEUR
	  ,risk_PNL_EUR
	  ,Category
	  ,Opening_Closing
from view_GPM_Risk_PNL

GO

