


CREATE view [dbo].[view_VM_NETTING_5_Report_Changes_in_Derivatives] as 

SELECT 
	FASTracker.AsofDate				
	,map_order.Desk			
	,[Strategy]
	,map_EndurPortfolioTree.Desk as Endur_Desk_Name
	,map_EndurPortfolioTree.InternalBusinessUnit 
	,Subdesk
	,map_SBM.Book
	,FASTracker.InternalPortfolio
	,FASTracker.InstrumentType
	,ProjIndexGroup
	,TermEnd			
	,ExtLegalEntity
	,FASTracker.CounterpartyGroup
	,SubDeskCCY			
	,sum(Discounted_PNL) AS Sum_PNL			
	,sum(FASTracker.Discounted_MTM * CASE 			
			WHEN map_order.LegalEntity = 'RWESTP'	
				THEN FXRates.rate
			ELSE FXRates.RateRisk	
			END) AS SumTotal_MTM_DeskCCY	
	,sum(FASTracker.[Discounted_PNL] * CASE 			
			WHEN map_order.LegalEntity = 'RWESTP'	
				THEN FXRates.rate
			ELSE FXRates.RateRisk	
			END) AS Sum_PNL_DeskCCY	

FROM 
(				
	(			
		dbo.FASTracker INNER JOIN dbo.map_SBM 
		ON FASTracker.InternalPortfolio = map_SBM.InternalPortfolio		
		AND FASTracker.CounterpartyGroup = map_SBM.CounterpartyGroup	
		AND FASTracker.InstrumentType = map_SBM.InstrumentType	
		AND FASTracker.ProjIndexGroup = map_SBM.ProjectionIndexGroup	
	) LEFT JOIN dbo.map_order ON FASTracker.internalportfolio = map_order.portfolio		
) LEFT JOIN dbo.FXRates 
	ON CASE WHEN (map_order.repccy IS NULL OR map_order.repccy = '')
					THEN map_order.SubDeskCCY	
					ELSE map_order.repccy		
			END = FXRates.currency
	LEFT JOIN dbo.map_EndurPortfolioTree 
	on FASTracker.InternalPortfolio = map_EndurPortfolioTree.Portfolio

WHERE 
	map_SBM.Book IN ('Trading','Derivative'	,'Adjustments & Credit Provisions'	)	
	AND Strategy IN (SELECT Desk_Name FROM dbo.table_map_Desk WHERE Desk_Type = 'Trading')			
GROUP BY 
	FASTracker.AsofDate				
	,map_order.Desk			
	,[Strategy]	
	,map_EndurPortfolioTree.Desk
	,map_EndurPortfolioTree.InternalBusinessUnit
	,ProjIndexGroup			
	,TermEnd			
	,FASTracker.InternalPortfolio			
	,ExtLegalEntity			
	,Subdesk			
	,SubDeskCCY			
	,map_SBM.Book
	,FASTracker.InstrumentType
	,FASTracker.CounterpartyGroup

GO

