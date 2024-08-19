CREATE TABLE [dbo].[RiskRecon_CAOCE] (
    [InternalLegalEntity]      VARCHAR (50)   NULL,
    [Desk]                     VARCHAR (50)   NULL,
    [Subdesk]                  VARCHAR (50)   NULL,
    [SubdeskCCY]               VARCHAR (5)    NULL,
    [Portfolio]                VARCHAR (60)   NULL,
    [InstrumentType]           VARCHAR (1500) NULL,
    [DealID]                   VARCHAR (800)  NULL,
    [Ticker]                   VARCHAR (100)  NULL,
    [ExtBunitName]             VARCHAR (100)  NULL,
    [ccy]                      VARCHAR (5)    NULL,
    [TradeDate]                DATE           NULL,
    [EndDate]                  DATE           NULL,
    [finance_mtm_EOM]          FLOAT (53)     CONSTRAINT [DF_RiskRecon_CAOCE_finance_mtm_EOM] DEFAULT ((0)) NULL,
    [finance_mtm_EOY]          FLOAT (53)     CONSTRAINT [DF_RiskRecon_CAOCE_finance_mtm_EOY] DEFAULT ((0)) NULL,
    [finance_realised_CCY]     FLOAT (53)     CONSTRAINT [DF_RiskRecon_CAOCE_finance_realised_CCY] DEFAULT ((0)) NULL,
    [finance_realised_EUR]     FLOAT (53)     CONSTRAINT [DF_RiskRecon_CAOCE_finance_realised_EUR] DEFAULT ((0)) NULL,
    [risk_mtm_EOM_EUR]         FLOAT (53)     CONSTRAINT [DF_RiskRecon_CAOCE_risk_mtm_EOM_EUR] DEFAULT ((0)) NULL,
    [risk_mtm_EOY_EUR]         FLOAT (53)     CONSTRAINT [DF_RiskRecon_CAOCE_risk_mtm_EOY_EUR] DEFAULT ((0)) NULL,
    [risk_realised_disc_EUR]   FLOAT (53)     CONSTRAINT [DF_RiskRecon_CAOCE_risk_realised_disc_EUR] DEFAULT ((0)) NULL,
    [risk_realised_undisc_CCY] FLOAT (53)     CONSTRAINT [DF_RiskRecon_CAOCE_risk_realised_undisc_CCY] DEFAULT ((0)) NULL
);


GO

