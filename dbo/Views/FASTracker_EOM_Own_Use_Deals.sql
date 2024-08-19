









CREATE view [dbo].[FASTracker_EOM_Own_Use_Deals]
as 
	SELECT  [Desk]
      ,[Subdesk]
      ,[SubDeskCCY]
      ,[AsofDate]
      ,[Sub ID]
      ,[Subsidiary]
      ,[Strategy]
      ,[Book]
      ,[AccountingTreatment]
      ,[InternalPortfolio]
      ,[ExternalBusinessUnit]
      ,[ExtLegalEntity]
      ,[ExtPortfolio]
      ,[CounterpartyGroup]
      ,[InstrumentType]
      ,[ProjIndexGroup]
      ,[CurveName]
      ,[Product]
      ,[ReferenceID]
      ,[TradeDate]
      ,[TermEnd]
      ,[Total_MTM]
      ,[PNL]
      ,[OCI]
      ,[OU]
      ,[NOR]
      ,[UOM]
      ,[Volume]
      ,[VolumeAvailable]
      ,[VolumeUsed]
      ,[DeskCCY]
      ,[Total_MTM_DeskCCY]
      ,[PNL_DeskCCY]
      ,[OCI_DeskCCY]
      ,[OU_DeskCCY]
      ,[NOR_DeskCCY]
  FROM [FinRecon].[dbo].[FASTracker_EOM]
        Where [AccountingTreatment] In('Own Use','out of scope')

GO

