















--
--Erstellt von MU für einen GPM Test mit Jan Sporing (2023-08-30)
CREATE view [dbo].[view_GPM_Unrealised_SAP] as
--Jan_Sporing_GPM_Unrealised_SAP



Select 
Query_Source
,result.InternalLegalEntity
,result.Desk
,result.Subdesk
,InternalPortfolio
,InstrumetType
,'' AS [External_Business_Unit]
,DocumentNumber
,Doc_In_Reverse_Engineering
,DocumentType
,[Text]
,Reference
,Account
,PostingDate
,EntryDate
,result.DealID_Recon
,DealID
,'MTM' as ReconGroup
,ytd_mtm_finance_PNL_EUR
,unrealised_EUR_SAP_PNL
,unrealised_EUR_SAP_conv_PNL
,Diff_PNL_EUR
,Volume
,0 AS risk_mtm_EOM_EUR
,0 AS risk_mtm_EOY_EUR
,0 AS risk_realised_disc_repEUR
,0 AS risk_PNL_EUR
,'' AS Category
,'' AS [Opening_Closing]
from
(
SELECT  'Unrealised_SAP' as Query_Source
		,SAP.InternalLegalEntity
		,SAP.Desk
        ,SAP.Subdesk
        ,SAP.Portfolio AS InternalPortfolio
        ,SAP.InstrumetType
        ,SAP.[source]
		,DocumentNumber
--		,Case when DocumentNumber in (Select Document_Number from [zzz_table_Jan_Spring_GPM_Reverse_Engineering]) then '1' else '0' end  as  Doc_In_Reverse_Engineering
        ,Case when reverse_engineering.Document_Number is null then '0' else '1' end  as  Doc_In_Reverse_Engineering
		,DocumentType
		,[Text]
		,Reference
		,SAP.Account
		,PostingDate
		,EntryDate
		,rtrim(case when (([SAP].[DocumentType] In ('RZ','WN','KN','DR','DG','AB','RN','ZM', 'ZA', 'AZ') 
						or (desk = 'Industrial Sales' and left([sap].[text],1) not in (',',';')))
									and ([sap].[text] not like 'ACC%' 
											and [sap].[text] not like 'Schätz%' 
											and [sap].[text] not like 'Abgrenzung%' 
											--and ([sap].[Reference] not like '%SCHÄTZ%' 
													--or [sap].[Reference] is null
													--)
											)
									)  
									or [recon_group] = 'Exchanges' 
							then dbo.[udf_SplitData](Replace([SAP].[Text] + ',', ',', ';'), 1) 
							else case when  [SAP].[Text] Like '%;%FUT%' 
															Or [SAP].[Text] Like '%,%Fut%' 
												then dbo.[udf_SplitData](Replace([SAP].[Text] + ',', ',', ';'), 1) 
												else case when [SAP].[TEXT] is NULL 
																	then '' 
																	else [SAP].[TEXT] 
																	end 
												end 
							end
				) 
			+ case when Desk in ('COAL AND FREIGHT DESK') AND  material = '10145238' then '_HandlingFees' else '' end
			+ case when Desk in ('COAL AND FREIGHT DESK','BIOFUELS DESK') AND  material = '10148926' then '_Demurrage' else '' end
			+ case when Desk in ('COAL AND FREIGHT DESK','BIOFUELSDESK') AND  material = '10063028' then '_Despatch' else '' end
			AS DealID_Recon

	,rtrim(case when ([SAP].[DocumentType] In ('RZ','WN','KN','DR','DG','AB','RN') and [sap].[text] not like 'ACC%') or  [recon_group] = 'Exchanges' then dbo.[udf_SplitData](Replace([SAP].[Text] + ',', ',', ';'), 1) else
			case when  [SAP].[Text] Like '%;%FUT%' Or [SAP].[Text] Like '%,%Fut%' then dbo.[udf_SplitData](Replace([SAP].[Text] + ',', ',', ';'), 1) else 
			case when [SAP].[TEXT] is NULL then '' else [SAP].[TEXT] end end end) AS Dealid
		,- sum(SAP.unrealised_EUR_SAP_conv_PNL) AS Diff_PNL_EUR
        ,- sum(SAP.unrealised_EUR_SAP_conv_NOR) AS Diff_NOR_EUR
        ,sum(SAP.unrealised_EUR_SAP_PNL) AS unrealised_EUR_SAP_PNL
        ,sum(SAP.unrealised_ccy_SAP_PNL) AS unrealised_ccy_SAP_PNL
        ,sum(SAP.unrealised_Deskccy_SAP_PNL) AS unrealised_Deskccy_SAP_PNL
        ,sum(SAP.unrealised_EUR_SAP_conv_PNL) AS unrealised_EUR_SAP_conv_PNL
        ,sum(SAP.unrealised_EUR_SAP_NOR) AS unrealised_EUR_SAP_NOR
        ,sum(SAP.unrealised_ccy_SAP_NOR) AS unrealised_ccy_SAP_NOR
        ,sum(SAP.unrealised_Deskccy_SAP_NOR) AS unrealised_Deskccy_SAP_NOR
        ,sum(SAP.unrealised_EUR_SAP_conv_NOR) AS unrealised_EUR_SAP_conv_NOR
        ,sum(SAP.Volume_SAP) AS Volume
        ,0 AS ytd_mtm_finance_total_EUR
        ,0 AS ytd_mtm_finance_OCI_EUR
        ,0 AS ytd_mtm_finance_PNL_EUR
        ,0 AS ytd_mtm_finance_OU_EUR
        ,0 AS ytd_mtm_finance_NOR_EUR
        ,0 AS ytd_mtm_finance_total_DeskCCY
        ,0 AS ytd_mtm_finance_OCI_DeskCCY
        ,0 AS ytd_mtm_finance_PNL_DeskCCY
        ,0 AS ytd_mtm_finance_OU_DeskCCY
        ,0 AS ytd_mtm_finance_NOR_DeskCCY
FROM (
        SELECT   [00_map_order].LegalEntity AS InternalLegalEntity
				,[00_map_order].[Desk] AS Desk
                ,[00_map_order].[Subdesk] AS Subdesk
                ,[00_map_order].[MaxvonPortfolio] AS Portfolio
				,DocumentNumber
				,DocumentType
				,[Text]
				,Reference
				,SAP.Account
				,PostingDate
				,EntryDate
				,[map_ReconGroupAccount].[recon_group]
				,Material
				,SAP.Quantity as Volume
                ,rtrim(CASE 
                                WHEN [SAP].[DocumentType] IN (
                                                'RZ'
                                                ,'WN'
                                                ,'KN'
                                                )
                                        THEN dbo.[udf_SplitData]([SAP].[Text], 3)
                                ELSE CASE 
                                                WHEN (
                                                                [SAP].[DocumentType] IN (
                                                                        'AB'
                                                                        ,'RN'
                                                                        ,'ZM'
                                                                        ,'ZA'
                                                                        ,'AZ'
                                                                        )
                                                                OR desk = 'Industrial Sales'
                                                                )
                                                        AND (
                                                                Replace([Text] + ',', ',', ';') LIKE '%;%;%;%'
                                                                OR [SAP].[Text] LIKE '%;%FUT%'
                                                                OR [SAP].[Text] LIKE '%,%Fut%'
                                                                )
                                                        THEN dbo.[udf_SplitData]([SAP].[Text], 3)
                                                ELSE CASE 
                                                                WHEN [SAP].[TEXT] IS NULL
                                                                        THEN ''
                                                                ELSE [SAP].[TEXT]
                                                                END + CASE 
                                                                WHEN [SAP].[Account] IS NULL
                                                                        THEN ''
                                                                ELSE [SAP].[Account]
                                                                END
                                                END
                                END) AS InstrumetType
                ,'sap_blank' AS [source]
                ,CASE 
                        WHEN dbo.sap.LocalCurrency = 'EUR'
                                AND dbo.SAP.Account <> 'I5999900'
                                THEN dbo.[udf_NZ_FLOAT]((([SAP].[Amountinlocalcurrency]) * - 1))
                        ELSE CASE 
                                        WHEN dbo.SAP.Account <> 'I5999900'
                                                THEN dbo.[udf_NZ_FLOAT]((([SAP].[Amountinlocalcurrency]) * - 1)) / fx4.Rate
                                        ELSE 0
                                        END
                        END AS unrealised_EUR_SAP_PNL
                ,CASE 
                        WHEN dbo.SAP.Account <> 'I5999900'
                                THEN dbo.[udf_NZ_FLOAT]((([SAP].[Amountindoccurr]) * - 1))
                        ELSE 0
                        END AS unrealised_ccy_SAP_PNL
                ,CASE 
                        WHEN dbo.SAP.Account <> 'I5999900'
                                THEN dbo.[udf_NZ_FLOAT]((([SAP].[Amountindoccurr]) * - 1)) / fx1.RateRisk * fx2.rateRisk
                        ELSE 0
                        END AS unrealised_Deskccy_SAP_PNL
                ,CASE 
                        WHEN dbo.SAP.Account <> 'I5999900'
                                THEN dbo.[udf_NZ_FLOAT]((([SAP].[Amountindoccurr]) * - 1) / fx1.raterisk)
                        ELSE 0
                        END AS unrealised_EUR_SAP_conv_PNL
                ,CASE 
                        WHEN dbo.sap.LocalCurrency = 'EUR'
                                AND dbo.SAP.Account = 'I5999900'
                                THEN dbo.[udf_NZ_FLOAT]((([SAP].[Amountinlocalcurrency]) * - 1))
                        ELSE CASE 
                                        WHEN dbo.SAP.Account = 'I5999900'
                                                THEN dbo.[udf_NZ_FLOAT]((([SAP].[Amountinlocalcurrency]) * - 1)) / fx4.Rate
                                        ELSE 0
                                        END
                        END AS unrealised_EUR_SAP_NOR
                ,CASE 
                        WHEN dbo.SAP.Account = 'I5999900'
                                THEN dbo.[udf_NZ_FLOAT]((([SAP].[Amountindoccurr]) * - 1))
                        ELSE 0
                        END AS unrealised_ccy_SAP_NOR
                ,CASE 
                        WHEN dbo.SAP.Account = 'I5999900'
                                THEN dbo.[udf_NZ_FLOAT]((([SAP].[Amountindoccurr]) * - 1)) / fx1.RateRisk * fx2.rateRisk
                        ELSE 0
                        END AS unrealised_Deskccy_SAP_NOR
                ,CASE 
                        WHEN dbo.SAP.Account = 'I5999900'
                                THEN dbo.[udf_NZ_FLOAT]((([SAP].[Amountindoccurr]) * - 1) / fx1.raterisk)
                        ELSE 0
                        END AS unrealised_EUR_SAP_conv_NOR
                ,dbo.[udf_NZ_FLOAT]((
                                CASE 
                                        WHEN (
                                                        [SAP].[BaseUnitofMeasure] IN (
                                                                'ST'
                                                                ,'PC'
                                                                )
                                                        AND [SAP].[Account] NOT IN (
                                                                '4008008'
                                                                ,'4008005'
                                                                ,'4006143'
                                                                ,'6016757'
                                                                ,'6010058'
                                                                ,'6010143'
                                                                ,'4006065'
                                                                ,'6010065'
                                                                ,'6010067'
                                                                ,'4008112'
                                                                ,'6010112'
                                                                )
                                                        )
                                                THEN 0
                                        ELSE [SAP].[Quantity] * CASE 
                                                        WHEN [map_UOM_conversion].[CONV] IS NULL
                                                                THEN 1
                                                        ELSE [map_UOM_conversion].[CONV]
                                                        END
                                        END
                                )) AS Volume_SAP
        FROM (
                (
                        (
                                (
                                        (
                                                (
                                                        [SAP] LEFT JOIN [map_UOM_conversion] ON [SAP].[BaseUnitofMeasure] = [map_UOM_conversion].[UNIT_FROM]
                                                        ) LEFT JOIN [map_ReconGroupAccount] ON [SAP].[Account] = [map_ReconGroupAccount].[Account]

                                                ) LEFT JOIN [00_map_order] ON (
                                                        CASE 
                                                                WHEN [SAP].[Order] IS NULL
                                                                        THEN ''
                                                                ELSE [SAP].[Order]
                                                                END
                                                        ) = [00_map_order].[OrderNo]
                                        ) LEFT JOIN dbo.FXRates fx1 ON dbo.sap.Documentcurrency = fx1.Currency
                                ) LEFT JOIN dbo.FXRates fx2 ON CASE 
                                        WHEN (
                                                        [00_map_order].repccy IS NULL
                                                        OR [00_map_order].repccy = ''
                                                        )
                                                THEN [00_map_order].SubDeskCCY
                                        ELSE [00_map_order].repccy
                                        END = fx2.Currency
                        ) LEFT JOIN dbo.FXRates fx3 ON dbo.[sap].LocalCurrency = fx3.Currency
                )
        LEFT JOIN (
                SELECT currency
                        ,sum(rate) / count(deliverymonth) AS rate
                FROM dbo.fxrate
                        ,dbo.AsOfDate
                WHERE left(deliverymonth, 4) = year(dbo.asofdate.AsOfDate_EOM)
                GROUP BY currency
                ) fx4 ON dbo.sap.LocalCurrency = fx4.currency
        WHERE [recon_group] = 'MtM'
                AND (
                        dbo.SAP.Account LIKE 'I5%'
                        OR dbo.SAP.Account LIKE 'I6%'
                        OR dbo.SAP.Account LIKE 'I7%'
                        )
				AND Desk LIKE 'CAO G%'
        ) SAP
		LEFT join (Select distinct Document_Number from [table_GPM_Reverse_Engineering]) reverse_engineering 
		on SAP.DocumentNumber = reverse_engineering.Document_Number
GROUP BY SAP.InternalLegalEntity
		,SAP.Desk
        ,SAP.Subdesk
        ,SAP.Portfolio
        ,SAP.InstrumetType
        ,SAP.[source]
		,DocumentNumber
		,reverse_engineering.Document_Number
		,DocumentType
		,[Text]
		,Reference
		,SAP.Account
		,PostingDate
		,EntryDate
		,[recon_group]
		,Material

 

UNION ALL

 

SELECT  
		'Unrealised_Fastracker' as Query_Source
		,FT.InternalLegalEntity
        ,FT.Desk
        ,FT.Subdesk
        ,FT.InternalPortfolio AS InternalPortfolio
        ,FT.InstrumentType
        ,FT.[source]
		,'' as DocumentNumber
		,'0' as Doc_In_Reverse_Engineering
		,'' as DocumentType
		,'' as [Text]
		,'' as Reference
		,'' as Account
		,'' as PostingDate
		,'' as EntryDate
		,ReferenceID as DealID_Recon
		,ReferenceID as DealID
        ,sum([ytd_mtm_finance_PNL_EUR]) AS Diff_PNL_EUR
        ,sum([ytd_mtm_finance_NOR_EUR]) AS Diff_NOR_EUR
        ,0 AS unrealised_EUR_SAP_PNL
        ,0 AS unrealised_ccy_SAP_PNL
        ,0 AS unrealised_Deskccy_SAP_PNL
        ,0 AS unrealised_EUR_SAP_conv_PNL
        ,0 AS unrealised_EUR_SAP_NOR
        ,0 AS unrealised_ccy_SAP_NOR
        ,0 AS unrealised_Deskccy_SAP_NOR
        ,0 AS unrealised_EUR_SAP_conv_NOR
        ,sum(Volume) AS Volume
        ,sum(ytd_mtm_finance_total_EUR) AS ytd_mtm_finance_total_EUR
        ,sum([ytd_mtm_finance_OCI_EUR]) AS ytd_mtm_finance_OCI_EUR
        ,sum([ytd_mtm_finance_PNL_EUR]) AS ytd_mtm_finance_PNL_EUR
        ,sum([ytd_mtm_finance_OU_EUR]) AS ytd_mtm_finance_OU_EUR
        ,sum([ytd_mtm_finance_NOR_EUR]) AS ytd_mtm_finance_NOR_EUR
        ,sum(ytd_mtm_finance_total_DeskCCY) AS ytd_mtm_finance_total_DeskCCY
        ,sum([ytd_mtm_finance_OCI_DeskCCY]) AS ytd_mtm_finance_OCI_DeskCCY
        ,sum([ytd_mtm_finance_PNL_DeskCCY]) AS ytd_mtm_finance_PNL_DeskCCY
        ,sum([ytd_mtm_finance_OU_DeskCCY]) AS ytd_mtm_finance_OU_DeskCCY
        ,sum([ytd_mtm_finance_NOR_DeskCCY]) AS ytd_mtm_finance_NOR_DeskCCY
FROM (
         SELECT ft.internallegalentity
		,CASE 
                        WHEN (
                                        ft.internalportfolio IN (
                                                'NG_OPTION_DELTA_EUR'
                                                ,'NG_OPTION_XCOMM_EUR'
                                                ,'NG_VANILLA_OPTIONS_EUR'
                                                ,'NG_OPTION_DELTA_GBP'
                                                ,'NG_VANILLA_OPTIONS_GBP'
                                                )
                                        )
                                THEN 'GPG - Global Options'
                        ELSE ft.desk
                        END AS Desk
                ,CASE 
                        WHEN (
                                        ft.internalportfolio IN (
                                                'NG_OPTION_DELTA_EUR'
                                                ,'NG_OPTION_XCOMM_EUR'
                                                ,'NG_VANILLA_OPTIONS_EUR'
                                                ,'NG_OPTION_DELTA_GBP'
                                                ,'NG_VANILLA_OPTIONS_GBP'
                                                )
                                        )
                                THEN 'GLOBAL OPTIONS ' + ft.SubDeskCCY
                        ELSE ft.subdesk
                        END AS Subdesk
                ,ft.InternalPortfolio
                ,ft.[Instrumenttype] AS [InstrumentType]
				,ft.ReferenceID
				,sum(ft.Volume) as Volume
                ,sum(ytd_mtm_finance_total) AS ytd_mtm_finance_total_EUR
                ,sum([ytd_mtm_finance_OCI]) AS ytd_mtm_finance_OCI_EUR
                ,sum([ytd_mtm_finance_PNL]) AS ytd_mtm_finance_PNL_EUR
                ,sum([ytd_mtm_finance_OU]) AS ytd_mtm_finance_OU_EUR
                ,sum([ytd_mtm_finance_NOR]) AS ytd_mtm_finance_NOR_EUR
                ,sum(ytd_mtm_finance_total_DeskCCY) AS ytd_mtm_finance_total_DeskCCY
                ,sum([ytd_mtm_finance_OCI_DeskCCY]) AS ytd_mtm_finance_OCI_DeskCCY
                ,sum([ytd_mtm_finance_PNL_DeskCCY]) AS ytd_mtm_finance_PNL_DeskCCY
                ,sum([ytd_mtm_finance_OU_DeskCCY]) AS ytd_mtm_finance_OU_DeskCCY
                ,sum([ytd_mtm_finance_NOR_DeskCCY]) AS ytd_mtm_finance_NOR_DeskCCY
                ,'FASTracker' AS [source]
        FROM (
                SELECT   Subsidiary AS InternalLegalEntity
						,[Desk]
                        ,[Subdesk]
                        ,SubDeskCCY
                        ,[InternalPortfolio]
                        ,[InstrumentType]
						,ReferenceID
						,Volume
                        ,total_mtm AS ytd_mtm_finance_total
						,PNL AS ytd_mtm_finance_PNL
                        ,OCI AS ytd_mtm_finance_OCI
                        ,ou AS ytd_mtm_finance_OU
                        ,NOR AS ytd_mtm_finance_NOR
                        ,total_mtm_DeskCCY AS ytd_mtm_finance_total_DeskCCY
                        ,PNL_deskccy AS ytd_mtm_finance_PNL_DeskCCY
                        ,OCI_DeskCCY AS ytd_mtm_finance_OCI_DeskCCY
                        ,OU_DeskCCY AS ytd_mtm_finance_OU_DeskCCY
                        ,NOR_DeskCCY AS ytd_mtm_finance_NOR_DeskCCY
                FROM dbo.Fastracker_eom

                UNION ALL

                SELECT   Subsidiary AS InternalLegalEntity
						,[Desk]
                        ,[Subdesk]
                        ,SubDeskCCY
                        ,[InternalPortfolio]
                        ,[InstrumentType]
						,ReferenceID
						,Volume
                        ,- total_mtm AS ytd_mtm_finance_total
                        ,- PNL AS ytd_mtm_finance_PNL
                        ,- OCI AS ytd_mtm_finance_OCI
                        ,- ou AS ytd_mtm_finance_OU
                        ,- nor AS ytd_mtm_finance_nor
                        ,- total_mtm_DeskCCY AS ytd_mtm_finance_total_DeskCCY
                        ,- PNL_deskccy AS ytd_mtm_finance_PNL_DeskCCY
                        ,- OCI_DeskCCY AS ytd_mtm_finance_OCI_DeskCCY
                        ,- OU_DeskCCY AS ytd_mtm_finance_OU_DeskCCY
                        ,- nor_DeskCCY AS ytd_mtm_finance_nor_DeskCCY
                FROM dbo.Fastracker_eoy
                ) FT
        LEFT JOIN dbo.map_instrument i ON ft.instrumenttype = i.instrumenttype
                ,dbo.asofdate
		where Desk LIKE 'CAO G%'
        GROUP BY ft.InternalLegalEntity
		       ,CASE 
                        WHEN (
                                        ft.internalportfolio IN (
                                                'NG_OPTION_DELTA_EUR'
                                                ,'NG_OPTION_XCOMM_EUR'
                                                ,'NG_VANILLA_OPTIONS_EUR'
                                                ,'NG_OPTION_DELTA_GBP'
                                                ,'NG_VANILLA_OPTIONS_GBP'
                                                )
                                        )
                                THEN 'GPG - Global Options'
                        ELSE ft.desk
                        END
                ,CASE 
                        WHEN (
                                        ft.internalportfolio IN (
                                                'NG_OPTION_DELTA_EUR'
                                                ,'NG_OPTION_XCOMM_EUR'
                                                ,'NG_VANILLA_OPTIONS_EUR'
                                                ,'NG_OPTION_DELTA_GBP'
                                                ,'NG_VANILLA_OPTIONS_GBP'
                                                )
                                        )
                                THEN 'GLOBAL OPTIONS ' + ft.SubDeskCCY
                        ELSE ft.subdesk
                        END
                ,ft.InternalPortfolio
                ,ft.[Instrumenttype]
				,ft.ReferenceID
        ) FT
GROUP BY FT.InternalLegalEntity
        ,FT.Desk
        ,FT.Subdesk
        ,FT.InternalPortfolio
        ,FT.InstrumentType
        ,FT.[source]
		,FT.ReferenceID


		) result
		--left join (select Distinct Document_Number from [dbo].[zzz_table_Jan_Spring_GPM_Reverse_Engineering]) reverse_engineering
		--on result.DocumentNumber = reverse_engineering.Document_Number


		

union all

select 
'Unrealised_SAP_Reverse_Engineering' as Query_Source
,map_order.LegalEntity AS InternalLegalEntity
,map_order.Desk
,map_order.Subdesk
,table_GPM_Reverse_Engineering.Portfolio
,Instrument_Type
,[External_Business_Unit]
,Document_Number
,'2' as Doc_In_Reverse_Engineering
,'' as DocumentType
,'' as [Text]
,'' as Reference
,'' as Account
,''as PostingDate
,'' as EntryDate
,DealID_Recon
,'' as DealID
,ReconGroup as ReconGroup
,0 as ytd_mtm_finance_PNL_EUR
,Diff_EUR as unrealised_EUR_SAP_PNL
,Diff_EUR as unrealised_EUR_SAP_conv_PNL
,-Diff_EUR as Diff_PNL_EUR
,0 as Volume
,0 AS risk_mtm_EOM_EUR
,0 AS risk_mtm_EOY_EUR
,0 AS risk_realised_disc_repEUR
,0 AS risk_PNL_EUR
,Category
,[Opening_Closing]
from table_GPM_Reverse_Engineering 
left JOIN map_order ON table_GPM_Reverse_Engineering.Portfolio = map_order.Portfolio 
where Category IN ('MtM','CreditProvision')

GO

