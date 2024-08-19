CREATE TABLE [dbo].[Temp_dbo_getrunflag] (
    [ID]              INT            IDENTITY (1, 1) NOT NULL,
    [RunFlag_Job]     NVARCHAR (200) NULL,
    [RunFlag_Blocked] NVARCHAR (200) NULL,
    [RunFlag_User]    NVARCHAR (200) NULL,
    [RunFlag_Time]    DATETIME       NULL
);


GO

