CREATE TABLE [SAP_Prod].[TestTabelle] (
    [ID]         INT           IDENTITY (1, 1) NOT NULL,
    [country]    VARCHAR (255) NULL,
    [ISO-2]      VARCHAR (255) NOT NULL,
    [ISO-3]      VARCHAR (255) NULL,
    [numeric]    FLOAT (53)    NULL,
    [Assignment] VARCHAR (255) NULL,
    [TimeStamp]  DATETIME      NULL,
    [USER]       VARCHAR (50)  NULL
);


GO

