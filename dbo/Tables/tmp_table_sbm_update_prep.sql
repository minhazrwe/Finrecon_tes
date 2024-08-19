CREATE TABLE [dbo].[tmp_table_sbm_update_prep] (
    [Desk]                 VARCHAR (50)   NULL,
    [Subdesk]              VARCHAR (255)  NULL,
    [SubDeskCCY]           VARCHAR (3)    NULL,
    [COB]                  DATE           NULL,
    [SubID]                INT            NULL,
    [Subsidiary]           VARCHAR (255)  NULL,
    [Strategy]             VARCHAR (255)  NULL,
    [Book]                 VARCHAR (255)  NULL,
    [AccountingTreatment]  VARCHAR (255)  NULL,
    [InternalPortfolio]    VARCHAR (50)   NULL,
    [ExternalBusinessUnit] VARCHAR (50)   NULL,
    [ExtLegalEntity]       VARCHAR (50)   NULL,
    [ExtPortfolio]         VARCHAR (50)   NULL,
    [CounterpartyGroup]    VARCHAR (50)   NULL,
    [InstrumentType]       VARCHAR (50)   NULL,
    [ProjIndexGroup]       VARCHAR (50)   NULL,
    [BusinessLineName]     NVARCHAR (100) NULL,
    [DeskName]             NVARCHAR (100) NULL,
    [Intermediate1Name]    NVARCHAR (100) NULL,
    [Intermediate2Name]    NVARCHAR (100) NULL,
    [BookName]             NVARCHAR (100) NULL,
    [PortfolioName]        NVARCHAR (100) NOT NULL,
    [PortfolioId]          INT            NOT NULL,
    [ExternalDesk]         NVARCHAR (100) NULL
);


GO

