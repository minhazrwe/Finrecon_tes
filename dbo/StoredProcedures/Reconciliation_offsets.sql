

CREATE PROCEDURE [dbo].[Reconciliation_offsets]
	AS
	BEGIN TRY


Truncate table dbo.recon_offsets


--- 1st query based on orderno, dealID_recon and ccy
insert into dbo.recon_offsets ([Identifier] ,[InternalLegalEntity] ,[Desk] ,[Subdesk] ,[ExternalBusinessUnit] ,[SAP_DocumentNumber] ,[ReconGroup],[OrderNo]
		,[DeliveryMonth] ,[DealID_Recon] ,[Account] ,[ccy] ,[Diff_Volume] ,[Diff_Realised_CCY] ,[comment] ,[EventDate], [source])
	select r.identifier, r.InternalLegalEntity, r.Desk, r.Subdesk, r.ExternalBusinessUnit, r.SAP_DocumentNumber, r.ReconGroup,
		r.OrderNo,  r.DeliveryMonth, r.DealID_Recon, r.Account, r.ccy, r.Diff_Volume, r.Diff_CCY, sql.comment, r.eventdate, 'query1'
	from recon_diff r
	inner join 
	(SELECT OrderNo, o.[DealID_Recon], ccy, case when abs(sum(diff_deskccy))+abs(sum(diff_eur))<2 then 'offsetting' else 'FX conversion' end as comment
		FROM dbo.[Recon_Diff] o  where recongroup not in ('FX','Brokerage','CAO cashout') and internallegalentity not in ('RWEST CZ')
			GROUP BY OrderNo, o.[DealID_Recon], ccy
			HAVING OrderNo Not In ('K06Z999','K06Z999U','K75Z1','K75Z1U','KL00002','KQP0001') AND abs(Sum(Diff_Volume))<1 And abs(Sum(Diff_CCY))<1) as sql
	on r.[dealid_recon] = sql.[dealid_recon] and r.orderno = sql.orderno and r.ccy = sql.ccy



--- 2nd query based on orderno, dealID_recon, ccy, recongroup

insert into dbo.recon_offsets ([Identifier] ,[InternalLegalEntity] ,[Desk] ,[Subdesk] ,[ExternalBusinessUnit] ,[SAP_DocumentNumber] ,[ReconGroup],[OrderNo]
		,[DeliveryMonth] ,[DealID_Recon] ,[Account] ,[ccy] ,[Diff_Volume] ,[Diff_Realised_CCY] ,[comment] ,[EventDate], [source])
	select r.identifier, r.InternalLegalEntity, r.Desk, r.Subdesk, r.ExternalBusinessUnit, r.SAP_DocumentNumber, r.ReconGroup,
		r.OrderNo,  r.DeliveryMonth, r.DealID_Recon, r.Account, r.ccy, r.Diff_Volume, r.Diff_CCY, sql.comment, r.eventdate, 'query2'
	from recon_diff r
	inner join 
		(SELECT OrderNo, o.[DealID_Recon], ccy, case when abs(sum(diff_deskccy))+abs(sum(diff_eur))<2 then 'offsetting' else 'FX conversion' end as comment, ReconGroup	
		FROM dbo.[Recon_Diff] o
		where recongroup not in ('FX','Brokerage','CAO cashout')  and internallegalentity not in ('RWEST CZ') 
		GROUP BY OrderNo, o.[DealID_Recon], ccy, ReconGroup	
		HAVING OrderNo Not In ('K06Z999','K06Z999U','K75Z1','K75Z1U','KL00002','KQP0001') AND abs(Sum(Diff_Volume))<1  And abs(Sum(Diff_CCY))<1) as sql
	on  r.[dealid_recon] = sql.[dealid_recon]  and r.orderno = sql.orderno and r.ccy = sql.ccy and r.recongroup = sql.recongroup 

--- 3rd query based on orderno, dealID_recon, ccy, deliverymonth

insert into dbo.recon_offsets ([Identifier] ,[InternalLegalEntity] ,[Desk] ,[Subdesk] ,[ExternalBusinessUnit] ,[SAP_DocumentNumber] ,[ReconGroup],[OrderNo]
		,[DeliveryMonth] ,[DealID_Recon] ,[Account] ,[ccy] ,[Diff_Volume] ,[Diff_Realised_CCY] ,[comment] ,[EventDate], [source])
	select r.identifier, r.InternalLegalEntity, r.Desk, r.Subdesk, r.ExternalBusinessUnit, r.SAP_DocumentNumber, r.ReconGroup,
		r.OrderNo,  r.DeliveryMonth, r.DealID_Recon, r.Account, r.ccy, r.Diff_Volume, r.Diff_CCY, sql.comment, r.eventdate, 'query3'
	from recon_diff r 
	inner join
	(SELECT OrderNo, o.[DealID_Recon], ccy, deliverymonth, case when abs(sum(diff_deskccy))+abs(sum(diff_eur))<2 then 'offsetting' else 'FX conversion' end as comment
	FROM dbo.[Recon_Diff] o
		where recongroup not in ('FX','Brokerage','CAO cashout') and internallegalentity not in ('RWEST CZ')
		GROUP BY OrderNo, o.[DealID_Recon], ccy, deliverymonth
		HAVING OrderNo Not In ('K06Z999','K06Z999U','K75Z1','K75Z1U','KL00002','KQP0001') AND abs(Sum(Diff_Volume))<1  And abs(Sum(Diff_CCY))<1) as sql
	on r.[dealid_recon] = sql.[dealid_recon] and r.orderno = sql.orderno and r.ccy = sql.ccy and r.deliverymonth = sql.deliverymonth

--- 4th query based on orderno, dealID_recon, ccy, deliverymonth, recongroup
insert into dbo.recon_offsets ([Identifier] ,[InternalLegalEntity] ,[Desk] ,[Subdesk] ,[ExternalBusinessUnit] ,[SAP_DocumentNumber] ,[ReconGroup],[OrderNo]
		,[DeliveryMonth] ,[DealID_Recon] ,[Account] ,[ccy] ,[Diff_Volume] ,[Diff_Realised_CCY] ,[comment] ,[EventDate], [source])
	select r.identifier, r.InternalLegalEntity, r.Desk, r.Subdesk, r.ExternalBusinessUnit, r.SAP_DocumentNumber, r.ReconGroup,
		r.OrderNo,  r.DeliveryMonth, r.DealID_Recon, r.Account, r.ccy, r.Diff_Volume, r.Diff_CCY, sql.comment, r.eventdate, 'query4'
	from recon_diff r 
	inner join
	(SELECT OrderNo, o.[DealID_Recon], ccy, deliverymonth, case when abs(sum(diff_deskccy))+abs(sum(diff_eur))<2 then 'offsetting' else 'FX conversion' end as comment, recongroup
		FROM dbo.[Recon_Diff] o
		where recongroup not in ('FX','Brokerage','CAO cashout') and internallegalentity not in ('RWEST CZ')
		GROUP BY OrderNo, o.[DealID_Recon], ccy, deliverymonth, recongroup
		HAVING OrderNo Not In ('K06Z999','K06Z999U','K75Z1','K75Z1U','KL00002','KQP0001') AND abs(Sum(Diff_Volume))<1 And abs(Sum(Diff_CCY))<1) as sql
	on r.[dealid_recon] = sql.[dealid_recon] and r.orderno = sql.orderno and r.ccy = sql.ccy and r.deliverymonth = sql.deliverymonth and r.recongroup =sql.recongroup
	
--- 5th query based on orderno, dealID, ccy, recongroup
insert into dbo.recon_offsets ([Identifier] ,[InternalLegalEntity] ,[Desk] ,[Subdesk] ,[ExternalBusinessUnit] ,[SAP_DocumentNumber] ,[ReconGroup],[OrderNo]
		,[DeliveryMonth] ,[DealID_Recon] ,[Account] ,[ccy] ,[Diff_Volume] ,[Diff_Realised_CCY] ,[comment] ,[EventDate], [source])
	select r.identifier, r.InternalLegalEntity, r.Desk, r.Subdesk, r.ExternalBusinessUnit, r.SAP_DocumentNumber, r.ReconGroup,
		r.OrderNo,  r.DeliveryMonth, r.DealID_Recon, r.Account, r.ccy, r.Diff_Volume, r.Diff_CCY, sql.comment, r.eventdate, 'query5'
	from recon_diff_uk r 
	inner join
	(SELECT OrderNo, o.[DealID], ccy, case when abs(sum(diff_deskccy))+abs(sum(diff_eur))<2 then 'offsetting' else 'FX conversion' end as comment, recongroup
		FROM dbo.[Recon_Diff_UK] o
		where recongroup not in ('FX','Brokerage','CAO cashout') and internallegalentity not in ('RWEST CZ') 
		GROUP BY OrderNo, o.[DealID], ccy, recongroup
		HAVING OrderNo Not In ('K06Z999','K06Z999U','K75Z1','K75Z1U','KL00002','KQP0001') AND abs(Sum(Diff_Volume))<1 And abs(Sum(Diff_CCY))<1 And abs(Sum(Diff_CCY))>0) as sql
	on r.[dealid] = sql.[dealid] and r.orderno = sql.orderno and r.ccy = sql.ccy  and r.recongroup =sql.recongroup
	

END TRY

	BEGIN CATCH
		--insert into [dbo].[Logfile] select 'ERROR-OCCURED', @TimeStamp
		EXEC [dbo].[usp_GetErrorInfo] '[dbo].[Reconciliation_offsets]', 1
	END CATCH

GO

