
create view dbo.RACE525_Sheet as select * from (select Kons, [RACE-Pos#], produkt, Sachkonto,Kontentext, Partner, [Wert in HW], Menge, ME, 'Einzel' as [Signal] from FinRecon.dbo.RACE525
union all
select Kons, [RACE-Pos#], produkt, Sachkonto,Kontentext, [Partner], sum([Wert in HW]), sum(Menge), ME , 'Summe' as [Signal]
from FinRecon.dbo.RACE525 group by Kons, [RACE-Pos#], produkt, Sachkonto,Kontentext, [Partner], ME ) as ff

GO

