CREATE TABLE [dbo].[table_GPM_RECON_RISK_REPORT] (
    [CoB]                           DATE           NULL,
    [Intermediate_1_Name]           NVARCHAR (100) NULL,
    [Intermediate1_Currency]        NVARCHAR (100) NULL,
    [Intermediate_2_Name]           NVARCHAR (100) NULL,
    [Deal_Number]                   NVARCHAR (100) NULL,
    [Delivery_Month]                DATE           NULL,
    [Portfolio_Name]                NVARCHAR (100) NULL,
    [Instrument_Type_Name]          NVARCHAR (100) NULL,
    [Ext_Business_Unit_Name]        NVARCHAR (100) NULL,
    [Cashflow_Type_Name]            NVARCHAR (100) NULL,
    [Adjustment_Comment]            NVARCHAR (500) NULL,
    [PnL_Disc_Total_YtD_PH_BU_CCY]  FLOAT (53)     NULL,
    [PnL_Disc_Real_YtD_PH_BU_CCY]   FLOAT (53)     NULL,
    [PnL_Disc_Unreal_YtD_PH_BU_CCY] FLOAT (53)     NULL,
    [PnL_Disc_Unreal_LtD_PH_BU_CCY] FLOAT (53)     NULL,
    [LastUpdate]                    DATETIME       CONSTRAINT [DF_table_GPM_RECON_RISK_REPORT_LastUpdate] DEFAULT (getdate()) NULL
);


GO

