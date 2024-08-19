CREATE TABLE [dbo].[Adjustments_2022] (
    [ID]                   INT           IDENTITY (1, 1) NOT NULL,
    [ReconGroup]           VARCHAR (40)  NOT NULL,
    [OrderNo]              VARCHAR (255) NOT NULL,
    [DeliveryMonth]        VARCHAR (255) NULL,
    [DealID]               VARCHAR (255) NULL,
    [Account]              VARCHAR (255) NULL,
    [Currency]             VARCHAR (255) NULL,
    [Quantity]             FLOAT (53)    NULL,
    [Realised_CCY]         FLOAT (53)    NULL,
    [Category]             VARCHAR (255) NULL,
    [Comment]              VARCHAR (255) NULL,
    [Valid_From]           DATETIME      NULL,
    [Valid_To]             DATETIME      NULL,
    [user]                 VARCHAR (255) CONSTRAINT [DF_Adjustments_new_user_Rock] DEFAULT (user_name()) NOT NULL,
    [timestamp]            DATETIME      CONSTRAINT [DF_Adjustments_new_timestamp_Rock] DEFAULT (getdate()) NOT NULL,
    [ExternalBusinessUnit] VARCHAR (100) NULL,
    [Partner]              VARCHAR (20)  NULL,
    [VAT]                  VARCHAR (20)  NULL,
    CONSTRAINT [PK_Adjustments_Rock] PRIMARY KEY CLUSTERED ([ID] ASC)
);


GO

