CREATE TABLE [dbo].[table_Clearer] (
    [ClearerID]                     INT            IDENTITY (1, 1) NOT NULL,
    [ClearerName]                   NVARCHAR (200) NOT NULL,
    [ClearerCountry]                NVARCHAR (10)  NOT NULL,
    [ClearerVariationMarginAccount] INT            NULL,
    [ClearerSpotBalanceAccount]     INT            NULL,
    [ClearerDBRelevant]             INT            NULL,
    [ClearerLongName]               NVARCHAR (200) NULL,
    [LastUpdate]                    DATETIME       CONSTRAINT [DF_table_Clearer_LastUpdate] DEFAULT (getdate()) NOT NULL
);


GO

