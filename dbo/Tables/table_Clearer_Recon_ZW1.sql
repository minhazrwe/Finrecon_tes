CREATE TABLE [dbo].[table_Clearer_Recon_ZW1] (
    [COB]                  DATE          NOT NULL,
    [DataSource]           VARCHAR (100) NOT NULL,
    [Exchange]             VARCHAR (100) NOT NULL,
    [DealNumber]           VARCHAR (100) NULL,
    [Deliverymonth]        VARCHAR (100) NULL,
    [ProductName]          VARCHAR (100) NULL,
    [ProductRecon]         VARCHAR (100) NULL,
    [Commodity]            VARCHAR (100) NULL,
    [Desk]                 VARCHAR (100) NULL,
    [InternalPortfolio]    VARCHAR (100) NULL,
    [InstrumentType]       VARCHAR (100) NULL,
    [ExternalBusinessUnit] VARCHAR (100) NULL,
    [Toolset]              VARCHAR (255) NULL,
    [ProjectionIndex1]     VARCHAR (100) NULL,
    [ProjectionIndex2]     VARCHAR (100) NULL,
    [TradePrice]           FLOAT (53)    NULL,
    [CCY]                  VARCHAR (5)   NULL,
    [PositionStatement]    FLOAT (53)    NULL,
    [RealisedStatement]    FLOAT (53)    NULL,
    [PositionEndur]        FLOAT (53)    NULL,
    [RealisedEndur]        FLOAT (53)    NULL,
    [ContractDate]         DATE          NULL,
    [SettlementDate]       DATE          NULL,
    [SettlementPrice]      FLOAT (53)    NULL,
    [OrderNo]              VARCHAR (100) NULL,
    [LegalEntity]          VARCHAR (100) NULL,
    [AccountName]          VARCHAR (100) NULL,
    [ContractName]         VARCHAR (100) NULL,
    [ClearerID]            INT           NOT NULL,
    [LastUpdate]           DATETIME      CONSTRAINT [DF_table_Clearer_RECON_ZW1_LastUpdate] DEFAULT (getdate()) NOT NULL
);


GO

