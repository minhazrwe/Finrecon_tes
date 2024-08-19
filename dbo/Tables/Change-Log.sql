CREATE TABLE [dbo].[Change-Log] (
    [ID]              INT            IDENTITY (1, 1) NOT NULL,
    [Change-Table]    NVARCHAR (150) NULL,
    [Change-Entry]    NVARCHAR (MAX) NULL,
    [Change-Type]     NVARCHAR (20)  NULL,
    [Change-User]     NVARCHAR (200) NULL,
    [Change-Datetime] DATETIME       NULL,
    CONSTRAINT [PK_Chgange-Log] PRIMARY KEY CLUSTERED ([ID] DESC)
);


GO

