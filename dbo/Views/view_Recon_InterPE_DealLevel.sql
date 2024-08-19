

--drop view dbo.View_Recon_InterPE_InsType 

CREATE view [dbo].[view_Recon_InterPE_DealLevel] as 
SELECT
	 Recon_InternalAll_Details.Recon
	,Recon_InternalAll_Details.InstrumentType
	,Recon_InternalAll_Details.ReferenceID
	,Recon_InternalAll_Details.InternalPortfolio
	,Recon_InternalAll_Details.ExtPortfolio
	,Recon_InternalAll_Details.Product
	,Recon_InternalAll_Details.TradeDate
	,Recon_InternalAll_Details.LastTermEnd
	,Recon_InternalAll_Details.Account_Asset
	,Recon_InternalAll_Details.Account_Liab
	,Recon_InternalAll_Details.Account_PNL
	,Recon_InternalAll_Details.RWEST_DE
	,Recon_InternalAll_Details.RWEST_UK
	,Recon_InternalAll_Details.RWEST_CZ
	,Recon_InternalAll_Details.RWEST_P
	,Recon_InternalAll_Details.RWEST_AP
	,Recon_InternalAll_Details.RWEST_SH
	,Recon_InternalAll_Details.TS_DE
	,Recon_InternalAll_Details.TS_UK
	,Recon_InternalAll_Details.MtM
	,map_order.Desk as Desk_internal
	,map_order_ext.Desk as Desk_external
	,dbo.Recon_InternalAll_Details.LastUpdate
FROM 	
	dbo.view_Recon_InterPE_InsType_TradeDate
INNER JOIN 
	dbo.Recon_InternalAll_Details
	ON (dbo.view_Recon_InterPE_InsType_TradeDate.Recon = dbo.Recon_InternalAll_Details.Recon)
		AND (dbo.view_Recon_InterPE_InsType_TradeDate.InstrumentType = dbo.Recon_InternalAll_Details.InstrumentType)
		AND (dbo.view_Recon_InterPE_InsType_TradeDate.TradeDate = dbo.Recon_InternalAll_Details.TradeDate)
	LEFT OUTER JOIN dbo.map_order on Recon_InternalAll_Details.InternalPortfolio = map_order.Portfolio
	LEFT OUTER JOIN dbo.map_order map_order_ext on Recon_InternalAll_Details.ExtPortfolio = map_order_ext.Portfolio
WHERE 		
	abs(dbo.view_Recon_InterPE_InsType_TradeDate.MtM) > 1
			


--HAVING abs(Sum(MTM)) >1;

GO

