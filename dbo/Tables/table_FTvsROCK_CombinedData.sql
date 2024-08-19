CREATE TABLE [dbo].[table_FTvsROCK_CombinedData] (
    [cob]               DATE           NULL,
    [subsidiary]        NVARCHAR (200) NULL,
    [strategy]          NVARCHAR (200) NULL,
    [TradeDealNumber]   NVARCHAR (50)  NULL,
    [InternalPortfolio] NVARCHAR (200) NULL,
    [ExternalPortfolio] NVARCHAR (100) NULL,
    [InstrumentType]    NVARCHAR (200) NULL,
    [Product]           NVARCHAR (200) NULL,
    [TermEnd]           DATE           NULL,
    [ROCK]              FLOAT (53)     NOT NULL,
    [FASTracker]        FLOAT (53)     NOT NULL,
    [Datasource]        VARCHAR (4)    NOT NULL
);


GO

