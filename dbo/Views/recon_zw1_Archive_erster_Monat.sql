


CREATE view [dbo].[recon_zw1_Archive_erster_Monat] as select * from dbo.Recon_zw1_Archive where asofdate = (select min(asofdate) from dbo.Recon_zw1_Archive)

GO

