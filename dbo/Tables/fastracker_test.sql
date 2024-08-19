CREATE TABLE [dbo].[fastracker_test] (
    [AsofDate]                                 DATETIME      NULL,
    [sub id]                                   INT           NULL,
    [ReferenceID]                              VARCHAR (50)  NULL,
    [TermEnd]                                  DATE          NULL,
    [Trade Date]                               DATETIME      NULL,
    [InternalPortfolio]                        VARCHAR (50)  NULL,
    [SourceSystemBookID]                       VARCHAR (50)  NULL,
    [Counterparty_ExtBunit]                    VARCHAR (50)  NULL,
    [CounterpartyGroup]                        VARCHAR (50)  NULL,
    [SourceSystemBookID+Counterparty_ExtBunit] VARCHAR (100) NULL,
    [ProjIndexGroup]                           VARCHAR (50)  NULL,
    [InstrumentType]                           VARCHAR (50)  NULL,
    [ExtLegalEntity]                           VARCHAR (50)  NULL,
    [Discounted_MTM]                           FLOAT (53)    NULL,
    [Undiscounted_MTM]                         FLOAT (53)    NULL,
    [Undiscounted_PNL]                         FLOAT (53)    NULL,
    [Undiscounted_AOCI]                        FLOAT (53)    NULL
);


GO

