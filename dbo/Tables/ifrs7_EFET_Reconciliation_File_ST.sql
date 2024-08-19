CREATE TABLE [dbo].[ifrs7_EFET_Reconciliation_File_ST] (
    [LegalEntity]      NVARCHAR (200) NULL,
    [OLF]              SMALLINT       NULL,
    [MyTradeID]        NVARCHAR (200) NOT NULL,
    [Commodity]        NVARCHAR (200) NULL,
    [TradeDate]        NVARCHAR (200) NULL,
    [INSTYPE]          NVARCHAR (200) NULL,
    [TradeStartDate]   NVARCHAR (200) NULL,
    [TradeEndDate]     NVARCHAR (200) NULL,
    [MTM]              FLOAT (53)     NULL,
    [SE]               FLOAT (53)     NULL,
    [TotalExposure]    FLOAT (53)     NULL,
    [ExposureCurrency] NVARCHAR (200) NULL,
    [FXRATE]           FLOAT (53)     NULL,
    [MFAP]             FLOAT (53)     NULL,
    [MFAP_check]       FLOAT (53)     NULL,
    [ExposureinEUR]    FLOAT (53)     NULL,
    [positivnegativ]   NVARCHAR (200) NULL
);


GO

