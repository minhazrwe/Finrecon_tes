CREATE TABLE [dbo].[AWV_Log_2020] (
    [SAPDocumentNumber] VARCHAR (50) NULL,
    [SAPAccount]        VARCHAR (50) NULL,
    [AsOfDate]          DATETIME     NULL,
    [SAPCompanyCode]    INT          NULL,
    [AWVAnlage]         VARCHAR (20) NULL,
    [AWV-Responsible]   VARCHAR (50) NULL,
    [User]              VARCHAR (50) NULL,
    [ExportDate]        DATETIME     NULL,
    [ID]                INT          IDENTITY (1, 1) NOT NULL
);


GO

