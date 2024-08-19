CREATE TABLE [dbo].[RiskRecon_GloRi_RiskPNL_tbl] (
    [Desk]                      VARCHAR (50) NULL,
    [Subdesk]                   VARCHAR (50) NULL,
    [Subdeskccy]                VARCHAR (5)  NULL,
    [risk_PnL_YtD_RepCCY]       FLOAT (53)   NULL,
    [risk_realised_disc_RepCCY] FLOAT (53)   NULL,
    [risk_mtm_EOM_RepCCY]       FLOAT (53)   NULL,
    [risk_mtm_EOY_RepCCY]       FLOAT (53)   NULL,
    [risk_PnL_YtD_EUR]          FLOAT (53)   NULL,
    [risk_realised_disc_repEUR] FLOAT (53)   NULL,
    [risk_mtm_EOM_RepEUR]       FLOAT (53)   NULL,
    [risk_mtm_EOY_RepEUR]       FLOAT (53)   NULL,
    [risk_mtm_EOM_EUR]          FLOAT (53)   NULL,
    [risk_mtm_EOY_EUR]          FLOAT (53)   NULL
);


GO

