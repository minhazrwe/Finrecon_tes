CREATE TABLE [dbo].[SAP_LedgerData] (
    [Variante]            NVARCHAR (100) NULL,
    [Periode]             NVARCHAR (100) NULL,
    [Company]             NVARCHAR (100) NULL,
    [Kons]                NVARCHAR (100) NULL,
    [RACEPosition]        NVARCHAR (100) NULL,
    [RACEPositionType]    NVARCHAR (100) NULL,
    [RACE-UP]             NVARCHAR (100) NULL,
    [Product]             NVARCHAR (100) NULL,
    [Restlaufzeit]        NVARCHAR (100) NULL,
    [Kundengruppe]        NVARCHAR (100) NULL,
    [Segment]             NVARCHAR (100) NULL,
    [Sachkonto]           NVARCHAR (100) NULL,
    [Kontentext]          NVARCHAR (100) NULL,
    [Kontenart]           NVARCHAR (100) NULL,
    [ProfitCenter]        NVARCHAR (100) NULL,
    [BWAFI]               NVARCHAR (100) NULL,
    [BWAFIAA]             NVARCHAR (100) NULL,
    [BWATR]               NVARCHAR (100) NULL,
    [Vertragstyp]         NVARCHAR (100) NULL,
    [Basisdatum]          NVARCHAR (100) NULL,
    [Zahlungsbedingungen] NVARCHAR (100) NULL,
    [Debitor]             NVARCHAR (100) NULL,
    [Kreditor]            NVARCHAR (100) NULL,
    [Partner]             NVARCHAR (100) NULL,
    [PGDK]                NVARCHAR (100) NULL,
    [Status]              NVARCHAR (100) NULL,
    [Gesellschaftsform]   NVARCHAR (100) NULL,
    [Land]                NVARCHAR (100) NULL,
    [Meldeeinheit]        NVARCHAR (100) NULL,
    [WertInHW]            FLOAT (53)     NULL,
    [Menge]               NVARCHAR (100) NULL,
    [ME]                  NVARCHAR (100) NULL,
    [LastUpdate]          DATETIME       CONSTRAINT [DF_SAP_LedgerData_LastUpdate] DEFAULT (getdate()) NULL
);


GO

