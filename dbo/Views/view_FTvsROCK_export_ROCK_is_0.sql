



CREATE view [dbo].[view_FTvsROCK_export_ROCK_is_0]
AS
SELECT 
	TradeDealNumber + '|' 
	+ Format(COB,'dd/MM/yyyy') + '|' 
	+ Format(Termend,'dd\/MM/yyyy') + '|EUR|1.0000|0.00|0.00' AS remove_this_header
FROM 
	dbo.view_FTvsROCK_DifferencesAggregrated			
WHERE 
	ROCK=0 
	AND Info Is Null;

GO

