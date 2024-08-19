CREATE TABLE [dbo].[table_IAS39_Flags_of_Contracts] (
    [NBAP_ID]                  NVARCHAR (200) NULL,
    [Contract_Name]            NVARCHAR (200) NULL,
    [Tenant]                   NVARCHAR (200) NULL,
    [CP_ID]                    NVARCHAR (200) NULL,
    [Counterparty_Name]        NVARCHAR (200) NULL,
    [Classification]           NVARCHAR (200) NULL,
    [Commodity]                NVARCHAR (200) NULL,
    [Base_Contract]            NVARCHAR (200) NULL,
    [Contract_Type]            NVARCHAR (200) NULL,
    [Supply_from]              DATE           NULL,
    [Supply_until]             DATE           NULL,
    [Settlement_Date]          DATE           NULL,
    [Accounting_Forwards]      NVARCHAR (200) NULL,
    [Accounting_Open_Position] NVARCHAR (200) NULL,
    [Short_Name_in_ENDUR]      NVARCHAR (200) NULL,
    [Payment_Date_Conditions]  NVARCHAR (200) NULL,
    [Sell_Option]              NVARCHAR (200) NULL,
    [Is_3CP_allowed]           NVARCHAR (200) NULL,
    [LastUpdate]               DATETIME       CONSTRAINT [DF_table_IAS39_Flags_of_Contracts_LastUpdate] DEFAULT (getdate()) NULL
);


GO

