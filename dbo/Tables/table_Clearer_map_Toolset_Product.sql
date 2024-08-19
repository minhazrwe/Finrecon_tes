CREATE TABLE [dbo].[table_Clearer_map_Toolset_Product] (
    [ID]          INT            IDENTITY (1, 1) NOT NULL,
    [Toolset]     NVARCHAR (100) NOT NULL,
    [ProductName] NVARCHAR (100) NULL,
    [LastUpdate]  DATETIME       CONSTRAINT [DF_table_map_Toolset_Product_LastUpdate] DEFAULT (getdate()) NOT NULL,
    CONSTRAINT [PK_table_map_Toolset_Product] PRIMARY KEY CLUSTERED ([ID] ASC)
);


GO

