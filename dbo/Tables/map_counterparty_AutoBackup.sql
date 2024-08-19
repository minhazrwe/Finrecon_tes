CREATE TABLE [dbo].[map_counterparty_AutoBackup] (
    [ExtBunit]         VARCHAR (50)   NOT NULL,
    [ExtLegalEntity]   VARCHAR (50)   NULL,
    [Partner]          VARCHAR (255)  NULL,
    [Debitor]          VARCHAR (255)  NULL,
    [Country]          VARCHAR (255)  NULL,
    [ctpygroup]        VARCHAR (255)  NULL,
    [AccrualOnDebitor] BIT            NOT NULL,
    [Exchange]         BIT            NOT NULL,
    [UStID]            VARCHAR (255)  NULL,
    [CtpyID_Endur]     VARCHAR (10)   NULL,
    [TimeStamp]        DATETIME       NULL,
    [User]             VARCHAR (50)   NULL,
    [LegalEntity]      NVARCHAR (255) NULL,
    [CompanyCode]      NVARCHAR (4)   NULL,
    [backup_id]        BIGINT         NULL,
    [backup_timestamp] DATETIME       NULL,
    [backup_user]      VARCHAR (100)  NULL
);


GO

