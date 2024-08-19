CREATE TABLE [dbo].[table_unrealised_hedging_relations_rawde] (
    [Subsidiary]             NVARCHAR (50) NOT NULL,
    [Strategy]               NVARCHAR (50) NOT NULL,
    [Book]                   NVARCHAR (50) NOT NULL,
    [Hedge_Rel_Type_ID]      TINYINT       NOT NULL,
    [Hedge_Rel_Type_Name]    NVARCHAR (50) NOT NULL,
    [Relation_ID]            INT           NOT NULL,
    [Rel_ID]                 INT           NOT NULL,
    [Dedesig_Rel_ID]         TINYINT       NOT NULL,
    [Rel_Type]               NVARCHAR (50) NOT NULL,
    [Effective_Date]         DATE          NOT NULL,
    [Perfect_Hedge]          NVARCHAR (50) NOT NULL,
    [Type]                   NVARCHAR (50) NOT NULL,
    [Ref_Deal_ID]            INT           NOT NULL,
    [Deal_ID]                INT           NOT NULL,
    [Perc_Included]          FLOAT (53)    NOT NULL,
    [Deal_Date]              DATE          NOT NULL,
    [Leg]                    TINYINT       NOT NULL,
    [Index]                  NVARCHAR (50) NOT NULL,
    [Term_Start]             DATE          NOT NULL,
    [Term_End]               DATE          NOT NULL,
    [Buy_Sell]               NVARCHAR (50) NOT NULL,
    [Volume]                 INT           NULL,
    [Allocated_Volume]       INT           NULL,
    [UOM]                    NVARCHAR (50) NOT NULL,
    [Frequency]              NVARCHAR (50) NOT NULL,
    [Price]                  FLOAT (53)    NOT NULL,
    [Internal_Portfolio]     NVARCHAR (50) NOT NULL,
    [Counterparty_Group]     NVARCHAR (50) NOT NULL,
    [Instrument_Type]        NVARCHAR (50) NOT NULL,
    [Projection_Index_Group] NVARCHAR (50) NOT NULL,
    [Created_On]             DATE          NOT NULL,
    [Created_By]             NVARCHAR (50) NOT NULL
);


GO

