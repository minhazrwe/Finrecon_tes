

--select * from view_Clearer_ImportOverview

CREATE view [dbo].[view_Clearer_ImportOverview] AS
select 
	table_Clearer.ClearerID
	,table_Clearer.ClearerName
	,subsql.trades 	
		,subsql.premium
		,subsql.settlement
		,subsql.lastimport
		,subsql.earlyimport
	from 
	dbo.table_Clearer left outer join 
	(
		SELECT 
		 c.ClearerID 
		,ClearerName	
		,sum(trades) as trades 	
		,sum(premium) as premium
		,sum(settlement) as settlement
		,max(lastimport) lastimport
		,min(lastimport) earlyimport
	FROM 
	(
		SELECT 
			 ClearerID 
			,0 as trades 	
			,0 as premium
			,COUNT(table_Clearer_AccountingData.ID) as settlement
			,MAX(table_Clearer_AccountingData.lastimport) lastimport
		FROM 
			dbo.table_Clearer_AccountingData
		WHERE 
			ClearerType ='settlement'
		GROUP BY
			ClearerID
		
		UNION ALL 
		
		SELECT 
			 ClearerID 
			,0 as trades 	
			,COUNT(table_Clearer_AccountingData.ID) as premium
			,0 settlement
			,MAX(table_Clearer_AccountingData.lastimport) lastimport
		FROM 
			dbo.table_Clearer_AccountingData 
		WHERE 
			ClearerType ='premium'
		GROUP BY
			ClearerID

		UNION ALL 
		
		SELECT 
			 ClearerID 
			,COUNT(table_Clearer_DealData.ID) as trades 
			,0 as premium
			,0 as settlement
			,MAX(table_Clearer_DealData.lastimport) lastimport
		FROM 
			dbo.table_Clearer_DealData 
		GROUP BY
			 ClearerID	
	) subsql
	left outer join dbo.table_Clearer c on c.ClearerID = subsql.ClearerID
	WHERE
		c.ClearerDBRelevant > 0
	GROUP BY
		 c.ClearerID 
		,ClearerName	
		)subsql on dbo.table_Clearer.ClearerID = subsql.ClearerID

GO

