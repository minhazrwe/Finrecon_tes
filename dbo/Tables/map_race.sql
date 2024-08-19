CREATE TABLE [dbo].[map_race] (
    [AccountGroup]  VARCHAR (50)  NULL,
    [AccountNumber] VARCHAR (50)  NULL,
    [AccountName]   VARCHAR (50)  NULL,
    [RACE_Pos]      VARCHAR (50)  NULL,
    [Commodity]     VARCHAR (255) NULL,
    [category1]     VARCHAR (255) NULL,
    [category2]     VARCHAR (255) NULL,
    [ID]            INT           IDENTITY (1, 1) NOT NULL,
    [TimeStamp]     DATETIME      NULL,
    [User]          VARCHAR (50)  NULL,
    CONSTRAINT [pk_map_race_new] PRIMARY KEY CLUSTERED ([ID] ASC)
);


GO

