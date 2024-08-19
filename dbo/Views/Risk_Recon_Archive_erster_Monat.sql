



create view [dbo].[Risk_Recon_Archive_erster_Monat] as select * from dbo.RiskRecon_archive where asofdate = (select min(asofdate) from dbo.RiskRecon_archive)

GO

