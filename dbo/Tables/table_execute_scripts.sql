CREATE TABLE [dbo].[table_execute_scripts] (
    [ID]                  INT            IDENTITY (1, 1) NOT NULL,
    [Procedure_Name]      NVARCHAR (500) NULL,
    [Procedure_Step]      INT            NULL,
    [Procedure_Statement] NVARCHAR (MAX) NULL,
    [Procedure_Order]     INT            NULL,
    [TimeStamp]           DATETIME       CONSTRAINT [DF_table_execute_scripts_TimeStamp] DEFAULT (getdate()) NULL,
    [User]                NVARCHAR (500) CONSTRAINT [DF_table_execute_scripts_USER] DEFAULT (user_name()) NULL,
    CONSTRAINT [PK_table_execute_scripts] PRIMARY KEY CLUSTERED ([ID] DESC)
);


GO

