CREATE TABLE [dbo].[GloriImportStaging] (
    [Trade Deal Number]                               NVARCHAR (100) NULL,
    [Trade Reference Text]                            NVARCHAR (400) NULL,
    [Transaction Info Status]                         NVARCHAR (100) NULL,
    [Instrument Toolset Name]                         NVARCHAR (100) NULL,
    [Instrument Type Name]                            NVARCHAR (100) NULL,
    [Int Legal Entity Name]                           NVARCHAR (100) NULL,
    [Int Business Unit Name]                          NVARCHAR (100) NULL,
    [Internal Portfolio Business Key]                 NVARCHAR (100) NULL,
    [Internal Portfolio Name]                         NVARCHAR (100) NULL,
    [External Portfolio Name]                         NVARCHAR (100) NULL,
    [Ext Business Unit Name]                          NVARCHAR (100) NULL,
    [Ext Legal Entity Name]                           NVARCHAR (100) NULL,
    [Index Name]                                      NVARCHAR (100) NULL,
    [Trade Currency]                                  NVARCHAR (100) NULL,
    [Transaction Info Buy Sell]                       NVARCHAR (100) NULL,
    [Cashflow Type]                                   NVARCHAR (100) NULL,
    [Side Pipeline Name]                              NVARCHAR (100) NULL,
    [Instrument Subtype Name]                         NVARCHAR (100) NULL,
    [Discounting Index Name]                          NVARCHAR (100) NULL,
    [Trade Price]                                     FLOAT (53)     NULL,
    [Cashflow Delivery Month]                         NVARCHAR (100) NULL,
    [Trade Date]                                      NVARCHAR (100) NULL,
    [Index Contract Size]                             FLOAT (53)     NULL,
    [Discounting Index Contract Size]                 NVARCHAR (100) NULL,
    [Trade Instrument Reference Text]                 NVARCHAR (100) NULL,
    [Unit Name (Trade Std)]                           NVARCHAR (100) NULL,
    [Leg Exercise Date]                               NVARCHAR (100) NULL,
    [Cashflow Payment Date]                           NVARCHAR (100) NULL,
    [Leg End Date]                                    NVARCHAR (100) NULL,
    [Index Group]                                     NVARCHAR (100) NULL,
    [Delivery Vessel Name]                            NVARCHAR (100) NULL,
    [Static Ticket ID]                                NVARCHAR (100) NULL,
    [Volume]                                          FLOAT (53)     NULL,
    [PnL YtD Realised Undiscounted Original Currency] FLOAT (53)     NULL,
    [PnL YtD Realised Discounted EUR]                 FLOAT (53)     NULL,
    [PnL YtD Realised Undiscounted EUR]               FLOAT (53)     NULL,
    [PnL YtD Realised Discounted GBP]                 FLOAT (53)     NULL,
    [PnL YtD Realised Undiscounted GBP]               FLOAT (53)     NULL,
    [PnL YtD Realised Discounted USD]                 FLOAT (53)     NULL,
    [PnL YtD Realised Undiscounted USD]               FLOAT (53)     NULL,
    [Unrealised Discounted EUR]                       FLOAT (53)     NULL,
    [Unrealised Undiscounted EUR]                     FLOAT (53)     NULL,
    [Unrealised Discounted GBP]                       FLOAT (53)     NULL,
    [Unrealised Undiscounted GBP]                     FLOAT (53)     NULL,
    [Unrealised Discounted Original Currency]         FLOAT (53)     NULL,
    [Unrealised Undiscounted Original Currency]       FLOAT (53)     NULL,
    [Unrealised Discounted USD]                       FLOAT (53)     NULL,
    [Unrealised Undiscounted USD]                     FLOAT (53)     NULL,
    [FileID]                                          INT            NULL
);


GO

