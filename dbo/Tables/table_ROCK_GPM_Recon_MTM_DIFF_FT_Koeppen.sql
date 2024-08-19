CREATE TABLE [dbo].[table_ROCK_GPM_Recon_MTM_DIFF_FT_Koeppen] (
    [Strategy]             VARCHAR (255)  NULL,
    [DealID]               NVARCHAR (100) NULL,
    [InternalPortfolio]    NVARCHAR (100) NULL,
    [CounterpartyGroup]    NVARCHAR (100) NULL,
    [InstrumentType]       NVARCHAR (100) NULL,
    [ProjectionIndexGroup] NVARCHAR (100) NULL,
    [Liefermonat]          NVARCHAR (50)  NULL,
    [GPM_MTM]              FLOAT (53)     NULL,
    [Finance]              FLOAT (53)     NULL,
    [Adj]                  FLOAT (53)     NULL,
    [DUMMY]                FLOAT (53)     NULL,
    [Diff]                 FLOAT (53)     NULL,
    [absDiff]              FLOAT (53)     NULL
);


GO

