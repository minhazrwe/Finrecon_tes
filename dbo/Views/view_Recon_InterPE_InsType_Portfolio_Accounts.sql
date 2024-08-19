
--drop view dbo.View_Recon_InterPE_InsType 

create view dbo.view_Recon_InterPE_InsType_Portfolio_Accounts as 
SELECT Recon
	,InternalPortfolio
	,InstrumentType
	,Account_Asset
	,Account_Liab
	,Account_PNL
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
	,InternalPortfolio
	,InstrumentType
	,Account_Asset
	,Account_Liab
	,Account_PNL;



--HAVING abs(Sum(MTM)) >1;

GO

