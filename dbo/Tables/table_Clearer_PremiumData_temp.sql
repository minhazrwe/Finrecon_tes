CREATE TABLE [dbo].[table_Clearer_PremiumData_temp] (
    [TradeDate]         NVARCHAR (100) NULL,
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
    [StrikePrice]       FLOAT (53)     NULL,
    [Premium]           NVARCHAR (20)  NULL,
    [CallPut]           NVARCHAR (100) NULL,
    [CCY]               NVARCHAR (100) NULL,
    [DeliveryType]      NVARCHAR (100) NULL
);


GO

