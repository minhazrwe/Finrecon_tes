CREATE TABLE [dbo].[table_ROCK_GPM_Recon_MTM_DIFF] (
    [Strategy]             VARCHAR (255)  NULL,
    [DealID]               NVARCHAR (100) NULL,
    [InternalPortfolio]    NVARCHAR (100) NULL,
    [CounterpartyGroup]    NVARCHAR (100) NULL,
    [InstrumentType]       NVARCHAR (100) NULL,
    [ProjectionIndexGroup] NVARCHAR (100) NULL,
    [Liefermonat]          NVARCHAR (50)  NULL,
    [Risk]                 FLOAT (53)     NULL,
    [Finance]              FLOAT (53)     NULL,
    [Adj]                  FLOAT (53)     NULL,
    [Dummy]                FLOAT (53)     NULL,
    [Diff]                 FLOAT (53)     NULL,
    [AbsDiff]              FLOAT (53)     NULL,
    [FileSource]           NVARCHAR (50)  NULL
);


GO

