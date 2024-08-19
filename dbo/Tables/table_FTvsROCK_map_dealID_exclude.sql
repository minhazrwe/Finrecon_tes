CREATE TABLE [dbo].[table_FTvsROCK_map_dealID_exclude] (
    [ID]              INT            IDENTITY (1, 1) NOT NULL,
    [TradeDealNumber] NVARCHAR (200) NOT NULL,
    [Comment]         NVARCHAR (200) NULL,
    [LastUpdate]      DATETIME       CONSTRAINT [DF_map_dealID_exclude_ROCK_LastUpdate] DEFAULT (getdate()) NOT NULL,
    CONSTRAINT [PK_map_dealID_exclude_ROCK] PRIMARY KEY CLUSTERED ([ID] ASC),
    CONSTRAINT [UK_map_dealID_exclude_ROCK] UNIQUE NONCLUSTERED ([TradeDealNumber] ASC)
);


GO

