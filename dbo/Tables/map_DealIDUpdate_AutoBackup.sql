CREATE TABLE [dbo].[map_DealIDUpdate_AutoBackup] (
    [DealID_Old]       VARCHAR (255) NOT NULL,
    [DealID_New]       VARCHAR (255) NOT NULL,
    [comment]          VARCHAR (255) NOT NULL,
    [TimeStamp]        DATETIME      NULL,
    [USER]             VARCHAR (50)  NULL,
    [backup_id]        BIGINT        NULL,
    [backup_timestamp] DATETIME      NULL,
    [backup_user]      VARCHAR (100) NULL
);


GO

