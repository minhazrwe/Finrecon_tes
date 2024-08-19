/**/
--SELECT 
--    distinct c.id
--   ,pt.pt_name as CCY
--   ,trading_date 
--   ,fx.MEAN as rate    
--FROM 
--    SMART.CURVES c
--    inner join SMART.PRODUCT_TYPE pt on pt.pt_id = c.product_type_id
--    inner join smart.v12_price_curves fx on fx.curve_id = c.id
--    inner join SMART.DELIVERY_PERIOD dp on dp.id = c.delivery_period_id 
--WHERE 
--    fx.curve_id in (286420,275393)
--    and c.id not in (891)
--    and fx.validity>=0
--    and trading_date>current_date -150
--ORDER BY
--   trading_date 
--   ,pt_name


/*ecb-curves*/
create View dbo.View_FX_RATES_SMART as
SELECT 
   -- distinct c.id,
   pt.pt_name as CCY
   ,cast(trading_date as date) as COB
   ,fx.MEAN as FX_Rate_SMART
FROM 
    SMART1P..SMART.CURVES c
    inner join SMART1P..SMART.PRODUCT_TYPE pt on pt.pt_id = c.product_type_id
    inner join SMART1P..SMART.FX_RATES_SPOT fx on fx.curve_id = c.id
    inner join SMART1P..SMART.DELIVERY_PERIOD dp on dp.id = c.delivery_period_id 
WHERE 
    fx.curve_id in 
    (15071,41351,15072,15073,23757,23753,15074,15075,15076,15077,15078,15079,15080,15081,30755,23759,99216,15082,15083,15084,
        23752,15085,41352,15086,15087,23762,15088,15089,23755,15090,15091,15092,15093,15094,15095,15096,23764,15097,15098,15099
    )
    and c.id not in (891)
    and fx.validity>=0
    and trading_date> CURRENT_TIMESTAMP-50
--ORDER BY
--   trading_date 
--   ,pt_name
   


----select * from SMART1P..SMART.CURVES where ID = 20

GO

