CREATE TEMP FUNCTION city_normalize(city STRING)
 RETURNS STRING AS (TRIM(INITCAP(REGEXP_REPLACE(REGEXP_REPLACE(TRANSLATE(REGEXP_REPLACE(LOWER(city), 'i̇', 'i'),'çğöşü','cgosu'),'ı','i'),r'\s+',' '))))
 ;

drop table if exists `hb-dagitim-gelistirme.kpi.time_differences_all_delta`;

create table if not exists `hb-dagitim-gelistirme.kpi.time_differences_all_delta` partition by delivery_date cluster by cargocompany as
select distinct 
    delivery_id as deliveryid,
    cargo_company_name as cargocompany,
    NULL AS platform,
    delivery_sender_code as sender_code,
    ordered_merchant_name as merchant_name,
    delivery_sender_city_name as sender_city,
    city_normalize(delivery_sender_city_name) as sender_city_fixed,
    delivery_receiver_city_name as receiver_city,
    city_normalize(delivery_receiver_city_name) as receiver_city_fixed,
    is_initial_delivery_jet_delivery as yk_mi,
    option_id as optionid,
    NULL AS initialDelivery_optionId,
    NULL AS AT_Durum,
    order_date as order_date,
    order_date_time as order_datetime,
    delivery_date as created_date,
    delivery_cargo_accept_date as accept_date,
    delivery_cargo_accept_date_time as accept_datetime,
    delivered_date as delivery_date,
    delivered_date_time as delivery_datetime,
    estimated_arrival_date as ead2,
    initial_estimated_arrival_date as ead1,
    case when coalesce(estimated_shipping_date_predicted_by_hb, "0001-01-01") <> "0001-01-01" then estimated_shipping_date_predicted_by_hb else estimated_shipping_date end as esd,
    case when date_diff(estimated_arrival_date, delivery_cargo_accept_date, week) > 0 
        then date_diff(estimated_arrival_date, delivery_cargo_accept_date, day) - (date_diff(estimated_arrival_date, delivery_cargo_accept_date, week) * 1) 
        else date_diff(estimated_arrival_date, delivery_cargo_accept_date, day) end as ead2_ac_sunday_off,
    date_diff(estimated_arrival_date, delivery_cargo_accept_date, day) as ead2_ac_glance,

    case when date_diff(delivered_date, delivery_cargo_accept_date, week) > 0 
        then date_diff(delivered_date, delivery_cargo_accept_date, day) - (date_diff(delivered_date, delivery_cargo_accept_date, week) * 1) 
        else date_diff(delivered_date, delivery_cargo_accept_date, day) end as dd_ac_sunday_off,
    date_diff(delivered_date, delivery_cargo_accept_date, day) as dd_ac_glance,

    case when date_diff(delivered_date, order_date, week) > 0 
        then date_diff(delivered_date, order_date, day) - (date_diff(delivered_date, order_date, week) * 1) 
        else date_diff(delivered_date, order_date, day) end as dd_od_sunday_off,
    date_diff(delivered_date, order_date, day) as dd_od_glance,

    case when date_diff(initial_estimated_arrival_date, order_date, week) > 0 
        then date_diff(initial_estimated_arrival_date, order_date, day) - (date_diff(initial_estimated_arrival_date, order_date, week) * 1) 
        else date_diff(initial_estimated_arrival_date, order_date, day) end as ead1_od_sunday_off,
    date_diff(initial_estimated_arrival_date, order_date, day) as ead1_od_glance,

    case when date_diff(delivery_cargo_accept_date, order_date, week) > 0 
        then date_diff(delivery_cargo_accept_date, order_date, day) - (date_diff(delivery_cargo_accept_date, order_date, week) * 1) 
        else date_diff(delivery_cargo_accept_date, order_date, day) end as ac_od_sunday_off,
    date_diff(delivery_cargo_accept_date, order_date, day) as ac_od_glance,

    case when date_diff(case when coalesce(estimated_shipping_date_predicted_by_hb, "0001-01-01") <> "0001-01-01" then estimated_shipping_date_predicted_by_hb else estimated_shipping_date end, order_date, week) > 0 
        then date_diff(case when coalesce(estimated_shipping_date_predicted_by_hb, "0001-01-01") <> "0001-01-01" then estimated_shipping_date_predicted_by_hb else estimated_shipping_date end, order_date, day) - (date_diff(case when coalesce(estimated_shipping_date_predicted_by_hb, "0001-01-01") <> "0001-01-01" then estimated_shipping_date_predicted_by_hb else estimated_shipping_date end, order_date, week) * 1) 
        else date_diff(case when coalesce(estimated_shipping_date_predicted_by_hb, "0001-01-01") <> "0001-01-01" then estimated_shipping_date_predicted_by_hb else estimated_shipping_date end, order_date, day) end as esd_od_sunday_off,

    date_diff(case when coalesce(estimated_shipping_date_predicted_by_hb, "0001-01-01") <> "0001-01-01" then estimated_shipping_date_predicted_by_hb else estimated_shipping_date end, order_date, day) as esd_od_glance,
    delivery_type_code as deliverytype,
    estimated_postponed_delivery_date as oteleme_tarihi,
    NULL AS Randevulu_Teslimat_Durumu,
    address_changed_estimated_arrival_date as randevu_tarihi_delivery,
    NULL AS address_change,
    is_addresschanged_from_cargo = 1 as detail_addressChangedOnCargo_isComingFromCargo,
    case when is_flow_through_flag = 1 and (cancel_reason_sap_code <> 'BundleProduct' OR cancel_reason_sap_code IS NULL) then 'FT' else null end as FT_Durum,
    merchant_delivery_seller_pays as merchant_sellerpays,
    case when extension_additional_fields is not null then false else true end as is_esd_ai_merchant,
    estimated_shipping_date as esd_merchant,
    case when cast(JSON_VALUE(extension_additional_fields, '$.ShipmentDays') as int) is null or JSON_VALUE(extension_additional_fields, '$.ShipmentDays') = "" 
        then estimatedShippingDay
        else cast(JSON_VALUE(extension_additional_fields, '$.ShipmentDays') as int) end AS esd_ai,
    estimatedShippingDay,
    case when city_normalize(delivery_sender_city_name) = 'Kocaeli' and city_normalize(delivery_receiver_city_name) in ('Istanbul','Bursa','Kocaeli') then true
         when city_normalize(delivery_sender_city_name)  = 'Izmir' and city_normalize(delivery_receiver_city_name) in ('Izmir','Aydin','Manisa') then true
         when city_normalize(delivery_sender_city_name)  = 'Duzce' and city_normalize(delivery_receiver_city_name) in ('Istanbul','Ankara','Sakarya','Kocaeli') then true
         when city_normalize(delivery_sender_city_name)  = 'Bilecik' and city_normalize(delivery_receiver_city_name) in ('Istanbul','Ankara','Sakarya','Kocaeli') then true
         when city_normalize(delivery_sender_city_name)  = 'Istanbul' and city_normalize(delivery_receiver_city_name) in ('Istanbul','Bursa','Sakarya','Kocaeli') then true
         when city_normalize(delivery_sender_city_name)  not in ('Kocaeli','Izmir','Duzce','Bilecik','Istanbul') and city_normalize(delivery_sender_city_name)  = city_normalize(delivery_receiver_city_name) then true
         else false end as is_local
from `hb-analysis-prod.delivery.delivery_dm_initial_order_sku_daily`
where delivered_date >= DATE_ADD(CURRENT_DATE(), interval -30 day)
      and delivered_date <= DATE_ADD(CURRENT_DATE, INTERVAL -1 DAY )
      and delivery_direction = 'MERCHANT_TO_CUSTOMER'
      and order_date >= DATE_ADD(CURRENT_DATE(),interval -60 day)
      and estimated_arrival_date >= DATE_ADD(CURRENT_DATE(),interval -60 day)
      and estimated_arrival_date <= DATE_ADD(CURRENT_DATE, INTERVAL 45 DAY )
      and initial_estimated_arrival_date >= DATE_ADD(CURRENT_DATE(),interval -60 day)
      and initial_estimated_arrival_date <= DATE_ADD(CURRENT_DATE, INTERVAL 45 DAY )
      and order_date >= DATE_ADD(CURRENT_DATE(),interval -60 day)
      and delivery_cargo_accept_date >= DATE_ADD(CURRENT_DATE(),interval -60 day)
      and delivery_cargo_accept_date <= DATE_ADD(CURRENT_DATE, INTERVAL 45 DAY )
      and delivery_feature_definition not in ('Çekiliş','Hediye Kartları','Hizmet Bedeli','Gümrük, Taşıma')
      and tenant_name = 'Hepsiburada'
      and initial_delivery_option_type_code != '99'
      and line_item_type in ('Standard')
      and is_merchant_order_inbound = 0
      and coalesce(extension_additional_fields,'Empty') not like '%"IsPhysicalDelivery":"false"%'
      and delivery_status in ('Accepted','AttemptFailed','OutForDelivered','Delivered')
      and delivered_date is not null
      and delivery_cargo_accept_date is not null
;

Delete from `hb-dagitim-gelistirme.kpi.time_differences_all`
where delivery_date between  DATE_ADD(CURRENT_DATE(),interval -30 day) and  DATE_ADD(CURRENT_DATE(),interval -1 day);

INSERT INTO  `hb-dagitim-gelistirme.kpi.time_differences_all`
SELECT * FROM `hb-dagitim-gelistirme.kpi.time_differences_all_delta`---oluşturacağın ara tablo
where delivery_date between  DATE_ADD(CURRENT_DATE(),interval -30 day) and  DATE_ADD(CURRENT_DATE(),interval -1 day);