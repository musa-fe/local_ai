CREATE TEMP FUNCTION city_normalize(city STRING)
 RETURNS STRING AS (TRIM(INITCAP(REGEXP_REPLACE(REGEXP_REPLACE(TRANSLATE(REGEXP_REPLACE(LOWER(city), 'i̇', 'i'),'çğöşü','cgosu'),'ı','i'),r'\s+',' '))))
 ;
 
 
 drop table if exists `hb-dagitim-gelistirme.kpi.time_differences_all_delta`;
 
 create table if not exists `hb-dagitim-gelistirme.kpi.time_differences_all_delta` partition by delivery_date cluster by cargocompany as
 select distinct a.deliveryid,
        a.cargocompany,
        a.platform,
        a.sender_code,
        b.merchant_name,
        a.sender_city,
        TRIM(INITCAP(REGEXP_REPLACE(REGEXP_REPLACE(TRANSLATE(REGEXP_REPLACE(LOWER(a.sender_city), 'i̇', 'i'),'çğöşü','cgosu'),'ı', 'i'),r'\s+',' '))) as sender_city_fixed,
        a.receiver_city,
        TRIM(INITCAP(REGEXP_REPLACE(REGEXP_REPLACE(TRANSLATE(REGEXP_REPLACE(LOWER(a.receiver_city), 'i̇', 'i'),'çğöşü','cgosu'),'ı', 'i'),r'\s+',' '))) as receiver_city_fixed,
        b.initialDelivery_isJetDelivery as yk_mi,
        a.optionid,
        b.initialDelivery_optionId,
        a.deliveryServiceForAddress as AT_Durum,
        date(b.orderdatetime,'Turkey') as order_date,
        datetime(b.orderdatetime,'Turkey') as order_datetime,
        date(a.deliverydatetime,'Turkey') as created_date,
        date(a.detail_acceptdate,'Turkey') as accept_date,
        datetime(a.detail_acceptdate,'Turkey') as accept_datetime,
        date(a.detail_delivereddate,'Turkey') as delivery_date,
        datetime(a.detail_delivereddate,'Turkey') as delivery_datetime,
        date(b.estimatedarrivaldate,'Turkey') as ead2,
        date(c.estimatedarrivaldate,'Turkey') as ead1,
        case when coalesce(date(b.estimatedShippingDatePredictedByHB,'Turkey'),"0001-01-01")<>"0001-01-01" then date(b.estimatedShippingDatePredictedByHB,'Turkey') else date(b.estimatedShippingDate,'Turkey') end as esd,
        case when date_diff(date(b.estimatedarrivaldate,'Turkey'), date(a.detail_acceptdate,'Turkey'), week) > 0 then date_diff(date(b.estimatedarrivaldate,  'Turkey'), date(a.detail_acceptdate,'Turkey'), day) - (date_diff(date(b.estimatedarrivaldate,'Turkey'), date(a.detail_acceptdate,'Turkey'), week) * 1) else date_diff(date(b.estimatedarrivaldate,'Turkey'), date(a.detail_acceptdate,'Turkey'), day) end as ead2_ac_sunday_off,
        date_diff(date(b.estimatedarrivaldate,'Turkey'), date(a.detail_acceptdate,'Turkey'), day) as ead2_ac_glance,
 
 
        case when date_diff(date(detail_delivereddate,'Turkey'), date(a.detail_acceptdate,'Turkey'), week) > 0 then date_diff(date(detail_delivereddate,'Turkey'), date(a.detail_acceptdate,'Turkey'), day) - (date_diff(date(detail_delivereddate,'Turkey'), date(a.detail_acceptdate,'Turkey'), week) * 1) else date_diff(date(detail_delivereddate,'Turkey'), date(a.detail_acceptdate,'Turkey'), day) end as dd_ac_sunday_off,
        date_diff(date(detail_delivereddate,'Turkey'), date(a.detail_acceptdate,'Turkey'), day) dd_ac_glance,
 
        case when date_diff(date(detail_delivereddate,'Turkey'), date(b.orderdatetime,'Turkey'), week) > 0 then date_diff(date(detail_delivereddate,'Turkey'), date(b.orderdatetime,'Turkey'), day) - (date_diff(date(detail_delivereddate,'Turkey'), date(b.orderdatetime,'Turkey'), week) * 1) else date_diff(date(detail_delivereddate,'Turkey'), date(b.orderdatetime,'Turkey'), day) end as dd_od_sunday_off,
        date_diff(date(detail_delivereddate,'Turkey'), date(b.orderdatetime,'Turkey'), day) dd_od_glance,
 
        case when date_diff(date(c.estimatedarrivaldate,'Turkey'), date(b.orderdatetime,'Turkey'), week) > 0 then date_diff(date(c.estimatedarrivaldate,  'Turkey'), date(b.orderdatetime,'Turkey'), day) - (date_diff(date(c.estimatedarrivaldate,'Turkey'), date(b.orderdatetime,'Turkey'), week) * 1) else date_diff(date(c.estimatedarrivaldate,'Turkey'), date(b.orderdatetime,'Turkey'), day) end as ead1_od_sunday_off,
        date_diff(date(c.estimatedarrivaldate,'Turkey'), date(b.orderdatetime,'Turkey'), day) as ead1_od_glance,
 
        case when date_diff(date(a.detail_acceptdate,'Turkey'), date(b.orderdatetime,'Turkey'), week) > 0 then date_diff(date(a.detail_acceptdate,  'Turkey'), date(b.orderdatetime,'Turkey'), day) - (date_diff(date(a.detail_acceptdate,'Turkey'), date(b.orderdatetime,'Turkey'), week) * 1) else date_diff(date(a.detail_acceptdate,'Turkey'), date(b.orderdatetime,'Turkey'), day) end as ac_od_sunday_off,
        date_diff(date(a.detail_acceptdate,'Turkey'), date(b.orderdatetime,'Turkey'), day) as ac_od_glance,
 
        case when date_diff(case when coalesce(date(b.estimatedShippingDatePredictedByHB,'Turkey'),"0001-01-01")<>"0001-01-01" then date(b.estimatedShippingDatePredictedByHB,'Turkey') else date(b.estimatedShippingDate,'Turkey') end, date(b.orderdatetime,'Turkey'), week) > 0 then date_diff(case when coalesce(date(b.estimatedShippingDatePredictedByHB,'Turkey'),"0001-01-01")<>"0001-01-01" then date(b.estimatedShippingDatePredictedByHB,'Turkey') else date(b.estimatedShippingDate,'Turkey') end, date(b.orderdatetime,'Turkey'), day) - (date_diff(case when coalesce(date(b.estimatedShippingDatePredictedByHB,'Turkey'),"0001-01-01")<>"0001-01-01" then date(b.estimatedShippingDatePredictedByHB,'Turkey') else date(b.estimatedShippingDate,'Turkey') end, date(b.orderdatetime,'Turkey'), week) * 1) else date_diff(case when coalesce(date(b.estimatedShippingDatePredictedByHB,'Turkey'),"0001-01-01")<>"0001-01-01" then date(b.estimatedShippingDatePredictedByHB,'Turkey') else date(b.estimatedShippingDate,'Turkey') end, date(b.orderdatetime,'Turkey'), day) end as esd_od_sunday_off,
 
        date_diff(case when coalesce(date(b.estimatedShippingDatePredictedByHB,'Turkey'),"0001-01-01")<>"0001-01-01" then date(b.estimatedShippingDatePredictedByHB,'Turkey') else date(b.estimatedShippingDate,'Turkey') end, date(b.orderdatetime,'Turkey'), day) as esd_od_glance,
        deliverytype,
        date(a.detail_postponedEstimatedDeliveryDate,'Turkey') as oteleme_tarihi,
        case when b.initialdelivery_optionid='15' then 'HJ Randevulu'
             when b.initialdelivery_optionid='14' then 'HJXL Randevulu'
             else 'Randevulu Teslimat Değil' end as Randevulu_Teslimat_Durumu,
        date(a.detail_estimatedArrivalDate1) as randevu_tarihi_delivery,
        date(a.detail_addressChangedOnCargo_datePromised) as address_change,
        a.detail_addressChangedOnCargo_isComingFromCargo,
        case when b.extension_flowThrough=TRUE and (b.cancel_reasonCode <>'BundleProduct' OR b.cancel_reasonCode IS NULL) then 'FT' else null end as FT_Durum,
        merchant_sellerpays,
        case when taglist is not null then false else true end as is_esd_ai_merchant,
        date(b.estimatedshippingdate,'Turkey') as esd_merchant,
       case when cast(JSON_VALUE(b.extension_additionalFields, '$.ShipmentDays') as int) is null or JSON_VALUE(b.extension_additionalFields, '$.ShipmentDays') = "" then b.estimatedShippingDay
            else cast(JSON_VALUE(b.extension_additionalFields, '$.ShipmentDays') as int) end AS esd_ai,
       b.estimatedShippingDay,
       case when city_normalize(sender_city) = 'Kocaeli' and city_normalize(receiver_city) in ('Istanbul','Bursa','Kocaeli') then true
             when city_normalize(sender_city)  = 'Izmir' and city_normalize(receiver_city) in ('Izmir','Aydin','Manisa') then true
             when city_normalize(sender_city)  = 'Duzce' and city_normalize(receiver_city) in ('Istanbul','Ankara','Sakarya','Kocaeli') then true
             when city_normalize(sender_city)  = 'Bilecik' and city_normalize(receiver_city) in ('Istanbul','Ankara','Sakarya','Kocaeli') then true
             when city_normalize(sender_city)  = 'Istanbul' and city_normalize(receiver_city) in ('Istanbul','Bursa','Sakarya','Kocaeli') then true
             when city_normalize(sender_city)  not in ('Kocaeli','Izmir','Duzce','Bilecik','Istanbul') and city_normalize(sender_city)  = city_normalize(receiver_city) then true
             else false end as is_local
 from `hb-delivery-prod.delivery_flat.delivery` a
 join `hb-oms-shared-prod.oms_flat.orderline` b on a.deliveryid=b.deliverycode
 left join `hb-oms-shared-prod.oms_flat.order_initialorderline` c on c.sku=b.sku
                                                                  and c.ordernumber=b.orderNumber
                                                                  and c.index=b.index
                                                                  and date(c.orderdatetime,'Turkey')>=DATE_ADD(CURRENT_DATE(),interval -60 day)
 left join `hb-merchant-prod.merchant_flat.merchant_tagList`  mt on mt.merchantId=b.merchant_id
                                                                 and taglist='ExcludeESDAI'
 where date(a.detail_delivereddate,'Turkey')>=DATE_ADD(CURRENT_DATE(),interval -30 day)
       and date(a.detail_delivereddate,'Turkey')<=DATE_ADD(CURRENT_DATE, INTERVAL -1 DAY )
       and deliverydirection='MERCHANT_TO_CUSTOMER'
       ----and a.cargocompany in ('YK','AR','PK','BL','HZ','HX','MK','SK','HL','CL','UP','AY')
       and date(a.deliverydatetime,'Turkey')>=DATE_ADD(CURRENT_DATE(),interval -60 day)
       and date(b.estimatedarrivaldate,'Turkey')>=DATE_ADD(CURRENT_DATE(),interval -60 day)
       and date(b.estimatedarrivaldate,'Turkey')<=DATE_ADD(CURRENT_DATE, INTERVAL 45 DAY )
       and date(c.estimatedarrivaldate,'Turkey')>=DATE_ADD(CURRENT_DATE(),interval -60 day)
       and date(c.estimatedarrivaldate,'Turkey')<=DATE_ADD(CURRENT_DATE, INTERVAL 45 DAY )
       and date(b.orderdatetime,'Turkey')>=DATE_ADD(CURRENT_DATE(),interval -60 day)
       and date(detail_acceptDate,'Turkey')>=DATE_ADD(CURRENT_DATE(),interval -60 day)
       and date(detail_acceptDate,'Turkey')<=DATE_ADD(CURRENT_DATE, INTERVAL 45 DAY )
       and b.definitionname not in ('Çekiliş','Hediye Kartları','Hizmet Bedeli','Gümrük, Taşıma')
       and b.tenant='Hepsiburada'
       and b.initialDelivery_optionId!='99'
       and b.lineitemtype in ('Standard')
       and b.merchant_isinternational=false
       and coalesce(a.customdata,'Empty') not like '%"IsPhysicalDelivery":"false"%'
       and a.currentstatus in ('Accepted','AttemptFailed','OutForDelivered','Delivered')
       and date(a.detail_delivereddate,'Turkey') is not null
       and date(a.detail_acceptdate,'Turkey') is not null
 ;
 
 Delete from `hb-dagitim-gelistirme.kpi.time_differences_all`
 where delivery_date between  DATE_ADD(CURRENT_DATE(),interval -30 day) and  DATE_ADD(CURRENT_DATE(),interval -1 day);
 
 INSERT INTO  `hb-dagitim-gelistirme.kpi.time_differences_all`
 SELECT * FROM `hb-dagitim-gelistirme.kpi.time_differences_all_delta`---oluşturacağın ara tablo
 where delivery_date between  DATE_ADD(CURRENT_DATE(),interval -30 day) and  DATE_ADD(CURRENT_DATE(),interval -1 day);