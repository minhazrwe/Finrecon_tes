CREATE TABLE [dbo].[map_CS_Settled_Portfolio] (
    [ReconGroup]           VARCHAR (40)  NOT NULL,
    [InternalPortfolio]    VARCHAR (100) NOT NULL,
    [CashflowType]         VARCHAR (100) NOT NULL,
    [ExternalBusinessUnit] VARCHAR (100) NOT NULL,
    [TimeStamp]            DATETIME      CONSTRAINT [DF_map_CS_Settled_Portfolio_TimeStamp] DEFAULT (getdate()) NOT NULL,
    [User]                 VARCHAR (255) CONSTRAINT [DF_map_CS_Settled_Portfolio_user] DEFAULT (user_name()) NOT NULL,
    [ID]                   INT           IDENTITY (1, 1) NOT NULL
);


GO

