





CREATE view [dbo].[map_FX_counterparty] as 


-- this view is for FX project (Zulfiqar Ahmed / Florian Buchloh)
select case when s.recon_group is null then 'pls review' else s.recon_group end as ReconGroup,  c.ExtBunit, c.ExtlegalEntity, c.Exchange, c.ctpygroup, c.Debitor, c.CtpyID_Endur, s.accountname, 'map_counterparty' as source 
from dbo.map_counterparty c left join dbo.map_ReconGroupAccount s on c.debitor=s.Account
where ExtBunit like '%BU' and ctpyid_endur is not null

union all
select 
case when recon_group in ('zz - other - non trading') then 'Debitor_Overhead' else 
case when recon_group in ('FX') then 'RWE AG' else recon_group end end as recon_group, 
null as ExtBunit, null as ExtLegalEntity, null as exchange, null as ctpygroup, account as Debitor, null as ctpyID_Endur, accountname, 'map_recongroupaccount' as source  
from dbo.map_ReconGroupAccount s 
where (commodity = 'FX_Recon' or (recon_group  in ('zz - other - non trading','FX','interest')))
and s.account not in (select debitor from dbo.map_counterparty where debitor is not null)

GO

