CREATE TABLE [dbo].[GloriRisk] (
    [COB]                                              DATETIME      NULL,
    [Desk_Name]                                        VARCHAR (100) NULL,
    [L05 - Intermediate2 (Current Name)]               VARCHAR (50)  NULL,
    [L06 - Intermediate3 (Current Name)]               VARCHAR (50)  NULL,
    [L10 - Book (Current Name)]                        VARCHAR (50)  NULL,
    [Internal Portfolio Name]                          VARCHAR (60)  NULL,
    [Instrument Type Name]                             VARCHAR (50)  NULL,
    [Ext Business Unit Name]                           VARCHAR (100) NULL,
    [Trade Deal Number]                                VARCHAR (80)  NULL,
    [Cashflow Settlement Type]                         VARCHAR (50)  NULL,
    [Trade Instrument Reference Text]                  VARCHAR (50)  NULL,
    [Trade Currency]                                   VARCHAR (5)   NULL,
    [INTERNAL_LEGAL_ENTITY_PARTY_NAME]                 VARCHAR (50)  NULL,
    [DEAL_PDC_END_DATE]                                DATE          NULL,
    [CASHFLOW_PAYMENT_DATE]                            DATE          NULL,
    [Realised Undiscounted Original Currency]          FLOAT (53)    NULL,
    [Realised Undiscounted Original Currency GPG EOLY] FLOAT (53)    NULL,
    [Unrealised Discounted (EUR)]                      FLOAT (53)    NULL,
    [Unrealised Discounted EUR GPG EOLY]               FLOAT (53)    NULL,
    [Realised Discounted (EUR)]                        FLOAT (53)    NULL,
    [Realised Undiscounted (EUR)]                      FLOAT (53)    NULL,
    [Realised Discounted EUR GPG EOLY]                 FLOAT (53)    NULL,
    [Unrealised Discounted (USD)]                      FLOAT (53)    NULL,
    [Unrealised Discounted USD GPG EOLY]               FLOAT (53)    NULL,
    [Realised Discounted (USD)]                        FLOAT (53)    NULL,
    [Realised Undiscounted USD]                        FLOAT (53)    NULL,
    [Realised Discounted USD GPG EOLY]                 FLOAT (53)    NULL,
    [Unrealised Discounted (AUD)]                      FLOAT (53)    NULL,
    [Unrealised Discounted Original Currency GPG EOLY] FLOAT (53)    NULL,
    [Realised Discounted (AUD)]                        FLOAT (53)    NULL,
    [Realised Undiscounted (AUD)]                      FLOAT (53)    NULL,
    [Realised Discounted Original Currency GPG EOLY]   FLOAT (53)    NULL,
    [Unrealised Discounted (GBP)]                      FLOAT (53)    NULL,
    [Unrealised Discounted GBP GPG EOLY]               FLOAT (53)    NULL,
    [Realised Discounted (GBP)]                        FLOAT (53)    NULL,
    [Realised Undiscounted (GBP)]                      FLOAT (53)    NULL,
    [Realised Discounted GBP GPG EOLY]                 FLOAT (53)    NULL,
    [TOTAL_VALUE_PH_IM1_CCY_YTD]                       FLOAT (53)    NULL,
    [REAL_DISC_PH_IM1_CCY_YTD]                         FLOAT (53)    NULL,
    [UNREAL_DISC_PH_IM1_CCY]                           FLOAT (53)    NULL,
    [UNREAL_DISC_PH_IM1_CCY_LGBY]                      FLOAT (53)    NULL,
    [TOTAL_VALUE_PH_BL_CCY_YTD]                        FLOAT (53)    NULL,
    [REAL_DISC_PH_BL_CCY_YTD]                          FLOAT (53)    NULL,
    [UNREAL_DISC_PH_BL_CCY]                            FLOAT (53)    NULL,
    [UNREAL_DISC_PH_BL_CCY_LGBY]                       FLOAT (53)    NULL,
    [UNREAL_DISC_BL_CCY]                               FLOAT (53)    NULL,
    [UNREAL_DISC_BL_CCY_LGBY]                          FLOAT (53)    NULL,
    [REAL_UNDISC_CASHFLOW_CCY_YTD]                     FLOAT (53)    NULL,
    [FileId]                                           INT           NULL,
    [LastUpdate]                                       DATETIME      CONSTRAINT [DF_GloriRisk_ROCK_LastUpdate] DEFAULT (getdate()) NULL
);


GO

