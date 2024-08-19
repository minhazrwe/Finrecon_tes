CREATE TABLE [dbo].[AWV_Log_AutoBackup] (
    [SAPDocumentNumber] VARCHAR (50)  NULL,
    [SAPAccount]        VARCHAR (50)  NULL,
    [AsOfDate]          DATETIME      NULL,
    [SAPCompanyCode]    INT           NULL,
    [AWVAnlage]         VARCHAR (20)  NULL,
    [AWV-Responsible]   VARCHAR (50)  NULL,
    [User]              VARCHAR (50)  NULL,
    [ExportDate]        DATETIME      NULL,
    [backup_id]         BIGINT        NULL,
    [backup_timestamp]  DATETIME      NULL,
    [backup_user]       VARCHAR (100) NULL
);


GO

