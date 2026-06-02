CREATE TEMP FUNCTION city_normalize(city STRING)
 RETURNS STRING AS (TRIM(INITCAP(REGEXP_REPLACE(REGEXP_REPLACE(TRANSLATE(REGEXP_REPLACE(LOWER(city), 'i̇', 'i'),'çğöşü','cgosu'),'ı','i'),r'\s+',' '))));
 
 CREATE OR REPLACE TABLE `hb-dataanalytics-prod.da_prod.time_differences_all_delta`
 PARTITION BY delivery_date
 CLUSTER BY cargo_company_code as
 
 select distinct delivery_id,
   cargo_company_code,
   item_category,
   delivery_sender_code,
   ordered_merchant_name,
   delivery_sender_city_name,
   TRIM(INITCAP(REGEXP_REPLACE(REGEXP_REPLACE(TRANSLATE(REGEXP_REPLACE(LOWER(delivery_sender_city_name), 'i̇', 'i'),'çğöşü','cgosu'),'ı', 'i'),r'\s+',' '))) as delivery_sender_city_fixed,
   delivery_receiver_city_name,
   TRIM(INITCAP(REGEXP_REPLACE(REGEXP_REPLACE(TRANSLATE(REGEXP_REPLACE(LOWER(delivery_receiver_city_name), 'i̇', 'i'),'çğöşü','cgosu'),'ı', 'i'),r'\s+',' '))) as delivery_receiver_city_fixed,
   is_initial_delivery_jet_delivery as yk_mi,
   option_id,
   initial_delivery_option_type_code,
   NULL as AT_Durum,
   order_date,
   datetime(order_date_time,'Turkey') as order_datetime,
   delivery_date as created_date,
   delivery_cargo_accept_date as accept_date,
   datetime(delivery_cargo_accept_date_time,'Turkey') as accept_datetime,
   delivered_date as delivery_date,
   datetime(delivered_date_time,'Turkey') as delivery_datetime,
   estimated_arrival_date as ead2,
   initial_estimated_arrival_date as ead1,
   CASE WHEN estimated_shipping_date_predicted_by_hb IS NOT NULL THEN estimated_shipping_date_predicted_by_hb ELSE estimated_shipping_date END AS esd,
 
 
    case when date_diff(estimated_arrival_date, delivery_cargo_accept_date, week) > 0 then date_diff(estimated_arrival_date, delivery_cargo_accept_date, day) - (date_diff(estimated_arrival_date, delivery_cargo_accept_date, week) ) else date_diff(estimated_arrival_date, delivery_cargo_accept_date, day) end as ead2_ac_sunday_off,
 
   date_diff(estimated_arrival_date, delivery_cargo_accept_date, day) as ead2_ac_glance,
   date_diff(delivered_date, delivery_cargo_accept_date, day) - (date_diff(delivered_date, delivery_cargo_accept_date, week)) as dd_ac_sunday_off,
   date_diff(delivered_date, delivery_cargo_accept_date, day) as dd_ac_glance,
    case when date_diff(delivered_date, order_date, week) > 0 then date_diff(delivered_date, order_date, day) - (date_diff(delivered_date, order_date, week) ) else date_diff(delivered_date, order_date, day) end as dd_od_sunday_off,
   date_diff(delivered_date, order_date, day) as dd_od_glance,
   case when date_diff(initial_estimated_arrival_date, order_date, week) > 0 then date_diff(initial_estimated_arrival_date, order_date, day) - (date_diff(initial_estimated_arrival_date, order_date, week) ) else date_diff(initial_estimated_arrival_date, order_date, day) end as ead1_od_sunday_off,
   date_diff(initial_estimated_arrival_date, order_date, day) as ead1_od_glance,
   case when date_diff(delivery_cargo_accept_date, order_date, week) > 0 then date_diff(delivery_cargo_accept_date, order_date, day) - (date_diff(delivery_cargo_accept_date, order_date, week)) else date_diff(delivery_cargo_accept_date, order_date, day) end as ac_od_sunday_off,
   date_diff(delivery_cargo_accept_date, order_date, day) as ac_od_glance,
   DATE_DIFF(CASE WHEN COALESCE(estimated_shipping_date_predicted_by_hb, "0001-01-01") <> "0001-01-01" THEN estimated_shipping_date_predicted_by_hb ELSE estimated_shipping_date END, order_date, DAY) - DATE_DIFF(CASE WHEN COALESCE(estimated_shipping_date_predicted_by_hb, "0001-01-01") <> "0001-01-01" THEN estimated_shipping_date_predicted_by_hb ELSE estimated_shipping_date END, order_date, WEEK) AS esd_od_sunday_off,
 
   date_diff(case when coalesce(estimated_shipping_date_predicted_by_hb,"0001-01-01")<>"0001-01-01" then estimated_shipping_date_predicted_by_hb else estimated_shipping_date end, order_date, day) as esd_od_glance,
   delivery_type_code,
   estimated_postponed_delivery_date as oteleme_tarihi,
        case when initial_delivery_option_type_code='15' then 'HJ Randevulu'
             when initial_delivery_option_type_code='14' then 'HJXL Randevulu'
             else 'Randevulu Teslimat Değil' end as Randevulu_Teslimat_Durumu,
 
   initial_estimated_arrival_date as randevu_tarihi_delivery,
   address_changed_estimated_arrival_date as address_change,
   is_addresschanged_from_cargo,
   case when is_flow_through_flag=1 and COALESCE( cancel_reason_sap_code,'') ='' then 'FT' else null end as FT_Durum,
   merchant_delivery_seller_pays,
   NULL as is_esd_ai_merchant,
   estimated_shipping_date as esd_merchant,
   CASE WHEN CAST(JSON_VALUE(extension_additional_fields, '$.ShipmentDays') AS INT64) IS NULL OR JSON_VALUE(extension_additional_fields, '$.ShipmentDays') = "" THEN estimated_shipping_day
   ELSE CAST(JSON_VALUE(extension_additional_fields, '$.ShipmentDays') AS INT64) END AS esd_ai,
 
 
   estimated_shipping_day as estimatedShippingDay,
   case when city_normalize(delivery_sender_city_name) = 'Kocaeli' and city_normalize(delivery_receiver_city_name) in ('Istanbul','Bursa','Kocaeli') then true
             when city_normalize(delivery_sender_city_name)  = 'Izmir' and city_normalize(delivery_receiver_city_name) in ('Izmir','Aydin','Manisa') then true
             when city_normalize(delivery_sender_city_name)  = 'Duzce' and city_normalize(delivery_receiver_city_name) in ('Istanbul','Ankara','Sakarya','Kocaeli') then true
             when city_normalize(delivery_sender_city_name)  = 'Bilecik' and city_normalize(delivery_receiver_city_name) in ('Istanbul','Ankara','Sakarya','Kocaeli') then true
             when city_normalize(delivery_sender_city_name)  = 'Istanbul' and city_normalize(delivery_receiver_city_name) in ('Istanbul','Bursa','Sakarya','Kocaeli') then true
             when city_normalize(delivery_sender_city_name)  not in ('Kocaeli','Izmir','Duzce','Bilecik','Istanbul') and city_normalize(delivery_sender_city_name)  = city_normalize(delivery_receiver_city_name) then true
         else false end as is_local
 
 from `hb-analysis-prod.delivery.delivery_dm_initial_order_sku_daily`
 
 
 
 
 
 
 
 
 
 where delivered_date>=DATE_ADD(CURRENT_DATE(),interval -30 day)
       and delivered_date<=DATE_ADD(CURRENT_DATE, INTERVAL -1 DAY )
       and delivery_direction='MERCHANT_TO_CUSTOMER'
       -- and a.cargocompany in ('YK','AR','PK','BL','HZ','HX','MK','SK','HL','CL','UP','AY')
       and delivery_date>=DATE_ADD(CURRENT_DATE(),interval -60 day)
       and estimated_arrival_date>=DATE_ADD(CURRENT_DATE(),interval -60 day)
       and estimated_arrival_date<=DATE_ADD(CURRENT_DATE, INTERVAL 45 DAY )
       and initial_estimated_arrival_date>=DATE_ADD(CURRENT_DATE(),interval -60 day)
       and initial_estimated_arrival_date<=DATE_ADD(CURRENT_DATE, INTERVAL 45 DAY )
       and order_date>=DATE_ADD(CURRENT_DATE(),interval -60 day)
       and delivery_cargo_accept_date>=DATE_ADD(CURRENT_DATE(),interval -60 day)
       and delivery_cargo_accept_date<=DATE_ADD(CURRENT_DATE, INTERVAL 45 DAY )
       and sub_category_name not in ('Çekiliş','Hediye Kartları','Hizmet Bedeli','Gümrük, Taşıma')
  and tenant_name ='Hepsiburada'
       and initial_delivery_option_type_code !='99'
       and line_item_type in ('Standard')
       and is_merchant_current_inbound =0
       and is_physical_delivery_order = 1
       and delivery_status in ('Accepted','AttemptFailed','OutForDelivered','Delivered')