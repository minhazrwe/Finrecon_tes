CREATE TABLE [dbo].[FutureRevenuesIII] (
    [Desk]                 VARCHAR (50)  NULL,
    [AsofDate]             DATETIME      NULL,
    [Subsidiary]           VARCHAR (255) NULL,
    [InternalPortfolio]    VARCHAR (50)  NULL,
    [ExternalBusinessUnit] VARCHAR (50)  NULL,
    [ExtLegalEntity]       VARCHAR (50)  NULL,
    [ExtPortfolio]         VARCHAR (50)  NULL,
    [CounterpartyGroup]    VARCHAR (50)  NULL,
    [InstrumentType]       VARCHAR (50)  NULL,
    [ProjIndexGroup]       VARCHAR (50)  NULL,
    [CurveName]            VARCHAR (50)  NULL,
    [Product]              VARCHAR (50)  NULL,
    [FixedPrice]           FLOAT (53)    NULL,
    [CCY_ROCK]             VARCHAR (5)   NULL,
    [ReferenceID]          VARCHAR (50)  NULL,
    [TermEnd]              DATETIME      NULL,
    [Buy_Sell]             VARCHAR (4)   NOT NULL,
    [Total_Volume]         FLOAT (53)    NULL,
    [Total_MtM]            FLOAT (53)    NULL,
    [Revenue]              FLOAT (53)    NULL
);


GO

