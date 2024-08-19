CREATE TABLE [dbo].[table_ROCK_GPM_PNL_ALL_Data] (
    [CoB]                  DATE           NULL,
    [DealID]               NVARCHAR (100) NULL,
    [InternalPortfolio]    NVARCHAR (100) NULL,
    [CounterpartyGroup]    NVARCHAR (100) NULL,
    [InstrumentType]       NVARCHAR (100) NULL,
    [ProjectionIndexGroup] NVARCHAR (100) NULL,
    [Liefermonat]          NVARCHAR (50)  NULL,
    [Risk_MTM]             FLOAT (53)     NULL,
    [FT_MTM]               FLOAT (53)     NULL,
    [FileID]               INT            NULL,
    [FileSource]           NVARCHAR (50)  NULL
);


GO

