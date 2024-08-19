CREATE TABLE [dbo].[Recon_DE_Adjustments] (
    [LegalEntity]    VARCHAR (50)  NULL,
    [Desk]           VARCHAR (50)  NULL,
    [SubDesk]        VARCHAR (255) NULL,
    [Book]           VARCHAR (255) NULL,
    [ReconGroup]     VARCHAR (40)  NOT NULL,
    [OrderNo]        VARCHAR (255) NOT NULL,
    [PortfolioID]    VARCHAR (100) NULL,
    [DeliveryMonth]  VARCHAR (255) NULL,
    [DealID]         VARCHAR (255) NULL,
    [Account]        VARCHAR (255) NULL,
    [Currency]       VARCHAR (255) NULL,
    [Quantity]       FLOAT (53)    NULL,
    [Realised_CCY]   FLOAT (53)    NULL,
    [Realised_CCY_2] FLOAT (53)    NULL,
    [Category]       VARCHAR (255) NULL,
    [Comment]        VARCHAR (255) NULL,
    [Valid_From]     DATETIME      NULL,
    [Valid_To]       DATETIME      NULL,
    [User]           VARCHAR (255) NOT NULL,
    [timestamp]      DATETIME      NOT NULL
);


GO

