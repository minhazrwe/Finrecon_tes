CREATE TABLE [dbo].[map_LZB] (
    [ID]             INT           IDENTITY (1, 1) NOT NULL,
    [InstrumentType] VARCHAR (100) NULL,
    [CashflowType]   VARCHAR (100) NULL,
    [Konto]          VARCHAR (100) NULL,
    [LZB]            VARCHAR (100) NULL,
    CONSTRAINT [pk_tmp_MKTest_map_AWV_LZB] PRIMARY KEY CLUSTERED ([ID] ASC)
);


GO

