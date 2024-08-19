
CREATE view [dbo].[view_ROCK_GPM_Risk_unrealised_PnL] as
	SELECT 
		 cast(COB as datetime) as cob				
		,sbm.Strategy				
		,[Internal Portfolio Name] as InternalPortfolio				
		,sum([Unrealised Discounted (EUR)]) as PV_in_EUR				
		,[Instrument Type Name]				
		,round(Sum((isnull([Unrealised Discounted (EUR)],0)) / 1000000),3) AS PV_in_Mio				
	FROM 
		GloriRisk 
		LEFT JOIN (SELECT Subsidiary, Strategy, Max(Book) AS Book, InternalPortfolio 			
							 FROM dbo.map_SBM				
							 WHERE Subsidiary='RWEST DE' AND Strategy Like 'CAO Gas%'				
							 GROUP BY Subsidiary, Strategy, InternalPortfolio											 
								) sbm ON GloriRisk.[Internal Portfolio Name] = sbm.InternalPortfolio				
	WHERE 
		Desk_Name like 'GPM DESK'				
		and CASHFLOW_PAYMENT_DATE >= (select DATEADD(yy, DATEDIFF(yy, 0, asofdate_eoy), 0) from dbo.AsOfDate)  /*Beginning of Last Year*/
		AND [instrument type name] NOT LIKE '%Dummy%'
		and [Internal Portfolio Name] NOT IN 
			('RGM_D_DUMMY_SENSI'
				,'RGM_CZ_DUMMY_POS'
				,'RGM_D_DUMMY_SWING'
				,'RGM_D_DUMMY_OPTIONS'
				,'RGM_D_DUMMY_SWING_1'
				,'RGM_D_DUMMY_SWING_2'
				,'RGM_D_DUMMY_POS'
				,'RGM_D_DUMMY_IRS'
			)				
	GROUP BY 				
		 COB			
		,sbm.strategy			
		,[Internal Portfolio Name]			
		,[instrument type name]

GO

