CREATE TABLE [dbo].[table_Exceptional_User] (
    [UserID]       VARCHAR (30) NOT NULL,
    [run_flag]     INT          DEFAULT ((0)) NULL,
    [execute_flag] INT          DEFAULT ((0)) NULL,
    [delete_flag]  INT          DEFAULT ((0)) NULL,
    PRIMARY KEY CLUSTERED ([UserID] ASC)
);


GO

