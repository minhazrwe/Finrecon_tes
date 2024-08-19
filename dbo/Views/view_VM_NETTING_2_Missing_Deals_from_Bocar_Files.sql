











CREATE view [dbo].[view_VM_NETTING_2_Missing_Deals_from_Bocar_Files] as 
--Neue Bocar Dateien müssen vom Format her richtig eingebunden werden und daher an der richtigen Stelle der Deallevel-Befüllung hinzugefügt werden

SELECT [Dealtype] 
			,OLFAccount
			,DealNumber
			,olfpnl
			,Product
			,ExchangeCode
			,Currency
			,Portfolio
			,ExternalBU
			,ContractDate
		FROM [dbo].[VM_NETTING_Deals]
		WHERE [Dealtype] not IN (
				'Deals_ASX'
				,'Deals_ASX_AP'
				,'Deals_BNP Paribas'
				,'Deals_BNP Paribas_AP'
				,'Deals_ECC'
				,'Deals_ECC_AP'
				,'Deals_ECC_JP'
				,'Deals_ICE'
				,'Deals_LME'
				,'Deals_Mizuho'
				,'Deals_Nodal'
				,'Deals_NOMXC'
				,'Deals_SocGen'
				,'Deals_SocGen_AP'
				,'Deals_SocGen_JP'
				,'Deals_ECCEmissions'
				,'Deals_BNP Paribas ICEEndex'
				,'Deals_BNP Paribas_JP'
				 
				)

GO

