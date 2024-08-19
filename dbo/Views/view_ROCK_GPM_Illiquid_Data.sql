

CREATE view [dbo].[view_ROCK_GPM_Illiquid_Data] as
SELECT 
	 cast(COB as datetime) as cob
  ,[Intermediate_5_Name]
  ,sum(PnL_Disc_Unreal_BU_CCY) as Unrealised_Discounted_EUR
	,sum(PnL_Disc_Unreal_LGBY_BU_CCY) as Unrealised_Discounted_EUR_CAO_Gas_EOLY
	,sum(PnL_Disc_Unreal_YtD_BU_CCY) as PnL_YtD_Unrealised_Discounted_EUR_CAO_Gas
  FROM 
		dbo.table_ROCK_GPM_Illiquid_Data
--		left join dbo.tmp_table_ROCK_GPM_SBM on 
	GROUP BY
		 [CoB]
		,[Intermediate_5_Name]
having 
		abs(sum(PnL_Disc_Unreal_BU_CCY))+abs(sum(PnL_Disc_Unreal_LGBY_BU_CCY))+abs(sum(PnL_Disc_Unreal_YtD_BU_CCY))>0

GO

