

/* 
---Author:			MU
---Created:			October 2022 

---Description:	
---		Shows on a deallevel basis all missing mappings. 
---		The view is aggregated in a second step to show what mappings needs to be maintained. 
---		The detailed data in this view can be used to find which entry in the Accouting or Deal Report is causing the missing mapping.

The view can be aggregated using this SQL:
select [Fieldnames], [Values], [Missing_in_Table], count([ID]) as [Number_of_occurences]
  FROM [FinRecon].[dbo].[view_Clearer_MissingMappingsDetail]
GROUP BY [Fieldnames], [Values], [Missing_in_Table]

*/

--select * from [view_Clearer_MissingMappingsDetail]

CREATE view [dbo].[view_Clearer_MissingMappingsDetail] AS
/*table_Clearer_map_ExpirationDate - table_Clearer_AccountingData */
SELECT distinct 'DealNumber' as [Fieldnames], table_Clearer_AccountingData .DealNumber as [Values], 'table_Clearer_map_ExpirationDate' as [Missing_in_Table], 'table_Clearer_AccountingData ' as [Relevant_for],  table_Clearer_AccountingData .ID as [ID]  
FROM 
	dbo.table_Clearer_AccountingData LEFT JOIN dbo.table_Clearer_map_ExpirationDate 
	ON table_Clearer_AccountingData .DealNumber = table_Clearer_map_ExpirationDate.ReferenceID
WHERE 
	table_Clearer_AccountingData .Toolset like '%Opt%' 
	and table_Clearer_map_ExpirationDate.ReferenceID is Null

UNION ALL

/*table_Clearer_map_ExternalBusinessUnit - table_Clearer_AccountingData */
SELECT 
	distinct 'AccountName | ClearerID' as [Fieldnames]
	,table_Clearer_AccountingData .AccountName + ' | ' + Convert(varchar(10),table_Clearer_AccountingData .ClearerID) + ' (' + Clearer.ClearerName + ')' as [Values]
	,'table_Clearer_map_ExternalBusinessUnit' as [Missing_in_Table]
	,'table_Clearer_AccountingData ' as [Relevant_for]
	, table_Clearer_AccountingData .ID as [ID]   
FROM 
	dbo.table_Clearer_AccountingData LEFT JOIN dbo.table_Clearer_map_ExternalBusinessUnit 
	ON table_Clearer_AccountingData .AccountName = table_Clearer_map_ExternalBusinessUnit.AccountName
		AND table_Clearer_AccountingData .ClearerID = table_Clearer_map_ExternalBusinessUnit.ClearerID
Left JOIN table_Clearer as Clearer
	ON table_Clearer_AccountingData .ClearerID = Clearer.ClearerID
WHERE table_Clearer_map_ExternalBusinessUnit.AccountName is Null

UNION ALL

/*table_Clearer_map_ExternalBusinessUnit - DealData*/
SELECT distinct 'AccountName | ClearerID' as [Fieldnames], DealData.AccountName + ' | ' + Convert(varchar(10),DealData.ClearerID) + ' (' + Clearer.ClearerName + ')' as [Values], 'table_Clearer_map_ExternalBusinessUnit' as [Missing_in_Table], 'DealData' as [Relevant_for], DealData.ID as [ID] 
FROM dbo.table_Clearer_DealData AS DealData
LEFT JOIN dbo.table_Clearer_map_ExternalBusinessUnit 
	ON DealData.AccountName = table_Clearer_map_ExternalBusinessUnit.AccountName
		AND DealData.ClearerID = table_Clearer_map_ExternalBusinessUnit.ClearerID
Left JOIN table_Clearer as Clearer
	ON DealData.ClearerID = Clearer.ClearerID
WHERE table_Clearer_map_ExternalBusinessUnit.AccountName is Null

UNION ALL

/*map_order - table_Clearer_AccountingData */
SELECT distinct 'InternalPortfolio' as [Fieldnames], table_Clearer_AccountingData .InternalPortfolio as [Values], 'map_order' as [Missing_in_Table], 'table_Clearer_AccountingData ' as [Relevant_for],  table_Clearer_AccountingData .ID as [ID]  
FROM dbo.table_Clearer_AccountingData  
LEFT JOIN dbo.map_order AS MapOrder
	ON table_Clearer_AccountingData .InternalPortfolio = MapOrder.Portfolio
WHERE MapOrder.Portfolio is Null and table_Clearer_AccountingData .InternalPortfolio <> 'BNPP Closing Trade'

UNION ALL

/*map_order - DealData*/
SELECT Case when DealData.InternalPortfolio = 'BNPP Closing Trade' Then 'InternalOrder ('+DealData.AccountName + ')' else 'InternalPortfolio' end as [Fieldnames], DealData.InternalPortfolio as [Values], Case when InternalPortfolio = 'BNPP Closing Trade' then 'table_Clearer_map_ExternalBusinessUnit' else 'map_order' end as [Missing_in_Table], 'DealData' as [Relevant_for], DealData.ID as [ID]  
FROM dbo.table_Clearer_DealData AS DealData
LEFT JOIN dbo.map_order AS MapOrder
	ON DealData.InternalPortfolio = MapOrder.Portfolio
LEFT JOIN dbo.table_Clearer_map_ExternalBusinessUnit 
	ON DealData.AccountName = table_Clearer_map_ExternalBusinessUnit.AccountName
		AND DealData.ClearerID = table_Clearer_map_ExternalBusinessUnit.ClearerID
LEFT JOIN (
	SELECT DISTINCT LegalEntity
		,OrderNo
	FROM dbo.map_order
	WHERE isnull(LegalEntity, 'n/a') != 'n/a'
	) AS MapOrder_Closing
	ON table_Clearer_map_ExternalBusinessUnit.InternalOrder = MapOrder_Closing.[OrderNo] --Join needed for Closing trades
WHERE MapOrder.Portfolio is Null and MapOrder_Closing.[OrderNo] is null

UNION ALL

/*map_ProjIndex - table_Clearer_AccountingData */
SELECT distinct 'ProjectionIndex1' as [Fieldnames], table_Clearer_AccountingData .ProjectionIndex1 as [Values], 'map_ProjIndex' as [Missing_in_Table], 'table_Clearer_AccountingData ' as [Relevant_for],  table_Clearer_AccountingData .ID as [ID]  
FROM dbo.table_Clearer_AccountingData  
LEFT JOIN dbo.map_ProjIndex AS MapProjIdx
	ON table_Clearer_AccountingData .ProjectionIndex1 = MapProjIdx.ProjIndex
WHERE MapProjIdx.ProjIndex is Null  and table_Clearer_AccountingData .ProjectionIndex1<> 'Unknown'

UNION ALL

/*map_ProjIndex - DealData*/
SELECT distinct 'ProjectionIndex1' as [Fieldnames], DealData.ProjectionIndex1 as [Values], 'map_ProjIndex' as [Missing_in_Table], 'DealData' as [Relevant_for], DealData.ID as [ID] 
FROM dbo.table_Clearer_DealData AS DealData
LEFT JOIN dbo.map_ProjIndex AS MapProjIdx
	ON DealData.ProjectionIndex1 = MapProjIdx.ProjIndex
WHERE MapProjIdx.ProjIndex is Null  and DealData.ProjectionIndex1<> 'Unknown'


UNION ALL

/*table_Clearer_map_Konten - table_Clearer_AccountingData */
SELECT distinct 'Commodity' as [Fieldnames], Isnull(MapProjIdx.Commodity, table_Clearer_map_ExternalBusinessUnit.Commodity) as [Values], 'table_Clearer_map_Konten' as [Missing_in_Table], 'table_Clearer_AccountingData ' as [Relevant_for],  table_Clearer_AccountingData .ID as [ID]  
FROM dbo.table_Clearer_AccountingData  
LEFT JOIN dbo.map_ProjIndex AS MapProjIdx
	ON table_Clearer_AccountingData .ProjectionIndex1 = MapProjIdx.ProjIndex
LEFT JOIN dbo.table_Clearer_map_ExternalBusinessUnit 
	ON table_Clearer_AccountingData .AccountName = table_Clearer_map_ExternalBusinessUnit.AccountName
		AND table_Clearer_AccountingData .ClearerID = table_Clearer_map_ExternalBusinessUnit.ClearerID
LEFT JOIN dbo.table_Clearer_map_Konten AS MapKonten
	ON Isnull(MapProjIdx.Commodity, table_Clearer_map_ExternalBusinessUnit.Commodity) = MapKonten.Commodity
WHERE Isnull(MapProjIdx.Commodity, table_Clearer_map_ExternalBusinessUnit.Commodity) is not Null and  MapKonten.Commodity is null

UNION ALL

/*table_Clearer_map_Konten - DealData*/
SELECT distinct 'Commodity' as [Fieldnames], Isnull(MapProjIdx.Commodity, table_Clearer_map_ExternalBusinessUnit.Commodity) as [Values], 'table_Clearer_map_Konten' as [Missing_in_Table], 'DealData' as [Relevant_for], DealData.ID as [ID] 
FROM dbo.table_Clearer_DealData AS DealData
LEFT JOIN dbo.map_ProjIndex AS MapProjIdx
	ON DealData.ProjectionIndex1 = MapProjIdx.ProjIndex
LEFT JOIN dbo.table_Clearer_map_ExternalBusinessUnit 
	ON DealData.AccountName = table_Clearer_map_ExternalBusinessUnit.AccountName
		AND DealData.ClearerID = table_Clearer_map_ExternalBusinessUnit.ClearerID
LEFT JOIN dbo.table_Clearer_map_Konten AS MapKonten
	ON Isnull(MapProjIdx.Commodity, table_Clearer_map_ExternalBusinessUnit.Commodity) = MapKonten.Commodity
WHERE Isnull(MapProjIdx.Commodity, table_Clearer_map_ExternalBusinessUnit.Commodity) is not Null 
AND MapKonten.Commodity is Null

UNION ALL

/*table_Clearer_map_LegalEntity_CompanyCode - table_Clearer_AccountingData */
SELECT distinct 'LegalEntity' as [Fieldnames], MapOrder.LegalEntity as [Values], 'table_Clearer_map_LegalEntity_CompanyCode' as [Missing_in_Table], 'table_Clearer_AccountingData ' as [Relevant_for],  table_Clearer_AccountingData .ID as [ID]  
FROM dbo.table_Clearer_AccountingData  
LEFT JOIN dbo.map_order AS MapOrder
	ON table_Clearer_AccountingData .InternalPortfolio = MapOrder.Portfolio
LEFT JOIN dbo.table_Clearer_map_LegalEntity_CompanyCode AS MapLegEntCC
	ON MapOrder.LegalEntity = MapLegEntCC.LegalEntity
WHERE MapLegEntCC.LegalEntity is Null and MapOrder.Portfolio is not null

UNION ALL

/*table_Clearer_map_LegalEntity_CompanyCode - DealData*/
SELECT distinct 'LegalEntity' as [Fieldnames], isnull(MapOrder.LegalEntity, MapOrder_Closing.LegalEntity) as [Values], 'table_Clearer_map_LegalEntity_CompanyCode' as [Missing_in_Table], 'DealData' as [Relevant_for], DealData.ID as [ID]  
FROM dbo.table_Clearer_DealData AS DealData
LEFT JOIN dbo.map_order AS MapOrder
	ON DealData.InternalPortfolio = MapOrder.Portfolio
LEFT JOIN dbo.table_Clearer_map_ExternalBusinessUnit 
	ON DealData.AccountName = table_Clearer_map_ExternalBusinessUnit.AccountName
		AND DealData.ClearerID = table_Clearer_map_ExternalBusinessUnit.ClearerID
LEFT JOIN (
	SELECT DISTINCT LegalEntity
		,OrderNo
	FROM dbo.map_order
	WHERE isnull(LegalEntity, 'n/a') != 'n/a'
	) AS MapOrder_Closing
	ON table_Clearer_map_ExternalBusinessUnit.InternalOrder = MapOrder_Closing.[OrderNo] --Join needed for Closing trades
LEFT JOIN dbo.table_Clearer_map_LegalEntity_CompanyCode AS MapLegEntCC
	ON isnull(MapOrder.LegalEntity, MapOrder_Closing.LegalEntity) = MapLegEntCC.LegalEntity
WHERE MapLegEntCC.LegalEntity is null and isnull(MapOrder.LegalEntity, MapOrder_Closing.LegalEntity) is not null

UNION ALL

/*table_Clearer_map_Toolset_Product - table_Clearer_AccountingData */
SELECT distinct 'Toolset' as [Fieldnames], table_Clearer_AccountingData .Toolset as [Values], 'table_Clearer_map_Toolset_Product' as [Missing_in_Table], 'table_Clearer_AccountingData ' as [Relevant_for],  table_Clearer_AccountingData .ID as [ID]   
FROM dbo.table_Clearer_AccountingData  
LEFT JOIN dbo.table_Clearer_map_Toolset_Product AS MapToolset
	ON table_Clearer_AccountingData .Toolset = MapToolset.Toolset
WHERE MapToolset.Toolset is Null

UNION ALL

/*table_Clearer_map_Taxcode - table_Clearer_AccountingData */
SELECT distinct 'CompanyCode | ClearerCountry | ProductName' as [Fieldnames],  isnull(MapLegEntCC.CompanyCode,'<null>') + ' | ' + isnull(MapClearer.ClearerCountry,'<null>') + ' | ' +  isnull(MapToolset.ProductName,'<null>')   as [Values], 'table_Clearer_map_Taxcode' as [Missing_in_Table], 'table_Clearer_AccountingData ' as [Relevant_for],  table_Clearer_AccountingData .ID as [ID]   
FROM dbo.table_Clearer_AccountingData  
LEFT JOIN dbo.table_Clearer AS MapClearer 
	ON table_Clearer_AccountingData .ClearerID = MapClearer.ClearerID
LEFT JOIN dbo.table_Clearer_map_Toolset_Product AS MapToolset
	ON table_Clearer_AccountingData .Toolset = MapToolset.Toolset
LEFT JOIN dbo.map_order AS MapOrder
	ON table_Clearer_AccountingData .InternalPortfolio = MapOrder.Portfolio
LEFT JOIN dbo.table_Clearer_map_LegalEntity_CompanyCode AS MapLegEntCC
	ON MapOrder.LegalEntity = MapLegEntCC.LegalEntity
LEFT JOIN dbo.table_Clearer_map_Taxcode AS MapTaxcode
	ON MapToolset.ProductName = MapTaxcode.ProductName
		AND MapLegEntCC.CompanyCode = MapTaxcode.CompanyCode
		AND MapClearer.ClearerCountry = MapTaxcode.ClearerCountry
WHERE MapTaxcode.ProductName is null and MapTaxcode.CompanyCode is null and MapTaxcode.ClearerCountry is null 
and  MapToolset.Toolset is not Null and MapLegEntCC.LegalEntity is not Null and MapOrder.Portfolio is not null

UNION ALL

/*table_Clearer_map_Taxcode - DealData*/
SELECT distinct 'CompanyCode | ClearerCountry | ProductName' as [Fieldnames], isnull(MapLegEntCC.CompanyCode,'<null>') + ' | ' + isnull(MapClearer.ClearerCountry,'<null>') + ' | ' +  'Fees'   as [Values], 'table_Clearer_map_Taxcode' as [Missing_in_Table], 'DealData' as [Relevant_for], DealData.ID as [ID] 
FROM dbo.table_Clearer_DealData AS DealData
LEFT JOIN dbo.table_Clearer AS MapClearer 
	ON DealData.ClearerID = MapClearer.ClearerID
LEFT JOIN dbo.map_order AS MapOrder
	ON DealData.InternalPortfolio = MapOrder.Portfolio
LEFT JOIN dbo.table_Clearer_map_ExternalBusinessUnit 
	ON DealData.AccountName = table_Clearer_map_ExternalBusinessUnit.AccountName
		AND DealData.ClearerID = table_Clearer_map_ExternalBusinessUnit.ClearerID
LEFT JOIN (
	SELECT DISTINCT LegalEntity
		,OrderNo
	FROM dbo.map_order
	WHERE isnull(LegalEntity, 'n/a') != 'n/a'
	) AS MapOrder_Closing
	ON table_Clearer_map_ExternalBusinessUnit.InternalOrder = MapOrder_Closing.[OrderNo] --Join needed for Closing trades
LEFT JOIN dbo.table_Clearer_map_LegalEntity_CompanyCode AS MapLegEntCC
	ON isnull(MapOrder.LegalEntity, MapOrder_Closing.LegalEntity) = MapLegEntCC.LegalEntity
LEFT JOIN dbo.table_Clearer_map_Taxcode AS MapTaxcode
	ON MapTaxcode.ProductName = 'Fees'
		AND MapLegEntCC.CompanyCode = MapTaxcode.CompanyCode
		AND MapClearer.ClearerCountry = MapTaxcode.ClearerCountry
WHERE MapTaxcode.CompanyCode is null and MapTaxcode.ClearerCountry is null 
and MapLegEntCC.LegalEntity is not null and isnull(MapOrder.LegalEntity, MapOrder_Closing.LegalEntity) is not null

GO

