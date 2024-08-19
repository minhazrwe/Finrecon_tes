








CREATE view [dbo].[view_VM_NETTING_2_Missing_Mappings] as 


SELECT DISTINCT [VM_NETTING_Deallevel].Product
	,[VM_NETTING_Deallevel].ExchangeCode
	,[VM_NETTING_Deallevel].ExternalBU
FROM [FinRecon].[dbo].[VM_NETTING_Deallevel]
LEFT JOIN [FinRecon].[dbo].[table_VM_NETTING_2_Mapping] ON [VM_NETTING_Deallevel].[Product] = [table_VM_NETTING_2_Mapping].Product
	AND [VM_NETTING_Deallevel].ExchangeCode = [table_VM_NETTING_2_Mapping].[ExchangeCode]
WHERE [table_VM_NETTING_2_Mapping].Product IS NULL

GO

