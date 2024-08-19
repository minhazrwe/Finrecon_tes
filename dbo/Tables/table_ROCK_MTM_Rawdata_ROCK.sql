CREATE TABLE [dbo].[table_ROCK_MTM_Rawdata_ROCK] (
    [COB]                              DATE           NULL,
    [DESK_NAME]                        NVARCHAR (100) NULL,
    [DEAL_NUMBER]                      NVARCHAR (100) NULL,
    [PORTFOLIO_NAME]                   NVARCHAR (100) NULL,
    [INSTRUMENT_TYPE_NAME]             NVARCHAR (100) NULL,
    [CASHFLOW_MONTH]                   DATE           NULL,
    [PDC_END_DATE]                     DATE           NULL,
    [EXTERNAL_LEGAL_ENTITY_PARTY_NAME] NVARCHAR (100) NULL,
    [EXT_BUSINESS_UNIT_NAME]           NVARCHAR (100) NULL,
    [EXTERNAL_PORTFOLIO_NAME]          NVARCHAR (100) NULL,
    [TRANSACTION_STATUS_NAME]          NVARCHAR (100) NULL,
    [SOURCE_OF_ROW]                    NVARCHAR (100) NULL,
    [BUSINESS_LINE_CURRENCY]           NVARCHAR (100) NULL,
    [UNREAL_DISC_PH_BUH_CCY]           FLOAT (53)     NULL,
    [REAL_DISC_PH_BUH_CCY]             FLOAT (53)     NULL,
    [UNREAL_DISC_BUH_CCY]              FLOAT (53)     NULL,
    [REAL_DISC_BUH_CCY]                FLOAT (53)     NULL,
    [FIleID]                           INT            NULL,
    [LastImport]                       DATETIME       CONSTRAINT [DF_table_ROCK_MTM_Rawdata_ROCK_LastImport] DEFAULT (getdate()) NULL
);


GO

