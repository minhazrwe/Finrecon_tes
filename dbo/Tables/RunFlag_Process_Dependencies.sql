CREATE TABLE [dbo].[RunFlag_Process_Dependencies] (
    [ID]                    INT            IDENTITY (1, 1) NOT NULL,
    [Process_Running]       NVARCHAR (200) NULL,
    [Process_to_be_blocked] VARCHAR (200)  NULL,
    CONSTRAINT [PK_RunFlag_Process_Dependencies] PRIMARY KEY CLUSTERED ([ID] ASC)
);


GO

