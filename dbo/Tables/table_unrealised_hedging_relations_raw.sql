CREATE TABLE [dbo].[table_unrealised_hedging_relations_raw] (
    [Subsidiary]             NVARCHAR (100) NOT NULL,
    [Strategy]               NVARCHAR (100) NOT NULL,
    [Book]                   NVARCHAR (100) NOT NULL,
    [Hedge_Rel_Type_ID]      NVARCHAR (100) NOT NULL,
    [Hedge_Rel_Type_Name]    NVARCHAR (100) NOT NULL,
    [Relation_ID]            NVARCHAR (100) NOT NULL,
    [Rel_ID]                 NVARCHAR (100) NOT NULL,
    [Dedesig_Rel_ID]         NVARCHAR (100) NOT NULL,
    [Rel_Type]               NVARCHAR (100) NOT NULL,
    [Effective_Date]         NVARCHAR (100) NOT NULL,
    [Perfect_Hedge]          NVARCHAR (100) NOT NULL,
    [Type]                   NVARCHAR (100) NOT NULL,
    [Ref_Deal_ID]            NVARCHAR (100) NOT NULL,
    [Deal_ID]                NVARCHAR (100) NOT NULL,
    [Perc_Included]          NVARCHAR (100) NOT NULL,
    [Deal_Date]              NVARCHAR (100) NOT NULL,
    [Leg]                    NVARCHAR (100) NOT NULL,
    [Index]                  NVARCHAR (100) NOT NULL,
    [Term_Start]             NVARCHAR (100) NOT NULL,
    [Term_End]               NVARCHAR (100) NOT NULL,
    [Buy_Sell]               NVARCHAR (100) NOT NULL,
    [Volume]                 NVARCHAR (100) NOT NULL,
    [Allocated_Volume]       NVARCHAR (100) NOT NULL,
    [UOM]                    NVARCHAR (100) NOT NULL,
    [Frequency]              NVARCHAR (100) NOT NULL,
    [Price]                  NVARCHAR (100) NOT NULL,
    [Internal_Portfolio]     NVARCHAR (100) NOT NULL,
    [Counterparty_Group]     NVARCHAR (100) NOT NULL,
    [Instrument_Type]        NVARCHAR (100) NOT NULL,
    [Projection_Index_Group] NVARCHAR (100) NOT NULL,
    [Created_On]             NVARCHAR (100) NOT NULL,
    [Created_By]             NVARCHAR (100) NOT NULL
);


GO

