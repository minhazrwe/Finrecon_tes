CREATE TABLE [dbo].[Recon_offsets] (
    [ID]                   INT           IDENTITY (1, 1) NOT NULL,
    [Identifier]           VARCHAR (255) NULL,
    [InternalLegalEntity]  VARCHAR (100) NULL,
    [Desk]                 VARCHAR (100) NULL,
    [Subdesk]              VARCHAR (100) NULL,
    [ExternalBusinessUnit] VARCHAR (100) NULL,
    [SAP_DocumentNumber]   VARCHAR (20)  NULL,
    [ReconGroup]           VARCHAR (40)  NULL,
    [OrderNo]              VARCHAR (50)  NULL,
    [DeliveryMonth]        VARCHAR (40)  NULL,
    [DealID_Recon]         VARCHAR (100) NULL,
    [Account]              VARCHAR (100) NULL,
    [ccy]                  VARCHAR (5)   NULL,
    [Diff_Volume]          FLOAT (53)    NULL,
    [Diff_Realised_CCY]    FLOAT (53)    NULL,
    [comment]              VARCHAR (100) NULL,
    [EventDate]            VARCHAR (40)  NULL,
    [source]               VARCHAR (100) NULL,
    CONSTRAINT [pk_Recon_offsets] PRIMARY KEY CLUSTERED ([ID] ASC)
);


GO

