CREATE TABLE [dbo].[table_Business_Unit_Hierarchy] (
    [BusinessLineName]  NVARCHAR (100) NULL,
    [BusinessLine_ID]   INT            NULL,
    [DeskName]          NVARCHAR (100) NULL,
    [Desk_ID]           INT            NULL,
    [Intermediate1Name] NVARCHAR (100) NULL,
    [Intermediate1_ID]  INT            NULL,
    [Intermediate2Name] NVARCHAR (100) NULL,
    [Intermediate2_ID]  INT            NULL,
    [Intermediate3Name] NVARCHAR (100) NULL,
    [Intermediate3_ID]  INT            NULL,
    [Intermediate4Name] NVARCHAR (100) NULL,
    [Intermediate4_ID]  INT            NULL,
    [Intermediate5Name] NVARCHAR (100) NULL,
    [Intermediate5_ID]  INT            NULL,
    [Intermediate6Name] NVARCHAR (100) NULL,
    [Intermediate6_ID]  INT            NULL,
    [BookName]          NVARCHAR (100) NULL,
    [Book_ID]           INT            NULL,
    [PortfolioName]     NVARCHAR (100) NULL,
    [Portfolio_Id]      INT            NOT NULL,
    [Internal_Order_ID] NVARCHAR (100) NULL,
    [LastImport]        DATETIME       CONSTRAINT [DF_table_business_unit_hierarchy_LastImport] DEFAULT (getdate()) NOT NULL,
    CONSTRAINT [PK_table_business_unit_hierarchy] PRIMARY KEY CLUSTERED ([Portfolio_Id] ASC)
);


GO

