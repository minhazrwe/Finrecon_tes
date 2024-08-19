














CREATE view [dbo].[view_VM_NETTING_5_Report_VM_for_Controlling] as 
-- The Report ist utilized by the RWEST controlling department (Fabian Kraus) and the RWE AG (Stephan Schwalbach )

SELECT 		
	  [BODataType]
      ,[FTSubsidiary]		
      ,[FTStrategy]		
      ,[FTProjIndexGroup]
      ,[BOCurrency]		
      ,[BOContractDate]		
      ,[BONettingType]		
      ,[FTProductYearTermEnd]
      ,[HedgeExtern]
      ,sum([BOolfpnl]) as [BOolfpnl]									--Enhält olfpnl aus den Bocar Dateien
      ,sum([BOolfpnlCalcinEURRateRisk]) as [BOolfpnlCalcinEURRateRisk]	--OlfPNL in EUR mit Umrechnungsfaktor aus Endur
      ,sum([FTSummeVolumefinal]) as [Position]							-- Enthält volumeused bei 'extern' und volumeavailable bei 'hedge' 	
      ,sum([FTPNL])  as [FTPNL]											-- Enthält PNL aus FT
      ,sum([FTOCI]) as [FTOCI]											-- Enthält OCI aus FT
	  ,sum([FTTotal_MtM]) as [FTTotal_MtM]								-- Enthält Total Mtm aus FT
      ,sum([FinMtMtoNet]) as [FinMtMtoNet]								-- Enhält die final berechnete MtMtoNet
  FROM [FinRecon].[dbo].[table_VM_NETTING_4_Analysis_incl_FT]		
  where BONettingType in ('VM netting')
  group by		
	 [BODataType]		
      ,[FTSubsidiary]		
      ,[FTStrategy]		
      ,[FTProjIndexGroup]		
      ,[BOCurrency]		
      ,[BOContractDate]		
      ,[BONettingType]		
      ,[FTProductYearTermEnd]		
      ,[HedgeExtern]

GO

