CREATE TABLE [dbo].[VM_NETTING_Produktzuordnung_Archive] (
    [ID]             INT           IDENTITY (1, 1) NOT NULL,
    [AsofDate]       DATETIME      NULL,
    [ExtBunit]       NVARCHAR (50) NOT NULL,
    [InstrumentType] NVARCHAR (50) NOT NULL,
    [Kommentar]      NVARCHAR (50) NOT NULL,
    [TimeStamp]      DATETIME      NULL,
    CONSTRAINT [PK_Netting_Produktzuordnung_Archive] PRIMARY KEY CLUSTERED ([ID] ASC),
    CONSTRAINT [UK_VM_Netting_Produktzuordnung_Archive] UNIQUE NONCLUSTERED ([AsofDate] ASC, [ExtBunit] ASC, [InstrumentType] ASC, [Kommentar] ASC)
);


GO

