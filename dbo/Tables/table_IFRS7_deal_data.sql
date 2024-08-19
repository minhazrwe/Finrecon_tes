CREATE TABLE [dbo].[table_IFRS7_deal_data] (
    [deal_num]       INT        NOT NULL,
    [Brady_ID]       INT        NULL,
    [OLF_ID]         INT        NULL,
    [CSA_FLAG]       TINYINT    NULL,
    [SE]             FLOAT (53) NULL,
    [MTM]            FLOAT (53) NULL,
    [total_exposure] FLOAT (53) NULL,
    [is_unique]      TINYINT    NULL,
    CONSTRAINT [PK_table_IFRS7_deal_data] PRIMARY KEY CLUSTERED ([deal_num] ASC)
);


GO

