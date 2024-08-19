CREATE TABLE [dbo].[table_FTvsROCK_FastrackerData] (
    [COB]                  DATE           NULL,
    [Subsidiary]           NVARCHAR (200) NULL,
    [Strategy]             NVARCHAR (200) NULL,
    [Book]                 NVARCHAR (200) NULL,
    [AccountingTreatment]  NVARCHAR (200) NULL,
    [ReferenceID]          NVARCHAR (50)  NULL,
    [TermEnd]              DATE           NULL,
    [InternalPortfolio]    NVARCHAR (200) NULL,
    [CounterpartyGroup]    NVARCHAR (200) NULL,
    [CurveName]            NVARCHAR (200) NULL,
    [ProjectionIndexGroup] NVARCHAR (200) NULL,
    [InstrumentType]       NVARCHAR (200) NULL,
    [Product]              NVARCHAR (200) NULL,
    [DiscountedPNL]        FLOAT (53)     NULL,
    [UndiscountedPNL]      FLOAT (53)     NULL,
    [FileID]               INT            NULL,
    [LastImport]           DATETIME       CONSTRAINT [DF_table_FTvsROCK_FastrackerData] DEFAULT (getdate()) NULL
);


GO

