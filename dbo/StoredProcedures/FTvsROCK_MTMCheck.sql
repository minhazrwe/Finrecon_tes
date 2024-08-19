
/*
============================================================================================================================================
created:	2022-09, MKB
purpose:	some queries to generate the detailed differences that are needed for the aggregated view to do the mtm check of ft vs rock
=====================================
changes: (when, who, what):
2024-01-25, mkb, step 30, removed duplicate filter criteria
2024-05-09, mkb, step 26, replaced a general filter condition by three more specific ones as it filtered out too much
============================================================================================================================================
*/

CREATE PROCEDURE [dbo].[FTvsROCK_MTMCheck]
AS
BEGIN TRY

		DECLARE @step integer
		DECLARE @LogInfo Integer
		declare @COB_MTM as date
		
		
		DECLARE @record_counter as int
		DECLARE @Status_Text as varchar(100)	 	
		DECLARE @Current_Procedure nvarchar(50)


		declare @q int=1		/*helper variable to work with quarters of a year*/
 
		select @step = 1
		select @Current_Procedure = Object_Name(@@PROCID)
			
		/*--identify the COB that the mtm_check should be done for*/	
		select @step = 2
		select @COB_MTM = AsOfDate_MtM_Check from dbo.AsOfDate
			 
		/*-- write log that import starts*/
		select @step = 4
		EXEC dbo.Write_Log 'Info', 'START', @Current_Procedure, NULL, NULL, @step, 1 


		/* InsTypes GAS-FUT-AVG-EXCH-P/F get additionally loaded from a separate file ("Fin_MtM_GAS-FUT-AVG-EXCH_All_desks.txt", ID 3122)
			 therefore all records for these instypes from other files need to be deleted before proceeding	*/
		select @step = 6
			if @LogInfo >= 1  BEGIN insert into [dbo].[Logfile] select @Current_Procedure + ' - cleanup InsTypes GAS-FUT-AVG-EXCH-P and -F', GETDATE () END											
			DELETE 
				FROM [dbo].[table_FTvsROCK_ROCKData] 
			WHERE 
				InstrumentType LIKE 'GAS-FUT-AVG-EXCH-%'
				AND FileID <> 3122 
							 			 
		/*prepare data merge*/
		select @step = 10
		EXEC dbo.Write_Log 'Info', 'Combine data from ROCK and FT', @Current_Procedure, NULL, NULL, @step, 1 

		DROP TABLE IF EXISTS [dbo].[table_FTvsROCK_CombinedData]


		/*combine data from ROCK and FT in one data table, enriched by information from mapping tables*/
		/*here we can use the * as field selector, as the neeeded fields and their order are explicitely specified in the subselects!*/
		select @step = 11				
		SELECT 
			subsql.*   
		INTO 
			[dbo].[table_FTvsROCK_CombinedData] 
		FROM 
			(
				SELECT
					cob
					,dbo.map_order.LegalEntity as subsidiary
					,dbo.map_order.desk as strategy
					,TradeDealNumber
					,InternalPortfolio
					,ExternalPortfolio
					,table_FTvsROCK_ROCKData.InstrumentType
					,null as Product
					,CASE WHEN CDM = 'CDM_FUT' THEN eomonth(CashflowDeliveryMonth) ELSE eomonth(LegEndDate) END AS TermEnd
					,isnull([UnrealisedDiscounted],0)+ case when CDM = 'CDM_OPT' OR table_FTvsROCK_ROCKData.InstrumentType = 'GAS-STOR-P' THEN 0 ELSE isnull([RealisedDiscounted],0) END as ROCK
					,0 AS FASTracker
					,'ROCK' as Datasource
				FROM 
					dbo.table_FTvsROCK_ROCKData
					LEFT JOIN dbo.map_instype	ON dbo.table_FTvsROCK_ROCKData.InstrumentType = dbo.map_instype.InstrumentType
					left join dbo.map_order on dbo.table_FTvsROCK_ROCKData.InternalPortfolio = dbo.map_order.Portfolio 
				WHERE 
						(
							CDM is null AND LegEndDate > COB 
						)
						OR  
						(
							CDM is not null AND  CashflowDeliveryMonth>COB
						)
				UNION ALL 	
					SELECT 
						 COB
						,Subsidiary
						,Strategy
						,ReferenceID
						,InternalPortfolio
						,NULL AS ExternalPortfolio
						,InstrumentType
						,Product			
						,TermEnd
						,0 as ROCK
						,isnull(DiscountedPNL,0) as Fastracker
						,'FT' as Datasource
					FROM 
						[dbo].[table_FTvsROCK_FastrackerData]
				) as subsql


			select @step = 20
			EXEC dbo.Write_Log 'Info', 'Identify differences en detail', @Current_Procedure, NULL, NULL, @step, 1 
			
			/*create and fill helper table for specific quarter based date formats (filled depending on the quarter we're in)*/
			DROP TABLE IF EXISTS dbo.tmp_quarter
			
						
			while @q <= cast(datepart(q,@COB_MTM) as varchar)
			BEGIN				
				IF @q=1		
					select 'Q_'+ cast(@q as varchar)+ format (@COB_MTM, '/yy') as tmp_value into dbo.tmp_quarter
				ELSE
					insert into dbo.tmp_quarter select 'Q_'+ cast(@q as varchar)+ format (@COB_MTM, '/yy')

				insert into dbo.tmp_quarter select 'Q'+ cast(@q as varchar)+ format (@COB_MTM, '-yy')
				set @q = @q+1
			END

			select @step = 25
			truncate table dbo.table_FTvsROCK_DifferencesDetail
			
			select @step = 26
			insert into dbo.table_FTvsROCK_DifferencesDetail
				(
					 COB
					,Subsidiary
					,Strategy
					,TradeDealNumber
					,InternalPortfolio
					,ExternalPortfolio
					,InstrumentType
					,Product
					,TermEnd
					,ROCK
					,FASTracker
					,DiffRounded
					,AbsDiffRounded
				)
				SELECT 
					COB
					,Max(subsidiary) AS Subsidiary
					,Max(Strategy) AS Strategy
					,TradeDealNumber
					,Max(InternalPortfolio) AS InternalPortfolio
					,Max(ExternalPortfolio) AS ExternalPortfolio
					,Max(InstrumentType) AS InstrumentType
					,Max(Product) AS Product
					,TermEnd
					,Sum(ROCK) AS ROCK
					,Sum(FASTracker) AS FASTracker
					,Round(Sum(ROCK - FASTracker), 2) AS DiffRounded
					,Round(Abs(Sum(ROCK - FASTracker)), 2) AS AbsDiffRounded
				FROM 
					dbo.table_FTvsROCK_CombinedData
				WHERE 	
							(Year(termend) * 100 + Month(termend)) > (year(cob) * 100 + month(cob))			--in case COB is not at the very last day of month ...
					AND InternalPortfolio NOT LIKE '%EDGW%'
					AND InternalPortfolio Not like 'GEN_UK%' /* Portfolien betreffen Generation UK und werden nicht benötigt, laut UK (April Xin),YK */
					
					AND InternalPortfolio Not IN ('SNV_COM_OPTION','SNV_COM_OPTION_COUNTERPARTY') /* Test-Portfolien, werden nicht reportet, YK */
					AND InternalPortfolio Not IN ('RGM_D_PM_STORAGE_UK','RGM_D_PM_STORAGE_UK_EPM') /* NICHT relevant für MTM-Check. Beinhaltet Sleeve-Deals, welche sich nahezu auf 0 ausgleichen. Die Desk-Verantwortlichen erhalten die ROCK-Werte aus anderen Quellen, sollte die Differenz > 1 Mio. sein, würde ein MTM-Upload in FASTracker erfolgen, YK.  */
					AND Subsidiary <> 'RWE GENERATION UK LE' /* Handelt sich um Generation, werden nicht benötigt, s.o., YK*/
					AND InstrumentType NOT LIKE 'CASH'					
					AND InstrumentType NOT LIKE 'WTH%' /* got excluded as existing FT data should not be overwritten*/				
					AND InstrumentType NOT LIKE 'IRS' /*excluded by order of VP+YK on 2024/01/02, mkb*/

				GROUP BY 	
					COB, 
					TradeDealNumber
					,TermEnd
				HAVING 
					Round(Abs(Sum(ROCK - FASTracker)), 2) > 1
					AND
					(
							Max(Product) IS NULL
						OR 						
								Max(Product) LIKE	'%'+upper(format (@COB_MTM, 'MMM-yy'))
						OR
						(
			   					Max(Product) NOT LIKE '%CAL' + format (@COB_MTM, '-yy')
							AND Max(Product) NOT LIKE 'F8BY_' + format (@COB_MTM, 'yyyy')
							AND Max(Product) NOT LIKE 'G1BY_' + format (@COB_MTM, 'yyyy')
							AND Max(Product) NOT LIKE '%y_' + format (@COB_MTM, 'yyyy')
							AND Max(Product) NOT LIKE '%YR-' + format (@COB_MTM, 'yy')
							AND Max(Product) NOT in (select distinct * from dbo.tmp_quarter)
							/*AND Max(Product) NOT LIKE '%y-' + format (@COB_MTM, 'yy')  replaced 2025-05-09 by the next three lines, as it filtered out too many.*/
							AND Max(Product) NOT LIKE 'FDBY%y-' + format (@COB_MTM, 'yy')
							AND Max(Product) NOT LIKE 'DEBY%y-' + format (@COB_MTM, 'yy')
							AND Max(Product) NOT LIKE 'DEPY%y-' + format (@COB_MTM, 'yy')
						)
					)			

			select @step = 30
			EXEC dbo.Write_Log 'Info', 'Remove adjustments from detailed list', @Current_Procedure, NULL, NULL, @step, 1 
			
			/*remove any "deal" that is in fact an adjustment*/
			delete from dbo.table_FTvsROCK_DifferencesDetail 
			where 
				   TradeDealNumber like 'JBB%'
				or TradeDealNumber like 'JCT%'
				or TradeDealNumber like 'RWEST%'
				or TradeDealNumber like '%CAOGas%'
				or TradeDealNumber LIKE '%_sc'
				or TradeDealNumber LIKE '%_tc'
				or TradeDealNumber LIKE '%_strc'
				or TradeDealNumber LIKE '%adj%'
				or TradeDealNumber LIKE 'DE_Gas_Hedge%'
							 
		/*============ done with it all ===================================================================================*/			

		/*NoFurtherAction, so tell the world we're done, but inform about potential warnings.*/
		SELECT @step = 50
		SET @Status_Text = 'FINISHED'
		EXEC dbo.Write_Log 'Info', @Status_Text, @Current_Procedure, NULL, NULL, @step, 1 
	
		Return 0
END TRY

BEGIN CATCH
	/*tell the world procedure failed*/
	EXEC [dbo].[usp_GetErrorInfo] @Current_Procedure, @step, NULL; 
	EXEC dbo.Write_Log 'FAILED', 'FAILED with error, check log for details', @Current_Procedure, NULL, NULL, @step, 1;
	Return @step
END CATCH

GO

