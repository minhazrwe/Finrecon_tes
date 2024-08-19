CREATE TABLE [dbo].[FASTracker] (
    [AsofDate]              DATETIME     NULL,
    [Sub ID]                INT          NULL,
    [ReferenceID]           VARCHAR (50) NULL,
    [Trade Date]            DATETIME     NULL,
    [TermStart]             DATETIME     NULL,
    [TermEnd]               DATETIME     NULL,
    [InternalPortfolio]     VARCHAR (50) NULL,
    [SourceSystemBookID]    VARCHAR (50) NULL,
    [Counterparty_ExtBunit] VARCHAR (50) NULL,
    [CounterpartyGroup]     VARCHAR (50) NULL,
    [Volume]                FLOAT (53)   NULL,
    [FixedPrice]            FLOAT (53)   NULL,
    [CurveName]             VARCHAR (50) NULL,
    [ProjIndexGroup]        VARCHAR (50) NULL,
    [InstrumentType]        VARCHAR (50) NULL,
    [UOM]                   VARCHAR (50) NULL,
    [ExtLegalEntity]        VARCHAR (50) NULL,
    [ExtPortfolio]          VARCHAR (50) NULL,
    [Product]               VARCHAR (50) NULL,
    [Discounted_MTM]        FLOAT (53)   NULL,
    [Discounted_PNL]        FLOAT (53)   NULL,
    [Discounted_AOCI]       FLOAT (53)   NULL,
    [Undiscounted_MTM]      FLOAT (53)   NULL,
    [Undiscounted_PNL]      FLOAT (53)   NULL,
    [Undiscounted_AOCI]     FLOAT (53)   NULL,
    [Volume Available]      FLOAT (53)   NULL,
    [Volume Used]           FLOAT (53)   NULL
);


GO

