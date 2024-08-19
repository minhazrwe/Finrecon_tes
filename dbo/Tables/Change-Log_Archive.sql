CREATE TABLE [dbo].[Change-Log_Archive] (
    [TimeOfArchiving] DATETIME       NOT NULL,
    [AsOfDate]        DATE           NOT NULL,
    [ID]              NVARCHAR (200) NOT NULL,
    [Change-Table]    NVARCHAR (150) NULL,
    [Change-Entry]    NVARCHAR (MAX) NULL,
    [Change-Type]     NVARCHAR (20)  NULL,
    [Change-User]     NVARCHAR (200) NULL,
    [Change-Datetime] DATETIME       NULL
);


GO

