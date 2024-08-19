CREATE TABLE [dbo].[table_SOLL_IST_ABGLEICH_CS_ARCHIV] (
    [Reference]                     VARCHAR (50) NULL,
    [Assignment]                    VARCHAR (50) NULL,
    [Taxcode]                       VARCHAR (50) NULL,
    [Gebuchte manuelle Anpassungen] FLOAT (53)   NULL,
    [Gebuchte Schätzung]            FLOAT (53)   NULL,
    [UST-Voranmeldung]              FLOAT (53)   NULL,
    [IST-Werte]                     FLOAT (53)   NULL,
    [Differenz]                     FLOAT (53)   NULL,
    [TimeStamp]                     DATETIME     CONSTRAINT [DF_SOLL_IST_ABGLEICH_CS_ARCHIV_TimeStamp] DEFAULT (getdate()) NULL
);


GO

