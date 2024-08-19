
/* ==========================================================================================================
author:				MKB
created:			September 2021 
Description:	prepares the BIM for the given Clearer by running several preparational queries.
							to speed up the process, a lot of data will be written into helper tables.
							The final bim results are queried from within MS Access in a "save_and_export_query" routine 
-------------------------------------------------------------------------------------------------------------
changes: when, who, step, what, (why)
2024-04-24, MK,		overall,	replaced "BuySell" with "PayReceive"
2024-04-30, MKB,	overall,	prepare consideration of data directly taken from BocarX , as it is stored in different tables.
2024-04-30, MKB,	overall,	refurbished step-logic & switched to new write_log approach
2024-05-30, PG,				,	added the Options part
2024-07-24, PG,				,	changed in the Options Part values from "TotalFee" to "Premium"
=============================================================================================================*/

CREATE PROCEDURE [dbo].[Clearer_BIM_creation] 
	@ClearerName nvarchar(20) 			/*Clearer Names: SELECT ClearerName FROM [FinRecon].[dbo].[table_Clearer]*/
	,@COBString nvarchar(20) = ''		/*Optional Parameter - Format 'YYYY-MM-DD' : It sets the COB date to a custom one*/
AS
	
	DECLARE @ReturnValue int	
	DECLARE @Current_Procedure nvarchar(50)	
	DECLARE @step Integer	
	DECLARE @LogInfo Integer
	
	DECLARE @ClearerID integer
	DECLARE @COB as date
	DECLARE @BocarXSourced as integer
	DECLARE @Record_Counter as int
	DECLARE @Warning_Counter as int 
	DECLARE @Status_Text as varchar(100)	 		

	BEGIN TRY
		SELECT  @Step = 0
		SELECT @Current_Procedure = Object_Name(@@PROCID)		
		EXEC dbo.Write_Log 'Info', 'START', @Current_Procedure, NULL, NULL, @step, 1

		SELECT @Step = 2		
		SELECT @ClearerID = ClearerID from dbo.table_Clearer WHERE ClearerName = @ClearerName
		SELECT @BocarXSourced = ClearerDBRelevant from dbo.table_clearer where ClearerID = @ClearerID /* those sourced from BocarX got a value of "2" */
				
		SELECT  @Step =3		
		IF @COBString = ''
			SELECT @COB = cast(asofdate_eom as date) FROM dbo.asofdate as cob
		ELSE
			SELECT @COB = @COBString
		
		SET @Status_Text = 'Create BIM for ' + @ClearerName + ', COB: ' + cast (@COB as varchar) 
		EXEC dbo.Write_Log 'Info', @Status_Text , @Current_Procedure, NULL, NULL, @step, 1

		/*preparing the BIMs means: fill some helper tables to speed up overall BIM generation, but delete any data for the specific clearer upfront   */
		
		SELECT @step=4  	
		SET @Status_Text = 'delete old data' 
		EXEC dbo.Write_Log 'Info', @Status_Text , @Current_Procedure, NULL, NULL, @step, 1
				
		/*delete existing data from the helper table*/
		DELETE FROM dbo.table_Clearer_BIM_preparation_Helper WHERE ClearerID = @ClearerID
		
		/*delete existing data for final BIM data. */
		DELETE FROM dbo.table_Clearer_BIM WHERE clearerID=@clearerID 

		SELECT @step=6  	
		SET @Status_Text = 'refill data tables.' 
		EXEC dbo.Write_Log 'Info', @Status_Text , @Current_Procedure, NULL, NULL, @step, 1

		/*fill the helper table that relpaces the formerly used "SELECT * from 10_bim_vorb_pnl union all select * from 10_bim_vorb_fee" */
		INSERT into dbo.table_Clearer_BIM_preparation_Helper		
		SELECT 
			a.* 
		FROM 
			/*2 Selects combined by a Union: Accounting Data, Deal Data (Fees) and Deal Data (Options) */
			(	SELECT '' AS Position
				,IIf(AccData.realisedpnl > 0, '50', '40') AS BS
				,IIf(MapTaxcode.ProductName = 'Option', IIf(realisedpnl > 0, optionsSell, optionsBuy), IIf(realisedpnl > 0, futuresSell, futuresBuy)) AS Konto
				,MapOrder.OrderNo AS Auftrag
				--,IIf(stkzloss = 'vn', Format(contractexpirationDate, 'dd.MM.yyyy'), Format(contractdate, 'yyyy/MM')) AS Zuordnung
				--,IIf(MapTaxcode.productname = 'Option', Format(contractexpirationDate, 'dd.MM.yyyy'), Format(contractdate, 'yyyy/MM')) AS Zuordnung
				,Format(isnull(MapExpDate.ContractExpirationDate,AccData.contractdate), 'yyyy/MM') AS Zuordnung
				,Round(Abs(Sum(RealisedPNL)), 2) AS BetragFW
				,IIf(MapTaxcode.ProductName = 'Option', DealNumber, contractname) + ';' + MapClearer.ClearerCountry + ';' + isnull(ExternalBusinessUnit, ClearerName) + ';' + IIf(contractexpirationdate IS NULL, Format(SettlementDate, 'yyyy/MM'), Format(contractexpirationDate, 'dd.MM.yyyy')) AS BuchungsText
				,IIf(AccData.realisedPNL > 0, MapTaxcode.STKZProfit, MapTaxcode.STKZLoss) AS StKz
				,MapLegEntCC.CompanyCode AS BuKr
				,MapClearer.ClearerSpotBalanceAccount AS Debitor
				,IIf(MapTaxcode.productname = 'Option', MapKonten.MaterialCodeOption, MapKonten.MaterialCode) AS MaterialCode
				,'/' AS Kostenstelle
				,MapOrder.LegalEntity
				,AccData.InternalPortfolio
				,MapTaxcode.ProductName AS Category
				,AccData.CCY
				,IIf(realisedpnl < 0, 'PAY', 'RECEIVE') AS PayReceive
				,Round(Sum(AccData.RealisedPNL),2) AS realisedPNL
				,AccData.AccountName
				,AccData.ProjectionIndex1
				,AccData.Toolset
				,AccData.SettlementDate
				,AccData.ContractDate
				,AccData.ContractName
				,AccData.ProductName
				,Isnull(MapProjIdx.Commodity,MapExtBU.Commodity) as Commodity
				,IIf(MapTaxcode.ProductName = 'Option', DealNumber, '') as DealID
				,NULL as DocumentPartition
				,@ClearerID AS ClearerID
				,MapClearer.ClearerSpotBalanceAccount 
				,MapClearer.ClearerName
				,MapClearer.ClearerCountry
				,@COB AS COB
				,1 AS SRC
			FROM dbo.table_Clearer_AccountingData AS AccData
			LEFT JOIN dbo.table_Clearer_map_ExternalBusinessUnit AS MapExtBU ON AccData.AccountName = MapExtBU.AccountName and MapExtBU.ClearerID = @ClearerID
			LEFT JOIN dbo.table_Clearer_map_ExpirationDate AS MapExpDate ON AccData.DealNumber = MapExpDate.ReferenceID
			LEFT JOIN dbo.map_order AS MapOrder ON AccData.InternalPortfolio = MapOrder.Portfolio
			LEFT JOIN dbo.table_Clearer AS MapClearer ON AccData.ClearerID = MapClearer.ClearerID
			LEFT JOIN dbo.map_ProjIndex AS MapProjIdx ON AccData.ProjectionIndex1 = MapProjIdx.ProjIndex
			LEFT JOIN dbo.table_Clearer_map_Konten AS MapKonten ON Isnull(MapProjIdx.Commodity,MapExtBU.Commodity) = MapKonten.Commodity
			LEFT JOIN dbo.table_Clearer_map_LegalEntity_CompanyCode AS MapLegEntCC ON MapOrder.LegalEntity = MapLegEntCC.LegalEntity
			--LEFT JOIN dbo.table_Clearer_map_Steuer AS MapSteuer ON AccData.Toolset = MapSteuer.Toolset AND MapLegEntCC.CompanyCode = MapSteuer.CompanyCode
			LEFT JOIN dbo.table_Clearer_map_Toolset_Product as MapToolset on AccData.Toolset = MapToolset.Toolset
			LEFT JOIN dbo.table_Clearer_map_Taxcode as MapTaxcode on MapToolset.ProductName = MapTaxcode.ProductName and MapLegEntCC.CompanyCode = MapTaxcode.CompanyCode and MapClearer.ClearerCountry = MapTaxcode.ClearerCountry
			WHERE AccData.clearerID = @clearerID
			and Format(COB, 'yyyy/MM') = Format(@COB, 'yyyy/MM')
			GROUP BY IIf(realisedpnl > 0, '50', '40')
				,IIf(MapTaxcode.ProductName = 'Option', IIf(realisedpnl > 0, optionsSell, optionsBuy), IIf(realisedpnl > 0, futuresSell, futuresBuy))
				,MapOrder.OrderNo
				--,IIf(stkzloss = 'vn', Format(contractexpirationDate, 'dd.MM.yyyy'), Format(contractdate, 'yyyy/MM'))
				--,IIf(MapTaxcode.productname = 'Option', Format(contractexpirationDate, 'dd.MM.yyyy'), Format(contractdate, 'yyyy/MM'))
				,Format(isnull(MapExpDate.ContractExpirationDate,AccData.contractdate), 'yyyy/MM')
				,IIf(MapTaxcode.ProductName = 'Option', DealNumber, contractname) + ';' + MapClearer.ClearerCountry + ';' + isnull(ExternalBusinessUnit, ClearerName) + ';' + IIf(contractexpirationdate IS NULL, Format(SettlementDate, 'yyyy/MM'), Format(contractexpirationDate, 'dd.MM.yyyy'))
				,IIf(realisedPNL > 0, STKZProfit, STKZLoss)
				,MapLegEntCC.CompanyCode
				,MapClearer.ClearerSpotBalanceAccount
				,IIf(MapTaxcode.productname = 'Option', MapKonten.MaterialCodeOption, MapKonten.MaterialCode)
				,IIf(MapTaxcode.ProductName = 'Option', DealNumber, '')										   
				,MapOrder.LegalEntity
				,AccData.InternalPortfolio
				,MapTaxcode.ProductName
				,AccData.CCY
				,IIf(realisedpnl < 0, 'PAY', 'RECEIVE')
				,AccData.AccountName
				,AccData.ProjectionIndex1
				,AccData.Toolset
				,AccData.SettlementDate
				,AccData.ContractDate
				,AccData.ContractName
				,AccData.ProductName
				,MapProjIdx.Commodity
				,MapExtBU.Commodity
				,MapClearer.ClearerSpotBalanceAccount
				,MapClearer.ClearerName
				,MapClearer.ClearerCountry
			HAVING (Round(Abs(Sum(RealisedPNL)), 2) <> 0)
			/*AND Format(SettlementDate, 'yyyy_MM') in (Format(@cob, 'yyyy_MM'))*/

			UNION ALL

			/*SELECT all Deals from table_Clearer_DealData (Clearingfee)*/
			SELECT '' AS Position
				,IIf(Totalfee > 0, '50', '40') AS BS
				,MapKonten.Fee AS Konto
				,isnull(MapOrder.OrderNo, MapExtBU.InternalOrder) AS Auftrag
				,Format(ReportDate, 'yyyy/MM') AS Zuordnung
				,Round(Abs(Sum(TotalFee)), 2) AS BetragFW
			    ,ClearerName + ';' + MapClearer.ClearerCountry + ';' + isnull(MapProjIdx.Commodity, isnull(MapExtBU.Commodity, 'UNKOWN')) + + ';Clearingfee;Commission; ' + Format(reportDate, 'MM/yyyy') AS BuchungsText
				--,IIf(isnull(MapOrder.legalentity,MapOrder_Closing.legalentity) = 'RWEST UK', '88', 'U1') AS StKz
				,IIf(Totalfee > 0, MapTaxcode.STKZProfit, MapTaxcode.STKZLoss)
				,MapLegEntCC.CompanyCode AS Bukr
				,MapClearer.ClearerSpotBalanceAccount AS Debitor --Ref1
				,MapKonten.MaterialCodeFEE AS MaterialCode
				,'/' AS Kostenstelle
				,isnull(MapOrder.legalentity,MapOrder_Closing.legalentity) as LegalEntity
				,DealData.InternalPortfolio AS InternalPortfolio
		    	,'Fee' AS Category        
			---	,CASE WHEN DealData.ContractName LIKE '%O' THEN 'OptionPremium' ELSE 'Fee' END As Category
				,DealData.Ccy AS CCY
				,IIf(Totalfee < 0, 'PAY', 'RECEIVE') AS PayReceive
			    ,Round(Sum(TotalFee),2) AS RealisedPNL
				,NULL AS AccountName
				,NULL AS ProjectionIndex1
				,DealData.Toolset AS Toolset
				,NULL AS SettlementDate
				,NULL AS ContractDate
				,NULL AS ContractName
				,NULL AS ProductName
				,isnull(MapProjIdx.Commodity, isnull(MapExtBU.Commodity, 'UNKOWN')) AS Commodity
				,NULL AS DealID 
				,NULL as DocumentPartition
				,@ClearerID AS ClearerID
				,MapClearer.ClearerSpotBalanceAccount 
				,MapClearer.ClearerName
				,MapClearer.ClearerCountry
				,@COB AS COB
				,2 AS SRC
			FROM dbo.table_Clearer_DealData AS DealData
			LEFT JOIN.[dbo].[table_Clearer_map_ExternalBusinessUnit] AS MapExtBU ON DealData.AccountName = MapExtBU.AccountName and MapExtBU.ClearerID = @ClearerID /*Join needed for Closing trades*/
			LEFT JOIN dbo.map_ProjIndex AS MapProjIdx ON DealData.ProjectionIndex1 = MapProjIdx.ProjIndex
			LEFT JOIN dbo.table_Clearer_map_Konten AS MapKonten ON Isnull(MapProjIdx.Commodity,MapExtBU.Commodity) = MapKonten.Commodity
			LEFT JOIN dbo.map_order AS MapOrder ON DealData.InternalPortfolio = MapOrder.Portfolio
			LEFT JOIN 
			(
				SELECT DISTINCT LegalEntity
					,OrderNo
				FROM 
					dbo.map_order
				WHERE 
					isnull(LegalEntity, 'n/a') != 'n/a'
			) AS MapOrder_Closing ON MapExtBU.InternalOrder = MapOrder_Closing.[OrderNo] --Join needed for Closing trades
			LEFT JOIN dbo.table_Clearer AS MapClearer ON DealData.ClearerID = MapClearer.ClearerID
			LEFT JOIN dbo.table_Clearer_map_LegalEntity_CompanyCode AS MapLegEntCC ON isnull(MapOrder.LegalEntity,MapOrder_Closing.LegalEntity) = MapLegEntCC.LegalEntity
			--LEFT JOIN dbo.table_Clearer_map_Toolset_Product as MapToolset on DealData.Toolset = MapToolset.Toolset
			LEFT JOIN dbo.table_Clearer_map_Taxcode as MapTaxcode on MapTaxcode.ProductName = 'Fees' and MapLegEntCC.CompanyCode = MapTaxcode.CompanyCode and MapClearer.ClearerCountry = MapTaxcode.ClearerCountry
			WHERE 
				DealData.ClearerID = @clearerID
				AND Format(reportDate, 'yyyy/MM') = Format(@COB, 'yyyy/MM')
			GROUP BY 
				IIf(Totalfee > 0, '50', '40')
				,MapKonten.Fee
				,MapOrder.OrderNo
				,IIf(Totalfee > 0, MapTaxcode.STKZProfit, MapTaxcode.STKZLoss)
				,Format(reportDate, 'yyyy/MM')
				,Format(reportDate, 'MM/yyyy')
				,ClearerName
				,MapClearer.ClearerCountry
				,MapProjIdx.Commodity
				,MapExtBU.Commodity
				,IIf(MapOrder.legalentity = 'RWEST UK', '/', 'U1')
				,MapLegEntCC.CompanyCode
				,MapClearer.ClearerSpotBalanceAccount
				,MapKonten.MaterialCodeFEE
				,MapOrder.LegalEntity
				,MapOrder_Closing.legalentity
				,DealData.InternalPortfolio
				,DealData.Ccy
				,IIf(Totalfee < 0, 'PAY', 'RECEIVE')
				,MapExtBU.InternalOrder
				,MapExtBU.Commodity
				,MapClearer.ClearerSpotBalanceAccount 
				,MapClearer.ClearerName
				,MapClearer.ClearerCountry
				,DealData.ContractName
				,DealData.Toolset
			HAVING 
				Round(Abs(Sum(TotalFee)), 2) <> 0
				) as a

			--				UNION ALL

			--/*SELECT all Options from table_Clearer_DealData   ------- THIS IS FOR OPTIONS*/
			--SELECT '' AS Position
			--	,IIf(Premium > 0, '50', '40') AS BS
			--	,MapKonten.Fee AS Konto
			--	,IIf(Position > 0, MapKonten.OptionsBuy, MapKonten.OptionsSell) AS Konto
			--	,isnull(MapOrder.OrderNo, MapExtBU.InternalOrder) AS Auftrag
			--	,Format(ReportDate, 'yyyy/MM') AS Zuordnung
			--	,Format(isnull(MapExpDate.ContractExpirationDate,DealData.ReportDate), 'yyyy/MM') AS Zuordnung
			--	,Round(Abs(Sum(Premium)), 2) AS BetragFW
			--    ,ClearerName + ';' + MapClearer.ClearerCountry + ';' + isnull(MapProjIdx.Commodity, isnull(MapExtBU.Commodity, 'UNKOWN')) + + ';Option; ' + Format(reportDate, 'MM/yyyy') AS BuchungsText
			--	,DealNumber + ';' + MapClearer.ClearerCountry + ';' + ClearerName + ';' + Format(reportDate, 'MM/yyyy') AS BuchungsText
			--	,IIf(isnull(MapOrder.legalentity,MapOrder_Closing.legalentity) = 'RWEST UK', '88', 'U1') AS StKz
			--	,IIf(Totalfee > 0, MapTaxcode.STKZProfit, MapTaxcode.STKZLoss)
			--	,MapLegEntCC.CompanyCode AS Bukr
			--	,MapClearer.ClearerSpotBalanceAccount AS Debitor --Ref1
			--	,MapKonten.MaterialCodeOption AS MaterialCode
			--	,'/' AS Kostenstelle
			--	,isnull(MapOrder.legalentity,MapOrder_Closing.legalentity) as LegalEntity
			--	,DealData.InternalPortfolio AS InternalPortfolio
		 --   	,'Option' AS Category        
			---	,CASE WHEN DealData.ContractName LIKE '%O' THEN 'OptionPremium' ELSE 'Fee' END As Category
			--	,DealData.Ccy AS CCY
			--	,IIf(Totalfee < 0, 'PAY', 'RECEIVE') AS PayReceive
			--    ,Round(Sum(Premium),2) AS RealisedPNL
			--	,NULL AS AccountName
			--	,NULL AS ProjectionIndex1
			--	,DealData.Toolset AS Toolset
			--	,NULL AS SettlementDate
			--	,NULL AS ContractDate
			--	,NULL AS ContractName
			--	,NULL AS ProductName
			--	,isnull(MapProjIdx.Commodity, isnull(MapExtBU.Commodity, 'UNKOWN')) AS Commodity
			--	,IIf(MapTaxcode.ProductName = 'Option', DealNumber, '') as DealID
			--	,NULL as DocumentPartition
			--	,@ClearerID AS ClearerID
			--	,MapClearer.ClearerSpotBalanceAccount 
			--	,MapClearer.ClearerName
			--	,MapClearer.ClearerCountry
			--	,@COB AS COB
			--	,2 AS SRC
			--FROM dbo.table_Clearer_DealData AS DealData
			--LEFT JOIN.[dbo].[table_Clearer_map_ExternalBusinessUnit] AS MapExtBU ON DealData.AccountName = MapExtBU.AccountName and MapExtBU.ClearerID = @ClearerID /*Join needed for Closing trades*/
			--LEFT JOIN dbo.map_ProjIndex AS MapProjIdx ON DealData.ProjectionIndex1 = MapProjIdx.ProjIndex
			--LEFT JOIN dbo.table_Clearer_map_Konten AS MapKonten ON Isnull(MapProjIdx.Commodity,MapExtBU.Commodity) = MapKonten.Commodity
			--LEFT JOIN dbo.map_order AS MapOrder ON DealData.InternalPortfolio = MapOrder.Portfolio
			--LEFT JOIN dbo.table_Clearer_map_ExpirationDate AS MapExpDate ON DealData.DealNumber = MapExpDate.ReferenceID
			--LEFT JOIN 
			--(
			--	SELECT DISTINCT LegalEntity
			--		,OrderNo
			--	FROM 
			--		dbo.map_order
			--	WHERE 
			--		isnull(LegalEntity, 'n/a') != 'n/a'
			--) AS MapOrder_Closing ON MapExtBU.InternalOrder = MapOrder_Closing.[OrderNo] --Join needed for Closing trades
			--LEFT JOIN dbo.table_Clearer AS MapClearer ON DealData.ClearerID = MapClearer.ClearerID
			--LEFT JOIN dbo.table_Clearer_map_LegalEntity_CompanyCode AS MapLegEntCC ON isnull(MapOrder.LegalEntity,MapOrder_Closing.LegalEntity) = MapLegEntCC.LegalEntity
			--LEFT JOIN dbo.table_Clearer_map_Toolset_Product as MapToolset on DealData.Toolset = MapToolset.Toolset
			--LEFT JOIN dbo.table_Clearer_map_Taxcode as MapTaxcode on MapTaxcode.ProductName = 'Option' and MapLegEntCC.CompanyCode = MapTaxcode.CompanyCode and MapClearer.ClearerCountry = MapTaxcode.ClearerCountry
			--WHERE 
			--	DealData.ClearerID = @clearerID
			--	AND Format(reportDate, 'yyyy/MM') = Format(@COB, 'yyyy/MM')
			--	AND Toolset IN ('ComOptFut','ComOpt')
			--GROUP BY 
			--	IIf(Premium > 0, '50', '40')
			--	,MapKonten.OptionsBuy
			--	,MapKonten.OptionsSell
			--	,Position
			--	,MapOrder.OrderNo
			--	,IIf(Totalfee > 0, MapTaxcode.STKZProfit, MapTaxcode.STKZLoss)
			--	,Format(reportDate, 'yyyy/MM')
			--	,Format(isnull(MapExpDate.ContractExpirationDate,DealData.ReportDate), 'yyyy/MM')
			--	,Format(reportDate, 'MM/yyyy')
			--	,DealNumber
			--	,MapClearer.ClearerCountry
			--	,MapProjIdx.Commodity
			--	,MapExtBU.Commodity
			--	,IIf(MapOrder.legalentity = 'RWEST UK', '/', 'U1')
			--	,MapLegEntCC.CompanyCode
			--	,MapClearer.ClearerSpotBalanceAccount
			--	,MapKonten.MaterialCodeOption
			--	,MapOrder.LegalEntity
			--	,MapOrder_Closing.legalentity
			--	,DealData.InternalPortfolio
			--	,DealData.Ccy
			--	,IIf(Totalfee < 0, 'PAY', 'RECEIVE')
			--	,MapExtBU.InternalOrder
			--	,MapExtBU.Commodity
			--	,IIf(MapTaxcode.ProductName = 'Option', DealNumber, '')	
			--	,MapClearer.ClearerSpotBalanceAccount 
			--	,MapClearer.ClearerName
			--	,MapClearer.ClearerCountry
			--	,DealData.ContractName
			--	,DealData.Toolset
			--HAVING 
			--	Round(Abs(Sum(TotalFee)), 2) <> 0
				

		SELECT @step=8  	
		SET @Status_Text = 'Set document partition to split documents which might exceed 999 rows' 
		EXEC dbo.Write_Log 'Info', @Status_Text , @Current_Procedure, NULL, NULL, @step, 1

		/* Update the data for OptionPremium */


		/*Set the DocumentPartition which is used to split documents which might exceed 999 rows*/
		UPDATE dbo.table_Clearer_BIM_preparation_Helper
		SET DocumentPartition = floor(helper.rownumber/900)
		FROM dbo.table_Clearer_BIM_preparation_Helper bim_prep
		JOIN (
			SELECT ROW_NUMBER() OVER (
					PARTITION BY Bukr /*Buchungskreis*/ ,CCY, PayReceive
					ORDER BY Bukr,CCY,PayReceive,ID ASC
					) AS rownumber
				,ID
			FROM dbo.table_Clearer_BIM_preparation_Helper
			WHERE ClearerID = @clearerID and DocumentPartition is null
			) AS helper ON bim_prep.ID = helper.ID
			
		SELECT @step=10  	
		SET @Status_Text = 'add transfer from RWEST UK to RWEST DE per CCY to helper table'  /*(In the past: 1486611) */
		EXEC dbo.Write_Log 'Info', @Status_Text , @Current_Procedure, NULL, NULL, @step, 1
		  	
		/*Booking for RWEST UK*/
		INSERT into dbo.table_Clearer_BIM_preparation_Helper
				SELECT
				''
				,IIf(Sum(RealisedPNL) < 0, '37', '07') as BS
				,[PETransferAccount] AS Konto 
				,'' AS Auftrag
				,Format(COB, 'yyyy/MM') AS Zuordnung
				,Round(Abs(Sum(RealisedPNL)), 2) AS BetragFW
				,'Transfer' AS BuchungsText
				,'/' AS StKz
				,bukr AS Bukr --Always 0611
				,null AS Debitor --Ref1
				,'/' AS MaterialCode
				,'/' AS Kostenstelle
				,'/'
				,'all' AS InternalPortfolio
				,'Transfer' AS Category
				,CCY AS CCY
				,PayReceive as PayReceive
				,-1 * Round(Sum(RealisedPNL),2) AS RealisedPNL
				,NULL AS AccountName
				,NULL AS ProjectionIndex1
				,NULL AS Toolset
				,NULL AS SettlementDate
				,NULL AS ContractDate
				,NULL AS ContractName
				,NULL AS ProductName
				,NULL AS Commodity
				,NULL AS DealID   
				,DocumentPartition as DocumentPartition
				,@ClearerID AS ClearerID
				,ClearerSpotBalanceAccount as ClearerSpotBalanceAccount
				,ClearerName as ClearerName
				,ClearerCountry as ClearerCountry
				,@COB AS COB
				,3 AS SRC
				FROM 
					dbo.table_Clearer_BIM_preparation_Helper
					LEFT JOIN  [dbo].[table_Clearer_map_LegalEntity_CompanyCode] 
					ON dbo.table_Clearer_BIM_preparation_Helper.BuKr = [dbo].[table_Clearer_map_LegalEntity_CompanyCode].CompanyCode
				WHERE 
					bukr = '0611'
					AND	ClearerID = @ClearerID
				GROUP BY 
					bukr
					,CCY
					,PayReceive
					,Zuordnung
					,[PETransferAccount]
					,DocumentPartition
					,ClearerName
					,ClearerCountry
					,ClearerSpotBalanceAccount
					,COB
					
		SELECT @step=12  	
		/*Booking for RWEST DE (Analog)*/
		INSERT into dbo.table_Clearer_BIM_preparation_Helper
				SELECT
				''
				,IIf(Sum(RealisedPNL) > 0, '37', '07') as BS
				,[PETransferAccount] AS Konto 
				,'' AS Auftrag
				,Format(COB, 'yyyy/MM') AS Zuordnung
				,Round(Abs(Sum(RealisedPNL)), 2) AS BetragFW
				,'Transfer' AS BuchungsText
				,'/' AS StKz
				,'0600' AS Bukr
				,null AS Debitor --Ref1
				,'/' AS MaterialCode
				,'/' AS Kostenstelle
				,'/'
				,'all' AS InternalPortfolio
				,'Transfer' AS Category
				,CCY AS CCY
				,PayReceive as PayReceive
				,Round(Sum(RealisedPNL),2) AS RealisedPNL
				,NULL AS AccountName
				,NULL AS ProjectionIndex1
				,NULL AS Toolset
				,NULL AS SettlementDate
				,NULL AS ContractDate
				,NULL AS ContractName
				,NULL AS ProductName
				,NULL AS Commodity
				,NULL AS DealID 
				,0  as DocumentPartition
				,@ClearerID AS ClearerID
				,ClearerSpotBalanceAccount as ClearerSpotBalanceAccount
				,ClearerName as ClearerName
				,ClearerCountry as ClearerCountry
				,@COB AS COB
				,4 AS SRC
				FROM 
					dbo.table_Clearer_BIM_preparation_Helper
					LEFT JOIN  dbo.table_Clearer_map_LegalEntity_CompanyCode 
					ON '0600' = dbo.table_Clearer_map_LegalEntity_CompanyCode.CompanyCode
				WHERE 
					bukr = '0611' and BuchungsText<>'Transfer'
					AND	ClearerID = @ClearerID
				GROUP BY 
					bukr
					,CCY
					,PayReceive
					,Zuordnung
					,[PETransferAccount]
					,DocumentPartition
					,ClearerName
					,ClearerCountry
					,ClearerSpotBalanceAccount
					,COB

		SELECT @step=14  	
		SET @Status_Text = 'Clearer Specific Updates'  
		EXEC dbo.Write_Log 'Info', @Status_Text , @Current_Procedure, NULL, NULL, @step, 1					
				
		/*1 - Update for BNPP Closing Trades - Clearer BNPP and BNPP ICE Endex*/
		UPDATE [dbo].[table_Clearer_BIM_preparation_Helper]
		SET  [Konto] = '6553100'
			,[Auftrag] = '/'
			,[Kostenstelle] = Case when bukr='0600' then 'K06Z999' else 'K06Z999U' end
		 WHERE ClearerID in (1,9) /*BNPP, BNPP ICE Endex*/ and InternalPortfolio = 'BNPP Closing Trade'
		 
	/*
	Now query the data for the BIM itself. 
	The results get stored per clearer(id) in a static table instead of an dynamic view as the data won't change during the process.
	The final bim results are queried from access in a "save_and_export routine 
	The rows of the BIM are sorted by QuerySource.
	*/
	
		SELECT @step=16  	
		SET @Status_Text = 'fill BIM header'  
		EXEC dbo.Write_Log 'Info', @Status_Text , @Current_Procedure, NULL, NULL, @step, 1					

		/*BIM HEADER: Insert the BIM header into the table for final BIM data. This header is the same for ALL clearers (In the past: bim_vorb)*/
		Insert into dbo.table_Clearer_BIM
		(
			[KopfIdent] ,[Buchungskreis] ,[Belegdatum] ,[Belegart] ,[Buchungsdatum] 
			,[Waehrung] ,[Belegkopftext] ,[Referenz] ,[loeschen01] ,[loeschen02] 
			,[loeschen03] ,[loeschen04] ,[loeschen05] ,[loeschen06] ,[loeschen07] 
			,[loeschen08], [loeschen09] ,[Desk] ,[clearerID] ,[COB] ,[RealisedPNL] 
			,[QuerySource]
		)
			SELECT 
				KopfIdent
				,Buchungskreis
				,Belegdatum
				,Belegart
				,Buchungsdatum
				,Waehrung
				,Belegkopftext
				,Referenz
				,loeschen1
				,loeschen2
				,loeschen3
				,loeschen4
				,loeschen5
				,loeschen6
				,loeschen7
				,loeschen8
				,loeschen9
				,Desk
				,@clearerID as clearerID
				,@COB as COB
				,'' as RealisedPNL
				,'0000_BIMHeader' as QuerySource
			FROM dbo.table_BIM_header
		
--/*BKFP: Insert the Docuumen Header. (In the past: BIM_vorb_BKPF)*/ 
		SELECT @step=18  	
		SET @Status_Text = 'fill document header'  
		EXEC dbo.Write_Log 'Info', @Status_Text , @Current_Procedure, NULL, NULL, @step, 1				
							
		Insert into dbo.table_Clearer_BIM
			([KopfIdent] ,[Buchungskreis] ,[Belegdatum] ,[Belegart] ,[Buchungsdatum] ,[Waehrung] ,[Belegkopftext] ,[Referenz] ,[loeschen01] 
			,[loeschen02] ,[loeschen03] ,[loeschen04] ,[loeschen05] ,[loeschen06] ,[loeschen07] ,[loeschen08], [loeschen09] ,[Desk], [PayReceive] ,[clearerID] ,[COB] 
			,[RealisedPNL] ,[QuerySource])
			SELECT 
				'BKPF' AS KopfIdent
				,BuKr AS Buchungskreis
				,format(COB,'dd.MM.yyyy') AS Belegdatum
				,'AB' AS Belegart
				,format(COB,'dd.MM.yyyy') AS Buchungsdatum
				,CCY as Waehrung
				,@ClearerName + ' ' + Format(@COB, 'MM/yyyy') AS Belegkopftext
				,@ClearerName + ' ' + Format(@COB, 'MM/yyyy') AS Referenz
				,'' AS loeschen1
				,'' AS loeschen2
				,'' AS loeschen3
				,'' AS loeschen4
				,'' AS loeschen5
				,'' AS loeschen6
				,'' AS loeschen7
				,'' AS loeschen8
				,CCY AS loeschen9
				,'' AS Desk
				,PayReceive As PayReceive
				,@ClearerID as cleaererID
				,COB
				,'' as RealisedPNL
				,Bukr + '_' + CCY + '_' + PayReceive + '_Part0' + '_1_BKPF'    as QuerySource
			FROM 
				table_Clearer_BIM_preparation_Helper
			WHERE 
				ClearerID = @ClearerID
			GROUP BY 
				 COB
				,CCY
				,Bukr
				,PayReceive

		/*Positions: Insert all Positions from the helper table - (in the past: BIM vorb PNL UNION FEE 600*/	
		SELECT @step=20  	
		SET @Status_Text = 'fill positions'  
		EXEC dbo.Write_Log 'Info', @Status_Text , @Current_Procedure, NULL, NULL, @step, 1				
		
		INSERT INTO [dbo].[table_Clearer_BIM]
			([KopfIdent] ,[Buchungskreis] ,[Belegdatum] ,[Belegart] ,[Buchungsdatum] ,[Waehrung] ,[Belegkopftext] ,[Referenz] ,[loeschen01] 
			,[loeschen02] ,[loeschen03] ,[loeschen04] ,[loeschen05] ,[loeschen06] ,[loeschen07] ,[loeschen08], [loeschen09] ,[Desk],[PayReceive], [DocumentPartition] ,[clearerID] ,[COB] 
			,[RealisedPNL] ,[QuerySource])
			SELECT 
				 [Position]--[KopfIdent]
				,[BS]--[Buchungskreis]
				,[Konto]--[Belegdatum]
				,[Auftrag]--[Belegart]
				,[Zuordnung]--[Buchungsdatum]
				,replace(format(sum([BetragFW]),'#.00'),'.',',')--[Waehrung]
				,[BuchungsText]--[Belegkopftext]
				,[StKz]--[Referenz]
				,[BuKr]--loeschen01
				,isnull(CONVERT(varchar(255),[Debitor]),'all')--loeschen02
				,[MaterialCode]--loeschen03
				,[Kostenstelle] -- loeschen04
				,[DealID] --loeschen05
				,[LegalEntity]--loeschen06
				,[InternalPortfolio]--loeschen07
				,[Category]--loeschen08
				,[CCY]--loeschen09
				,[AccountName]--[Desk]
				,[PayReceive] --PayReceive
				,[DocumentPartition]
				,[ClearerID]
				,[COB]
				,replace(format(Round(sum([RealisedPNL]),2),'#.00'),'.',',') as RealisedPNL
				,Bukr + '_' + CCY + '_' + PayReceive + '_Part' + convert(varchar,DocumentPartition) + '_2_Positions_SRC'+convert(varchar,SRC) as QuerySource
			FROM 
				dbo.table_Clearer_BIM_preparation_Helper
			WHERE		
				clearerID=@ClearerID
			GROUP BY
				[Position]
				,[BS]
				,[Konto]
				,[Auftrag]
				,[Zuordnung]
				,[BuchungsText]
				,[StKz]
				,[BuKr]
				,[MaterialCode]
				,[Kostenstelle]
				,[LegalEntity]
				,[InternalPortfolio]
				,[Category]
				,[CCY]
				,[DealID]
				,[AccountName]
				,[PayReceive]
				,[DocumentPartition]
				,[ClearerID]
				,[COB]
				,[Debitor]
				,[SRC]
				

		/*Debitor: Clearer Spot balance account bookings / Booking on the Clearer Debitor Account (In the past: bim_vorb_bilanz)*/
		SELECT @step=22  	
		SET @Status_Text = 'debitor bookings'  
		EXEC dbo.Write_Log 'Info', @Status_Text , @Current_Procedure, NULL, NULL, @step, 1				
		
		Insert into dbo.table_Clearer_BIM
			([KopfIdent] ,[Buchungskreis] ,[Belegdatum] ,[Belegart] ,[Buchungsdatum] ,[Waehrung] ,[Belegkopftext] ,[Referenz] ,[loeschen01] 
			,[loeschen02] ,[loeschen03] ,[loeschen04] ,[loeschen05] ,[loeschen06] ,[loeschen07] ,[loeschen08], [loeschen09] ,[Desk] ,[PayReceive], [DocumentPartition], [clearerID] ,[COB] 
			,[RealisedPNL] ,[QuerySource])
			SELECT 
				'' AS Pos --[KopfIdent]
				,IIf(RealisedPNL < 0, '17', '07') AS BS_Bilanz --[Buchungskreis]
				,ClearerSpotBalanceAccount AS Konto
				,'' AS Auftrag
				,Format(COB, 'yyyy/MM') AS Zuordnung
				,replace(format(Round(Abs(Sum(RealisedPNL)), 2),'#.00'),'.',',') AS BetragCCY
				,clearerCountry + ';' + clearername + ';' + Category + '; ' + Format(cob, 'MM/yyyy') AS Belegkopftext
				,'/' AS StKZ 
				,BuKr --löschen1
				,'all' AS löschen2
				,Category AS löschen3
				,'/' AS loeschen4
				,'' As loeschen5
				,'/' AS loeschen6
				,'all'  AS loeschen7
				,'Debitor' As loeschen8
				,CCY As loeschen9
				,Category AS DESK
				,PayReceive
				,DocumentPartition
				,ClearerID
				,COB
				,replace(format(Round(sum(-1 * [RealisedPNL]),2),'#.00'),'.',',') as RealisedPNL
				,BuKr + '_' + CCY + '_' + PayReceive + '_Part' + convert(varchar,DocumentPartition) + '_3_SpotBalance' as QuerySource
			FROM 
				dbo.table_Clearer_BIM_preparation_Helper 
			WHERE 
				ClearerID = @clearerID  
				and bukr <> '0611' /*The bookings from RWEST UK are transferred to RWEST DE and do not need to be booked*/
			GROUP BY 
				 IIf(RealisedPNL < 0, '17', '07')
				,ClearerSpotBalanceAccount
				,Format(COB, 'yyyy/MM')
				,Category
				,BuKr
				,clearerCountry
				,clearername
				,CCY
				,DocumentPartition
				,ClearerID
				,COB
				,PayReceive
		
		SELECT @step=24  	
		SET @Status_Text = 'enumerate the single positions of a document'  
		EXEC dbo.Write_Log 'Info', @Status_Text , @Current_Procedure, NULL, NULL, @step, 1	

		/*Set ascending position numbers in table_Clearer_BIM*/
		UPDATE dbo.table_Clearer_BIM
		SET KopfIdent = helper.rownumber
		FROM dbo.table_Clearer_BIM bim
		JOIN (
			SELECT ROW_NUMBER() OVER (
					PARTITION BY loeschen01 /*Buchungskreis*/ ,loeschen09 /*CCY*/,PayReceive, DocumentPartition
					ORDER BY QuerySource ,ID ASC
					) AS rownumber
				,ID
			FROM dbo.table_Clearer_BIM
			WHERE ClearerID = @clearerID and KopfIdent = ''
			) AS helper ON bim.ID = helper.ID


		SELECT @step=26  	
		SET @Status_Text = 'identify and mark last position of a document'  
		EXEC dbo.Write_Log 'Info', @Status_Text , @Current_Procedure, NULL, NULL, @step, 1	
		
		/*set the last position of a document to '999' in table_Clearer_BIM*/
		UPDATE dbo.table_Clearer_BIM
			SET KopfIdent = '999'
		FROM dbo.table_Clearer_BIM bim
		JOIN (
			SELECT convert(varchar,max(convert(int,KopfIdent))) as MaxPositionNumber, loeschen01 as 'Buchungskreis',loeschen09 as 'CCY',PayReceive , DocumentPartition 
			FROM dbo.table_Clearer_BIM
			WHERE ClearerID = @clearerID and isnumeric(KopfIdent)=1
			group by 
			loeschen01 /*Buchungskreis*/ ,loeschen09 /*CCY*/, PayReceive, DocumentPartition 
			) AS helper ON bim.Kopfident = helper.MaxPositionNumber and bim.loeschen01 = helper.Buchungskreis and bim.loeschen09 = helper.CCY  and bim.PayReceive = helper.PayReceive and bim.DocumentPartition = helper.DocumentPartition

		/*Change CNH to CNY since only CNY is available in SAP*/	
		SELECT @step=28  	
		SET @Status_Text = 'update currency CNH/CNY'  
		EXEC dbo.Write_Log 'Info', @Status_Text , @Current_Procedure, NULL, NULL, @step, 1	
		Update dbo.table_Clearer_BIM set Waehrung  = 'CNY' where Waehrung = 'CNH'											/*Update currency in Header*/
		SELECT @step=29  	
		Update dbo.table_Clearer_BIM set loeschen09/*CCY*/  = 'CNY' where loeschen09/*CCY*/ = 'CNH'		/*Update currency in Positions*/
		
		/*The final bim results are queried from access in a "save_and_export_query" routine */
		SELECT @step=30  	
		EXEC dbo.Write_Log 'Info', 'FINISHED' , @Current_Procedure, NULL, NULL, @step, 1			
		
		Return 0

	END TRY

	BEGIN CATCH
		EXEC [dbo].[usp_GetErrorInfo] @Current_Procedure, @step, NULL; 
		EXEC dbo.Write_Log 'ERROR', 'FAILED, check log for details' , @Current_Procedure, NULL, NULL, @step, 1			
		Return @step
END CATCH

GO

