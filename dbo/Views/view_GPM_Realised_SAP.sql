





















--Erstellt von MU für einen GPM Test mit Jan Sporing (2023-08-30)
CREATE view [dbo].[view_GPM_Realised_SAP] as
--Jan_Sporing_GPM_Realised_SAP

SELECT 
	'Realised_SAP' as Query_Source
	,Max([dbo].[00_map_order].[LegalEntity]) AS InternalLegalEntity
	,Max([dbo].[00_map_order].[Desk]) AS Desk
	,Max([dbo].[00_map_order].[SubDesk]) AS SubDesk
	,Portfolio
	,InstrumentType
	,ExternalBusinessUnit AS [External_Business_Unit]
	,DocumentNumber_SAP
	,Case when reverse_engineering.Document_Number is null then '0' else '1' end  as  Doc_In_Reverse_Engineering
	,DocumentType_SAP
	,Text_SAP
	,Reference_SAP
	,Account_SAP
	,PostingDate
	,EntryDate
	,DealID_Recon
	,DealID
	,ReconGroup
	,sum(realised_EUR_Endur) AS realised_EUR_Endur
	,sum(realised_EUR_SAP) AS realised_EUR_SAP
	,sum(realised_eur_sap_conv) AS realised_eur_sap_conv
	,sum([realised_EUR_adj]) AS [realised_EUR_adj]
	,sum([dbo].[Recon_zw1].[realised_eur_endur] - [dbo].[Recon_zw1].[realised_eur_sap_conv] - [dbo].[Recon_zw1].[realised_eur_adj]) AS Diff_EUR
	,sum([Volume_SAP]) AS Volume
	,0 AS risk_mtm_EOM_EUR
	,0 AS risk_mtm_EOY_EUR
	,0 AS risk_realised_disc_repEUR
	,0 AS risk_PNL_EUR
	,'' AS Category
	,'' AS [Opening_Closing]
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
WHERE Desk LIKE 'CAO G%' --and [Text_SAP] <> 'CZ FX RECLASS' funktioniert nicht
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

union all

select 
'Realised_SAP_Reverse_Engineering' as Query_Source
,map_order.LegalEntity AS InternalLegalEntity
,map_order.Desk
,map_order.Subdesk
,table_GPM_Reverse_Engineering.Portfolio
,Instrument_Type
,External_Business_Unit
,Document_Number
,'2' as Doc_In_Reverse_Engineering
,'' as DocumentType
,'' as Text
,'' as Reference
,'' as Account
,''as PostingDate
,'' as EntryDate
,table_GPM_Reverse_Engineering.DealID_Recon
,'' as DealID
,ReconGroup
,0 as ytd_mtm_finance_PNL_EUR
,Diff_EUR as unrealised_EUR_SAP_PNL
,Diff_EUR as unrealised_EUR_SAP_conv_PNL
,0 AS [realised_EUR_adj]
,-Diff_EUR as Diff_PNL_EUR
,0 as Volume
,0 AS risk_mtm_EOM_EUR
,0 AS risk_mtm_EOY_EUR
,0 AS risk_realised_disc_repEUR
,0 AS risk_PNL_EUR
,Category
,Opening_Closing
from table_GPM_Reverse_Engineering 
left join map_order ON table_GPM_Reverse_Engineering.Portfolio = map_order.Portfolio
where Category NOT IN ('MtM','CreditProvision')

GO

