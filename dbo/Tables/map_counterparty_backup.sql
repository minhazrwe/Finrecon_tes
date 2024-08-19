CREATE TABLE [dbo].[map_counterparty_backup] (
    [ID]               INT           IDENTITY (1, 1) NOT NULL,
    [ExtBunit]         VARCHAR (50)  NOT NULL,
    [ExtLegalEntity]   VARCHAR (50)  NULL,
    [Partner]          VARCHAR (255) NULL,
    [Debitor]          VARCHAR (255) NULL,
    [Country]          VARCHAR (255) NULL,
    [ctpygroup]        VARCHAR (255) NULL,
    [AccrualOnDebitor] BIT           NOT NULL,
    [Exchange]         BIT           NOT NULL,
    [UStID]            VARCHAR (255) NULL,
    [CtpyID_Endur]     VARCHAR (10)  NULL,
    [TimeStamp]        DATETIME      CONSTRAINT [DF_map_counterparty_backup_TimeStamp] DEFAULT (getdate()) NULL,
    [User]             VARCHAR (50)  CONSTRAINT [DF_map_counterparty_backup_USER] DEFAULT (user_name()) NULL,
    CONSTRAINT [PK_map_counterparty_backup] PRIMARY KEY CLUSTERED ([ExtBunit] ASC)
);


GO

