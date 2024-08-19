CREATE TABLE [dbo].[VM_NETTING_Deallevel_archive] (
    [ID]           INT          IDENTITY (1, 1) NOT NULL,
    [AsofDate]     DATETIME     NULL,
    [source]       VARCHAR (50) NULL,
    [DealNumber]   VARCHAR (50) NULL,
    [olfpnl]       FLOAT (53)   NULL,
    [Product]      VARCHAR (50) NULL,
    [ExchangeCode] VARCHAR (50) NULL,
    [Currency]     VARCHAR (50) NULL,
    [Portfolio]    VARCHAR (50) NULL,
    [ExternalBU]   VARCHAR (50) NULL,
    [ContractDate] DATETIME     NULL
);


GO

