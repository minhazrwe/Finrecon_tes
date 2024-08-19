CREATE TABLE [dbo].[table_ROCK_GPM_Koeppen_data] (
    [COB]                DATE           NOT NULL,
    [Intermediate2Name]  NVARCHAR (100) NULL,
    [INTERNAL_PORTFOLIO] NVARCHAR (100) NULL,
    [Instrument_Type]    NVARCHAR (100) NULL,
    [DEAL_NUMBER]        NVARCHAR (100) NULL,
    [Term_End]           DATE           NULL,
    [MtM]                FLOAT (53)     NULL,
    [FileID]             INT            NULL,
    [LastImport]         DATETIME       CONSTRAINT [DF_table_ROCK_GPM_Koeppen_data_LastImport] DEFAULT (getdate()) NOT NULL
);


GO

