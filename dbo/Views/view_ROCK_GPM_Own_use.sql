

/*
ChangeLog
2023-04-11 (MU): Adding filter "and AccountingTreatment LIKE 'Own use' and CounterpartyGroup  NOT LIKE 'Intradesk'" requested by Yvonne Neuhäuser and verified by Andre Albrecht
*/

CREATE view [dbo].[view_ROCK_GPM_Own_use] as 
SELECT 
	AsOfDate as cob
	,Subsidiary
	,Strategy
	,ReferenceID						/*Reference_ID*/
	,TradeDate							/*Trade_Date*/
	,NULL as Term_Start
	,TermEnd								/*Term_End*/
	,InternalPortfolio			/*Internal_Portfolio*/
	,ExternalBusinessUnit		/*Counterparty_Ext_Bunit*/
	,CounterpartyGroup			/*Counterparty_Group*/
	,Volume
	,NULL as Header_Buy_Sell
	,CurveName							/*Curve_Name*/
	,ProjIndexGroup					/*Projection_Index_Group*/
	,InstrumentType					/*Instrument_Type*/
	,UOM				
	,NULL as Int_Legal_Entity
	,NULL as Int_Bunit
	,ExtLegalEntity					/*Ext_Legal_Entity*/
	,ExtPortfolio						/*Ext_Portfolio*/
	,NULL as Discounted_PNL
	,NULL as Undiscounted_PNL
	,AccountingTreatment		/*Accounting_Treatment*/
	,NULL as Reference
	,Product
	,NULL as FileID
	,NULL as Lastupdate
	,sum([OCI]) as OCI
	,SUM([OU]) AS OU
	,sum([OCI]) + SUM([OU]) AS unwind
FROM 
	dbo.FASTracker_EOM
WHERE 
	Desk like '%CAO GAS%' and AccountingTreatment LIKE 'Own use' and CounterpartyGroup  NOT LIKE 'Intradesk'
group by 
	AsOfDate 
	,Subsidiary
	,Strategy
	,ReferenceID						
	,TradeDate							
	,TermEnd								
	,InternalPortfolio			
	,ExternalBusinessUnit		
	,CounterpartyGroup			
	,Volume
	,CurveName							
	,ProjIndexGroup					
	,InstrumentType					
	,UOM				
	,ExtLegalEntity					
	,ExtPortfolio						
	,AccountingTreatment		
	,Product
	having
			ABS(sum(OCI))+ABS(SUM(OU)) <>0

/*old approach as it was used in ROCK until 2023/01

SELECT 
	cast(COB as datetime) as cob
	,Subsidiary
	,Strategy
	,Reference_ID
	,Trade_Date
	,Term_Start
	,Term_End
	,Internal_Portfolio
	,Counterparty_Ext_Bunit
	,Counterparty_Group
	,Volume
	,Header_Buy_Sell
	,Curve_Name
	,Projection_Index_Group
	,Instrument_Type
	,UOM
	,Int_Legal_Entity
	,Int_Bunit
	,Ext_Legal_Entity
	,Ext_Portfolio
	,Discounted_PNL
	,Undiscounted_PNL
	,Accounting_Treatment
	,Reference
	,Product
	,FileID
	,Lastupdate
FROM 
	dbo.FASTracker_EOM
WHERE 
	Counterparty_Group NOT LIKE 'Intradesk'
	AND Accounting_Treatment LIKE 'Own use'
	*/

GO

