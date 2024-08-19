CREATE TABLE [dbo].[map_CS_Counterparty] (
    [CS_LegalEntity] VARCHAR (300) NOT NULL,
    [ExtBunit]       VARCHAR (50)  NOT NULL,
    [Comment]        VARCHAR (300) NOT NULL,
    [TimeStamp]      DATETIME      CONSTRAINT [DF_map_CS_Counterparty_TimeStamp] DEFAULT (getdate()) NOT NULL,
    [User]           VARCHAR (255) CONSTRAINT [DF_map_CS_Counterparty_user] DEFAULT (user_name()) NOT NULL,
    [ID]             INT           IDENTITY (1, 1) NOT NULL,
    [Gassteuer]      FLOAT (53)    NULL,
    [Stromsteuer]    FLOAT (53)    NULL,
    CONSTRAINT [PK_map_CS_Counterparty] PRIMARY KEY CLUSTERED ([CS_LegalEntity] ASC)
);


GO

