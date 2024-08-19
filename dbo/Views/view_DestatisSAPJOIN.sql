


CREATE VIEW [dbo].[view_DestatisSAPJOIN] AS
SELECT * FROM [dbo].[SAP]
UNION ALL
SELECT * FROM [dbo].[SAP_Current_Month]

GO

