

CREATE view [dbo].[view_GPM_ALL] AS
(
SELECT     case 
					when [Intermediate_2_Name] like '% D%' 
							then 'CAO GAS DE'
					else case 
							when [Intermediate_2_Name] like '% CZ%' 
									then 'CAO GAS CZ' 
							else '' 
							END 
					END AS [Subdesk] 
          ,[Portfolio_Name] AS [InternalPortfolio]
		  ,[Instrument_Type_Name] AS [InstrumentType]
		  ,[Ext_Business_Unit_Name] AS [ExternalBusinessUnit]
		  ,[Deal_Number] AS [Deal_Number]
		  ,'NULL' AS [CounterpartyGroup]
		  ,CAST(format([Delivery_Month],'yyyy/MM') as varchar) AS [Delivery_Month]
		  ,'NULL' AS [ReconGroup]
		  ,'NULL' AS [DealID_Recon]
		  ,'NULL' AS [Adj_Category]
		  ,'NULL' AS [Adj_Comment]
		  ,sum([PnL_Disc_Total_YtD_PH_BU_CCY]) AS [ROCK_PnL_Disc_Total_YtD_PH_BU_CCY]
		  ,sum([PnL_Disc_Real_YtD_PH_BU_CCY]) AS [ROCK_PnL_Disc_Real_YtD_PH_BU_CCY]
		  ,sum([PnL_Disc_Unreal_YtD_PH_BU_CCY]) AS [ROCK_PnL_Disc_Unreal_YtD_PH_BU_CCY]
		  ,sum([PnL_Disc_Unreal_LtD_PH_BU_CCY]) AS [ROCK_PnL_Disc_Unreal_LtD_PH_BU_CCY]
		  ,0 AS [FT_EOM_PNL]
		  ,0 AS [FT_EOM_OCI]
		  ,0 AS [FT_EOM_OU]
		  ,0 AS [FT_EOM_NOR]
		  ,0 AS [FT_EOY_PNL]
		  ,0 AS [FT_EOY_OCI]
		  ,0 AS [FT_EOY_OU]
		  ,0 AS [FT_EOY_NOR]
		  ,0 AS [RECON_Volume_Endur]
		  ,0 AS [RECON_Volume_SAP]
		  ,0 AS [RECON_Volume_Adj]
		  ,0 AS [RECON_realised_EUR_Endur]
		  ,0 AS [RECON_realised_EUR_SAP]
		  ,0 AS [RECON_realised_EUR_SAP_conv]
		  ,0 AS [RECON_realised_EUR_adj]
		  ,0 AS [RECON_Diff_Volume]
		  ,0 AS [RECON_Diff_Realised_EUR]
	FROM [FinRecon].[dbo].[table_GPM_RECON_RISK_REPORT]
	GROUP BY case 
					when [Intermediate_2_Name] like '% D%' 
							then 'CAO GAS DE'
					else case 
							when [Intermediate_2_Name] like '% CZ%' 
									then 'CAO GAS CZ' 
							else '' 
							END 
					END 
			,[Portfolio_Name]
		    ,[Instrument_Type_Name] 
		    ,[Ext_Business_Unit_Name] 
		    ,[Deal_Number] 
		    ,CAST(format([Delivery_Month],'yyyy/MM') as varchar)

UNION

	SELECT [Subdesk]
		  ,[InternalPortfolio] AS [InternalPortfolio]
		  ,[InstrumentType] AS [InstrumentType]
		  ,[ExternalBusinessUnit] AS [ExternalBusinessUnit]
		  ,[ReferenceID] AS [Deal_Number]
		  ,[CounterpartyGroup] AS [CounterpartyGroup]
		  ,'NULL' AS [Delivery_Month]
		  ,'NULL' AS [ReconGroup]
		  ,'NULL' AS [DealID_Recon]
		  ,'NULL' AS [Adj_Category]
		  ,'NULL' AS [Adj_Comment]
		  ,0 AS [ROCK_PnL_Disc_Total_YtD_PH_BU_CCY]
		  ,0 AS [ROCK_PnL_Disc_Real_YtD_PH_BU_CCY]
		  ,0 AS [ROCK_PnL_Disc_Unreal_YtD_PH_BU_CCY]
		  ,0 AS [ROCK_PnL_Disc_Unreal_LtD_PH_BU_CCY]
		  ,sum([PNL]) AS [FT_EOM_PNL]
		  ,sum([OCI]) AS [FT_EOM_OCI]
		  ,sum([OU]) AS [FT_EOM_OU]
		  ,sum([NOR]) AS [FT_EOM_NOR]
		  ,0 AS [FT_EOY_PNL]
		  ,0 AS [FT_EOY_OCI]
		  ,0 AS [FT_EOY_OU]
		  ,0 AS [FT_EOY_NOR]
		  ,0 AS [RECON_Volume_Endur]
		  ,0 AS [RECON_Volume_SAP]
		  ,0 AS [RECON_Volume_Adj]
		  ,0 AS [RECON_realised_EUR_Endur]
		  ,0 AS [RECON_realised_EUR_SAP]
		  ,0 AS [RECON_realised_EUR_SAP_conv]
		  ,0 AS [RECON_realised_EUR_adj]
		  ,0 AS [RECON_Diff_Volume]
		  ,0 AS [RECON_Diff_Realised_EUR]
	FROM [FinRecon].[dbo].[FASTracker_EOM]
	WHERE Desk = 'CAO Gas'
	GROUP BY [Subdesk]
	        ,[InternalPortfolio] 
		    ,[InstrumentType] 
		    ,[ExternalBusinessUnit] 
		    ,[ReferenceID] 
		    ,[CounterpartyGroup] 

UNION

	SELECT [Subdesk]
		  ,[InternalPortfolio] AS [InternalPortfolio]
		  ,[InstrumentType] AS [InstrumentType]
		  ,[ExternalBusinessUnit] AS [ExternalBusinessUnit]
		  ,[ReferenceID] AS [Deal_Number]
		  ,[CounterpartyGroup] AS [CounterpartyGroup]
		  ,'NULL' AS [Delivery_Month]
		  ,'NULL' AS [ReconGroup]
		  ,'NULL' AS [DealID_Recon]
		  ,'NULL' AS [Adj_Category]
		  ,'NULL' AS [Adj_Comment]
		  ,0 AS [ROCK_PnL_Disc_Total_YtD_PH_BU_CCY]
		  ,0 AS [ROCK_PnL_Disc_Real_YtD_PH_BU_CCY]
		  ,0 AS [ROCK_PnL_Disc_Unreal_YtD_PH_BU_CCY]
		  ,0 AS [ROCK_PnL_Disc_Unreal_LtD_PH_BU_CCY]
		  ,0 AS [FT_EOM_PNL]
		  ,0 AS [FT_EOM_OCI]
		  ,0 AS [FT_EOM_OU]
		  ,0 AS [FT_EOM_NOR]
		  ,sum([PNL]) AS [FT_EOY_PNL]
		  ,sum([OCI]) AS [FT_EOY_OCI]
		  ,sum([OU]) AS [FT_EOY_OU]
		  ,sum([NOR]) AS [FT_EOY_NOR]
		  ,0 AS [RECON_Volume_Endur]
		  ,0 AS [RECON_Volume_SAP]
		  ,0 AS [RECON_Volume_Adj]
		  ,0 AS [RECON_realised_EUR_Endur]
		  ,0 AS [RECON_realised_EUR_SAP]
		  ,0 AS [RECON_realised_EUR_SAP_conv]
		  ,0 AS [RECON_realised_EUR_adj]
		  ,0 AS [RECON_Diff_Volume]
		  ,0 AS [RECON_Diff_Realised_EUR]
	FROM [FinRecon].[dbo].[FASTracker_EOY]
	WHERE Desk = 'CAO Gas'
	GROUP BY [Subdesk]
		    ,[InternalPortfolio] 
		    ,[InstrumentType] 
		    ,[ExternalBusinessUnit] 
		    ,[ReferenceID] 
		    ,[CounterpartyGroup] 

UNION

	SELECT [Subdesk]
		  ,[Portfolio] AS [InternalPortfolio]
		  ,[InstrumentType] AS [InstrumentType]
		  ,[ExternalBusinessUnit] AS [ExternalBusinessUnit]
		  ,[DealID] AS [Deal_Number]
		  ,[CounterpartyGroup] AS [CounterpartyGroup]
		  ,[DeliveryMonth] AS [Delivery_Month]
		  ,[ReconGroup] AS [ReconGroup]
		  ,[DealID_Recon] AS [DealID_Recon]
		  ,[Adj_Category] AS [Adj_Category]
		  ,[Adj_Comment] AS [Adj_Comment]
		  ,0 AS [ROCK_PnL_Disc_Total_YtD_PH_BU_CCY]
		  ,0 AS [ROCK_PnL_Disc_Real_YtD_PH_BU_CCY]
		  ,0 AS [ROCK_PnL_Disc_Unreal_YtD_PH_BU_CCY]
		  ,0 AS [ROCK_PnL_Disc_Unreal_LtD_PH_BU_CCY]
		  ,0 AS [FT_EOM_PNL]
		  ,0 AS [FT_EOM_OCI]
		  ,0 AS [FT_EOM_OU]
		  ,0 AS [FT_EOM_NOR]
		  ,0 AS [FT_EOY_PNL]
		  ,0 AS [FT_EOY_OCI]
		  ,0 AS [FT_EOY_OU]
		  ,0 AS [FT_EOY_NOR]
		  ,sum([Volume_Endur]) AS [RECON_Volume_Endur]
		  ,sum([Volume_SAP]) AS [RECON_Volume_SAP]
		  ,sum([Volume_Adj]) AS [RECON_Volume_Adj]
		  ,sum([realised_EUR_Endur]) AS [RECON_realised_EUR_Endur]
		  ,sum([realised_EUR_SAP]) AS [RECON_realised_EUR_SAP]
		  ,sum([realised_EUR_SAP_conv]) AS [RECON_realised_EUR_SAP_conv]
		  ,sum([realised_EUR_adj]) AS [RECON_realised_EUR_adj]
		  ,sum([Diff_Volume]) AS [RECON_Diff_Volume]
		  ,sum([Diff_Realised_EUR]) AS [RECON_Diff_Realised_EUR]
	FROM [FinRecon].[dbo].[Recon]
	WHERE Desk = 'CAO Gas'
	GROUP BY [Subdesk]
			,[Portfolio] 
		    ,[InstrumentType] 
		    ,[ExternalBusinessUnit]
		    ,[DealID] 
		    ,[CounterpartyGroup] 
		    ,[DeliveryMonth] 
		    ,[ReconGroup] 
		    ,[DealID_Recon] 
		    ,[Adj_Category] 
		    ,[Adj_Comment]
)

GO

