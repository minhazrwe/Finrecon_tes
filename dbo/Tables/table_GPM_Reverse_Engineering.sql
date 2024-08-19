CREATE TABLE [dbo].[table_GPM_Reverse_Engineering] (
    [ID]                     INT           IDENTITY (1, 1) NOT NULL,
    [Category]               VARCHAR (100) NULL,
    [Document_Number]        VARCHAR (100) NULL,
    [Opening_Closing]        VARCHAR (100) NULL,
    [Desk]                   VARCHAR (100) NULL,
    [Subdesk]                VARCHAR (100) NULL,
    [DealID_Recon]           VARCHAR (100) NULL,
    [ccy]                    VARCHAR (10)  NULL,
    [Portfolio]              VARCHAR (100) NULL,
    [Instrument_Type]        VARCHAR (100) NULL,
    [External_Business_Unit] VARCHAR (100) NULL,
    [Diff_EUR]               FLOAT (53)    NULL,
    [ReconGroup]             VARCHAR (40)  NULL,
    CONSTRAINT [PK_zzz_table_Jan_Spring_GPM_Reverse_Engineering] PRIMARY KEY CLUSTERED ([ID] ASC)
);


GO

