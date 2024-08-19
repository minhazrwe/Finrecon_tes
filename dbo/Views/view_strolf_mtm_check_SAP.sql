






CREATE view [dbo].[view_strolf_mtm_check_SAP] as
SELECT 'BALANCE' AS 'POSITION'
      ,-ROUND(SUM(CASE WHEN RIGHT(Reference,7) = convert(varchar,year([AsOfDate_EOY])) + '/' + convert(varchar,month([AsOfDate_EOY])) THEN [Amountinlocalcurrency] ELSE 0 END),2) AS 'PY'
	  ,ROUND(SUM(CASE WHEN RIGHT(Reference,7) = convert(varchar,year([AsOfDate_EOM])) + '/' + convert(char(2),cast([AsOfDate_EOM] as datetime),101) THEN [Amountinlocalcurrency] ELSE 0 END),2) AS 'CY'
  FROM [FinRecon].[dbo].[SAP]
  ,AsOfDate
  WHERE DocumentHeaderText = 'MtM CAO Power'

  UNION ALL

  SELECT 'OCI' AS 'POSITION'
      ,-ROUND(SUM(CASE WHEN RIGHT(Reference,7) = convert(varchar,year([AsOfDate_EOY])) + '/' + convert(varchar,month([AsOfDate_EOY])) THEN [Amountinlocalcurrency] ELSE 0 END),2) AS 'PY'
	  ,ROUND(SUM(CASE WHEN RIGHT(Reference,7) = convert(varchar,year([AsOfDate_EOM])) + '/' + convert(char(2),cast([AsOfDate_EOM] as datetime),101) THEN [Amountinlocalcurrency] ELSE 0 END),2) AS 'CY'
  FROM [FinRecon].[dbo].[SAP]
  ,AsOfDate
  WHERE DocumentHeaderText = 'MtM CAO Power' AND Account LIKE 'I2%'

  UNION ALL

  SELECT 'PNL' AS 'POSITION'
      ,-ROUND(SUM(CASE WHEN RIGHT(Reference,7) = convert(varchar,year([AsOfDate_EOY])) + '/' + convert(varchar,month([AsOfDate_EOY])) THEN [Amountinlocalcurrency] ELSE 0 END),2) AS 'PY'
	  ,ROUND(SUM(CASE WHEN RIGHT(Reference,7) = convert(varchar,year([AsOfDate_EOM])) + '/' + convert(char(2),cast([AsOfDate_EOM] as datetime),101) THEN [Amountinlocalcurrency] ELSE 0 END),2) AS 'CY'
  FROM [FinRecon].[dbo].[SAP]
  ,AsOfDate
  WHERE DocumentHeaderText = 'MtM CAO Power' AND Account NOT LIKE 'I2%'

GO

