CREATE TABLE [dbo].[Recon-Deloitte-2024-06-PG] (
    [Identifier]             VARCHAR (255) NULL,
    [InternalLegalEntity]    VARCHAR (100) NULL,
    [ReconGroup]             VARCHAR (40)  NULL,
    [Desk]                   VARCHAR (50)  NULL,
    [SubDesk]                VARCHAR (255) NULL,
    [RevRecSubDesk]          VARCHAR (255) NULL,
    [OrderNo]                VARCHAR (50)  NULL,
    [DeliveryMonth]          VARCHAR (100) NULL,
    [DealID_Recon]           VARCHAR (100) NULL,
    [DealID]                 VARCHAR (100) NULL,
    [Portfolio]              VARCHAR (100) NULL,
    [CounterpartyGroup]      VARCHAR (100) NULL,
    [InstrumentType]         VARCHAR (100) NULL,
    [ProjIndexGroup]         VARCHAR (100) NULL,
    [CurveName]              VARCHAR (100) NULL,
    [ExternalLegal]          VARCHAR (100) NULL,
    [ExternalBusinessUnit]   VARCHAR (100) NULL,
    [ExternalPortfolio]      VARCHAR (100) NULL,
    [TradeDate]              DATE          NULL,
    [EventDate]              DATE          NULL,
    [SAP_DocumentNumber]     VARCHAR (20)  NULL,
    [Volume_Endur]           FLOAT (53)    NULL,
    [Volume_SAP]             FLOAT (53)    NULL,
    [Volume_Adj]             FLOAT (53)    NULL,
    [UOM_Endur]              VARCHAR (20)  NULL,
    [UOM_SAP]                VARCHAR (20)  NULL,
    [realised_ccy_Endur]     FLOAT (53)    NULL,
    [realised_ccy_SAP]       FLOAT (53)    NULL,
    [realised_ccy_adj]       FLOAT (53)    NULL,
    [ccy]                    VARCHAR (5)   NULL,
    [realised_Deskccy_Endur] FLOAT (53)    NULL,
    [realised_Deskccy_SAP]   FLOAT (53)    NULL,
    [realised_Deskccy_adj]   FLOAT (53)    NULL,
    [Deskccy]                VARCHAR (5)   NULL,
    [realised_EUR_Endur]     FLOAT (53)    NULL,
    [realised_EUR_SAP]       FLOAT (53)    NULL,
    [realised_EUR_SAP_conv]  FLOAT (53)    NULL,
    [realised_EUR_adj]       FLOAT (53)    NULL,
    [Account_Endur]          VARCHAR (20)  NULL,
    [Account_SAP]            VARCHAR (20)  NULL,
    [diff_Volume]            FLOAT (53)    NULL,
    [Diff_Realised_EUR]      FLOAT (53)    NULL,
    [Diff_Realised_DeskCCY]  FLOAT (53)    NULL,
    [Diff_Realised_CCY]      FLOAT (53)    NULL,
    [InternalBusinessUnit]   VARCHAR (100) NULL,
    [DocumentNumber]         VARCHAR (20)  NULL,
    [Reference]              VARCHAR (100) NULL,
    [TranStatus]             VARCHAR (100) NULL,
    [Action]                 VARCHAR (20)  NULL,
    [CashflowType]           VARCHAR (100) NULL,
    [Account]                VARCHAR (40)  NULL,
    [Adj_Category]           VARCHAR (60)  NULL,
    [Adj_Comment]            VARCHAR (255) NULL,
    [Partner]                VARCHAR (20)  NULL,
    [VAT_Script]             VARCHAR (20)  NULL,
    [VAT_SAP]                VARCHAR (20)  NULL,
    [VAT_CountryCode]        VARCHAR (40)  NULL,
    [Material]               VARCHAR (50)  NULL
);


GO

