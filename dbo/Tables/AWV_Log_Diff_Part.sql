CREATE TABLE [dbo].[AWV_Log_Diff_Part] (
    [SAPDocumentNumber] VARCHAR (50) NULL,
    [SAPAccount]        VARCHAR (50) NULL,
    [SAPResponsible]    VARCHAR (50) NULL,
    [ID]                INT          IDENTITY (1, 1) NOT NULL,
    CONSTRAINT [pk_AWV_Log_Diff_Part] PRIMARY KEY CLUSTERED ([ID] DESC)
);


GO

