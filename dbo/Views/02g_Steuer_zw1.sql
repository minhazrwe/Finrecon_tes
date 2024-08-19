
/*This view shows the data from map_VAT but additionally adds the country codes based on the VAT_Countrycodes (EU, NonEU, DE, DE_19, DE_19_Gas, DE_19_Strom, DE_INN)
This means this view adds some lines to have not just this VAT_Countrycodes category but rather the actual country codes*/

CREATE view [dbo].[02g_Steuer_zw1] as 
SELECT [dbo].[map_VAT].[ctpygroup], 
[dbo].[map_VAT].[VAT_Group], 
[dbo].[map_VAT].[VAT_CountryCode], 
[dbo].[map_VAT].[Buys], 
[dbo].[map_VAT].[Sells], 
[dbo].[map_countryCode].[ISO-2] AS countrycode
FROM [dbo].[map_countryCode] INNER JOIN [dbo].[map_VAT] ON [dbo].[map_countryCode].[Assignment] = [dbo].[map_VAT].[VAT_CountryCode]

GO

