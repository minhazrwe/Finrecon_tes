CREATE TABLE [dbo].[table_FixedPrice] (
    [Strategy]     NVARCHAR (100) NULL,
    [ReferenceID]  NVARCHAR (100) NULL,
    [TermEnd]      DATE           NULL,
    [FixedPrice]   FLOAT (53)     NULL,
    [DealCurrency] NVARCHAR (50)  NULL,
    [FixedFloat]   NVARCHAR (100) NULL,
    [LastUpdate]   DATETIME       CONSTRAINT [DF_table_FixedPrice_LastUpdate] DEFAULT (getdate()) NULL
);


GO

