CREATE TABLE [dbo].[Strolf_ROM_POS_DE_EOM] (
    [ID]             INT        IDENTITY (1, 1) NOT NULL,
    [COB]            DATETIME   NULL,
    [DELIVERY_MONTH] DATETIME   NULL,
    [POWER_DE]       FLOAT (53) NULL,
    [CO2_DE]         FLOAT (53) NULL,
    [COAL_DE]        FLOAT (53) NULL,
    [GAS_DE]         FLOAT (53) NULL,
    CONSTRAINT [pk_Strolf_ROM_POS_DE_EOM] PRIMARY KEY CLUSTERED ([ID] ASC)
);


GO

