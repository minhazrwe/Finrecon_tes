CREATE TABLE [dbo].[Adjustments_AutoBackup] (
    [ReconGroup]            VARCHAR (40)  NOT NULL,
    [OrderNo]               VARCHAR (255) NOT NULL,
    [DeliveryMonth]         VARCHAR (255) NULL,
    [DealID]                VARCHAR (255) NULL,
    [Account]               VARCHAR (255) NULL,
    [Currency]              VARCHAR (255) NULL,
    [Quantity]              FLOAT (53)    NULL,
    [Realised_CCY]          FLOAT (53)    NULL,
    [Category]              VARCHAR (255) NULL,
    [Comment]               VARCHAR (255) NULL,
    [Valid_From]            DATETIME      NULL,
    [Valid_To]              DATETIME      NULL,
    [ExternalBusinessUnit]  VARCHAR (100) NULL,
    [Partner]               VARCHAR (20)  NULL,
    [VAT]                   VARCHAR (20)  NULL,
    [Internal_Portfolio_ID] VARCHAR (100) NULL,
    [External_Portfolio]    VARCHAR (100) NULL,
    [user]                  VARCHAR (255) NOT NULL,
    [timestamp]             DATETIME      NOT NULL,
    [CompanyCode]           VARCHAR (4)   NULL,
    [backup_id]             BIGINT        NULL,
    [backup_timestamp]      DATETIME      NULL,
    [backup_user]           VARCHAR (100) NULL
);


GO

