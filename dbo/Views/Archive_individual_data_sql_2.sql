

CREATE view [dbo].[Archive_individual_data_sql_2] as select * from  FinRecon.dbo.[FASTracker_Archive] where year(asofdate) in (2024) and MONTH(asofdate) in (1,2,4)

GO

