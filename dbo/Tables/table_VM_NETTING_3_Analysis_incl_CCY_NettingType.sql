CREATE TABLE [dbo].[table_VM_NETTING_3_Analysis_incl_CCY_NettingType] (
    [DealNumber]              VARCHAR (50)   NULL,
    [source]                  VARCHAR (50)   NULL,
    [Dealtype]                VARCHAR (50)   NULL,
    [DataType]                VARCHAR (50)   NULL,
    [Product]                 VARCHAR (50)   NULL,
    [ExchangeCode]            VARCHAR (50)   NULL,
    [Currency]                VARCHAR (50)   NULL,
    [Portfolio]               VARCHAR (50)   NULL,
    [ExternalBU]              VARCHAR (50)   NULL,
    [ContractDate]            DATETIME       NULL,
    [NettingType]             NVARCHAR (255) NULL,
    [Rate]                    FLOAT (53)     NULL,
    [RateRisk]                FLOAT (53)     NULL,
    [olfpnl]                  FLOAT (53)     NULL,
    [olfpnlCalcinEURRate]     FLOAT (53)     NULL,
    [olfpnlCalcinEURRateRisk] FLOAT (53)     NULL
);


GO

