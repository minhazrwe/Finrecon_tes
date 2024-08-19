CREATE TABLE [dbo].[table_Clearer_SettlementData_temp] (
    [SettlementDate]    NVARCHAR (100) NULL,
    [AccountName]       NVARCHAR (100) NULL,
    [DealNumber]        NVARCHAR (100) NULL,
    [ContractName]      NVARCHAR (100) NULL,
    [ContractDate]      NVARCHAR (100) NULL,
    [ProjectionIndex1]  NVARCHAR (100) NULL,
    [ProjectionIndex2]  NVARCHAR (100) NULL,
    [InternalPortfolio] NVARCHAR (100) NULL,
    [Toolset]           NVARCHAR (100) NULL,
    [Position]          FLOAT (53)     NULL,
    [TradePrice]        FLOAT (53)     NULL,
    [SettlementPrice]   FLOAT (53)     NULL,
    [RealizedPNL]       FLOAT (53)     NULL,
    [CCY]               NVARCHAR (100) NULL
);


GO

