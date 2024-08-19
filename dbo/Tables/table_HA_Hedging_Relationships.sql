CREATE TABLE [dbo].[table_HA_Hedging_Relationships] (
    [COB]                    DATE           NULL,
    [Subsidiary]             NVARCHAR (100) NULL,
    [Strategy]               NVARCHAR (100) NULL,
    [Book]                   NVARCHAR (100) NULL,
    [Hedge_Rel_Type_ID]      INT            NULL,
    [Hedge_Rel_Type_Name]    NVARCHAR (100) NULL,
    [Relation_ID]            INT            NULL,
    [Dedesig_Rel_ID]         INT            NULL,
    [Rel_Type]               NVARCHAR (100) NULL,
    [Effective_Date]         DATE           NULL,
    [Perfect_Hedge]          NVARCHAR (10)  NULL,
    [Hedge_Type]             NVARCHAR (10)  NULL,
    [Ref_Deal_ID]            INT            NULL,
    [Deal_ID]                INT            NULL,
    [Perc_Included]          FLOAT (53)     NULL,
    [Deal_Date]              DATE           NULL,
    [Leg]                    INT            NULL,
    [Index_Name]             NVARCHAR (100) NULL,
    [Term_Start]             DATE           NULL,
    [Term_End]               DATE           NULL,
    [Buy_Sell]               NVARCHAR (100) NULL,
    [Volume]                 FLOAT (53)     NULL,
    [Allocated_Volume]       FLOAT (53)     NULL,
    [UOM]                    NVARCHAR (100) NULL,
    [Frequency]              NVARCHAR (100) NULL,
    [Price]                  FLOAT (53)     NULL,
    [Internal_Portfolio]     NVARCHAR (100) NULL,
    [Counterparty_Group]     NVARCHAR (100) NULL,
    [Instrument_Type]        NVARCHAR (100) NULL,
    [Projection_Index_Group] NVARCHAR (100) NULL,
    [created_on]             DATE           NULL,
    [FileID]                 INT            NULL,
    [LastUpdate]             DATETIME       CONSTRAINT [DF_table_Hedging_Relationships_LastUpdate] DEFAULT (getdate()) NULL
);


GO

