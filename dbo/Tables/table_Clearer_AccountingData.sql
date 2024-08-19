CREATE TABLE [dbo].[table_Clearer_AccountingData] (
    [ID]                INT            IDENTITY (1, 1) NOT NULL,
    [CoB]               DATE           NOT NULL,
    [DealNumber]        NVARCHAR (200) NOT NULL,
    [AccountName]       NVARCHAR (200) NULL,
    [InternalPortfolio] NVARCHAR (200) NULL,
    [ContractName]      NVARCHAR (200) NULL,
    [ContractDate]      DATE           NULL,
    [ProductName]       NVARCHAR (200) NULL,
    [SettlementDate]    DATE           NULL,
    [ExerciseDate]      DATE           NULL,
    [DeliveryDate]      DATE           NULL,
    [DeliveryType]      NVARCHAR (200) NULL,
    [ProjectionIndex1]  NVARCHAR (200) NULL,
    [ProjectionIndex2]  NVARCHAR (200) NULL,
    [Toolset]           NVARCHAR (200) NULL,
    [Position]          FLOAT (53)     NULL,
    [TradePrice]        FLOAT (53)     NULL,
    [SettlementPrice]   FLOAT (53)     NULL,
    [RealisedPnL]       FLOAT (53)     NULL,
    [CCY]               NVARCHAR (200) NULL,
    [ClearerID]         INT            NOT NULL,
    [ClearerType]       NVARCHAR (200) NOT NULL,
    [LastImport]        DATETIME       CONSTRAINT [DF_table_Clearer_AccountingData_LastImport] DEFAULT (getdate()) NOT NULL,
    CONSTRAINT [PK_table_Clearer_AccountingData] PRIMARY KEY CLUSTERED ([ID] ASC)
);


GO

