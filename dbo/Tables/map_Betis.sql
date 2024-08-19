CREATE TABLE [dbo].[map_Betis] (
    [KonzNr]             INT           NOT NULL,
    [Kurzname]           VARCHAR (50)  NULL,
    [Langname]           VARCHAR (150) NULL,
    [statusNummer]       VARCHAR (5)   NULL,
    [StatusBeschreibung] VARCHAR (100) NULL,
    [Konzernbereich]     VARCHAR (50)  NULL,
    [MutterNr]           INT           NULL,
    [MutterKurztext]     VARCHAR (40)  NULL,
    [Anteil]             FLOAT (53)    NULL
);


GO

