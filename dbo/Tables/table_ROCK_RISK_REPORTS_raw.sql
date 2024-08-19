CREATE TABLE [dbo].[table_ROCK_RISK_REPORTS_raw] (
    [CoB]                           NVARCHAR (150) NULL,
    [Deal_Number]                   NVARCHAR (150) NULL,
    [Desk_Name]                     NVARCHAR (150) NULL,
    [Intermediate1_Name]            NVARCHAR (150) NULL,
    [Book_Name]                     NVARCHAR (150) NULL,
    [Portfolio_Name]                NVARCHAR (150) NULL,
    [Instrument_Type_Name]          NVARCHAR (150) NOT NULL,
    [Ext_Business_Unit_Name]        NVARCHAR (150) NOT NULL,
    [Cashflow_Settlement_Type_Name] NVARCHAR (150) NULL,
    [Cashflow_Type_Name]            NVARCHAR (150) NULL,
    [Int_Legal_Entity_Name]         NVARCHAR (150) NULL,
    [Business_Line_Currency]        NVARCHAR (150) NULL,
    [Intermediate1_Currency]        NVARCHAR (150) NULL,
    [Base_Currency]                 NVARCHAR (150) NULL,
    [Cashflow_Currency]             NVARCHAR (150) NULL,
    [Projection_Index_Name]         NVARCHAR (150) NULL,
    [Trade_End_Date]                NVARCHAR (150) NULL,
    [Deal_Pdc_End_Date]             NVARCHAR (150) NULL,
    [Ext_Legal_Entity_Name]         NVARCHAR (150) NULL,
    [External_Portfolio_Name]       NVARCHAR (150) NULL,
    [PnL_Disc_Total_YtD_PH_BU_CCY]  FLOAT (53)     NULL,
    [PnL_Disc_Real_YtD_PH_BU_CCY]   FLOAT (53)     NULL,
    [PnL_Disc_Unreal_YtD_PH_BU_CCY] FLOAT (53)     NULL,
    [PnL_Disc_Total_LtD_PH_BU_CCY]  FLOAT (53)     NULL,
    [PnL_Disc_Real_LtD_PH_BU_CCY]   FLOAT (53)     NULL,
    [PnL_Disc_Unreal_LtD_PH_BU_CCY] FLOAT (53)     NULL,
    [PnL_Disc_Real_BU_CCY]          FLOAT (53)     NULL,
    [PnL_Disc_Unreal_BU_CCY]        FLOAT (53)     NULL,
    [PnL_Disc_Total_YtD_BU_CCY]     FLOAT (53)     NULL
);


GO

