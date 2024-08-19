

CREATE view [dbo].[view_doppelte_in_01_realised_all_zu_löschen] as 
SELECT  [Trade Deal Number]      ,[Trade Reference Text]      ,[Transaction Info Status]      ,[Instrument Toolset Name]      ,[Instrument Type Name]      ,[Int Legal Entity Name]      ,[Int Business Unit Name]
      ,[Internal Portfolio Business Key]      ,[Internal Portfolio Name]      ,[External Portfolio Name]      ,[Ext Business Unit Name]      ,[Ext Legal Entity Name]      ,[Index Name]      ,[Trade Currency]      ,[Transaction Info Buy Sell]
      ,[Cashflow Type]      ,[Side Pipeline Name]      ,[Instrument Subtype Name]      ,[Discounting Index Name]      ,[Trade Price]            ,[Cashflow Delivery Month]      ,[Trade Date]      ,[Index Contract Size]
      ,[Discounting Index Contract Size]      ,[Trade Instrument Reference Text]      ,[Unit Name (Trade Std)]      ,[Leg Exercise Date]      ,[Cashflow Payment Date]      ,[Leg End Date]      ,[Index Group]
      ,[Delivery Vessel Name]      ,[Static Ticket ID]            ,[volume]      ,[Realised_OrigCCY_Undisc]      ,[Realised_EUR_Undisc]      ,[Realised_EUR_Disc]      ,[Realised_GBP_Undisc]      ,[Realised_GBP_Disc]
      ,[Realised_USD_Undisc]      ,[Realised_USD_Disc]      ,[Delivery Month]      ,max([FileID_New]) as FileID
  FROM [FinRecon].[dbo].[view_doppelte_in_01_realised_all] group by 
  [Trade Deal Number]      ,[Trade Reference Text]      ,[Transaction Info Status]      ,[Instrument Toolset Name]      ,[Instrument Type Name]      ,[Int Legal Entity Name]      ,[Int Business Unit Name]
      ,[Internal Portfolio Business Key]      ,[Internal Portfolio Name]      ,[External Portfolio Name]      ,[Ext Business Unit Name]      ,[Ext Legal Entity Name]      ,[Index Name]      ,[Trade Currency]      ,[Transaction Info Buy Sell]
      ,[Cashflow Type]      ,[Side Pipeline Name]      ,[Instrument Subtype Name]      ,[Discounting Index Name]      ,[Trade Price]            ,[Cashflow Delivery Month]      ,[Trade Date]      ,[Index Contract Size]
      ,[Discounting Index Contract Size]      ,[Trade Instrument Reference Text]      ,[Unit Name (Trade Std)]      ,[Leg Exercise Date]      ,[Cashflow Payment Date]      ,[Leg End Date]      ,[Index Group]
      ,[Delivery Vessel Name]      ,[Static Ticket ID]            ,[volume]      ,[Realised_OrigCCY_Undisc]      ,[Realised_EUR_Undisc]      ,[Realised_EUR_Disc]      ,[Realised_GBP_Undisc]      ,[Realised_GBP_Disc]
      ,[Realised_USD_Undisc]      ,[Realised_USD_Disc]      ,[Delivery Month]

GO

