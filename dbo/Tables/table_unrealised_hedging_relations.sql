CREATE TABLE [dbo].[table_unrealised_hedging_relations] (
    [ID]                       INT           IDENTITY (1, 1) NOT NULL,
    [Internal_Legal_Entity]    VARCHAR (100) NULL,
    [Desk_Name]                VARCHAR (100) NULL,
    [Hedge_Derivate_Flag]      VARCHAR (50)  NULL,
    [Hedge_Relation_Type_Name] VARCHAR (100) NULL,
    [Hedge_ID]                 INT           NULL,
    [Relation_Type]            VARCHAR (30)  NULL,
    [Effective_Date]           DATE          NULL,
    [Hedge_Item_Flag]          VARCHAR (100) NULL,
    [Deal_Number]              VARCHAR (20)  NULL,
    [Percent_Included]         FLOAT (53)    NULL,
    [Trade_Date]               DATE          NULL,
    [Index_Name]               VARCHAR (100) NULL,
    [Term_Start]               DATE          NULL,
    [Term_End]                 DATE          NULL,
    [Buy_Sell_Flag]            VARCHAR (10)  NULL,
    [Volume]                   INT           NULL,
    [Allocated_Volume]         INT           NULL,
    [Available_Volume]         INT           NULL,
    [Unit_Of_Measure]          VARCHAR (10)  NULL,
    [Frequency]                VARCHAR (100) NULL,
    [Price]                    FLOAT (53)    NULL,
    [Internal_Portfolio]       VARCHAR (50)  NULL,
    [Counterparty_Group]       VARCHAR (30)  NULL,
    [Instrument_Type]          VARCHAR (100) NULL,
    [Projection_Index_Group]   VARCHAR (30)  NULL,
    [Creation_Date]            DATE          NULL,
    [Created_By]               VARCHAR (50)  NULL,
    [Data_Origin]              VARCHAR (50)  NULL,
    CONSTRAINT [PK_table_unrealised_hedging_relations_id] PRIMARY KEY CLUSTERED ([ID] ASC),
    CONSTRAINT [UK_table_unrealised_hedging_relations1] UNIQUE NONCLUSTERED ([Deal_Number] ASC, [Hedge_ID] ASC, [Term_End] ASC)
);


GO

