CREATE TABLE [dbo].[table_Clearer_DealData_x] (
    [ID]                   INT            IDENTITY (1, 1) NOT NULL,
    [ReportDate]           DATE           NOT NULL,
    [DealNumber]           NVARCHAR (200) NULL,
    [AccountName]          NVARCHAR (200) NULL,
    [InternalPortfolio]    NVARCHAR (200) NULL,
    [ExternalBusinessUnit] NVARCHAR (200) NULL,
    [ContractName]         NVARCHAR (200) NULL,
    [ContractSize]         FLOAT (53)     NULL,
    [BrokerName]           NVARCHAR (200) NULL,
    [TradeDate]            DATE           NULL,
    [StartDate]            DATE           NULL,
    [EndDate]              DATE           NULL,
    [ProjectionIndex1]     NVARCHAR (200) NULL,
    [ProjectionIndex2]     NVARCHAR (200) NULL,
    [Toolset]              NVARCHAR (200) NULL,
    [Position]             FLOAT (53)     NULL,
    [CCY]                  NVARCHAR (3)   NULL,
    [TradePrice]           FLOAT (53)     NULL,
    [StrikePrice]          FLOAT (53)     NULL,
    [Premium]              FLOAT (53)     NULL,
    [CallPut]              NVARCHAR (4)   NULL,
    [FeeType]              NVARCHAR (200) NULL,
    [FeeRate]              FLOAT (53)     NULL,
    [TotalFee]             FLOAT (53)     NULL,
    [AdjustedTotalFee]     FLOAT (53)     NULL,
    [ClearerID]            INT            NOT NULL,
    [ClearerType]          NVARCHAR (200) NOT NULL,
    [LastImport]           DATETIME       NOT NULL
);


GO

