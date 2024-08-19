

create view [dbo].[00_map_partner] as 
SELECT [dbo].[map_counterparty].[Partner], Max([dbo].[map_counterparty].[ctpygroup]) AS ctpygroup
FROM [dbo].[map_counterparty]
GROUP BY [dbo].[map_counterparty].[Partner]
HAVING ((([dbo].[map_counterparty].[Partner]) Is Not Null));

GO

