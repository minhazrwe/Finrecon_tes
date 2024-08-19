CREATE TABLE [dbo].[map_not_needed_Portfolios] (
    [ID]             INT           IDENTITY (1, 1) NOT NULL,
    [Portfolio_Key]  VARCHAR (255) NOT NULL,
    [Portfolio_Name] VARCHAR (255) NOT NULL,
    [TimeStamp]      DATETIME      CONSTRAINT [DF_map_not_needed_Portfolios_ROCK_TimeStamp] DEFAULT (getdate()) NULL,
    [USER]           VARCHAR (50)  CONSTRAINT [DF_map_not_needed_Portfolios_ROCK_USER] DEFAULT (user_name()) NULL,
    CONSTRAINT [pkmap_not_needed_Portfolios_ROCK] PRIMARY KEY CLUSTERED ([Portfolio_Key] ASC)
);


GO

