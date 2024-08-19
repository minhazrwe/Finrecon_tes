CREATE TABLE [dbo].[table_Day1ProfitLoss_MTM] (
    [Reference_ID] NVARCHAR (150) NULL,
    [report_date]  DATE           NULL,
    [Term_end]     DATE           NULL,
    [CCY]          NVARCHAR (10)  NULL,
    [fx_rate]      FLOAT (53)     NULL,
    [mtm_disc]     FLOAT (53)     NULL,
    [mtm_undisc]   FLOAT (53)     NULL
);


GO

