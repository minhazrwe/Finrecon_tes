CREATE TABLE [dbo].[Strolf_REALIZED_IFA] (
    [COB]                       DATETIME       NULL,
    [TRADE_DEAL_NUMBER]         NVARCHAR (400) NULL,
    [TRAN_STATUS]               NVARCHAR (400) NULL,
    [INS_TYPE_NAME]             NVARCHAR (400) NULL,
    [LENTITY_NAME]              NVARCHAR (400) NULL,
    [BUNIT_NAME]                NVARCHAR (400) NULL,
    [PORTFOLIO_ID]              FLOAT (53)     NULL,
    [PORTFOLIO_NAME]            NVARCHAR (400) NULL,
    [EXT_PORTFOLIO_NAME]        NVARCHAR (400) NULL,
    [EXT_BUNIT_NAME]            NVARCHAR (400) NULL,
    [EXT_LENTITY_NAME]          NVARCHAR (400) NULL,
    [INDEX_NAME]                NVARCHAR (400) NULL,
    [TRADE_CURRENCY]            NVARCHAR (3)   NULL,
    [TRANSACTION_INFO_BUY_SELL] NVARCHAR (400) NULL,
    [CASHFLOW_TYPE]             NVARCHAR (400) NULL,
    [TRADE_PRICE]               FLOAT (53)     NULL,
    [TRADE_DATE]                DATETIME       NULL,
    [TICKER]                    NVARCHAR (400) NULL,
    [UNIT_NAME]                 NVARCHAR (400) NULL,
    [CASHFLOW_PAYMENT_DATE]     DATETIME       NULL,
    [INDEX_GROUP]               NVARCHAR (400) NULL,
    [VOLUME]                    FLOAT (53)     NULL,
    [REALISED_ORIGCCY_UNDISC]   FLOAT (53)     NULL,
    [REALISED_EUR_UNDISC]       FLOAT (53)     NULL,
    [DELIVERY_MONTH]            DATETIME       NULL,
    [TRADE_REFERENCE_TEXT]      NVARCHAR (100) NULL
);


GO

