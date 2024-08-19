
/*=================================================================================================================
	Author:		Unknown
	Created:	2024-04-23
	Purpose:	
-----------------------------------------------------------------------------------------------------------------
	Changes:
	2024-04-23, MK, step 0, changed ReconGroup exemption from "Börse" to "Exchanges"
=================================================================================================================*/

CREATE VIEW [dbo].[base_recon_update_Endur]
AS
SELECT [dbo].[Recon].[OrderNo], [dbo].[Recon].[DeliveryMonth], [dbo].[Recon].[DealID_Recon], [dbo].[Recon].[ccy], Sum([dbo].[Recon].[Realised_ccy_Endur] - [dbo].[Recon].[Realised_ccy_SAP]) AS diff_ccy, Sum([dbo].[Recon].[Volume_Endur] + [dbo].[Recon].[Volume_SAP]) AS Volume, Max([dbo].[Recon].[Account_Endur]) AS Endur, Max([dbo].[Recon].[Account_SAP]) AS SAP, MAX([dbo].[udf_Check_Accounts]([dbo].[Recon].[Account_Endur], [dbo].[Recon].[Account_SAP])) AS [check], Count([dbo].[Recon].[ReconGroup]) AS AnzahlvonReconGroup, Sum([dbo].[Recon].[Realised_ccy_Endur]) AS Summevonrealised_ccy_Endur, Sum([dbo].[Recon].[Realised_ccy_SAP]) AS Summevonrealised_ccy_SAP, [dbo].[Recon].[ReconGroup], Sum(Abs([dbo].[Recon].[diff_Realised_ccy])) AS [ABS]
FROM [dbo].[Recon]
---WHERE 
----((([dbo].[Recon].[EventDate])<=(select [AsOfDate_eom] from [dbo].[AsOfDate]) Or ([dbo].[Recon].[EventDate]) Is Null))
GROUP BY [dbo].[Recon].[OrderNo], [dbo].[Recon].[DeliveryMonth], [dbo].[Recon].[DealID_Recon], [dbo].[Recon].[ccy], [dbo].[Recon].[ReconGroup]
HAVING (([dbo].[Recon].[DealID_Recon]) NOT IN ('DE', 'GB', 'INV'))
	AND abs(Sum([dbo].[Recon].[realised_ccy_Endur] - [dbo].[Recon].[realised_ccy_SAP])) < 0.1
	AND abs(Sum([dbo].[Recon].[Volume_Endur] + [dbo].[Recon].[Volume_SAP])) < 0.1
	AND ((Max([dbo].[Recon].[Account_Endur])) IS NOT NULL)
	AND ((Max([dbo].[Recon].[Account_SAP])) IS NOT NULL)
	AND ((Max([dbo].[Recon].[Account_endur]) <> Max([dbo].[Recon].[Account_SAP])))
	---AND ((Count([dbo].[Recon].[ReconGroup]))=2) 
	AND abs(Sum([dbo].[Recon].[Realised_ccy_Endur])) > 1
	AND abs(Sum([dbo].[Recon].[Realised_ccy_SAP])) > 1
	AND (([dbo].[Recon].[ReconGroup]) NOT IN ('Exchanges', 'InterPE', 'Intradesk'))
	AND ((Sum(Abs([dbo].[Recon].[diff_Realised_ccy]))) > 1)

GO

