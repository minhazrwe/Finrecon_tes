CREATE TABLE [dbo].[VM_NETTING_Deals] (
    [ID]                      INT          IDENTITY (1, 1) NOT NULL,
    [BusinessDate]            VARCHAR (50) NULL,
    [DealNumber]              VARCHAR (50) NULL,
    [TradeDate]               VARCHAR (50) NULL,
    [TradePrice]              VARCHAR (50) NULL,
    [OLFPosition]             VARCHAR (50) NULL,
    [OLFPnl]                  VARCHAR (50) NULL,
    [OLFVM]                   VARCHAR (50) NULL,
    [Product]                 VARCHAR (50) NULL,
    [ExchangeCode]            VARCHAR (50) NULL,
    [OLFAccount]              VARCHAR (50) NULL,
    [ContractDate]            VARCHAR (50) NULL,
    [CallPut]                 VARCHAR (50) NULL,
    [StrikePrice]             VARCHAR (50) NULL,
    [StmClosingPrice]         VARCHAR (50) NULL,
    [StmPreviousClosingPrice] VARCHAR (50) NULL,
    [StmTotalPosition]        VARCHAR (50) NULL,
    [StmTotalVM]              VARCHAR (50) NULL,
    [StmTotalPnl]             VARCHAR (50) NULL,
    [Toolset]                 VARCHAR (50) NULL,
    [ProjectionIndex1]        VARCHAR (50) NULL,
    [ProjectionIndex2]        VARCHAR (50) NULL,
    [ExternalBU]              VARCHAR (50) NULL,
    [Portfolio]               VARCHAR (50) NULL,
    [Trader]                  VARCHAR (50) NULL,
    [Currency]                VARCHAR (50) NULL,
    [Dealtype]                VARCHAR (50) NULL
);


GO

