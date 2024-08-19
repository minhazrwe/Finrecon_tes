CREATE TABLE [dbo].[map_order_backup_20210923] (
    [ID]             INT           IDENTITY (1, 1) NOT NULL,
    [System]         VARCHAR (255) NOT NULL,
    [LegalEntity]    VARCHAR (50)  NOT NULL,
    [Desk_Risk]      VARCHAR (50)  NOT NULL,
    [SubDesk_Risk]   VARCHAR (255) NULL,
    [Desk]           VARCHAR (50)  NOT NULL,
    [SubDesk]        VARCHAR (255) NULL,
    [Book]           VARCHAR (255) NULL,
    [Portfolio]      VARCHAR (50)  NOT NULL,
    [PortfolioID]    VARCHAR (50)  NULL,
    [OrderNo]        VARCHAR (50)  NOT NULL,
    [Ref3]           VARCHAR (255) NULL,
    [ProfitCenter]   VARCHAR (255) NULL,
    [SubDeskCCY]     VARCHAR (3)   NOT NULL,
    [CommodityForFX] VARCHAR (50)  NULL,
    [Comment]        VARCHAR (255) NULL,
    [User]           VARCHAR (255) NOT NULL,
    [TimeStamp]      DATETIME      NOT NULL,
    [RepCCY]         VARCHAR (3)   NULL
);


GO

