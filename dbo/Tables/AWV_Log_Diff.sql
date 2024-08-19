CREATE TABLE [dbo].[AWV_Log_Diff] (
    [SAPDocumentNumber] VARCHAR (50) NULL,
    [SAPAccount]        VARCHAR (50) NULL,
    [ID]                INT          IDENTITY (1, 1) NOT NULL,
    CONSTRAINT [pk_AWV_Log_Diff] PRIMARY KEY CLUSTERED ([ID] DESC)
);


GO

