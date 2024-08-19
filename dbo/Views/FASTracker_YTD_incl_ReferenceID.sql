



CREATE view [dbo].[FASTracker_YTD_incl_ReferenceID] as 
SELECT 

ReferenceID,
desk, 
subdesk, 
subdeskccy,
strategy, 
InternalPortfolio, 
CounterpartyGroup,
Instrumenttype, 
ProjIndexGroup,
ExternalBusinessUnit,
Product,
AccountingTreatment, 
TermEnd, 
total_mtm as mtm_finance_total, 
PNL as mtm_finance_PNL, 
OCI as mtm_finance_OCI, 
ou as mtm_finance_OU,
NOR as mtm_finance_NOR,
0 as prevYE_mtm_finance_total, 
0 as PrevYE_mtm_finance_PNL, 
0 as PrevYE_mtm_finance_OCI, 
0 as PrevYE_mtm_finance_OU,
0 as PrevYE_mtm_finance_NOR,
total_mtm_DeskCCY as mtm_finance_total_DeskCCY, 
PNL_deskccy as mtm_finance_PNL_DeskCCY, 
OCI_DeskCCY as mtm_finance_OCI_DeskCCY, 
OU_DeskCCY as mtm_finance_OU_DeskCCY,
NOR_DeskCCY as mtm_finance_NOR_DeskCCY,
0 as prevYE_mtm_finance_total_DeskCCY, 
0 as PrevYE_mtm_finance_PNL_DeskCCY, 
0 as PrevYE_mtm_finance_OCI_DeskCCY, 
0 as PrevYE_mtm_finance_OU_DeskCCY,
0 as PrevYE_mtm_finance_NOR_DeskCCY,

total_mtm as ytd_mtm_finance_total, 
PNL as ytd_mtm_finance_PNL, 
OCI as ytd_mtm_finance_OCI, 
ou as ytd_mtm_finance_OU,
NOR as ytd_mtm_finance_NOR,

total_mtm_DeskCCY as ytd_mtm_finance_total_DeskCCY, 
PNL_deskccy as ytd_mtm_finance_PNL_DeskCCY, 
OCI_DeskCCY as ytd_mtm_finance_OCI_DeskCCY, 
OU_DeskCCY as ytd_mtm_finance_OU_DeskCCY,
NOR_DeskCCY as ytd_mtm_finance_NOR_DeskCCY

from dbo.Fastracker_eom 


union all 

select 
ReferenceID,
desk, 
subdesk, 
subdeskccy,
strategy, 
InternalPortfolio, 
CounterpartyGroup,
Instrumenttype, 
ProjIndexGroup,
ExternalBusinessUnit,
Product,
AccountingTreatment, 
TermEnd, 
0 as mtm_finance_total, 
0 as mtm_finance_pnl, 
0 as mtm_finance_OCI, 
0 as mtm_finance_ou,
0 as mtm_finance_nor,
total_mtm  as prevYE_mtm_finance_total, 
PNL  as PrevYE_mtm_finance_pnl, 
OCI as PrevYE_mtm_finance_OCI, 
OU as PrevYE_mtm_finance_ou,
NOR as PrevYE_mtm_finance_nor,
0 as mtm_finance_total_DeskCCY, 
0 as mtm_finance_pnl_DeskCCY, 
0 as mtm_finance_OCI_DeskCCY, 
0 as mtm_finance_ou_DeskCCY,
0 as mtm_finance_nor_DeskCCY,
total_mtm_DeskCCY  as prevYE_mtm_finance_total_DeskCCY, 
PNL_DeskCCY  as PrevYE_mtm_finance_pnl_DeskCCY, 
OCI_DeskCCY as PrevYE_mtm_finance_OCI_DeskCCY, 
OU_DeskCCY as PrevYE_mtm_finance_ou_DeskCCY, 
NOR_DeskCCY as PrevYE_mtm_finance_nor_DeskCCY,
-total_mtm as ytd_mtm_finance_total, 
-PNL as ytd_mtm_finance_PNL, 
-OCI as ytd_mtm_finance_OCI, 
-ou as ytd_mtm_finance_OU,
-nor as ytd_mtm_finance_nor,
-total_mtm_DeskCCY as ytd_mtm_finance_total_DeskCCY, 
-PNL_deskccy as ytd_mtm_finance_PNL_DeskCCY, 
-OCI_DeskCCY as ytd_mtm_finance_OCI_DeskCCY, 
-OU_DeskCCY as ytd_mtm_finance_OU_DeskCCY,
-nor_DeskCCY as ytd_mtm_finance_nor_DeskCCY

from dbo.Fastracker_eoy

GO

