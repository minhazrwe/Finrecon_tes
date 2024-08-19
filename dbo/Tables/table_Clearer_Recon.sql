CREATE TABLE [dbo].[table_Clearer_Recon] (
    [COB]                  DATE          NOT NULL,
    [DeliveryMonth]        VARCHAR (100) NULL,
    [Exchange]             VARCHAR (100) NOT NULL,
    [LegalEntity]          VARCHAR (100) NULL,
    [Desk]                 VARCHAR (100) NULL,
    [InternalPortfolio]    VARCHAR (100) NULL,
    [ExternalBusinessUnit] VARCHAR (100) NULL,
    [AccountName]          VARCHAR (100) NULL,
    [InstrumentType]       VARCHAR (100) NULL,
    [ProductRecon]         VARCHAR (100) NULL,
    [DealNumber]           VARCHAR (100) NULL,
    [ProductName]          VARCHAR (100) NULL,
    [ContractName]         VARCHAR (100) NULL,
    [Toolset]              VARCHAR (255) NULL,
    [ProjectionIndex1]     VARCHAR (100) NULL,
    [ProjectionIndex2]     VARCHAR (100) NULL,
    [ContractDate]         DATE          NULL,
    [SettlementDate]       DATE          NULL,
    [TradePrice]           FLOAT (53)    NULL,
    [SettlementPrice]      FLOAT (53)    NULL,
    [PositionStatement]    FLOAT (53)    NULL,
    [PositionEndur]        FLOAT (53)    NULL,
    [RealisedStatement]    FLOAT (53)    NULL,
    [RealisedEndur]        FLOAT (53)    NULL,
    [RealisedDifference]   FLOAT (53)    NULL,
    [CCY]                  VARCHAR (10)  NULL,
    [OrderNo]              VARCHAR (100) NULL,
    [Commodity]            VARCHAR (100) NULL,
    [ClearerID]            INT           NOT NULL,
    [LastUpdate]           DATE          CONSTRAINT [DF_table_Clearer_Recon_LastUpdate] DEFAULT (getdate()) NOT NULL
);


GO

