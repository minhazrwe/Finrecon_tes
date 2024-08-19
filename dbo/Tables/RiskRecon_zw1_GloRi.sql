CREATE TABLE [dbo].[RiskRecon_zw1_GloRi] (
    [Portfolio]                 VARCHAR (60)   NULL,
    [InstrumentType]            VARCHAR (1500) NULL,
    [DealID]                    VARCHAR (800)  NULL,
    [Ticker]                    VARCHAR (100)  NULL,
    [ExtBunitName]              VARCHAR (100)  NULL,
    [ccy]                       VARCHAR (5)    NULL,
    [TradeDate]                 DATE           NULL,
    [EndDate]                   DATE           NULL,
    [finance_mtm_EOM]           FLOAT (53)     CONSTRAINT [DF_RiskRecon_zw1finance_mtm_EOM] DEFAULT ((0)) NULL,
    [finance_mtm_EOY]           FLOAT (53)     CONSTRAINT [DF_RiskRecon_zw1finance_mtm_EOY] DEFAULT ((0)) NULL,
    [finance_mtm_EOM_DeskCCY]   FLOAT (53)     CONSTRAINT [DF_RiskRecon_zw1risk_finance_mtm_EOM_DeskCCY] DEFAULT ((0)) NULL,
    [finance_mtm_EOY_DeskCCY]   FLOAT (53)     CONSTRAINT [DF_RiskRecon_zw1risk_finance_mtm_EOY_DeskCCY] DEFAULT ((0)) NULL,
    [finance_realised_CCY]      FLOAT (53)     CONSTRAINT [DF_RiskRecon_zw1finance_realised_CCY] DEFAULT ((0)) NULL,
    [finance_realised_DeskCCY]  FLOAT (53)     CONSTRAINT [DF_RiskRecon_zw1risk_finance_realised_DeskCCY] DEFAULT ((0)) NULL,
    [finance_realised_EUR]      FLOAT (53)     CONSTRAINT [DF_RiskRecon_zw1finance_realised_EUR] DEFAULT ((0)) NULL,
    [risk_mtm_EOM_EUR]          FLOAT (53)     CONSTRAINT [DF_RiskRecon_zw1risk_mtm_EOM_EUR] DEFAULT ((0)) NULL,
    [risk_mtm_EOM_RepCCY]       FLOAT (53)     CONSTRAINT [DF_RiskRecon_zw1risk_mtm_EOM_RepCCY] DEFAULT ((0)) NULL,
    [risk_mtm_EOM_RepEUR]       FLOAT (53)     CONSTRAINT [DF_RiskRecon_zw1risk_mtm_EOM_RepEUR] DEFAULT ((0)) NULL,
    [risk_mtm_EOY_EUR]          FLOAT (53)     CONSTRAINT [DF_RiskRecon_zw1risk_mtm_EOY_EUR] DEFAULT ((0)) NULL,
    [risk_mtm_EOY_RepCCY]       FLOAT (53)     CONSTRAINT [DF_RiskRecon_zw1risk_mtm_EOY_RepCCY] DEFAULT ((0)) NULL,
    [risk_mtm_EOY_RepEUR]       FLOAT (53)     CONSTRAINT [DF_RiskRecon_zw1risk_mtm_EOY_RepEUR] DEFAULT ((0)) NULL,
    [risk_realised_disc_EUR]    FLOAT (53)     CONSTRAINT [DF_RiskRecon_zw1risk_realised_disc_EUR] DEFAULT ((0)) NULL,
    [risk_realised_disc_RepCCY] FLOAT (53)     CONSTRAINT [DF_RiskRecon_zw1risk_realised_disc_RepCCY] DEFAULT ((0)) NULL,
    [risk_realised_disc_RepEUR] FLOAT (53)     CONSTRAINT [DF_RiskRecon_zw1risk_realised_disc_RepEUR] DEFAULT ((0)) NULL,
    [risk_realised_undisc_CCY]  FLOAT (53)     CONSTRAINT [DF_RiskRecon_zw1risk_realised_undisc_CCY] DEFAULT ((0)) NULL,
    [source]                    VARCHAR (10)   NULL
);


GO

