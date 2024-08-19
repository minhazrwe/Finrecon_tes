CREATE TABLE [dbo].[VM_NETTING_Produktzuordnung_Ausnahmen_vom_Produktnetting_Archive] (
    [ID]                      INT           IDENTITY (1, 1) NOT NULL,
    [AsofDate]                DATETIME      NULL,
    [InstrumentType]          NVARCHAR (50) NOT NULL,
    [Kennzeichnung_in_InsRef] NVARCHAR (50) NOT NULL,
    [TimeStamp]               DATETIME      NULL,
    CONSTRAINT [PK_VM_NETTING_Produktzuordnung_Ausnahmen_vom_Produktnetting_Archive] PRIMARY KEY CLUSTERED ([ID] ASC),
    CONSTRAINT [UK_VM_NETTING_Produktzuordnung_Ausnahmen_vom_Produktnetting_Archive] UNIQUE NONCLUSTERED ([AsofDate] ASC, [InstrumentType] ASC, [Kennzeichnung_in_InsRef] ASC)
);


GO

