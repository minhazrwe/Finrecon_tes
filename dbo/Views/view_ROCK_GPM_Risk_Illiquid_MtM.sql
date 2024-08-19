

CREATE view [dbo].[view_ROCK_GPM_Risk_Illiquid_MtM] as
/*old versions from data of extra-report
select 
	cast(COB as datetime) as cob
	,case when Intermediate_5_Name like '%CZ%' then 'RGM CZ' ELSE 'CAO GAS'end as Book
	,sum(isnull(Unrealised_Discounted_EUR,0)) as illiquid_mtm
from 
	dbo.view_ROCK_GPM_Illiquid_Data		
group by
	cob
	,case when Intermediate_5_Name like '%CZ%' then 'RGM CZ' ELSE 'CAO GAS'end 
*/

select 
	cast(COB as date) as cob
	,case when [L10 - Book (Current Name)] like '%CZ%' then 'RGM CZ' ELSE 'CAO GAS'end as Book
	,sum(isnull(UNREAL_DISC_PH_BL_CCY,0)) as illiquid_mtm
from 
	dbo.GloriRisk 
where 
	fileID = 3133
group by 
	cob
	,case when [L10 - Book (Current Name)] like '%CZ%' then 'RGM CZ' ELSE 'CAO GAS'end

GO

