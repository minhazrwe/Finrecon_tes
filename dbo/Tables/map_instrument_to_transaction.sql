CREATE TABLE [dbo].[map_instrument_to_transaction] (
    [Instrument_Type_ID]    INT            NULL,
    [Instrument_Name]       VARCHAR (250)  NULL,
    [Payment_Type_ID]       INT            NULL,
    [Payment_Type_Name]     VARCHAR (250)  NULL,
    [Counterparty_ID]       INT            NULL,
    [Counterparty_Name]     NVARCHAR (250) NULL,
    [Transaction_Type_ID]   INT            NULL,
    [Transaction_Type_Name] NVARCHAR (250) NULL
);


GO

