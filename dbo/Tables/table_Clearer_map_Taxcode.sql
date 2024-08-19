CREATE TABLE [dbo].[table_Clearer_map_Taxcode] (
    [ID]             INT            IDENTITY (1, 1) NOT NULL,
    [CompanyCode]    NVARCHAR (100) NULL,
    [ClearerCountry] NVARCHAR (10)  NULL,
    [ProductName]    NVARCHAR (100) NULL,
    [STKZProfit]     NVARCHAR (100) NULL,
    [STKZLoss]       NVARCHAR (100) NULL,
    [LastUpdate]     DATETIME       CONSTRAINT [DF_table_map_Taxcode_LastUpdate] DEFAULT (getdate()) NOT NULL,
    CONSTRAINT [PK_table_map_Taxcode] PRIMARY KEY CLUSTERED ([ID] ASC)
);


GO

