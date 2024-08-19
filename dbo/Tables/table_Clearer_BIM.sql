CREATE TABLE [dbo].[table_Clearer_BIM] (
    [ID]                INT            IDENTITY (1, 1) NOT NULL,
    [KopfIdent]         NVARCHAR (150) NULL,
    [Buchungskreis]     NVARCHAR (150) NULL,
    [Belegdatum]        NVARCHAR (150) NULL,
    [Belegart]          NVARCHAR (150) NULL,
    [Buchungsdatum]     NVARCHAR (150) NULL,
    [Waehrung]          NVARCHAR (150) NULL,
    [Belegkopftext]     NVARCHAR (150) NULL,
    [Referenz]          NVARCHAR (150) NULL,
    [loeschen01]        NVARCHAR (150) NULL,
    [loeschen02]        NVARCHAR (150) NULL,
    [loeschen03]        NVARCHAR (150) NULL,
    [loeschen04]        NVARCHAR (150) NULL,
    [loeschen05]        NVARCHAR (150) NULL,
    [loeschen06]        NVARCHAR (150) NULL,
    [loeschen07]        NVARCHAR (150) NULL,
    [loeschen08]        NVARCHAR (150) NULL,
    [loeschen09]        VARCHAR (200)  NULL,
    [loeschen10]        VARCHAR (200)  NULL,
    [loeschen11]        VARCHAR (200)  NULL,
    [loeschen12]        VARCHAR (200)  NULL,
    [loeschen13]        VARCHAR (200)  NULL,
    [loeschen14]        VARCHAR (200)  NULL,
    [Desk]              NVARCHAR (150) NULL,
    [PayReceive]        NVARCHAR (10)  NULL,
    [DocumentPartition] INT            NULL,
    [clearerID]         INT            NULL,
    [COB]               DATE           NULL,
    [RealisedPNL]       NVARCHAR (150) NULL,
    [QuerySource]       NVARCHAR (150) NULL,
    CONSTRAINT [pk_table_Clearer_BIM] PRIMARY KEY CLUSTERED ([ID] ASC)
);


GO

