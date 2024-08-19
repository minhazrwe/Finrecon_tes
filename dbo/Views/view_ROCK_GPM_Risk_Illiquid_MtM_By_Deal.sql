


create view [dbo].[view_ROCK_GPM_Risk_Illiquid_MtM_By_Deal] as
/*old version basing on separate rock report data 
SELECT 
	cast(COB as datetime) as cob
	,Intermediate_5_Name
	,Deal_Number
  ,PnL_Disc_Unreal_BU_CCY as Unrealised_Discounted_EUR
	,PnL_Disc_Unreal_LGBY_BU_CCY as Unrealised_Discounted_EUR_CAO_Gas_EOLY
	,PnL_Disc_Unreal_YtD_BU_CCY as PnL_YtD_Unrealised_Discounted_EUR_CAO_Gas	
  FROM 
		dbo.table_ROCK_GPM_Illiquid_Data
where 
		(abs(PnL_Disc_Unreal_BU_CCY)+abs(PnL_Disc_Unreal_LGBY_BU_CCY)+abs(PnL_Disc_Unreal_YtD_BU_CCY))>0
*/

select 
	cast(COB as date) as cob
	,[L10 - Book (Current Name)] as Book
	,[trade deal number]
	,sum(UNREAL_DISC_PH_BL_CCY) Unrealised_Discounted_EUR
	,sum(UNREAL_DISC_PH_BL_CCY_LGBY) Unrealised_Discounted_EUR_EOLY
from 
	dbo.GloriRisk 
where 
	fileID = 3133
group by 
	cob
	,[L10 - Book (Current Name)] 
	,[trade deal number]
having 
abs(sum(UNREAL_DISC_PH_BL_CCY)) + abs(sum(UNREAL_DISC_PH_BL_CCY_LGBY))<>0

GO

