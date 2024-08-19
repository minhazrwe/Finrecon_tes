
CREATE VIEW [dbo].[VM_NETTING_FASTrackerData] as 
			SELECT
				'Extern' as Accounting 
				,AsOfDate
				,Subsidiary	
				,Strategy	
				,Book	
				,ReferenceID	
				,TradeDate	
				,max(TermEnd) as TermEnd
				,InternalPortfolio	
				,ExternalBusinessUnit as ExtBusinessUnit
				,ExtLegalEntity	
				,CounterpartyGroup	
				,sum(VolumeAvailable) as Volume
				,max(CurveName) as Curvename
				,ProjIndexGroup	
				,InstrumentType	
				,AccountingTreatment	
				,sum(PNL)	 as MtMtoNet
				,sum(PNL) as PNL
				,sum(OCI) as OCI
				,sum(total_MtM) as Total_MTM
				, [Product] 
		FROM 
			[dbo].[FASTracker_EOM]
		WHERE
			extlegalentity in ('BNP PARIBAS(CLEAR)','CME GROUP','DB CLEARING','DOM MAKLERSKI','KELER CCP LTD'
												,'NASDAQ OMX','SGIL','SGNUK','BNP PARIBAS CLEAR', 'NASDAQ CLEARING AB'
												,'IRGIT CLEARING','ABN AMRO CLEARING BANK','BNP PARIBAS','SocGen','MIZUHO CLEARING'
												,'APX CLEARING', 'BANCO SANTANDER', 'CME GROUP LE', 'EXAA', 'ECC LUX'
												,'ECC','ICE','NORD POOL SPOT','OMICLEAR'
												)
			AND (
						abs(pnl)>0 
						or (
								pnl=0 
								and FASTracker_EOM.OCI = 0 
								and abs(volumeused)=0
								)
					) 
			and externalbusinessunit not in ('BNP PARIBAS BU','SOCGEN BU')
		GROUP BY 
			AsOfDate
			,Subsidiary	
			,Strategy	
			,Book	
			,ReferenceID	
			,TradeDate	
			,InternalPortfolio	
			,ExternalBusinessUnit,ExtLegalEntity	
			,CounterpartyGroup	
			,ProjIndexGroup	
			,InstrumentType	
			,AccountingTreatment
			,[Product]	

	UNION ALL 

		SELECT 
			'Hedge' as Accounting
			, AsOfDate,Subsidiary	
			,Strategy	
			,Book	
			,ReferenceID	
			,TradeDate	
			,max(TermEnd) as TermEnd
			,InternalPortfolio	
			,ExternalBusinessUnit as ExtBusinessUnit
			,ExtLegalEntity	
			,CounterpartyGroup	
			,sum(VolumeUsed) as Volume
			,max(CurveName) as Curvename	
			,ProjIndexGroup	
			,InstrumentType	
			,AccountingTreatment	
			,sum(OCI) as MtMtoNet
			,sum(PNL) as PNL
			,sum(OCI) as OCI
			,sum(total_MtM) as Total_MTM
			, [Product]
		FROM 
			dbo.FASTracker_EOM
		WHERE 
			extlegalentity in 
			(
				'BNP PARIBAS(CLEAR)','CME GROUP','DB CLEARING','DOM MAKLERSKI','KELER CCP LTD'
				,'NASDAQ OMX','SGIL','SGNUK','BNP PARIBAS CLEAR', 'NASDAQ CLEARING AB'
				,'IRGIT CLEARING','ABN AMRO CLEARING BANK','BNP PARIBAS','SocGen','MIZUHO CLEARING'
				,'APX CLEARING','BANCO SANTANDER','CME GROUP LE','EXAA','ECC LUX'
				,'ECC','ICE','NORD POOL SPOT','OMICLEAR'
			)
			AND 
			(
				abs(volumeused)>0  
				or abs(oci)>0
			) 
			AND externalbusinessunit not in ('BNP PARIBAS BU','SOCGEN BU')

GROUP BY 
	AsOfDate
	,Subsidiary	
	,Strategy	
	,Book	
	,ReferenceID	
	,TradeDate	
	,InternalPortfolio	
	,ExternalBusinessUnit
	,ExtLegalEntity
	,CounterpartyGroup
	,ProjIndexGroup	
	,InstrumentType	
	,AccountingTreatment
	,[Product]

GO

