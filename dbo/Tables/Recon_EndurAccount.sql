CREATE TABLE [dbo].[Recon_EndurAccount] (
    [ID]                         INT           IDENTITY (1, 1) NOT NULL,
    [OrderNo]                    VARCHAR (255) NULL,
    [DeliveryMonth]              VARCHAR (255) NULL,
    [DealID_Recon]               VARCHAR (255) NULL,
    [diff_ccy]                   FLOAT (53)    NULL,
    [Volume]                     FLOAT (53)    NULL,
    [Endur]                      VARCHAR (255) NULL,
    [SAP]                        VARCHAR (255) NULL,
    [check]                      SMALLINT      NULL,
    [AnzahlvonReconGroup]        INT           NULL,
    [Summevonrealised_ccy_Endur] FLOAT (53)    NULL,
    [Summevonrealised_ccy_SAP]   FLOAT (53)    NULL,
    [ReconGroup]                 VARCHAR (255) NULL,
    [ABS]                        FLOAT (53)    NULL,
    CONSTRAINT [pk_map_EndurAccount_ROCK] PRIMARY KEY CLUSTERED ([ID] ASC)
);


GO

