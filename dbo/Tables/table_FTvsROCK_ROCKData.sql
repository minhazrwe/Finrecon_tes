CREATE TABLE [dbo].[table_FTvsROCK_ROCKData] (
    [COB]                   DATE           NULL,
    [DeskName]              NVARCHAR (200) NULL,
    [TradeDealNumber]       NVARCHAR (20)  NULL,
    [InternalPortfolio]     NVARCHAR (100) NULL,
    [InstrumentType]        NVARCHAR (100) NULL,
    [CashflowDeliveryMonth] DATE           NULL,
    [LegEndDate]            DATE           NULL,
    [ExternalPortfolio]     NVARCHAR (100) NULL,
    [UnrealisedDiscounted]  FLOAT (53)     NULL,
    [RealisedDiscounted]    FLOAT (53)     NULL,
    [FileID]                INT            NULL,
    [LastImport]            DATETIME       CONSTRAINT [DF_table_FTvsROCK_ROCKData] DEFAULT (getdate()) NULL
);


GO

