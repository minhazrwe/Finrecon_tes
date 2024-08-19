CREATE TABLE [dbo].[table_Clearer_BocarX_Fees] (
    [ReportDate]           DATE            NULL,
    [AccountName]          VARCHAR (40)    NOT NULL,
    [CurrencyFees]         VARCHAR (10)    NULL,
    [TradeDate]            DATE            NULL,
    [DealNumber]           VARCHAR (40)    NULL,
    [ContractName]         VARCHAR (40)    NULL,
    [StartDate]            DATE            NULL,
    [EndDate]              DATE            NULL,
    [ProjectionIndex1]     VARCHAR (100)   NULL,
    [ProjectionIndex2]     VARCHAR (100)   NULL,
    [ExternalBusinessUnit] VARCHAR (100)   NULL,
    [InternalPortfolio]    VARCHAR (100)   NULL,
    [Toolset]              VARCHAR (100)   NULL,
    [ContractSize]         INT             NULL,
    [Position]             INT             NULL,
    [TradePrice]           FLOAT (53)      NULL,
    [CallPut]              VARCHAR (100)   NULL,
    [StrikePrice]          FLOAT (53)      NULL,
    [Premium]              NUMERIC (28, 6) NULL,
    [Broker]               VARCHAR (100)   NULL,
    [FeeRate]              FLOAT (53)      NULL,
    [TotalFee]             FLOAT (53)      NULL,
    [ClearerID]            INT             NULL,
    [LastImport]           DATETIME        CONSTRAINT [DF_table_Clearer_BocarX_Fees] DEFAULT (getdate()) NOT NULL
);


GO

