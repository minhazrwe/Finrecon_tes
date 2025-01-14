CREATE TABLE [dbo].[table_VM_NETTING_4_Analysis_incl_FT_TEST] (
    [BODealNumber]                             VARCHAR (50)    NULL,
    [BOsource]                                 VARCHAR (50)    NULL,
    [BODealtype]                               VARCHAR (50)    NULL,
    [BODataType]                               VARCHAR (50)    NULL,
    [FTSubsidiary]                             VARCHAR (255)   NULL,
    [FTStrategy]                               VARCHAR (255)   NULL,
    [FTBook]                                   VARCHAR (255)   NULL,
    [FTReferenceID]                            VARCHAR (50)    NULL,
    [FTInternalPortfolio]                      VARCHAR (50)    NULL,
    [FTExtBusinessUnit]                        VARCHAR (50)    NULL,
    [FTExtLegalEntity]                         VARCHAR (50)    NULL,
    [FTCounterpartyGroup]                      VARCHAR (50)    NULL,
    [FTCurvename]                              VARCHAR (50)    NULL,
    [FTProjIndexGroup]                         VARCHAR (50)    NULL,
    [FTInstrumentType]                         VARCHAR (50)    NULL,
    [FTAccountingTreatment]                    VARCHAR (255)   NULL,
    [BOProduct]                                VARCHAR (50)    NULL,
    [BOExchangeCode]                           VARCHAR (50)    NULL,
    [BOCurrency]                               VARCHAR (50)    NULL,
    [BOPortfolio]                              VARCHAR (50)    NULL,
    [BOExternalBU]                             VARCHAR (50)    NULL,
    [BOContractDate]                           DATETIME        NULL,
    [BONettingType]                            NVARCHAR (255)  NULL,
    [FTProductYearTermEnd]                     NVARCHAR (4000) NULL,
    [BORate]                                   FLOAT (53)      NULL,
    [BORateRisk]                               FLOAT (53)      NULL,
    [BOolfpnl]                                 FLOAT (53)      NULL,
    [BOolfpnlCalcinEURRate]                    FLOAT (53)      NULL,
    [BOolfpnlCalcinEURRateRisk]                FLOAT (53)      NULL,
    [FTSummeVolume]                            FLOAT (53)      NULL,
    [FTSummeVolumefinal]                       FLOAT (53)      NULL,
    [FTPNL]                                    FLOAT (53)      NULL,
    [FTOCI]                                    FLOAT (53)      NULL,
    [FTTotal_MtM]                              FLOAT (53)      NULL,
    [FTTotal_MtMCalcinFXCCYRateRisk]           FLOAT (53)      NULL,
    [DiffBOolfpnlCalcinEURRateRiskFTTotal_MtM] FLOAT (53)      NULL,
    [FinMtMtoNet]                              FLOAT (53)      NULL,
    [posnegVM]                                 VARCHAR (50)    NULL,
    [CheckVZ]                                  VARCHAR (50)    NULL,
    [HedgeExtern]                              VARCHAR (50)    NULL,
    [Desk]                                     VARCHAR (100)   NULL,
    [OrderNumber]                              VARCHAR (50)    NULL
);


GO

