CREATE TABLE [dbo].[RiskRecon_GloRi_Discounting_tbl] (
    [Desk]                       VARCHAR (50)   NULL,
    [Subdesk]                    VARCHAR (50)   NULL,
    [PhysFin]                    VARCHAR (69)   NULL,
    [InstrumentType]             VARCHAR (1500) NULL,
    [ccy]                        VARCHAR (5)    NULL,
    [finance_realised_EUR]       FLOAT (53)     NULL,
    [risk_realised_disc_repEUR]  FLOAT (53)     NULL,
    [Diff_EUR]                   FLOAT (53)     NULL,
    [finance_realised_DeskCCY]   FLOAT (53)     NULL,
    [risk_realised_disc_DeskCCY] FLOAT (53)     NULL,
    [Diff_DeskCCY]               FLOAT (53)     NULL
);


GO

