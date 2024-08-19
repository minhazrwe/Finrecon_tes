CREATE TABLE [dbo].[table_Clearer_Manual_Adjustments] (
    [ID]                 INT           IDENTITY (1, 1) NOT NULL,
    [Trade_Date]         DATE          NOT NULL,
    [Adjustment_Value]   FLOAT (53)    NULL,
    [Adjustment_Type]    VARCHAR (30)  NULL,
    [Account_Name]       VARCHAR (30)  NULL,
    [Adjustment_Comment] VARCHAR (500) NULL,
    [Product_Name]       VARCHAR (30)  NULL,
    [Commodity]          VARCHAR (30)  NULL,
    [Clearer_id]         INT           NOT NULL,
    [LastImport]         DATETIME      CONSTRAINT [DF_table_Clearer_Manual_Adjustments_LastImport] DEFAULT (getdate()) NOT NULL,
    CONSTRAINT [PK_table_Clearer_Manual_Adjustments] PRIMARY KEY CLUSTERED ([ID] ASC)
);


GO

