







CREATE view [dbo].[FixedPrices] as 
SELECT 

[Reference_ID],
      max(Iif([Fixed_Float] = 'Fixed',[Fixed_Price],0)) as Fixed_Price,
	  max(Iif([Fixed_Float] = 'Float',[Fixed_Price],0)) as Float_Price,
      max([Fixed_Price_Currency]) as Fixed_Proce_Currency
      
  FROM [FinRecon].[ENERGY\UI856115].[FixedPrice_IFRS7_r884018_2022_01_31_145736]

  group by
  [Reference_ID]

GO

