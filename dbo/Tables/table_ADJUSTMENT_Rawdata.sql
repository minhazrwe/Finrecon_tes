CREATE TABLE [dbo].[table_ADJUSTMENT_Rawdata] (
    [COB]                          NVARCHAR (200)  NULL,
    [BUSINESS_LINE_NAME]           NVARCHAR (200)  NULL,
    [DESK_NAME]                    NVARCHAR (200)  NULL,
    [INTERMEDIATE1_NAME]           NVARCHAR (200)  NULL,
    [INTERMEDIATE2_NAME]           NVARCHAR (200)  NULL,
    [INTERMEDIATE3_NAME]           NVARCHAR (200)  NULL,
    [INTERMEDIATE4_NAME]           NVARCHAR (200)  NULL,
    [BOOK_NAME]                    NVARCHAR (200)  NULL,
    [PORTFOLIO_NAME]               NVARCHAR (200)  NULL,
    [ADJUSTMENT_ID]                NVARCHAR (200)  NULL,
    [ADJUSTMENT_CATEGORY]          NVARCHAR (200)  NULL,
    [ADJUSTMENT_SUBCATEGORY]       NVARCHAR (200)  NULL,
    [USER_COMMENT]                 NVARCHAR (2000) NULL,
    [ROCK_USER_ID]                 NVARCHAR (200)  NULL,
    [BUSINESS_LINE_CURRENCY]       NVARCHAR (200)  NULL,
    [INTERMEDIATE1_CURRENCY]       NVARCHAR (200)  NULL,
    [CASHFLOW_CURRENCY]            NVARCHAR (200)  NULL,
    [VALID_FROM]                   NVARCHAR (200)  NULL,
    [VALID_TO]                     NVARCHAR (200)  NULL,
    [PAYMENT_DATE]                 NVARCHAR (200)  NULL,
    [REAL_DISC_PH_BL_CCY_YTD]      FLOAT (53)      DEFAULT ((0)) NULL,
    [REAL_DISC_PH_BL_CCY]          NVARCHAR (200)  DEFAULT ((0)) NULL,
    [REAL_DISC_PH_BL_CCY_LGBY]     FLOAT (53)      DEFAULT ((0)) NULL,
    [UNREAL_DISC_PH_BL_CCY]        FLOAT (53)      DEFAULT ((0)) NULL,
    [UNREAL_DISC_PH_BL_CCY_LGBY]   FLOAT (53)      DEFAULT ((0)) NULL,
    [REAL_UNDISC_PH_BL_CCY_YTD]    FLOAT (53)      DEFAULT ((0)) NULL,
    [UNREAL_UNDISC_PH_BL_CCY]      FLOAT (53)      DEFAULT ((0)) NULL,
    [REAL_DISC_PH_IM1_CCY_YTD]     FLOAT (53)      DEFAULT ((0)) NULL,
    [REAL_DISC_PH_IM1_CCY]         NVARCHAR (200)  DEFAULT ((0)) NULL,
    [REAL_DISC_PH_IM1_CCY_LGBY]    FLOAT (53)      DEFAULT ((0)) NULL,
    [UNREAL_DISC_PH_IM1_CCY]       FLOAT (53)      DEFAULT ((0)) NULL,
    [UNREAL_DISC_PH_IM1_CCY_LGBY]  FLOAT (53)      DEFAULT ((0)) NULL,
    [REAL_UNDISC_PH_IM1_CCY_YTD]   FLOAT (53)      DEFAULT ((0)) NULL,
    [UNREAL_UNDISC_PH_IM1_CCY]     FLOAT (53)      DEFAULT ((0)) NULL,
    [REAL_DISC_BL_CCY_YTD]         FLOAT (53)      DEFAULT ((0)) NULL,
    [REAL_DISC_BL_CCY]             FLOAT (53)      DEFAULT ((0)) NULL,
    [REAL_DISC_BL_CCY_LGBY]        FLOAT (53)      DEFAULT ((0)) NULL,
    [UNREAL_DISC_BL_CCY]           FLOAT (53)      DEFAULT ((0)) NULL,
    [UNREAL_DISC_BL_CCY_LGBY]      FLOAT (53)      DEFAULT ((0)) NULL,
    [REAL_UNDISC_BL_CCY_YTD]       FLOAT (53)      DEFAULT ((0)) NULL,
    [REAL_UNDISC_BL_CCY]           FLOAT (53)      DEFAULT ((0)) NULL,
    [UNREAL_UNDISC_BL_CCY]         FLOAT (53)      DEFAULT ((0)) NULL,
    [REAL_DISC_IM1_CCY_YTD]        FLOAT (53)      DEFAULT ((0)) NULL,
    [REAL_DISC_IM1_CCY]            FLOAT (53)      DEFAULT ((0)) NULL,
    [REAL_DISC_IM1_CCY_LGBY]       FLOAT (53)      DEFAULT ((0)) NULL,
    [UNREAL_DISC_IM1_CCY]          FLOAT (53)      DEFAULT ((0)) NULL,
    [UNREAL_DISC_IM1_CCY_LGBY]     FLOAT (53)      DEFAULT ((0)) NULL,
    [REAL_UNDISC_IM1_CCY_YTD]      FLOAT (53)      DEFAULT ((0)) NULL,
    [REAL_UNDISC_IM1_CCY]          FLOAT (53)      DEFAULT ((0)) NULL,
    [UNREAL_UNDISC_IM1_CCY]        FLOAT (53)      DEFAULT ((0)) NULL,
    [TOTAL_VALUE_PH_IM1_CCY_YTD]   FLOAT (53)      DEFAULT ((0)) NULL,
    [TOTAL_VALUE_PH_BL_CCY_YTD]    FLOAT (53)      DEFAULT ((0)) NULL,
    [REAL_UNDISC_CASHFLOW_CCY_YTD] FLOAT (53)      NULL,
    [REAL_UNDISC_CASHFLOW_CCY]     FLOAT (53)      DEFAULT ((0)) NULL,
    [UNREAL_DISC_CASHFLOW_CCY]     FLOAT (53)      DEFAULT ((0)) NULL,
    [UNREAL_DISC_CASHFLOW_CCY_YTD] FLOAT (53)      DEFAULT ((0)) NULL,
    [REAL_DISC_PH_BL_CCY_MTD]      FLOAT (53)      DEFAULT ((0)) NULL,
    [UNREAL_DISC_PH_BL_CCY_MTD]    FLOAT (53)      DEFAULT ((0)) NULL
);


GO

