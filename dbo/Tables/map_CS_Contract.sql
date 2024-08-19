CREATE TABLE [dbo].[map_CS_Contract] (
    [ID]                   INT           IDENTITY (1, 1) NOT NULL,
    [OrderNo]              VARCHAR (50)  NOT NULL,
    [ExternalBusinessUnit] VARCHAR (100) NOT NULL,
    [InstrumentType]       VARCHAR (25)  NOT NULL,
    [DealID_Recon]         VARCHAR (100) NULL,
    CONSTRAINT [constraint_map_cs_contract] PRIMARY KEY CLUSTERED ([OrderNo] ASC, [ExternalBusinessUnit] ASC, [InstrumentType] ASC)
);


GO

