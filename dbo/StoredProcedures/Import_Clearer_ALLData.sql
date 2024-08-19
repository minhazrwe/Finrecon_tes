
/* 
-- =============================================
-- Author:      DS, MKB, MU
-- Created:     Sep 2021
-- Description:	execute clearer import routines for trade data, option premiums and settlement data, 
								run some "global" update scripts on the imported data afterwards, 
								prepare the data to query BIMs of it.
-- Changes (when/who/what):
-- 2022-07-20 // mkb // excluding nasdaq from being imported, as it gets imported via database link already
-- 2022-09-05 // mu  // Join to steuer mapping table using toolset and additionally the companycode
-- =============================================
*/

CREATE PROCEDURE [dbo].[Import_Clearer_ALLData] 
	@ClearerToImport nvarchar(20) 		/*--welche kann es geben ? --> die aus der table_clearer*/
	,@COBString nvarchar(20) = ''  /*Optional Parameter - Format 'YYYY-MM-DD' : It sets the COB date to a custom one*/
AS	
	DECLARE @ReturnValue int
	
	DECLARE @proc nvarchar(50)	
	DECLARE @step Integer	
	DECLARE @LogInfo Integer
	DECLARE @ClearerID integer
	DECLARE @COB as date
	---DECLARE @ClearerTestReportPath as nvarchar(100)
	
	BEGIN TRY
		SELECT  @Step = 1		
		--/*check if logging is enabled (0 = disabled, anything >0 = enabled */
		SELECT @LogInfo = [dbo].[LogInfo].[LogInfo] FROM [dbo].[LogInfo]
		
		IF @ClearerToImport ='Nasdaq' 
		BEGIN 
			IF @LogInfo >= 1  BEGIN insert into [dbo].[Logfile] SELECT 'Clearer - Trade Data import for ' + @ClearerToImport + ' must only be done by databaselink', GETDATE () END
			GOTO NoFurtherAction 
		END

		/* Get the COB date if not set manually by a parameter */
		IF @COBString = ''
			SELECT @COB = cast(asofdate_eom as date) FROM dbo.asofdate as cob
		ELSE
			SELECT @COB = cast(@COBString as date)
		
		IF @LogInfo >= 1  BEGIN INSERT INTO [dbo].[Logfile] SELECT 'Clearer - Import All Data - ' + @ClearerToImport + ' for COB ' + convert(varchar, @COB, 23) + ' - START', GETDATE () END
		SELECT @proc = Object_Name(@@PROCID)

		SELECT  @Step = 2		
		--/*Identify clearerID*/
		SELECT @ClearerID = ClearerID from dbo.table_Clearer WHERE ClearerName = @ClearerToImport
		
		SELECT  @Step = 3
		
		
		--/*execute the three import routines*/		
		SELECT @step=4  	
		IF @LogInfo >= 1  BEGIN INSERT INTO [dbo].[Logfile] SELECT 'Clearer - Import All Data - Part 1/3', GETDATE () END
		EXECUTE @ReturnValue = [dbo].[Import_Clearer_PremiumData] @ClearerToImport, @COBString

		IF @ReturnValue=0 
		SELECT @step=5	
		IF @LogInfo >= 1  BEGIN INSERT INTO [dbo].[Logfile] SELECT 'Clearer - Import All Data - Part 2/3', GETDATE () END
		EXECUTE @ReturnValue = [dbo].[Import_Clearer_SettlementData] @ClearerToImport, @COBString

		SELECT @step=6
		IF @LogInfo >= 1  BEGIN INSERT INTO [dbo].[Logfile] SELECT 'Clearer - Import All Data - Part 3/3', GETDATE () END
		EXECUTE @ReturnValue = [dbo].[Import_Clearer_TradeData] @ClearerToImport, @COBString

/*===========================================================================================================================================*/
		--/*now execute some data updates */

		--/*update projection index */ --> from  "00_update_ProjIndex" is the same query in all exchange-frontends
		---valid for all clearer but NASDAQ!!!
		IF @ClearerToImport <>'NASDAQ' 
		BEGIN 
			SELECT @step=7
			if @LogInfo >= 1  BEGIN insert into [dbo].[Logfile] select 'Clearer - Import All Data - Update ProjectionIndex1', GETDATE () END
		
			UPDATE dbo.table_Clearer_AccountingData 
			SET ProjectionIndex1 = CASE WHEN ContractName = 'FEUA' THEN 'EM_EUA' ELSE Commodity END
			FROM 
				dbo.table_Clearer_AccountingData 
				INNER JOIN dbo.table_Clearer_map_ExternalBusinessUnit	
				ON table_Clearer_AccountingData.AccountName = table_Clearer_map_ExternalBusinessUnit.AccountName
			WHERE 
				ProjectionIndex1 IS NULL
				AND table_Clearer_map_ExternalBusinessUnit.ExternalBusinessUnit LIKE 'NEW%'		
		END
		
		/*
		-- 2022-09-01 - Commented out since the expiry data is loaded by [dbo].[Import_Clearer_Option_Report]

		SELECT @step=8
		if @LogInfo >= 1  BEGIN insert into [dbo].[Logfile] select 'Clearer - Import All Data - Insert Missing Option Excersize Dates', GETDATE () END

	  --/*Insert missing excersize dates for options*/ --> from  "00_insert_Option_ExcersizeDate"
		---(no deletion of old data required, as we only merge new data into the table.)

		BEGIN 
			MERGE INTO dbo.table_Clearer_map_ExpirationDate AS target_table
				USING 
				(
					SELECT 
							[Trade Deal Number] AS ReferenceID
						,convert(date,Max([Leg Exercise Date]) ,103) AS ContractExpirationDate
					FROM 
						dbo.[01_realised_all]
					WHERE 
						[Leg Exercise Date] IS NOT NULL
						AND [Instrument Type Name] LIKE '%opt%'
					GROUP BY 
						 [Trade Deal Number]
					) AS source_table
				ON 
				target_table.referenceID = source_table.referenceID 
				WHEN NOT MATCHED THEN 
					INSERT (ReferenceID, ContractExpirationDate)
					VALUES (source_table.ReferenceID, source_table.ContractExpirationDate);
		END
		*/

		SELECT @step=9
		if @LogInfo >= 1  BEGIN insert into [dbo].[Logfile] select 'Clearer - Import All Data - Fill CLEARER_RECON_ZW1', GETDATE () END
		
		--/*to avoid loading duplicates, we need to delete exisiting data for this specific clearer first*/		
		DELETE FROM dbo.table_Clearer_RECON_ZW1 where clearerID = @ClearerID

---		@Kö: wir sind hier 2021-12-06
		--/* now enter the data */
		--/* first former query "01_RealisedScript_v12"	--> Anfügeanfrage an RECON_ZW1 */			 	 	
		
		
		--IF @ClearerToImport = 'NASDAQ'
		--BEGIN 
		--	INSERT INTO [dbo].[table_Clearer_RECON_ZW1]
		--						 ([COB]
		--						 ,[DataSource]
		--						 ,[Exchange]
		--						 ,[DealNumber]
		--						 ,[Deliverymonth]
		--						 ,[ProductName]
		--						 ,[ProductRecon]
		--						 ,[Commodity]
		--						 ,[Desk]
		--						 ,[InternalPortfolio]
		--						 ,[InstrumentType]
		--						 ,[ExternalBusinessUnit]
		--						 ,[Toolset]
		--						 ,[ProjectionIndex1]
		--	--           ,[ProjectionIndex2]--here not used
		--						 ,[TradePrice]
		--						 ,[CCY]
		--	--           ,[PositionStatement]--here not used
		--	--           ,[RealisedStatement]--here not used
		--						 ,[PositionEndur]
		--						 ,[RealisedEndur]
		--	           ,[ContractDate]
		--						 ,[SettlementDate]
		--	--           ,[SettlementPrice]--here not used
		--						 ,[OrderNo]
		--						 ,[LegalEntity]
		--	--					 ,[AccountName]
		--	--           ,[ContractName]--here not used
		--						 ,[ClearerID]
		--						 )
		--		SELECT 
		--			@COB as COB
		--			,'endurv12' AS DataSource		
		--			,case when instrumentgroup = 'Option' then 'NASDAQ_OPT' else 'NASDAQ' END AS Exchange
		--			,Deal
		--			,DeliveryMonth
		--			,isnull(productname, IIf(Ticker = 'not assigned', ' ', '') + Ticker) AS ProductName
		--			,deal AS ProductRecon
		--			,Commodity
		--			,IntDesk as Desk
		--			,InternalPortfolio
		--			,dbo.[02_Realised_all_details].InstrumentType
		--			,ExternalBusinessUnit
		--			,Toolset
		--			,ProjectionIndex
		--			,TradePrice
		--			,Currency as CCY
		--			,Volume as PositionEndur
		--			,Round([Realised], 2) as RealisedEndur
		--			,convert(date,eventdate,103) as SettlementDate
		--			,orderno 
		--			,LegalEntity
		--			,SAP_Account as AccountName
		--			,@ClearerID as ClearerID
		--	FROM (
		--		dbo.[02_Realised_all_details] LEFT JOIN dbo.map_instrument
		--			ON dbo.[02_Realised_all_details].InstrumentType = dbo.map_instrument.InstrumentType
		--		)
		--	LEFT JOIN dbo.table_Clearer_map_Product_InstrumentType
		--		ON (ProjectionIndex = table_Clearer_map_Product_InstrumentType.CurveName)
		--			AND (dbo.[02_Realised_all_details].InstrumentType = table_Clearer_map_Product_InstrumentType.InstrumentType)
		--	WHERE 
		--		DeliveryMonth = Format(@COB, 'yyyy\/MM')
		--		AND ExternalBusinessUnit LIKE 'NASDAQ%'		
		--END 
				
		
		IF  @ClearerToImport <> 'NASDAQ'
		SELECT @step=10
		BEGIN 
			--/*using a subselect to be able to limit the query to just ONE clearer */
			--/*so in case a new clearer appears, we just need to add the filters in an addidional OR-condition at the end*/
			INSERT INTO [dbo].[table_Clearer_RECON_ZW1]
								 ([COB]
								 ,[DataSource]
								 ,[Exchange]
								 ,[DealNumber]
								 ,[Deliverymonth]
								 ,[ProductName]
								 ,[ProductRecon]
								 ,[Commodity]
								 ,[Desk]
								 ,[InternalPortfolio]
								 ,[InstrumentType]
								 ,[ExternalBusinessUnit]           
								 ,[Toolset]
								 ,[ProjectionIndex1]
								 --,[ProjectionIndex2] --here not used
								 ,[TradePrice]
								 ,[CCY]
								 --,[PositionStatement]--here not used
								 --,[RealisedStatement]--here not used
								 ,[PositionEndur]
								 ,[RealisedEndur]
								 ,[ContractDate]
								 ,[SettlementDate]
								 --,[SettlementPrice]--here not used
								 ,[OrderNo]
								 ,[LegalEntity]
								 --,[AccountName]--here not used
								 --,[ContractName]--here not used
								 ,[ClearerID])   
				SELECT
					@COB as COB
					,DataSource
					,Exchange
					,DealNumber
					,DeliveryMonth		
					,ProductName	
					,ProductRecon
					,Commodity	
					,Desk 
					,InternalPortfolio
					,InstrumentType
					,ExternalBusinessUnit
					,Toolset
					,ProjectionIndex1
					,TradePrice
					,Currency 
					,PositionEndur
					,RealisedEndur
					,ContractDate
					,SettlementDate
					,OrderNo
					,LegalEntity
					,@ClearerID
				FROM 
				(
					SELECT 
						'endurv12' AS DataSource
						,CASE WHEN instrumentgroup = 'Option' THEN @ClearerToImport + '_OPT' ELSE @ClearerToImport END AS Exchange
						,Deal as DealNumber		
  					,DeliveryMonth	
						,Ticker AS ProductName 		
						,Deal AS ProductRecon
						,Commodity
						,IntDesk as Desk
						,InternalPortfolio
						,dbo.[02_Realised_all_details].InstrumentType
						,ExternalBusinessUnit
						,Toolset
						,ProjectionIndex as ProjectionIndex1
						,TradePrice
						,Currency 
						,Volume as PositionEndur
						,Realised as RealisedEndur
						,TradeDate as ContractDate
						,convert(date,eventdate,103) as SettlementDate
						,OrderNo
						,LegalEntity
						,@ClearerToImport as ClearerToImport
						,ExternalLegalEntity
					FROM dbo.[02_Realised_all_details]
						LEFT JOIN dbo.map_instrument
						ON dbo.[02_Realised_all_details].InstrumentType = dbo.map_instrument.InstrumentType 
				)	as subsql
				WHERE 
					---BNPPAP
					(
						ClearerToImport = 'BNPPAP' 
						AND LegalEntity = 'RWEST AP'
						AND InstrumentType NOT IN ('GAS-FWD-P', 'EM-FWD-P')
						AND ExternalBusinessUnit LIKE 'BNPP%'
						--AND Right(deliverymonth, 2) = Format(Month(@COB), '00')	
						AND deliverymonth = convert(varchar, Format(@COB,'yyyy/MM'))
					)
					OR
					---NewedgeAP
					(	
						ClearerToImport = 'NEWEDGEAP'
						AND
						((
							LegalEntity = 'RWEST AP'
							AND InstrumentType NOT IN ('GAS-FWD-P', 'EM-FWD-P')		
							AND ExternalLegalEntity IN ('SGNUK', 'SGIL')
						--AND Right(deliverymonth, 2) = Format(Month(@COB), '00')	
							AND deliverymonth = convert(varchar, Format(@COB,'yyyy/MM'))
						)
						OR 
						(
							LegalEntity = 'RWEST AP'
							AND ExternalLegalEntity IN ('SGNUK', 'SGIL')
							AND Convert(date, SettlementDate ,103) > @COB
						))
					)
					OR
					---MIZUHO
					(		
						ClearerToImport = 'MIZUHO'
						AND InstrumentType NOT IN ('GAS-FWD-P', 'EM-FWD-P')
						AND 
						(	ExternalLegalEntity IN ('ABN AMRO CLEARING BANK') ---old value, replaced by: 
							OR ExternalLegalEntity like ('%MIZUHO%CLEARING%')
						)
						--AND Right(deliverymonth, 2) = Format(Month(@COB), '00')	
						AND deliverymonth = convert(varchar, Format(@COB,'yyyy/MM'))
					)
					-----NEWEDGE
					OR
					(
						ClearerToImport = 'NEWEDGE'
						AND
						((
							InstrumentType NOT IN ('GAS-FWD-P', 'EM-FWD-P')
							AND ExternalBusinessUnit NOT IN ('SOCGEN BU')
							AND LegalEntity IN ('RWEST DE', 'RWEST UK')
							AND ExternalLegalEntity IN ('SGNUK', 'SGIL', 'SOCGEN')
							--AND Right(deliverymonth, 2) = Format(Month(@COB), '00')	
							AND deliverymonth = convert(varchar, Format(@COB,'yyyy/MM'))

						)
						OR 
						(		
							InstrumentType NOT IN ('GAS-FWD-P', 'EM-FWD-P')
							AND InstrumentType NOT LIKE '%opt%'
							AND ExternalBusinessUnit NOT IN ('SOCGEN BU')
							AND LegalEntity IN ('RWEST DE', 'RWEST UK')
							AND ExternalLegalEntity IN ('SGNUK', 'SGIL', 'SOCGEN')		
							AND CONVERT(DATE, SettlementDate,103) > @COB
						))			
					)
					OR
					---BNPP
					(
						ClearerToImport = 'BNPP'
						AND ExternalBusinessUnit LIKE 'BNPP%'
						AND LegalEntity IN ('RWEST UK', 'RWEST DE')
						AND 
						(
							--Right(deliverymonth, 2) = Format(Month(@COB), '00')			
							deliverymonth = convert(varchar, Format(@COB,'yyyy/MM'))
							OR 
							CONVERT(DATE, SettlementDate	,103) > @COB			
						)
					)
					OR
					---SOCGENJP
					(
						ClearerToImport = 'SOCGENJP'
						AND LegalEntity IN ('RWEST Japan')
						AND LegalEntity IN ('SGIL')	
					)

		END

		--/* then former query "02_NewEdge", not applicable for NASDAQ --> Anfügeanfrage an RECON_ZW1*/
		IF @ClearerToImport <> 'NASDAQ'
		SELECT @step=11
		BEGIN
			INSERT INTO [dbo].[table_Clearer_RECON_ZW1]
									 ([COB]
									 ,[DataSource]
									 ,[Exchange]
									 ,[DealNumber]
									 ,[Deliverymonth]
									 ,[ProductName]
									 ,[ProductRecon]
									 ,[Commodity]
									 ,[Desk]
									 ,[InternalPortfolio]
  								 ---,[InstrumentType] --here not used
									 ---,[ExternalBusinessUnit] --here not used
									 ,[Toolset]
									 ,[ProjectionIndex1]
									 ,[ProjectionIndex2] 
									 ,[TradePrice]
									 ,[CCY]	
									 ,[PositionStatement]
									 ,[RealisedStatement]
									 ---,[PositionEndur]--here not used
									 ---,[RealisedEndur]--here not used
									 ,[ContractDate]
									 ,[SettlementDate]
									 ,[SettlementPrice]
									 ,[OrderNo]
									 ,[LegalEntity]
									 ,[AccountName]
									 ,[ContractName]
									 ,[ClearerID])   
				SELECT 
         @COB	 
				,@clearertoimport as Datasource
				,IIf([contractname] = 'Option', @clearertoimport + '_OPT', @clearertoimport) AS Exchange
				,DealNumber
				,Format(ContractDate, 'yyyy\/MM') AS Deliverymonth
				,ContractName AS ProductName
				,DealNumber as ProductRecon
				,map_ProjIndex.Commodity
				,map_order.Desk
				,InternalPortfolio
				,dbo.table_Clearer_AccountingData.Toolset
				,ProjectionIndex1
				,ProjectionIndex2
				,TradePrice	
				,dbo.table_Clearer_AccountingData.CCY ---vorher: Left(table_Clearer_map_ExternalBusinessUnit.account2, 3) AS CCY
				,Position as PositionStatement
				,RealisedPnL as RealisedStatement
				,ContractDate
				,SettlementDate
				,SettlementPrice
				,map_order.OrderNo
				,map_order.LegalEntity	 	
				,dbo.table_Clearer_AccountingData.AccountName	
				,ContractName
				,@clearerid	
			FROM 
				dbo.table_Clearer_AccountingData 
				LEFT JOIN dbo.map_order
				ON dbo.table_Clearer_AccountingData.InternalPortfolio= dbo.map_order.Portfolio
				LEFT JOIN dbo.table_Clearer_map_LegalEntity_CompanyCode
				ON dbo.map_order.LegalEntity = dbo.table_Clearer_map_LegalEntity_CompanyCode.LegalEntity
				LEFT JOIN dbo.table_Clearer_map_Steuer
				ON dbo.table_Clearer_AccountingData.Toolset = dbo.table_Clearer_map_Steuer.Toolset and dbo.table_Clearer_map_LegalEntity_CompanyCode.CompanyCode = dbo.table_Clearer_map_Steuer.CompanyCode
				LEFT JOIN table_Clearer_map_ExternalBusinessUnit
				ON dbo.table_Clearer_AccountingData.AccountName = table_Clearer_map_ExternalBusinessUnit.AccountName
				LEFT JOIN dbo.map_ProjIndex
				ON dbo.table_Clearer_AccountingData.ProjectionIndex1 = map_ProjIndex.ProjIndex
			WHERE 
				dbo.map_order.[system]='v12'
				and dbo.table_Clearer_AccountingData.ClearerID = @clearerID

		END
		
		--/*special case Nasdaq --> "02_update_map_ticker" */
		
		--ACHTUNG !!!! überprüfe die tabelle "Nasdaq_SettledDeals"
		
		----------IF  @ClearerToImport = 'NASDAQ'
		----------BEGIN 
		----------	INSERT INTO dbo.map_DealID_Ticker ( DealID, Ticker, InstrumentTypeName )
		----------		SELECT 
		----------			[Deal Number], 
		----------			Contract, 
		----------			NULL 
		----------		FROM Nasdaq_SettledDeals
		----------		WHERE Nasdaq_SettledDeals.[Deal Number] Is Not Null
		----------END
		

		SELECT @step=12  		
		if @LogInfo >= 1  BEGIN insert into [dbo].[Logfile] select 'Clearer - Import All Data - Fill RECON', GETDATE () END

		--/*transfer summed data from RECONZW1 to Recon */ --> "03_Recon" not valid for NASDAQ 
		IF @ClearerToImport<>'NASDAQ'
		BEGIN		
			INSERT INTO [dbo].[table_Clearer_Recon](
				COB
				,Exchange
				,LegalEntity
				,Deliverymonth
				,OrderNo
				,Desk
				,ProductRecon
				,InstrumentType
				,InternalPortfolio
				,ExternalBusinessUnit
				,AccountName
				,DealNumber
				,ProductName
				,ContractName
				,Toolset
				,ProjectionIndex1
				,ProjectionIndex2
				,ContractDate
				,SettlementDate
				,TradePrice
				,SettlementPrice
				,PositionStatement
				,PositionEndur
				,RealisedStatement
				,RealisedEndur
				,CCY
				,RealisedDifference
				,Commodity
				,ClearerID
				)
			SELECT 
				@COB
				,Exchange
				,Max(LegalEntity) AS MaxvonLegalEntity
				,Deliverymonth
				,Max(OrderNo) AS MaxvonAuftrag
				,Desk
				,Max(ProductRecon) AS MaxvonProduct_Recon
				,Max(InstrumentType) AS MaxvonInsType
				,Max(InternalPortfolio) AS MaxvonPortfolio
				,Max(ExternalBusinessUnit) AS MaxvonExternalBusinessUnit
				,Max(AccountName) AS MaxvonAccount
				,DealNumber
				,Max(ProductName) AS MaxvonProduct
				,Max(ContractName) AS MaxvonContract
				,Max(Toolset) AS MaxvonToolset
				,Max(ProjectionIndex1) AS MaxvonProjIndex1
				,Max(ProjectionIndex2) AS MaxvonProjIndex2
				,Max(ContractDate) AS MaxvonContractDate
				,Max(SettlementDate) AS MaxvonSettlementDate
				,Max(TradePrice) AS MaxvonTradePrice
				,Max(SettlementPrice) AS MaxvonSettlementPrice
				,Sum(PositionStatement) AS SummevonPosition_Statement
				,Sum(PositionEndur) AS SummevonPosition_Endur
				,Sum(RealisedStatement) AS SummevonRealised_Statement
				,Sum(RealisedEndur) AS SummevonRealised_Endur
				,Max(CCY) AS MaxvonCurrency
				,Sum(RealisedStatement - RealisedEndur) AS RealisedDifference
				,Max(Commodity) AS MaxvonCommodity
				,@ClearerID
			FROM 
				dbo.table_Clearer_RECON_ZW1
			WHERE 
				ClearerID = @ClearerID
			GROUP BY 
				 Exchange
				,Deliverymonth
				,Desk
				,DealNumber
		END
		
		SELECT @step=13
		if @LogInfo >= 1  BEGIN insert into [dbo].[Logfile] select 'Clearer - Import All Data - update DealID Ticker mapping', GETDATE () END			
		
		--/**/ --> 03b_update_DealID_Ticker /"02_update_map_ticker" 
		MERGE INTO dbo.map_DealID_Ticker AS target_table
			USING 
			(
				SELECT 
						DealNumber
					,Toolset 
					,ContractName
					,ClearerID
				FROM 
					dbo.table_Clearer_AccountingData
				WHERE
					---bnpp, bnppICE
					(ClearerID in (1,11) AND ClearerID=@ClearerID AND (Toolset='ComSwap' OR (Toolset='Power' AND ProjectionIndex1 Not In ('vPWR_UK_F'))))
					OR ---bnppAP 
					(ClearerID=2 AND ClearerID=@ClearerID AND (Toolset='Power' Or Toolset='COMSWAP' OR (Toolset='COMFUT' AND ContractName='FEUA' AND AccountName='RECC1')))
					OR ---newedge
					(ClearerID=5 AND ClearerID=@ClearerID AND (Toolset='Power' Or Toolset='COMSWAP' OR (Toolset='COMFUT' AND ContractName='FEUA' AND AccountName='RECC1')))
					OR ---newedgeAP
					(ClearerID=6 AND ClearerID=@ClearerID AND (Toolset='Power' Or Toolset='COMSWAP' OR (Toolset='COMFUT' AND ContractName='FEUA' AND AccountName='RECC1')))
					OR ---mizuho
					(ClearerID=3 AND ClearerID=@ClearerID AND (Toolset='COMMODITY' Or Toolset='ComFut'))
					OR ---NASDAQ
					(ClearerID=4 AND ClearerID = @ClearerID AND DealNumber Is Not Null )
					/*
					OR --> SocGenJP und BNPPJP fehlt noch							
					*/
				GROUP BY 
						DealNumber
						,Toolset 
						,ContractName
						,ClearerID
			) AS source_table
			ON 
			target_table.DealID = source_table.DealNumber 
			WHEN NOT MATCHED THEN 
				INSERT (DealID, InstrumentTypeName, Ticker)
				VALUES (DealNumber, CASE WHEN @clearertoimport = 'NASDAQ' THEN '' ELSE Toolset END, ContractName);

			
			
NoFurtherAction:
		IF @LogInfo >= 1  BEGIN INSERT INTO [dbo].[Logfile] SELECT 'Clearer - Import All Data - ' + @ClearerToImport + ' - FINISHED', GETDATE () END
	END TRY

	BEGIN CATCH
		EXEC [dbo].[usp_GetErrorInfo] @proc, @step
		BEGIN INSERT INTO [dbo].[Logfile] SELECT 'Clearer - Import All Data - ' + @ClearerToImport + ' - FAILED', GETDATE () END
	END CATCH

GO

