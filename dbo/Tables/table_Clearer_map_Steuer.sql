CREATE TABLE [dbo].[table_Clearer_map_Steuer] (
    [ID]          INT            IDENTITY (1, 1) NOT NULL,
    [Toolset]     NVARCHAR (100) NOT NULL,
    [CompanyCode] NVARCHAR (100) NOT NULL,
    [STKZProfit]  NVARCHAR (100) NULL,
    [STKZLoss]    NVARCHAR (100) NULL,
    [ProductName] NVARCHAR (100) NULL,
    [LastUpdate]  DATETIME       CONSTRAINT [DF_table_map_Steuer_LastUpdate] DEFAULT (getdate()) NOT NULL,
    CONSTRAINT [PK_table_map_Steuer] PRIMARY KEY CLUSTERED ([ID] ASC)
);


GO

