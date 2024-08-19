






	CREATE PROCEDURE [dbo].[InsertSAPintoRecon_zw1] 
	AS
	BEGIN TRY
	
	/*define some variables */
		DECLARE @LogInfo Integer
		DECLARE @step Integer
		DECLARE @proc varchar(40)
				
		SELECT @proc = Object_Name(@@PROCID)

		select @LogInfo = [dbo].[LogInfo].[LogInfo] from [dbo].[LogInfo]

		if @LogInfo >= 1  BEGIN insert into [dbo].[Logfile] select 'Reconciliation - ' + @proc + ': fill SAP Data into Recon_zw1', GETDATE () END

		select @Step = 1
		INSERT INTO Recon_zw1
		( 
			Portfolio
			, Portfolio_ID
			, InternalLegalEntity
			, DealID_Recon
			, Dealid
			, ExternalBusinessUnit
			, ExternalPortfolio
			, [source]
			, [Account_SAP]
			, ReconGroup
			, OrderNo
			, ccy
			, Deskccy
			, [Partner]
			, UOM_SAP, DeliveryMonth
			, [realised_EUR_SAP]
			, [realised_ccy_SAP]
			, [realised_deskccy_SAP]
			, [realised_EUR_SAP_conv]
			, [Volume_SAP]
			, InstrumentType
			, [Text_SAP]
			, [Reference_SAP]
			, [DocumentNumber_SAP]
			, [VAT_SAP]
			, Eventdate
			, Material
			, deliveryvesselname
			, staticticketid
			, DocumentType_SAP
			, VAT_CountryCode 
			, SAP_refkey1
			, SAP_refkey2
			, SAP_refkey3
		)
		SELECT 
			Portfolio
			, Portfolio_ID
			, InternalLegalEntity
			, DealID_Recon
			, Dealid
			, ExternalBusinessUnit
			, ExternalPortfolio
			, [source]
			, [Account_SAP]
			, ReconGroup
			, OrderNo
			, ccy
			, Deskccy
			, [Partner]
			, UOM_SAP
			, DeliveryMonth
			, [realised_EUR_SAP]
			, [realised_ccy_SAP]
			, [realised_deskccy_SAP]
			, case when recongroup = 'Brokerage' then [realised_EUR_SAP] else [realised_EUR_SAP_conv] end as [realised_EUR_SAP_conv]
			, [Volume_SAP]
			, InstrumentType
			, [Text_SAP]
			, [Reference_SAP]
			, [DocumentNumber_SAP]
			, [VAT_SAP]
			, postingdate
			, Material
			, refkey2
			, refkey3
			, DocType
			, CountryCode
			, refkey1
			, refkey2
			, refkey3
		from
			[dbo].[base_realised_SAP_Recon_zw1]

		
		/*special rule for Coal & Freight desk 1*/
		if @LogInfo >= 1  BEGIN insert into [dbo].[Logfile] select 'Reconciliation - ' + @proc + ': update recongroup 1', GETDATE () END
		
		select @Step = 2
		UPDATE [dbo].[recon_zw1]
			SET [ReconGroup] = 'Bunker Roll - External'
			where 
				Recongroup = 'Secondary Cost' 
				and account_sap in ('4006049','6008111','4006145','6010145') 
				and material in ('10249861','10154039','10275938')

		/*special rule for Coal & Freight desk 3*/
		if @LogInfo >= 1  BEGIN insert into [dbo].[Logfile] select 'Reconciliation - ' + @proc + ': update recongroup 2', GETDATE () END
		
		select @Step = 3	
		UPDATE [dbo].[recon_zw1]
			SET [ReconGroup] = 'TC'
			where 
			(
				account_sap in ('4006163','6018012','4006164','6010164') 
				and material in ('10148839','10154033','10154032')
			) 
			and Text_SAP not like 'ACC;TC Hire;%'

		/*special rule for Coal&Freight desk 3*/
		if @LogInfo >= 1  BEGIN insert into [dbo].[Logfile] select 'Reconciliation - ' + @proc + ': update recongroup 3', GETDATE () END
				
		select @Step = 4
		UPDATE [dbo].[recon_zw1]
			SET [ReconGroup] = 'TC-Bunkers'
			where 
				account_sap in ('4006163','6018012','4006164','6010164') 
				and material in ('10249862')

		/*special request from Stefanie, Tamim, April (MBE 2021-11-17)*/
		--select @Step = 5
		--delete from [dbo].[recon_zw1] where Material in ('10287044','10287021','10287045')

		select @Step = 6
		if @LogInfo >= 1  BEGIN insert into [dbo].[Logfile] select 'Reconciliation - ' + @proc + ': update recongroup 4', GETDATE () END

		/*special rule for Coal&Freight desk reuqired by April 06/07/2022, SH*/
		UPDATE [dbo].[recon_zw1]
			SET [dbo].[recon_zw1].[ReconGroup] = 'HOEGH ESPERA'
			from [dbo].[recon_zw1] where recon_zw1.DeliveryVesselName in ('HOEGH ESPERA')

		/*special rule for Coal&Freight desk reuqired by April 31/03/2023, MBE*/
		UPDATE [dbo].[recon_zw1]
			SET [dbo].[recon_zw1].[ReconGroup] = 'PnL Transfer'
			from [dbo].[recon_zw1] where recon_zw1.deliveryvesselname in ('PnL Transfer')

		select @Step = 7
		if @LogInfo >= 1  BEGIN insert into [dbo].[Logfile] select 'Reconciliation - ' + @proc + ' - update PortfolioID for SAP', GETDATE () END

			
			/*adding Portfolio enrichment via portfolio ID for SAP 09/02/2024, SH*/
		UPDATE [dbo].[recon_zw1]
			SET [dbo].[recon_zw1].[Portfolio] = dbo.[00_map_order_PortfolioID].MaxvonPortfolio
			from [dbo].[recon_zw1] 
			left join dbo.[00_map_order_PortfolioID] on
			dbo.Recon_zw1.Portfolio_ID = dbo.[00_map_order_PortfolioID].PortfolioID
			where recon_zw1.Source in ('sap_blank') and Recon_zw1.Portfolio_ID is not null

		select @Step = 7
		if @LogInfo >= 1  BEGIN insert into [dbo].[Logfile] select 'Reconciliation - ' + @proc + ' - FINISHED', GETDATE () END	
							 			 
END TRY

	BEGIN CATCH
		EXEC [dbo].[usp_GetErrorInfo] @proc, @step		
		BEGIN INSERT INTO [dbo].[Logfile] SELECT 'Reconciliation - ' + @proc + ' - FAILED', GETDATE () END
	END CATCH

GO

