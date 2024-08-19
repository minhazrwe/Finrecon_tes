CREATE TABLE [dbo].[table_LATE_PNL_CAO_raw] (
    [ID]                        INT           IDENTITY (1, 1) NOT NULL,
    [SUBDESK]                   VARCHAR (100) NULL,
    [COB]                       DATE          NULL,
    [TRADE_DEAL_NUMBER]         VARCHAR (100) NULL,
    [TRAN_STATUS]               VARCHAR (100) NULL,
    [INS_TYPE_NAME]             VARCHAR (100) NULL,
    [LENTITY_NAME]              VARCHAR (100) NULL,
    [BUNIT_NAME]                VARCHAR (100) NULL,
    [PORTFOLIO_ID]              VARCHAR (100) NULL,
    [PORTFOLIO_NAME]            VARCHAR (100) NULL,
    [EXT_PORTFOLIO_NAME]        VARCHAR (100) NULL,
    [EXT_BUNIT_NAME]            VARCHAR (100) NULL,
    [EXT_LENTITY_NAME]          VARCHAR (100) NULL,
    [INDEX_NAME]                VARCHAR (100) NULL,
    [TRADE_CURRENCY]            VARCHAR (100) NULL,
    [TRANSACTION_INFO_BUY_SELL] VARCHAR (100) NULL,
    [CASHFLOW_TYPE]             VARCHAR (100) NULL,
    [TRADE_PRICE]               FLOAT (53)    NULL,
    [TRADE_DATE]                DATE          NULL,
    [TICKER]                    VARCHAR (100) NULL,
    [UNIT_NAME]                 VARCHAR (100) NULL,
    [CASHFLOW_PAYMENT_DATE]     DATE          NULL,
    [INDEX_GROUP]               VARCHAR (100) NULL,
    [VOLUME]                    FLOAT (53)    NULL,
    [REALISED_ORIGCCY_UNDISC]   FLOAT (53)    NULL,
    [REALISED_EUR_UNDISC]       FLOAT (53)    NULL,
    [DELIVERY_MONTH]            VARCHAR (100) NULL,
    [TRADE_REFERENCE_TEXT]      VARCHAR (100) NULL,
    [LastUpdate]                DATETIME      DEFAULT (getdate()) NOT NULL,
    CONSTRAINT [PK_LATE_PNL] PRIMARY KEY CLUSTERED ([ID] ASC)
);


GO

