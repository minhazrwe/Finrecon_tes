CREATE TABLE [dbo].[AWV_Log_Erweiterung_Okt_2019] (
    [SAPDocumentNumber] VARCHAR (50) NULL,
    [SAPAccount]        VARCHAR (50) NULL,
    [AsOfDate]          DATETIME     NULL,
    [SAPCompanyCode]    INT          NULL,
    [AWVAnlage]         VARCHAR (20) NULL,
    [AWV-Responsible]   VARCHAR (50) NULL,
    [User]              VARCHAR (50) NULL,
    [ExportDate]        DATETIME     NULL,
    [ID]                INT          IDENTITY (1, 1) NOT NULL,
    CONSTRAINT [pk_AWV_Log_OKT_2019] PRIMARY KEY CLUSTERED ([ID] DESC)
);


GO

