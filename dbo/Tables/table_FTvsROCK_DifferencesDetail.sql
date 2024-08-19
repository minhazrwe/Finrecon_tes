CREATE TABLE [dbo].[table_FTvsROCK_DifferencesDetail] (
    [COB]               DATE           NULL,
    [Subsidiary]        NVARCHAR (200) NULL,
    [strategy]          NVARCHAR (200) NULL,
    [TradeDealNumber]   NVARCHAR (50)  NULL,
    [InternalPortfolio] NVARCHAR (200) NULL,
    [ExternalPortfolio] NVARCHAR (200) NULL,
    [InstrumentType]    NVARCHAR (200) NULL,
    [Product]           NVARCHAR (200) NULL,
    [TermEnd]           DATE           NULL,
    [ROCK]              FLOAT (53)     NULL,
    [FASTracker]        FLOAT (53)     NULL,
    [DiffRounded]       FLOAT (53)     NULL,
    [AbsDiffRounded]    FLOAT (53)     NULL,
    [LastRun]           DATETIME       CONSTRAINT [DF_FTvsROCK_DifferencesDetail_lastrun] DEFAULT (getdate()) NOT NULL,
    [ID]                INT            IDENTITY (1, 1) NOT NULL,
    CONSTRAINT [PK_FTvsROCK_DifferencesDetail] PRIMARY KEY CLUSTERED ([ID] ASC)
);


GO

