
--drop view dbo.View_Recon_InterPE_InsType 

create view dbo.view_Recon_InterPE_InsType_TradeDate as 
SELECT 
	 Recon
	,InstrumentType
	,TradeDate
	,Sum(RWEST_DE) AS RWEST_DE
	,Sum(RWEST_UK) AS RWEST_UK
	,Sum(RWEST_CZ) AS RWEST_CZ
	,Sum(RWEST_P) AS RWEST_P
	,Sum(RWEST_AP) AS RWEST_AP
	,Sum(RWEST_SH) AS RWEST_SH
	,Sum(TS_DE) AS TS_DE
	,Sum(TS_UK) AS TS_UK
	,Sum(MtM) AS MtM
FROM 
 dbo.Recon_InternalAll_Details
GROUP BY 
	 Recon
	,InstrumentType
	,TradeDate
HAVING 
	abs(Sum(MTM)) >1;
	
	--ORDER BY Recon
	--,InstrumentType
	--,TradeDate;

GO

