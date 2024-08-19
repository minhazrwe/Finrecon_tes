CREATE TABLE [dbo].[RiskRecon_GloRi_DealLevel_tbl] (
    [Desk]                       VARCHAR (50)   NULL,
    [Subdesk]                    VARCHAR (50)   NULL,
    [Portfolio]                  VARCHAR (60)   NULL,
    [InstrumentType]             VARCHAR (1500) NULL,
    [DealID]                     VARCHAR (800)  NULL,
    [maxccy]                     VARCHAR (5)    NULL,
    [MaxEndDate]                 DATE           NULL,
    [MaxTradeDate]               DATE           NULL,
    [finance_mtm_EOM_EUR]        FLOAT (53)     NULL,
    [finance_mtm_EOY_EUR]        FLOAT (53)     NULL,
    [risk_mtm_EOM_EUR]           FLOAT (53)     NULL,
    [risk_mtm_EOY_EUR]           FLOAT (53)     NULL,
    [finance_mtm_EOM_DeskCCY]    FLOAT (53)     NULL,
    [finance_mtm_EOY_DeskCCY]    FLOAT (53)     NULL,
    [risk_mtm_EOM_DeskCCY]       FLOAT (53)     NULL,
    [risk_mtm_EOY_DeskCCY]       FLOAT (53)     NULL,
    [finance_realised_CCY]       FLOAT (53)     NULL,
    [finance_realised_DeskCCY]   FLOAT (53)     NULL,
    [finance_realised_EUR]       FLOAT (53)     NULL,
    [risk_realised_undisc_CCY]   FLOAT (53)     NULL,
    [risk_realised_disc_DeskCCY] FLOAT (53)     NULL,
    [risk_realised_disc_repEUR]  FLOAT (53)     NULL,
    [Diff_mtm_EOM_EUR]           FLOAT (53)     NULL,
    [Diff_mtm_EOY_EUR]           FLOAT (53)     NULL,
    [Diff_mtm_EUR]               FLOAT (53)     NULL,
    [Diff_mtm_DeskCCY]           FLOAT (53)     NULL,
    [Diff_realised_CCY]          FLOAT (53)     NULL,
    [Diff_realised_DeskCCY]      FLOAT (53)     NULL,
    [Diff_realised_EUR]          FLOAT (53)     NULL,
    [Total_Diff_EUR]             FLOAT (53)     NULL,
    [AbsTotal_Diff_EUR]          FLOAT (53)     NULL
);


GO

