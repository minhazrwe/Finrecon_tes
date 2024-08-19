CREATE TABLE [dbo].[map_CS_Settled_DealID] (
    [EndurDealID] VARCHAR (100) NOT NULL,
    [Comment]     VARCHAR (100) NOT NULL,
    [TimeStamp]   DATETIME      CONSTRAINT [DF_map_CS_Settled_DealID_TimeStamp] DEFAULT (getdate()) NOT NULL,
    [User]        VARCHAR (255) CONSTRAINT [DF_map_CS_Settled_DealID_user] DEFAULT (user_name()) NOT NULL,
    [ID]          INT           IDENTITY (1, 1) NOT NULL,
    CONSTRAINT [PK_map_CS_Settled_DealID] PRIMARY KEY CLUSTERED ([EndurDealID] ASC)
);


GO

