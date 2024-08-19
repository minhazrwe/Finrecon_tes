

create view [dbo].[Strolf_Dummy_Portfolio] as select sum(pnl) as pnl, 'UNREALIZED' as [Realised/Unrealised]  from dbo.Strolf_HIST_PNL_PORT_FIN_EOM as dd , dbo.AsOfDate as gg
where dd.COB = gg.AsOfDate_EOM
and dd.PORTFOLIO_ID = 55555 --LTT_DE_DUMMY_DH 
and dd.PNL_Type = 'UNREALIZED'
union all
select sum(pnl) as pnl, 'REALIZED' as [Realised/Unrealised]  from dbo.Strolf_HIST_PNL_PORT_FIN_EOM as dd , dbo.AsOfDate as gg
where dd.COB = gg.AsOfDate_EOM
and dd.PORTFOLIO_ID = 55555 --LTT_DE_DUMMY_DH 
and dd.PNL_Type = 'REALIZED'
;

GO

