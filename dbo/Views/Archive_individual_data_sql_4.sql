

CREATE view [dbo].[Archive_individual_data_sql_4] as select * from FinRecon.dbo.FASTracker_Archive where YEAR(asofdate) = '2023' and month(asofdate) in (7,8,10,11)

GO

