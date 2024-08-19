

CREATE view [dbo].[view_HA_check] as
SELECT 
	view_HA_check_prep.Reference_ID
	,view_HA_check_prep.Trade_Date
	,view_HA_check_prep.Term_Start
	,view_HA_check_prep.Term_End
	,view_HA_check_prep.Internal_Portfolio
	,view_HA_check_prep.Counterparty_Group
	,view_HA_check_prep.Volume
	,view_HA_check_prep.Curve_Name
	,view_HA_check_prep.Projection_Index_Group
	,view_HA_check_prep.Instrument_Type
	,view_HA_check_prep.Int_Bunit
	,view_HA_check_prep.Ext_Portfolio
	,view_HA_check_prep.discounted_pnl
	,CASE WHEN internal_portfolio LIKE 'SO DE DMA%' THEN  'SO DE'ELSE view_HA_check_prep.Strategy END AS Strategy
	,view_HA_check_prep.Subsidiary
	,view_HA_check_prep.Accounting_Treatment
	,ISNULL(summe_von_perc_included, 0) AS Perc_Used
	,Sum(view_HA_check_prep.volume * (1 - isnull(summe_von_perc_included, 0))) AS free_volume
	,view_HA_check_prep.Discounted_PNL * (1 - isnull(summe_von_perc_included, 0)) AS free_mtm
	,CASE WHEN accounting_Treatment = 'Hedged Items' 
				THEN CASE WHEN view_HA_check_prep.Volume < 0 THEN 'pos' ELSE 'neg' END 
				ELSE CASE WHEN view_HA_check_prep.Volume > 0 THEN 'pos' ELSE 'neg'END 
		END AS Vorzeichen_Volume
	,table_HA_map_Curve_GROUP.GROUP_name as Emissions_curve
FROM 
	dbo.view_HA_check_prep LEFT JOIN (	SELECT Ref_Deal_ID, Sum(Volume) AS Volume, Sum(Allocated_Volume) AS Allocated_Volume, 
																				Sum(allocated_volume/volume) AS Summe_von_Perc_Included
																			FROM dbo.table_HA_Hedging_Relationships 
																			WHERE Volume<>0
																			GROUP BY Ref_Deal_ID
																	) as check_zw2
		ON view_HA_check_prep.Reference_ID = check_zw2.Ref_Deal_ID
		LEFT JOIN dbo.table_HA_map_Curve_GROUP
		ON dbo.view_HA_check_prep.Curve_Name = dbo.table_HA_map_Curve_GROUP.curve_name
WHERE
(
		Projection_Index_Group in('Natural Gas','Coal')
		AND Subsidiary = 'RWEST UK'		
		AND Accounting_Treatment in ('Hedging Instrument (Der)', 'Hedged Items')			
		AND isnull(summe_von_perc_included, 0) < 1				
		)
	OR	
	(
		Internal_Portfolio NOT IN ('SO DE WC CARBON')
		AND view_HA_check_prep.Subsidiary = 'RWEST DE'
		AND Accounting_Treatment in ('Hedging Instrument (Der)','Hedged Items')
		AND isnull(summe_von_perc_included, 0) < 1
	)
GROUP BY 
	 Reference_ID
	,Trade_Date
	,Term_Start
	,Term_End
	,Internal_Portfolio
	,Counterparty_Group
	,view_HA_check_prep.Volume
	,view_HA_check_prep.Curve_Name
	,Projection_Index_Group
	,Instrument_Type
	,Int_Bunit
	,Ext_Portfolio
	,discounted_pnl
	,case when internal_portfolio LIKE 'SO DE DMA%' THEN 'SO DE'ELSE Strategy END
	,Subsidiary
	,Accounting_Treatment
	,isnull(summe_von_perc_included, 0)
	,CASE WHEN accounting_Treatment = 'Hedged Items' 
				THEN CASE WHEN view_HA_check_prep.Volume < 0 THEN 'pos' ELSE 'neg' END 
				ELSE CASE WHEN view_HA_check_prep.Volume > 0 THEN 'pos' ELSE 'neg'END 
		END 
	,GROUP_name

GO

