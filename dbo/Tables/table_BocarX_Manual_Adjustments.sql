CREATE TABLE [dbo].[table_BocarX_Manual_Adjustments] (
    [ID]                 INT          IDENTITY (1, 1) NOT NULL,
    [Report_Date]        DATE         NULL,
    [Trade_Date]         DATE         NULL,
    [Adjustment_Value]   FLOAT (53)   NULL,
    [Adjustment_Type]    VARCHAR (30) NULL,
    [Account_Name]       VARCHAR (30) NULL,
    [Adjustment_Comment] VARCHAR (30) NULL,
    [CCY]                VARCHAR (30) NULL,
    [Report_Name]        VARCHAR (30) NULL,
    [Clearer_ID]         INT          NOT NULL,
    [Last_Import]        DATETIME     CONSTRAINT [DF_table_BocarX_Manual_Adjustments_Last_Import] DEFAULT (getdate()) NOT NULL,
    CONSTRAINT [PK_table_BocarX_Manual_Adjustments] PRIMARY KEY CLUSTERED ([ID] ASC)
);


GO

