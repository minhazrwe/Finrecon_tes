CREATE TABLE [dbo].[AWV_Import] (
    [SAP-Buchungskreis]           INT            NULL,
    [SAP-Konto]                   VARCHAR (50)   NULL,
    [SAP-Belegnummer]             VARCHAR (50)   NULL,
    [SAP-Buchungsdatum]           DATE           NULL,
    [SAP-Belegart]                VARCHAR (50)   NULL,
    [SAP-Referenz]                VARCHAR (50)   NULL,
    [SAP-Debitor/Kreditor]        VARCHAR (50)   NULL,
    [SAP-Buchungsschlüssel]       INT            NULL,
    [SAP-Zuordnung]               VARCHAR (50)   NULL,
    [AWV-Bezeichnung]             VARCHAR (1000) NULL,
    [AWV-Info]                    VARCHAR (1000) NULL,
    [AWV-Bemerkung/Zahlungszweck] VARCHAR (1000) NULL,
    [Absatz/Bezug]                VARCHAR (10)   NULL,
    [AWV-LZB]                     VARCHAR (100)  NULL,
    [AWV-Anlage]                  VARCHAR (20)   NULL,
    [Counterparty Land]           VARCHAR (100)  NULL,
    [SAP-Text]                    VARCHAR (100)  NULL,
    [SAP-Belegdatum]              DATE           NULL,
    [SAP-Betrag in Hauswährung]   FLOAT (53)     NULL,
    [SAP-Hauswährung]             VARCHAR (50)   NULL,
    [SAP-Betrag in Belegwährung]  FLOAT (53)     NULL,
    [SAP-Belegwährung]            VARCHAR (50)   NULL,
    [SAP-Steuerkennzeichen]       VARCHAR (50)   NULL,
    [SAP-Menge]                   FLOAT (53)     NULL,
    [AusschlussKommentar]         VARCHAR (100)  NULL,
    [SAP-Belegkopftext]           VARCHAR (300)  NULL,
    [TradingPartner]              VARCHAR (50)   NULL,
    [Liefer Land]                 VARCHAR (100)  NULL,
    [RefSchl2]                    VARCHAR (300)  NULL,
    [AWV-Responsible]             VARCHAR (50)   NULL,
    [ROWID]                       BIGINT         NULL
);


GO

