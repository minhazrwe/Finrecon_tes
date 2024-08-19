CREATE TABLE [dbo].[map_SBM] (
    [ID]                   INT           IDENTITY (1, 1) NOT NULL,
    [AsOfDate]             SMALLDATETIME NULL,
    [Subsidiary]           VARCHAR (255) NULL,
    [Strategy]             VARCHAR (255) NULL,
    [Book]                 VARCHAR (255) NULL,
    [InternalPortfolio]    VARCHAR (255) NULL,
    [CounterpartyGroup]    VARCHAR (255) NULL,
    [InstrumentType]       VARCHAR (255) NULL,
    [ProjectionIndexGroup] VARCHAR (255) NULL,
    [AccountingTreatment]  VARCHAR (255) NULL,
    [HedgeSTAsset]         VARCHAR (255) NULL,
    [HedgeLTAsset]         VARCHAR (255) NULL,
    [HedgeSTLiability]     VARCHAR (255) NULL,
    [HedgeLTLiability]     VARCHAR (255) NULL,
    [UnhedgedSTAsset]      VARCHAR (255) NULL,
    [UnhedgedLTAsset]      VARCHAR (255) NULL,
    [UnhedgedSTLiability]  VARCHAR (255) NULL,
    [UnhedgedLTLiability]  VARCHAR (255) NULL,
    [AOCI_Hedge Reserve]   VARCHAR (255) NULL,
    [UnrealizedEarnings]   VARCHAR (255) NULL,
    [PortfolioID]          VARCHAR (255) NULL,
    [TimeStamp]            DATETIME      CONSTRAINT [DF_map_SBM_TimeStamp] DEFAULT (getdate()) NULL,
    [User]                 VARCHAR (50)  CONSTRAINT [DF_map_SBM_User] DEFAULT (user_name()) NULL,
    CONSTRAINT [pk_map_SBM] PRIMARY KEY CLUSTERED ([ID] ASC)
);


GO

