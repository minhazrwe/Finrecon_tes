CREATE TABLE [dbo].[table_IFRS7_deal_data_import] (
    [deal_num]       INT        NOT NULL,
    [BradyId]        INT        NULL,
    [OLF_ID]         INT        NULL,
    [CSA_FLAG]       BIT        NULL,
    [mtm]            FLOAT (53) NULL,
    [se]             FLOAT (53) NULL,
    [total_exposure] FLOAT (53) NULL,
    CONSTRAINT [PK_table_IFRS7_deal_data_import] PRIMARY KEY CLUSTERED ([deal_num] ASC)
);


GO

