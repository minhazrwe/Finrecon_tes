CREATE TABLE [dbo].[table_FixedPrice_AutoBackup] (
    [Strategy]         NVARCHAR (100) NULL,
    [ReferenceID]      NVARCHAR (100) NULL,
    [TermEnd]          DATE           NULL,
    [FixedPrice]       FLOAT (53)     NULL,
    [DealCurrency]     NVARCHAR (50)  NULL,
    [FixedFloat]       NVARCHAR (100) NULL,
    [LastUpdate]       DATETIME       NULL,
    [backup_id]        BIGINT         NULL,
    [backup_timestamp] DATETIME       NULL,
    [backup_user]      VARCHAR (100)  NULL
);


GO

