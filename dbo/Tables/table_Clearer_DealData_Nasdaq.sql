CREATE TABLE [dbo].[table_Clearer_DealData_Nasdaq] (
    [report_date]            DATE          NULL,
    [deal_number]            VARCHAR (30)  NULL,
    [account_name]           VARCHAR (30)  NULL,
    [internal_portfolio]     VARCHAR (30)  NULL,
    [external_business_unit] VARCHAR (30)  NULL,
    [ContractName]           VARCHAR (30)  NULL,
    [ContractSize]           FLOAT (53)    NULL,
    [brokerName]             VARCHAR (30)  NULL,
    [TradeDate]              DATE          NULL,
    [StartDate]              DATE          NULL,
    [EndDate]                DATE          NULL,
    [projection_index1]      VARCHAR (30)  NULL,
    [toolset]                VARCHAR (30)  NULL,
    [position]               FLOAT (53)    NULL,
    [CCY]                    VARCHAR (30)  NULL,
    [TradePrice]             FLOAT (53)    NULL,
    [StrikePrice]            FLOAT (53)    NULL,
    [premium]                FLOAT (53)    NULL,
    [callput]                VARCHAR (30)  NULL,
    [FeeRate]                FLOAT (53)    NULL,
    [TotalFee]               FLOAT (53)    NULL,
    [clearerID]              INT           NULL,
    [clearertype]            NVARCHAR (30) NULL
);


GO

