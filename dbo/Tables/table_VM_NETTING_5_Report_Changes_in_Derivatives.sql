CREATE TABLE [dbo].[table_VM_NETTING_5_Report_Changes_in_Derivatives] (
    [AsofDate]             DATETIME      NULL,
    [Desk]                 VARCHAR (50)  NULL,
    [Strategy]             VARCHAR (255) NULL,
    [Endur_Desk_Name]      VARCHAR (100) NULL,
    [InternalBusinessUnit] VARCHAR (100) NULL,
    [Subdesk]              VARCHAR (255) NULL,
    [Book]                 VARCHAR (255) NULL,
    [InternalPortfolio]    VARCHAR (50)  NULL,
    [InstrumentType]       VARCHAR (50)  NULL,
    [ProjIndexGroup]       VARCHAR (50)  NULL,
    [TermEnd]              DATETIME      NULL,
    [ExtLegalEntity]       VARCHAR (50)  NULL,
    [CounterpartyGroup]    VARCHAR (50)  NULL,
    [SubDeskCCY]           VARCHAR (3)   NULL,
    [Sum_PNL]              FLOAT (53)    NULL,
    [SumTotal_MTM_DeskCCY] FLOAT (53)    NULL,
    [Sum_PNL_DeskCCY]      FLOAT (53)    NULL
);


GO

