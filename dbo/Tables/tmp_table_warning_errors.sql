CREATE TABLE [dbo].[tmp_table_warning_errors] (
    [ID]                  INT            IDENTITY (1, 1) NOT NULL,
    [Time_Stamp_CET]      DATETIME       NULL,
    [Log_Level]           VARCHAR (20)   NULL,
    [Current_Procedure]   VARCHAR (100)  NULL,
    [Description]         VARCHAR (2000) NULL,
    [Step]                VARCHAR (100)  NULL,
    [Main_Process]        VARCHAR (100)  NULL,
    [Calling_Application] VARCHAR (100)  NULL,
    [User]                VARCHAR (100)  NULL,
    [Time_Stamp]          DATETIME       NULL,
    [Session_Key]         VARCHAR (100)  NULL
);


GO

