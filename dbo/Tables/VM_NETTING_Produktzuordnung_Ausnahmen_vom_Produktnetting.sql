CREATE TABLE [dbo].[VM_NETTING_Produktzuordnung_Ausnahmen_vom_Produktnetting] (
    [ID]                      INT           IDENTITY (1, 1) NOT NULL,
    [InstrumentType]          NVARCHAR (50) NOT NULL,
    [Kennzeichnung_in_InsRef] NVARCHAR (50) NOT NULL,
    [TimeStamp]               DATETIME      CONSTRAINT [DF_VM_NETTING_Produktzuordnung_Ausnahmen_vom_Produktnetting_TimeStamp1] DEFAULT (getdate()) NULL,
    CONSTRAINT [PK_VM_NETTING_Produktzuordnung_Ausnahmen_vom_Produktnetting] PRIMARY KEY CLUSTERED ([ID] ASC),
    CONSTRAINT [UK_VM_NETTING_Produktzuordnung_Ausnahmen_vom_Produktnetting] UNIQUE NONCLUSTERED ([InstrumentType] ASC, [Kennzeichnung_in_InsRef] ASC)
);


GO

