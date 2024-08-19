



--/*abgleich der fehlenden daten*/
create view dbo.view_strolf_mtm_check_rough_deal_recon AS
select 
   dbo.table_strolf_mtm_check_01_FT_data.DealID AS FT_DealID
	,dbo.Strolf_MOP_PLUS_REAL_CORR_EOM.DEAL_NUM AS STROLF_DealID
  --,dbo.table_strolf_mtm_check_01_FT_data.InstrumentType AS FT_InstrumentType
  --,dbo.Strolf_MOP_PLUS_REAL_CORR_EOM.INS_TYPE_NAME AS STROLF_InstrumentType 
	,dbo.Strolf_MOP_PLUS_REAL_CORR_EOM.PNL_TYPE AS STROLF_PNL_TYPE
	,sum(isnull(dbo.table_strolf_mtm_check_01_FT_data.MtM,0)) AS FT_MTM
	,sum(isnull(dbo.Strolf_MOP_PLUS_REAL_CORR_EOM.PNL,0)) AS STROLF_MTM
	,SUM(isnull(dbo.table_strolf_mtm_check_01_FT_data.MtM,0)-isnull(dbo.Strolf_MOP_PLUS_REAL_CORR_EOM.PNL,0)) AS MTM_Diff
from 
  dbo.table_strolf_mtm_check_01_FT_data
  full join dbo.Strolf_MOP_PLUS_REAL_CORR_EOM 
	on dbo.table_strolf_mtm_check_01_FT_data.dealID= dbo.Strolf_MOP_PLUS_REAL_CORR_EOM.DEAL_NUM 
where 
	Strategy like 'CAO%'
	and [ProjectionIndexGroup] in ('Electricity')
	AND (dbo.table_strolf_mtm_check_01_FT_data.dealID is null
	or dbo.Strolf_MOP_PLUS_REAL_CORR_EOM.DEAL_NUM is null
	or (
		dbo.table_strolf_mtm_check_01_FT_data.dealID= dbo.Strolf_MOP_PLUS_REAL_CORR_EOM.DEAL_NUM
		AND dbo.table_strolf_mtm_check_01_FT_data.MtM<>dbo.Strolf_MOP_PLUS_REAL_CORR_EOM.PNL
		AND dbo.Strolf_MOP_PLUS_REAL_CORR_EOM.PNL_TYPE ='UNREALISED'
		)
)
group by 
   dbo.table_strolf_mtm_check_01_FT_data.DealID
	,dbo.Strolf_MOP_PLUS_REAL_CORR_EOM.DEAL_NUM 
  --,dbo.table_strolf_mtm_check_01_FT_data.InstrumentType 
  --,dbo.Strolf_MOP_PLUS_REAL_CORR_EOM.INS_TYPE_NAME 
	,dbo.Strolf_MOP_PLUS_REAL_CORR_EOM.PNL_TYPE 
--having 
--	abs(SUM(isnull(dbo.table_strolf_mtm_check_01_FT_data.MtM,0)-isnull(dbo.Strolf_MOP_PLUS_REAL_CORR_EOM.PNL,0)))>0.5 

GO

