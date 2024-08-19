CREATE TABLE [dbo].[map_SBM_Allocation] (
    [ID]                   INT           IDENTITY (1, 1) NOT NULL,
    [InternalPortfolio]    VARCHAR (200) NOT NULL,
    [CounterpartyGroup]    VARCHAR (200) NOT NULL,
    [InstrumentType]       VARCHAR (200) NOT NULL,
    [ProjectionIndexGroup] VARCHAR (200) NOT NULL,
    [AllocationComment]    VARCHAR (255) NULL,
    [TimeStamp]            DATETIME      CONSTRAINT [DF_map_SBM_Allocation_TimeStamp] DEFAULT (getdate()) NULL,
    [User]                 VARCHAR (50)  CONSTRAINT [DF_map_SBM_Allocation_User] DEFAULT (user_name()) NULL,
    CONSTRAINT [pk_map_SBM_Allocation] PRIMARY KEY CLUSTERED ([InternalPortfolio] ASC, [CounterpartyGroup] ASC, [InstrumentType] ASC, [ProjectionIndexGroup] ASC)
);


GO

