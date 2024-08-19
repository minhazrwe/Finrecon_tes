
CREATE VIEW [dbo].[view_strolf_mtm_check_ReconFX]as
SELECT 
   Dealid
  ,Max(Desk) AS Desk
  ,Max(InternalPortfolio) AS InternalPortfolio
  ,Max(InstrumentType) AS InstrumentType
  ,Max(EventDate) AS EventDate
  ,Round(Sum([Finance]), 2) AS Finance
  ,Round(Sum([Risk]), 2) AS Risk
  ,Round(Sum([MTM_Diff]), 2) AS Diff
  --,CASE WHEN Abs(Sum([MTM_Diff]))>100 THEN 'CHECK IT' ELSE NULL END CheckFlag
	,CASE WHEN (Sum(Risk)<>0 AND ISNULL(Sum(Finance),0)=0) THEN 'CHECK IT' ELSE NULL END CheckFlag
FROM 
  dbo.table_strolf_mtm_check_ReconFX
WHERE   
  Desk NOT IN ('TS_UK', 'TS_DE','ETI')/*to be clarified: should desk "ETI" get excluded as well (mkb / VP 06/2022)*/
  AND DealID NOT IN ('FX_JBB_MTM', 'FX_JBB_OCI', 'JBB_Transfer_DE')
	AND cob in (select AsOfDate_EOM from dbo.AsOfDate)
	AND InternalPortfolio not like 'RES_BE' /* excluded 2022-05-03 */
GROUP BY 
  DealId
HAVING 
	Round(Sum([MTM_Diff]), 2) <> 0;

GO

