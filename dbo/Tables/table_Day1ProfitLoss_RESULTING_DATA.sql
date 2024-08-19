CREATE TABLE [dbo].[table_Day1ProfitLoss_RESULTING_DATA] (
    [Reference_ID]       NVARCHAR (150) NULL,
    [trade_date]         DATE           NULL,
    [first_report_date]  DATE           NULL,
    [CCY]                NVARCHAR (10)  NULL,
    [portfolio_name]     NVARCHAR (150) NULL,
    [instrument_type]    NVARCHAR (150) NULL,
    [counterparty]       NVARCHAR (150) NULL,
    [counterparty_group] NVARCHAR (150) NULL,
    [Term_end]           DATE           NULL,
    [mtm_disc]           FLOAT (53)     NULL,
    [mtm_undisc]         FLOAT (53)     NULL
);


GO

