		CREATE PROCEDURE [dbo].[prepare_Recon_Files]
		AS
		BEGIN TRY

				/*define some variables */
				DECLARE @LogInfo Integer
				DECLARE @step Integer
				DECLARE @proc nvarchar(40)

				SELECT @proc = Object_Name(@@PROCID)

				select @step = 1

				if @LogInfo >= 1  BEGIN insert into [dbo].[Logfile] select @proc + ' - create Table Recon_UK_All', GETDATE () END

				/*=======================================================*/
				/* starting here the Production of the UK Tables         */
				/*=======================================================*/
				IF (
						EXISTS (
							SELECT *
							FROM INFORMATION_SCHEMA.TABLES
							WHERE TABLE_SCHEMA = 'dbo'
								AND TABLE_NAME = 'Recon_UK_All'
							)
						)
				BEGIN
					DROP TABLE dbo.Recon_UK_All
				END

				/*=======================================================*/
				SELECT [InternalLegalEntity]
					,r.[Desk]
					,r.[Subdesk]
					,o.book
					,r.[ReconGroup] + CASE 
						WHEN account IN (
								'6010149'
								,'4006149'
								)
							THEN ' - Comm Fee'
						ELSE ''
						END AS ReconGroup
					,r.[OrderNo]
					,[DeliveryMonth]
					,[DealID_Recon]
					,[Account]
					,[ccy]
					,[Portfolio]
					,[CounterpartyGroup]
					,[InstrumentType]
					,[CashflowType]
					,[ProjIndexGroup]
					,[CurveName]
					,[ExternalLegal]
					,[ExternalBusinessUnit]
					,[ExternalPortfolio]
					,[DocumentNumber]
					,[Reference]
					,[partner]
					,[TradeDate]
					,[EventDate]
					,[SAP_DocumentNumber]
					,[Volume_Endur]
					,[Volume_SAP]
					,[Volume_Adj]
					,[UOM_Endur]
					,[UOM_SAP]
					,[realised_ccy_Endur]
					,[realised_ccy_SAP]
					,[realised_ccy_adj]
					,[Deskccy]
					,[realised_Deskccy_Endur]
					,[realised_Deskccy_SAP]
					,[realised_Deskccy_adj]
					,[realised_EUR_Endur]
					,[realised_EUR_SAP]
					,[realised_EUR_adj]
					,[Account_Endur]
					,[Account_SAP]
					,Diff_Volume
					,Diff_Realised_CCY
					,Diff_Realised_DeskCCY
					,Diff_Realised_EUR
					,[Identifier]
				INTO dbo.Recon_UK_All
				FROM recon r
				INNER JOIN dbo.[00_map_order] o ON r.orderno = o.orderno
				WHERE r.internallegalentity IN (
						'RWEST UK'
						,'TS UK'
						,'RWESTP'
						,'RWEST AP'
						,'RWEST INDIA'
						,'RWEST SH'
						,'RWEST Indonesia'
						,'RWEST Japan'
						,'RWEST ZA'
						)

				select @step = 2

				if @LogInfo >= 1  BEGIN insert into [dbo].[Logfile] select @proc + ' - create Table Recon_UK_Diff', GETDATE () END

				/*=======================================================*/
				IF (
						EXISTS (
							SELECT *
							FROM INFORMATION_SCHEMA.TABLES
							WHERE TABLE_SCHEMA = 'dbo'
								AND TABLE_NAME = 'Recon_UK_Diff'
							)
						)
				BEGIN
					DROP TABLE dbo.Recon_UK_Diff
				END

				/*=======================================================*/
				SELECT CASE 
						WHEN deliverymonth IN (
								'2017/01'
								,'2017/02'
								,'2017/03'
								,'2017/04'
								,'2017/05'
								,'2017/06'
								,'2017/07'
								,'2017/08'
								,'2017/09'
								,'2017/10'
								,'2017/11'
								,'2017/12'
								)
							THEN 'PriorYear'
						ELSE CASE 
								WHEN deliverymonth IN (
										'2018/01'
										,'2018/02'
										,'2018/03'
										,'2018/04'
										,'2018/05'
										,'2018/06'
										,'2018/07'
										,'2018/08'
										,'2018/09'
										,'2018/10'
										,'2018/11'
										,'2018/12'
										)
									THEN deliverymonth
								ELSE 'other'
								END
						END AS DelMonth
					,[InternalLegalEntity]
					,r.[Desk]
					,r.[Subdesk]
					,o.book
					,ReconGroup
					,r.[OrderNo]
					,[DeliveryMonth]
					,[DealID_Recon]
					,[Account]
					,[ccy]
					,[Portfolio]
					,[CounterpartyGroup]
					,[InstrumentType]
					,[CashflowType]
					,[ProjIndexGroup]
					,[CurveName]
					,[ExternalLegal]
					,[ExternalBusinessUnit]
					,[ExternalPortfolio]
					,[DocumentNumber]
					,[Reference]
					,[partner]
					,[TradeDate]
					,[EventDate]
					,[SAP_DocumentNumber]
					,[Volume_Endur]
					,[Volume_SAP]
					,[Volume_Adj]
					,[UOM_Endur]
					,[UOM_SAP]
					,[realised_ccy_Endur]
					,[realised_ccy_SAP]
					,[realised_ccy_adj]
					,[Deskccy]
					,[realised_Deskccy_Endur]
					,[realised_Deskccy_SAP]
					,[realised_Deskccy_adj]
					,[realised_EUR_Endur]
					,[realised_EUR_SAP]
					,[realised_EUR_adj]
					,[Account_Endur]
					,[Account_SAP]
					,Diff_Volume
					,Diff_Realised_CCY
					,Diff_Realised_DeskCCY
					,Diff_Realised_EUR
					,abs(Diff_Realised_CCY) AS AbsDiff_CCY
					,[Identifier]
				INTO dbo.Recon_UK_Diff
				FROM recon r
				INNER JOIN dbo.[00_map_order] o ON r.orderno = o.orderno
				WHERE (
						abs(diff_realised_ccy) > 1
						OR abs(diff_volume) > 1
						)
					AND r.internallegalentity IN (
						'RWEST UK'
						,'TS UK'
						,'RWESTP'
						,'RWEST AP'
						,'RWEST SH'
						,'RWEST Indonesia'
						,'RWEST Japan'
						,'RWEST INDIA'
						,'RWEST ZA'
						)
				ORDER BY InternalLegalEntity
					,Desk
					,Subdesk
					,OrderNo
					,dealid_recon

				select @step = 3

				if @LogInfo >= 1  BEGIN insert into [dbo].[Logfile] select @proc + ' - create Table Recon_UK_Diff_SF', GETDATE () END

				/*=======================================================*/
				IF (
						EXISTS (
							SELECT *
							FROM INFORMATION_SCHEMA.TABLES
							WHERE TABLE_SCHEMA = 'dbo'
								AND TABLE_NAME = 'Recon_UK_Diff_SF'
							)
						)
				BEGIN
					DROP TABLE dbo.Recon_UK_Diff_SF
				END

				/*=======================================================*/
				SELECT *
				INTO dbo.Recon_UK_Diff_SF
				FROM dbo.[recon_diff_uk]

				select @step = 4

				if @LogInfo >= 1  BEGIN insert into [dbo].[Logfile] select @proc + ' - create Table Recon_UK_Adjustments', GETDATE () END

				/*=======================================================*/
				IF (
						EXISTS (
							SELECT *
							FROM INFORMATION_SCHEMA.TABLES
							WHERE TABLE_SCHEMA = 'dbo'
								AND TABLE_NAME = 'Recon_UK_Adjustments'
							)
						)
				BEGIN
					DROP TABLE dbo.Recon_UK_Adjustments
				END

				/*=======================================================*/

				SELECT [dbo].[00_map_order].LegalEntity
					,[dbo].[00_map_order].Desk
					,[dbo].[00_map_order].SubDesk
					,[dbo].[00_map_order].Book
					,[Adjustments].ReconGroup
					,[Adjustments].OrderNo
					,[Adjustments].DeliveryMonth
					,[Adjustments].DealID
					,[Adjustments].Account
					,[Adjustments].Currency
					,[Adjustments].Quantity
					,[Adjustments].Realised_CCY
					,[Adjustments].Realised_CCY AS 'Realised_CCY_2'
					,
					/*[Adjustments].Realised_EUR,*/
					[Adjustments].Category
					,[Adjustments].Comment
					,[Adjustments].Valid_From
					,[Adjustments].Valid_To
					,[Adjustments].[User]
					,[Adjustments].[timestamp]
				INTO dbo.Recon_UK_Adjustments
				FROM [Adjustments]
				INNER JOIN [dbo].[00_map_order] ON [Adjustments].OrderNo = [dbo].[00_map_order].OrderNo
				WHERE (
						[dbo].[00_map_order].LegalEntity LIKE '%UK%'
						OR [dbo].[00_map_order].LegalEntity LIKE '%ZA%'
						)
					AND [Adjustments].Valid_From <= (
						SELECT asofdate_eom
						FROM asofdate
						)
					AND [Adjustments].Valid_To >= (
						SELECT asofdate_eom
						FROM asofdate
						)

				/*=======================================================*/
				/* starting here the Production of the DE Tables         */
				/*=======================================================*/

				select @step = 5

				if @LogInfo >= 1  BEGIN insert into [dbo].[Logfile] select @proc + ' - create Table Recon_DE_Adjustments', GETDATE () END

				IF (
						EXISTS (
							SELECT *
							FROM INFORMATION_SCHEMA.TABLES
							WHERE TABLE_SCHEMA = 'dbo'
								AND TABLE_NAME = 'Recon_DE_Adjustments'
							)
						)
				BEGIN
					DROP TABLE dbo.Recon_DE_Adjustments
				END

				SELECT [dbo].[00_map_order].LegalEntity
					,[dbo].[00_map_order].Desk
					,[dbo].[00_map_order].SubDesk
					,[dbo].[00_map_order].Book
					,[Adjustments].ReconGroup
					,[Adjustments].OrderNo
					,[Adjustments].DeliveryMonth
					,[Adjustments].DealID
					,[Adjustments].Account
					,[Adjustments].Currency
					,[Adjustments].Quantity
					,[Adjustments].Realised_CCY
					,[Adjustments].Realised_CCY AS 'Realised_CCY_2'
					,/*[Adjustments].Realised_EUR,*/
					[Adjustments].Category
					,[Adjustments].Comment
					,[Adjustments].Valid_From
					,[Adjustments].Valid_To
					,[Adjustments].[User]
					,[Adjustments].[timestamp]
				INTO dbo.Recon_DE_Adjustments
				FROM [Adjustments]
				INNER JOIN [dbo].[00_map_order] ON [Adjustments].OrderNo = [dbo].[00_map_order].OrderNo
				WHERE (
						[dbo].[00_map_order].LegalEntity LIKE '%DE%'
						OR [dbo].[00_map_order].LegalEntity LIKE '%CZ%'
						OR [dbo].[00_map_order].LegalEntity LIKE '%UK%' /*Added for april since CAO Gas has 2 UK portfolios*/
						)
					AND [Adjustments].Valid_From <= (
						SELECT asofdate_eom
						FROM asofdate
						)
					AND [Adjustments].Valid_To >= (
						SELECT asofdate_eom
						FROM asofdate
						)

				select @step = 6

				if @LogInfo >= 1  BEGIN insert into [dbo].[Logfile] select @proc + ' - create Table Recon_DE_All', GETDATE () END


				/*=======================================================*/
				IF (
						EXISTS (
							SELECT *
							FROM INFORMATION_SCHEMA.TABLES
							WHERE TABLE_SCHEMA = 'dbo'
								AND TABLE_NAME = 'Recon_DE_All'
							)
						)
				BEGIN
					DROP TABLE dbo.Recon_DE_All
				END

				/*=======================================================*/

				SELECT [InternalLegalEntity]
					,r.[Desk]
					,r.[Subdesk]
					,o.book
					,r.[ReconGroup] + CASE 
						WHEN account IN (
								'6010149'
								,'4006149'
								)
							THEN ' - Comm Fee'
						ELSE ''
						END AS ReconGroup
					,r.[OrderNo]
					,[DeliveryMonth]
					,[DealID_Recon]
					,[Account]
					,[ccy]
					,[Portfolio]
					,[CounterpartyGroup]
					,[InstrumentType]
					,[CashflowType]
					,[ProjIndexGroup]
					,[CurveName]
					,[ExternalLegal]
					,[ExternalBusinessUnit]
					,[ExternalPortfolio]
					,[DocumentNumber]
					,[Reference]
					,[partner]
					,[TradeDate]
					,[EventDate]
					,[SAP_DocumentNumber]
					,[Volume_Endur]
					,[Volume_SAP]
					,[Volume_Adj]
					,[UOM_Endur]
					,[UOM_SAP]
					,[realised_ccy_Endur]
					,[realised_ccy_SAP]
					,[realised_ccy_adj]
					,[Deskccy]
					,[realised_Deskccy_Endur]
					,[realised_Deskccy_SAP]
					,[realised_Deskccy_adj]
					,[realised_EUR_Endur]
					,[realised_EUR_SAP]
					,[realised_EUR_adj]
					,[Account_Endur]
					,[Account_SAP]
					,Diff_Volume
					,Diff_Realised_CCY
					,Diff_Realised_DeskCCY
					,Diff_Realised_EUR
					,[Identifier]
				INTO dbo.Recon_DE_All
				FROM recon r
				INNER JOIN dbo.[00_map_order] o ON r.orderno = o.orderno
				WHERE (
						r.internallegalentity IN (
							'RWEST CZ'
							,'RWEST DE'
							)
						OR Portfolio IN (
							'RGM_D_PM_STORAGE_UK'
							,'RGM_D_PM_STORAGE_UK_EPM'
							) /*Added for april since CAO Gas has 2 UK portfolios*/
						)

				/*=======================================================*/

				select @step = 7

				if @LogInfo >= 1  BEGIN insert into [dbo].[Logfile] select @proc + ' - create Table Recon_DE_Diff', GETDATE () END


				IF (
						EXISTS (
							SELECT *
							FROM INFORMATION_SCHEMA.TABLES
							WHERE TABLE_SCHEMA = 'dbo'
								AND TABLE_NAME = 'Recon_DE_Diff'
							)
						)
				BEGIN
					DROP TABLE dbo.Recon_DE_Diff
				END

				/*=======================================================*/

				SELECT CASE 
						WHEN deliverymonth IN (
								'2017/01'
								,'2017/02'
								,'2017/03'
								,'2017/04'
								,'2017/05'
								,'2017/06'
								,'2017/07'
								,'2017/08'
								,'2017/09'
								,'2017/10'
								,'2017/11'
								,'2017/12'
								)
							THEN 'PriorYear'
						ELSE CASE 
								WHEN deliverymonth IN (
										'2018/01'
										,'2018/02'
										,'2018/03'
										,'2018/04'
										,'2018/05'
										,'2018/06'
										,'2018/07'
										,'2018/08'
										,'2018/09'
										,'2018/10'
										,'2018/11'
										,'2018/12'
										)
									THEN deliverymonth
								ELSE 'other'
								END
						END AS DelMonth
					,[InternalLegalEntity]
					,r.[Desk]
					,r.[Subdesk]
					,o.book
					,ReconGroup
					,r.[OrderNo]
					,[DeliveryMonth]
					,[DealID_Recon]
					,[Account]
					,[ccy]
					,[Portfolio]
					,[CounterpartyGroup]
					,[InstrumentType]
					,[CashflowType]
					,[ProjIndexGroup]
					,[CurveName]
					,[ExternalLegal]
					,[ExternalBusinessUnit]
					,[ExternalPortfolio]
					,[DocumentNumber]
					,[Reference]
					,[partner]
					,[TradeDate]
					,[EventDate]
					,[SAP_DocumentNumber]
					,[Volume_Endur]
					,[Volume_SAP]
					,[Volume_Adj]
					,[UOM_Endur]
					,[UOM_SAP]
					,[realised_ccy_Endur]
					,[realised_ccy_SAP]
					,[realised_ccy_adj]
					,[Deskccy]
					,[realised_Deskccy_Endur]
					,[realised_Deskccy_SAP]
					,[realised_Deskccy_adj]
					,[realised_EUR_Endur]
					,[realised_EUR_SAP]
					,[realised_EUR_adj]
					,[Account_Endur]
					,[Account_SAP]
					,Diff_Volume
					,Diff_Realised_CCY
					,Diff_Realised_DeskCCY
					,Diff_Realised_EUR
					,abs(Diff_Realised_CCY) AS AbsDiff_CCY
					,[Identifier]
				INTO dbo.Recon_DE_Diff
				FROM recon r
				INNER JOIN dbo.[00_map_order] o ON r.orderno = o.orderno
				WHERE (
						abs(diff_realised_ccy) > 1
						OR abs(diff_volume) > 1
						)
					AND (
						r.internallegalentity IN (
							'RWEST DE'
							,'RWEST CZ'
							)
						OR Portfolio IN (
							'RGM_D_PM_STORAGE_UK'
							,'RGM_D_PM_STORAGE_UK_EPM'
							) /*Added for april since CAO Gas has 2 UK portfolios*/
						)
				ORDER BY InternalLegalEntity
					,Desk
					,Subdesk
					,OrderNo
					,[dealid_recon]

				/*=======================================================*/

END TRY

	BEGIN CATCH
		EXEC [dbo].[usp_GetErrorInfo] @proc, @step
		BEGIN insert into [dbo].[Logfile] select @proc + ' - FAILED', GETDATE () END		
	END CATCH

GO

