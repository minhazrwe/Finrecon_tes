CREATE TABLE [dbo].[Queries_Backup_20230808] (
    [ID]         INT            IDENTITY (1, 1) NOT NULL,
    [Name]       VARCHAR (100)  NOT NULL,
    [Statement]  VARCHAR (MAX)  NOT NULL,
    [ExportPath] INT            NULL,
    [Purpose]    VARCHAR (100)  NULL,
    [Comment]    VARCHAR (2000) NULL,
    [Temp_Table] INT            NULL,
    [TimeStamp]  DATETIME       CONSTRAINT [DF_Queries_New_TimeStamp] DEFAULT (getdate()) NOT NULL,
    [User]       VARCHAR (50)   CONSTRAINT [DF_Queries_New_user_] DEFAULT (user_name()) NOT NULL,
    CONSTRAINT [PK_Queries_New] PRIMARY KEY CLUSTERED ([ID] ASC, [Name] ASC)
);


GO

