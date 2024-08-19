CREATE TABLE [dbo].[map_EndurPortfolioTree] (
    [LegalEntity]          VARCHAR (100) NULL,
    [Desk]                 VARCHAR (100) NULL,
    [SubDesk1]             VARCHAR (100) NULL,
    [SubDesk2]             VARCHAR (100) NULL,
    [SubDesk3]             VARCHAR (100) NULL,
    [Book]                 VARCHAR (255) NULL,
    [InternalBusinessUnit] VARCHAR (100) NULL,
    [Portfolio]            VARCHAR (100) NULL,
    [PortfolioID]          INT           NOT NULL,
    CONSTRAINT [pk_EndurPortfolioTree] PRIMARY KEY CLUSTERED ([PortfolioID] ASC)
);


GO

