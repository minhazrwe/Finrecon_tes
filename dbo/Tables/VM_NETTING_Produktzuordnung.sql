CREATE TABLE [dbo].[VM_NETTING_Produktzuordnung] (
    [ID]             INT           IDENTITY (1, 1) NOT NULL,
    [ExtBunit]       NVARCHAR (50) NOT NULL,
    [InstrumentType] NVARCHAR (50) NOT NULL,
    [Kommentar]      NVARCHAR (50) NOT NULL,
    [TimeStamp]      DATETIME      CONSTRAINT [DF_VM_Netting_Produktzuordnung_TimeStamp1] DEFAULT (getdate()) NULL,
    CONSTRAINT [PK_Netting_Produktzuordnung] PRIMARY KEY CLUSTERED ([ID] ASC),
    CONSTRAINT [UK_VM_Netting_Produktzuordnung] UNIQUE NONCLUSTERED ([ExtBunit] ASC, [InstrumentType] ASC, [Kommentar] ASC)
);


GO

