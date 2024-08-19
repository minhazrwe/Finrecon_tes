CREATE TABLE [dbo].[map_order_NEW] (
    [ID]             INT           IDENTITY (1, 1) NOT NULL,
    [System]         VARCHAR (55)  NOT NULL,
    [LegalEntity]    VARCHAR (50)  NOT NULL,
    [Desk]           VARCHAR (50)  NOT NULL,
    [Desk_ID]        VARCHAR (50)  NOT NULL,
    [SubDesk]        VARCHAR (255) NULL,
    [SubDesk_ID]     VARCHAR (50)  NULL,
    [Book]           VARCHAR (255) NULL,
    [Book_ID]        VARCHAR (50)  NULL,
    [Portfolio]      VARCHAR (50)  NOT NULL,
    [PortfolioID]    VARCHAR (50)  NULL,
    [OrderNo]        VARCHAR (50)  NOT NULL,
    [Ref3]           VARCHAR (255) NULL,
    [ProfitCenter]   VARCHAR (255) NULL,
    [SubDeskCCY]     VARCHAR (3)   NULL,
    [CommodityForFX] VARCHAR (50)  NULL,
    [Comment]        VARCHAR (255) NULL,
    [User]           VARCHAR (255) CONSTRAINT [DF_map_order_user_new] DEFAULT (user_name()) NOT NULL,
    [LatestUpdate]   DATETIME      CONSTRAINT [DF_map_order_LatestUpdate] DEFAULT (getdate()) NOT NULL,
    [RepCCY]         VARCHAR (3)   NULL,
    CONSTRAINT [PK_map_order_NEW] PRIMARY KEY CLUSTERED ([Portfolio] ASC)
);


GO

