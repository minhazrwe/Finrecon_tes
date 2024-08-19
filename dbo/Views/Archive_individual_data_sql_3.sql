

CREATE view [dbo].[Archive_individual_data_sql_3] as select * from FinRecon.dbo.FASTracker_Archive where YEAR(asofdate) = '2023' and month(asofdate) in (3,6,9)

GO

