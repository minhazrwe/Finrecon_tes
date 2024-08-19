CREATE TABLE [dbo].[Clearer_Helper] (
    [Position]          VARCHAR (1)     NOT NULL,
    [BS]                VARCHAR (2)     NOT NULL,
    [Konto]             NVARCHAR (100)  NULL,
    [Auftrag]           VARCHAR (50)    NULL,
    [Zuordnung]         NVARCHAR (4000) NULL,
    [BetragFW]          FLOAT (53)      NULL,
    [BuchungsText]      NVARCHAR (4000) NULL,
    [StKz]              NVARCHAR (100)  NULL,
    [BuKr]              NVARCHAR (10)   NULL,
    [Debitor]           INT             NULL,
    [MaterialCode]      NVARCHAR (100)  NULL,
    [LegalEntity]       VARCHAR (50)    NULL,
    [InternalPortfolio] NVARCHAR (200)  NULL,
    [Category]          NVARCHAR (100)  NULL,
    [CCY]               NVARCHAR (200)  NULL,
    [AccountName]       NVARCHAR (200)  NULL,
    [realisedPNL]       FLOAT (53)      NULL,
    [ProjectionIndex1]  NVARCHAR (200)  NULL,
    [Toolset]           NVARCHAR (200)  NULL,
    [SettlementDate]    DATE            NULL,
    [ContractDate]      DATE            NULL,
    [ContractName]      NVARCHAR (200)  NULL,
    [ProductName]       NVARCHAR (200)  NULL,
    [ClearerID]         INT             NULL,
    [COB]               DATE            NULL
);


GO

