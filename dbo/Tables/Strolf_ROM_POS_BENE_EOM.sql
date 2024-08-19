CREATE TABLE [dbo].[Strolf_ROM_POS_BENE_EOM] (
    [ID]             INT        IDENTITY (1, 1) NOT NULL,
    [COB]            DATETIME   NULL,
    [DELIVERY_MONTH] DATETIME   NULL,
    [POWER_NL]       FLOAT (53) NULL,
    [POWER_BE]       FLOAT (53) NULL,
    [CO2_BENE]       FLOAT (53) NULL,
    [COAL_NL]        FLOAT (53) NULL,
    [GAS_BENE]       FLOAT (53) NULL,
    CONSTRAINT [pk_Strolf_ROM_POS_BENE_EOM] PRIMARY KEY CLUSTERED ([ID] ASC)
);


GO

