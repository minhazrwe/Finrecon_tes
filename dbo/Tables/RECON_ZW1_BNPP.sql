CREATE TABLE [dbo].[RECON_ZW1_BNPP] (
    [Source]               VARCHAR (100) NOT NULL,
    [Liefermonat]          VARCHAR (100) NULL,
    [Exchange]             VARCHAR (100) NOT NULL,
    [LegalEntity]          VARCHAR (100) NULL,
    [desk]                 VARCHAR (100) NULL,
    [Portfolio]            VARCHAR (100) NULL,
    [ExternalBusinessUnit] VARCHAR (100) NULL,
    [Account]              VARCHAR (100) NULL,
    [InsType]              VARCHAR (100) NULL,
    [Product_Recon]        VARCHAR (100) NULL,
    [dealID]               VARCHAR (100) NULL,
    [product]              VARCHAR (100) NULL,
    [Contract]             VARCHAR (100) NULL,
    [toolset]              VARCHAR (255) NULL,
    [ProjIndex1]           VARCHAR (100) NULL,
    [ProjIndex2]           VARCHAR (100) NULL,
    [ContractDate]         DATE          NULL,
    [SettlementDate]       DATE          NULL,
    [TradePrice]           FLOAT (53)    NULL,
    [SettlementPrice]      FLOAT (53)    NULL,
    [Position_Statement]   FLOAT (53)    NULL,
    [Position_Endur]       FLOAT (53)    NULL,
    [Realised_Statement]   FLOAT (53)    NULL,
    [realised_Endur]       FLOAT (53)    NULL,
    [CurrencyZW1]          VARCHAR (5)   NULL,
    [Auftrag]              VARCHAR (100) NULL,
    [commodity]            VARCHAR (100) NULL
);


GO

