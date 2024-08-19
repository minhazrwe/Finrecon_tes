

CREATE view [dbo].[Archive_individual_data_sql] as select * from  FinRecon.dbo.[FASTracker_Archive] where year(asofdate) in (2023) and MONTH(asofdate) in (7,8,10,11)

GO

