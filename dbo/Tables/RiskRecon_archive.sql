CREATE TABLE [dbo].[RiskRecon_archive] (
    [AsOfDate]                  DATETIME       NULL,
    [InternalLegalEntity]       VARCHAR (50)   NULL,
    [Desk]                      VARCHAR (50)   NULL,
    [Subdesk]                   VARCHAR (50)   NULL,
    [SubdeskCCY]                VARCHAR (5)    NULL,
    [Portfolio]                 VARCHAR (60)   NULL,
    [InstrumentType]            VARCHAR (1500) NULL,
    [DealID]                    VARCHAR (800)  NULL,
    [Ticker]                    VARCHAR (100)  NULL,
    [ExtBunitName]              VARCHAR (100)  NULL,
    [ccy]                       VARCHAR (5)    NULL,
    [TradeDate]                 DATE           NULL,
    [EndDate]                   DATE           NULL,
    [finance_mtm_EOM]           FLOAT (53)     NULL,
    [finance_mtm_EOY]           FLOAT (53)     NULL,
    [finance_mtm_EOM_DeskCCY]   FLOAT (53)     NULL,
    [finance_mtm_EOY_DeskCCY]   FLOAT (53)     NULL,
    [finance_realised_CCY]      FLOAT (53)     NULL,
    [finance_realised_DeskCCY]  FLOAT (53)     NULL,
    [finance_realised_EUR]      FLOAT (53)     NULL,
    [risk_mtm_EOM_EUR]          FLOAT (53)     NULL,
    [risk_mtm_EOM_RepCCY]       FLOAT (53)     NULL,
    [risk_mtm_EOM_RepEUR]       FLOAT (53)     NULL,
    [risk_mtm_EOY_EUR]          FLOAT (53)     NULL,
    [risk_mtm_EOY_RepCCY]       FLOAT (53)     NULL,
    [risk_mtm_EOY_RepEUR]       FLOAT (53)     NULL,
    [risk_realised_disc_EUR]    FLOAT (53)     NULL,
    [risk_realised_disc_RepCCY] FLOAT (53)     NULL,
    [risk_realised_disc_RepEUR] FLOAT (53)     NULL,
    [risk_realised_undisc_CCY]  FLOAT (53)     NULL
);


GO

