

CREATE view [dbo].[PNL_RACE] as SELECT distinct [ID]      ,[CompanyCode]      ,[Account], [OffsettingAccount]      ,[DocumentHeaderText]      ,[Reference]      ,[Assignment]      ,[DocumentNumber]
      [BusinessArea]      ,[DocumentType]      ,[PostingDate]      ,[DocumentDate]      ,[PostingKey]      ,[Amountinlocalcurrency]      ,[LocalCurrency]      ,[Taxcode]      ,[ClearingDocument]
      ,[Text]           ,[TransactionType]      ,[Documentcurrency]      ,[Amountindoccurr]      ,[Order]      ,[CostCenter]      ,[Quantity]      ,[BaseUnitofMeasure]      ,[Material]      ,[RefKey1]      ,[RefKey2]
      ,[TradingPartner] ,[Username]      ,[EntryDate]      ,[TimeStamp], 
	  case when convert (varchar,gg.[race extern IAS]) <> '' and convert(varchar,gg.[RACE intern IAS]) <> '' and convert (varchar, dd.TradingPartner) = '' then  gg.[race extern IAS] else 
		case when convert (varchar,gg.[race extern IAS]) <> '' and convert(varchar,gg.[RACE intern IAS]) <> '' and convert(varchar,dd.TradingPartner) <> '' then  gg.[RACE intern IAS] else
			case when convert (varchar,gg.[race extern IAS]) = '' and convert(varchar,gg.[RACE intern IAS]) = '' and convert(varchar,dd.TradingPartner) <> '' then gg.[RACE position] else
				case when convert (varchar,gg.[race extern IAS]) = '' and convert(varchar,gg.[RACE intern IAS]) = '' and convert(varchar,dd.TradingPartner) = '' then gg.[RACE position] else
			gg.[RACE position] end end end end as 'RacePosition'
	  FROM [FinRecon].[dbo].[SAP] as dd, [Finrecon].[dbo].[map_SAP_RACE] as gg where 
		('0' + rtrim(ltrim(dd.Account)) = right(rtrim(ltrim(gg.Konto)),8) and 
		rtrim(ltrim(dd.CompanyCode)) = right(rtrim(ltrim(gg.Bukrs)),3) and 
		dd.CompanyCode in ('600','611'))
		--or
		--('I' + rtrim(ltrim(dd.Account)) = right(rtrim(ltrim(gg.Konto)),8) and
		--rtrim(ltrim(dd.CompanyCode)) = right(rtrim(ltrim(gg.Bukrs)),3) and 
		--dd.CompanyCode in ('600','611'))  --order by [RacePosition] desc  -- and dd.Account like '%6018002%'-- where Companycode = 611 and [Assignment] in ('5040200025','5040200030')
union SELECT distinct [ID]      ,[CompanyCode]      ,[Account], [OffsettingAccount]      ,[DocumentHeaderText]      ,[Reference]      ,[Assignment]      ,[DocumentNumber]
      [BusinessArea]      ,[DocumentType]      ,[PostingDate]      ,[DocumentDate]      ,[PostingKey]      ,[Amountinlocalcurrency]      ,[LocalCurrency]      ,[Taxcode]      ,[ClearingDocument]
      ,[Text]           ,[TransactionType]      ,[Documentcurrency]      ,[Amountindoccurr]      ,[Order]      ,[CostCenter]      ,[Quantity]      ,[BaseUnitofMeasure]      ,[Material]      ,[RefKey1]      ,[RefKey2]
      ,[TradingPartner] ,[Username]      ,[EntryDate]      ,[TimeStamp], 
	  case when convert (varchar,gg.[race extern IAS]) <> '' and convert(varchar,gg.[RACE intern IAS]) <> '' and convert (varchar, dd.TradingPartner) = '' then  gg.[race extern IAS] else 
		case when convert (varchar,gg.[race extern IAS]) <> '' and convert(varchar,gg.[RACE intern IAS]) <> '' and convert(varchar,dd.TradingPartner) <> '' then  gg.[RACE intern IAS] else
			case when convert (varchar,gg.[race extern IAS]) = '' and convert(varchar,gg.[RACE intern IAS]) = '' and convert(varchar,dd.TradingPartner) <> '' then gg.[RACE position] else
				case when convert (varchar,gg.[race extern IAS]) = '' and convert(varchar,gg.[RACE intern IAS]) = '' and convert(varchar,dd.TradingPartner) = '' then gg.[RACE position] else
			gg.[RACE position] end end end end as 'RacePosition'
	  FROM [FinRecon].[dbo].[SAP] as dd, [Finrecon].[dbo].[map_SAP_RACE] as gg where 
		(rtrim(ltrim(dd.Account)) = right(rtrim(ltrim(gg.Konto)),8) and  len(rtrim(ltrim(dd.Account))) = 8 and
		rtrim(ltrim(dd.CompanyCode)) = right(rtrim(ltrim(gg.Bukrs)),3) and 
		dd.CompanyCode in ('600','611')) -- and dd.Account like '%6018002%'-- where Companycode = 611 and [Assignment] in ('5040200025','5040200030')

GO

