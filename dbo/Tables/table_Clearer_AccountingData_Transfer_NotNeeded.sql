CREATE TABLE [dbo].[table_Clearer_AccountingData_Transfer_NotNeeded] (
    [SettlementDate]    DATE           NULL,
    [AccountName]       NVARCHAR (200) NULL,
    [DealNumber]        NVARCHAR (200) NULL,
    [ContractName]      NVARCHAR (200) NULL,
    [ContractDate]      DATE           NULL,
    [ProjectionIndex1]  NVARCHAR (200) NULL,
    [ProjectionIndex2]  NVARCHAR (200) NULL,
    [InternalPortfolio] NVARCHAR (200) NULL,
    [Toolset]           NVARCHAR (200) NULL,
    [Position]          FLOAT (53)     NULL,
    [TradePrice]        FLOAT (53)     NULL,
    [SettlementPrice]   FLOAT (53)     NULL,
    [RealisedPnL]       FLOAT (53)     NULL,
    [CallPut]           NVARCHAR (4)   NULL,
    [CCY]               NVARCHAR (200) NULL,
    [DeliveryType]      NVARCHAR (200) NULL,
    [ProductName]       NVARCHAR (200) NULL,
    [ExerciseDate]      DATE           NULL,
    [DeliveryDate]      DATE           NULL,
    [ClearerName]       NVARCHAR (200) NOT NULL,
    [LastImport]        DATETIME       CONSTRAINT [DF_table_Clearer_AccountingData_Transfer_LastImport] DEFAULT (getdate()) NOT NULL
);


GO

