CREATE TABLE [dbo].[table_D2D_BIM] (
    [KopfIdent]     VARCHAR (100) NULL,
    [Buchungskreis] VARCHAR (100) NULL,
    [Belegdatum]    VARCHAR (100) NULL,
    [Belegart]      VARCHAR (100) NULL,
    [Buchungsdatum] VARCHAR (100) NULL,
    [Currency]      VARCHAR (100) NULL,
    [Belegkopftext] VARCHAR (100) NULL,
    [Referenz]      VARCHAR (100) NULL,
    [dummy1]        VARCHAR (100) NULL,
    [dummy2]        VARCHAR (100) NULL,
    [dummy3]        VARCHAR (100) NULL,
    [dummy4]        VARCHAR (100) NULL,
    [dummy5]        VARCHAR (100) NULL,
    [dummy6]        VARCHAR (100) NULL,
    [dummy7]        VARCHAR (100) NULL,
    [dummy8]        VARCHAR (100) NULL,
    [dummy9]        VARCHAR (100) NULL,
    [dummy10]       VARCHAR (100) NULL,
    [dummy11]       VARCHAR (100) NULL,
    [ID]            INT           IDENTITY (1, 1) NOT NULL,
    [lastUpdate]    DATETIME      CONSTRAINT [DF_table_D2D_BIM_lastUpdate] DEFAULT (getdate()) NULL
);


GO

