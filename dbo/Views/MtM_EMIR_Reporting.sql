

CREATE view dbo.[MtM_EMIR_Reporting] as 

SELECT 
	AsofDate
	,Desk
	,Subsidiary
	,refID
	,InternalPortfolio
	,CounterpartyGroup
	,InstrumentType
	,ProjIndexGroup
	,Counterparty_ExtBunit
	,UOM
	,Volume
	,CASE 
		WHEN Volume = 0
			THEN 0
		ELSE Volumeused / Volume
		END AS Volume_hedge_perc
	,Treatment
	,Discounted_MtM
FROM (
	SELECT AsofDate
		,Desk
		,Subsidiary
		,replace(replace(ReferenceID, '_tc', ''), '_strc', '') AS refID
		,InternalPortfolio
		,CounterpartyGroup
		,InstrumentType
		,ProjIndexGroup
		,ExternalBusinessUnit AS Counterparty_ExtBunit
		,UOM
		,Sum(ft.Volume) AS Volume
		,Sum(ft.Volumeused) AS Volumeused
		,CASE 
			WHEN (internalportfolio LIKE 'RGM_CZ%' or internalportfolio LIKE 'RGM_Supp_East%')
			THEN 'Own Use'
			ELSE
				CASE 
					WHEN counterpartygroup = 'External_NON_IAS'
					THEN 'Own Use'
					ELSE	
						CASE 
							WHEN AccountingTreatment = 'out of scope'
							THEN 'Own Use'
							ELSE AccountingTreatment
						END
				END				
		END	AS Treatment
		,Sum(Total_MTM) AS Discounted_MtM
	FROM 
		dbo.[FASTracker_EOM] ft
	WHERE
		Subsidiary NOT IN ('RWE Trading Services','Trading Services Essen','RWEST Participations')
		AND ReferenceID NOT LIKE '[A-Z]%'
		AND InternalPortfolio NOT LIKE 'RGM_CZ%'
		AND CounterpartyGroup IN ('External','External_Hedge')				
	GROUP BY 
		AsofDate
		,Desk
		,Subsidiary
		,ReferenceID
		,InternalPortfolio
		,CounterpartyGroup
		,InstrumentType
		,ProjIndexGroup
		,ExternalBusinessUnit
		,UOM
		,CASE 
			WHEN (internalportfolio LIKE 'RGM_CZ%' or internalportfolio LIKE 'RGM_Supp_East%')
			THEN 'Own Use'
			ELSE
				CASE 
					WHEN counterpartygroup = 'External_NON_IAS'
					THEN 'Own Use'
					ELSE	
						CASE 
							WHEN AccountingTreatment = 'out of scope'
							THEN 'Own Use'
							ELSE AccountingTreatment
						END
				END				
		END	
	) AS subsql

GO

