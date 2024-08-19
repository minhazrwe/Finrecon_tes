CREATE TABLE [dbo].[table_IFRS7_deal_data_import_2022] (
    [deal_num]       INT           NOT NULL,
    [BradyId]        INT           NULL,
    [OLF_ID]         INT           NULL,
    [CSA_FLAG]       BIT           NULL,
    [TradingArea]    NVARCHAR (50) NULL,
    [LPARTYID]       INT           NULL,
    [SE]             FLOAT (53)    NULL,
    [MTM]            FLOAT (53)    NULL,
    [total_exposure] FLOAT (53)    NULL
);


GO

