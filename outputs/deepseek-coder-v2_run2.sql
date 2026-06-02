CREATE TEMP FUNCTION city_normalize(city STRING)
RETURNS STRING AS (TRIM(INITCAP(REGEXP_REPLACE(REGEXP_REPLACE(TRANSLATE(REGEXP_REPLACE(LOWER(city), 'i̇', 'i'),'çğöşü','cgosu'),'ı','i'),r'\s+',' '))));

DROP TABLE IF EXISTS `hb-dagitim-gelistirme.kpi.time_differences_all_delta`;

CREATE TABLE IF NOT EXISTS `hb-dagitim-gelistirme.kpi.time_differences_all_delta` PARTITION BY delivery_date CLUSTER BY cargocompany AS
SELECT DISTINCT a.deliveryid,
       a.cargocompany,
       a.platform,
       a.sender_code,
       b.merchant_name,
       city_normalize(a.sender_city) AS sender_city_fixed,
       city_normalize(b.receiver_city) AS receiver_city_fixed,
       b.initialDelivery_isJetDelivery AS yk_mi,
       a.optionid,
       b.initialDelivery_optionId,
       a.deliveryServiceForAddress AS AT_Durum,
       CASE 
           WHEN description LIKE '%TR%' THEN DATE(b.orderdatetime)
           WHEN description LIKE '%UTC%' THEN DATETIME(b.orderdatetime, 'Turkey')
           ELSE NULL
       END AS order_date,
       CASE 
           WHEN description LIKE '%TR%' THEN DATETIME(b.orderdatetime, 'Turkey')
           WHEN description LIKE '%UTC%' THEN DATETIME(b.orderdatetime, 'Turkey')
           ELSE NULL
       END AS order_datetime,
       CASE 
           WHEN description LIKE '%TR%' THEN DATE(a.deliverydatetime)
           WHEN description LIKE '%UTC%' THEN DATETIME(a.deliverydatetime, 'Turkey')
           ELSE NULL
       END AS created_date,
       CASE 
           WHEN description LIKE '%TR%' THEN DATE(a.detail_acceptdate)
           WHEN description LIKE '%UTC%' THEN DATETIME(a.detail_acceptdate, 'Turkey')
           ELSE NULL
       END AS accept_date,
       CASE 
           WHEN description LIKE '%TR%' THEN DATETIME(a.detail_acceptdate, 'Turkey')
           WHEN description LIKE '%UTC%' THEN DATETIME(a.detail_acceptdate, 'Turkey')
           ELSE NULL
       END AS accept_datetime,
       CASE 
           WHEN description LIKE '%TR%' THEN DATE(a.detail_delivereddate)
           WHEN description LIKE '%UTC%' THEN DATETIME(a.detail_delivereddate, 'Turkey')
           ELSE NULL
       END AS delivery_date,
       CASE 
           WHEN description LIKE '%TR%' THEN DATETIME(a.detail_delivereddate, 'Turkey')
           WHEN description LIKE '%UTC%' THEN DATETIME(a.detail_delivereddate, 'Turkey')
           ELSE NULL
       END AS delivery_datetime,
       CASE 
           WHEN description LIKE '%TR%' THEN DATE(b.estimatedarrivaldate)
           WHEN description LIKE '%UTC%' THEN DATETIME(b.estimatedarrivaldate, 'Turkey')
           ELSE NULL
       END AS ead2,
       CASE 
           WHEN description LIKE '%TR%' THEN DATE(c.estimatedarrivaldate)
           WHEN description LIKE '%UTC%' THEN DATETIME(c.estimatedarrivaldate, 'Turkey')
           ELSE NULL
       END AS ead1,
       CASE 
           WHEN description LIKE '%TR%' THEN 
               CASE 
                   WHEN COALESCE(DATE(b.estimatedShippingDatePredictedByHB, 'Turkey'), "0001-01-01") <> "0001-01-01" THEN DATE(b.estimatedShippingDatePredictedByHB)
                   ELSE DATE(b.estimatedShippingDate)
               END
           WHEN description LIKE '%UTC%' THEN 
               CASE 
                   WHEN COALESCE(DATETIME(b.estimatedShippingDatePredictedByHB, 'Turkey'), "0001-01-01") <> "0001-01-01" THEN DATETIME(b.estimatedShippingDatePredictedByHB)
                   ELSE DATETIME(b.estimatedShippingDate)
               END
           ELSE NULL
       END AS esd,
       CASE 
           WHEN description LIKE '%TR%' THEN 
               CASE 
                   WHEN DATE_DIFF(DATE(b.estimatedarrivaldate), DATE(a.detail_acceptdate), WEEK) > 0 THEN DATE_DIFF(DATE(b.estimatedarrivaldate), DATE(a.detail_acceptdate), DAY) - (DATE_DIFF(DATE(b.estimatedarrivaldate), DATE(a.detail_acceptdate), WEEK) * 1)
                   ELSE DATE_DIFF(DATE(b.estimatedarrivaldate), DATE(a.detail_acceptdate), DAY)
               END
           WHEN description LIKE '%UTC%' THEN 
               CASE 
                   WHEN DATE_DIFF(DATETIME(b.estimatedarrivaldate, 'Turkey'), DATETIME(a.detail_acceptdate, 'Turkey'), WEEK) > 0 THEN DATE_DIFF(DATETIME(b.estimatedarrivaldate, 'Turkey'), DATETIME(a.detail_acceptdate, 'Turkey'), DAY) - (DATE_DIFF(DATETIME(b.estimatedarrivaldate, 'Turkey'), DATETIME(a.detail_acceptdate, 'Turkey'), WEEK) * 1)
                   ELSE DATE_DIFF(DATETIME(b.estimatedarrivaldate, 'Turkey'), DATETIME(a.detail_acceptdate, 'Turkey'), DAY)
               END
           ELSE NULL
       END AS ead2_ac_sunday_off,
       CASE 
           WHEN description LIKE '%TR%' THEN 
               CASE 
                   WHEN DATE_DIFF(DATE(b.estimatedarrivaldate), DATE(a.detail_acceptdate), WEEK) > 0 THEN DATE_DIFF(DATE(b.estimatedarrivaldate), DATE(a.detail_acceptdate), DAY) - (DATE_DIFF(DATE(b.estimatedarrivaldate), DATE(a.detail_acceptdate), WEEK) * 1)
                   ELSE DATE_DIFF(DATE(b.estimatedarrivaldate), DATE(a.detail_acceptdate), DAY)
               END
           WHEN description LIKE '%UTC%' THEN 
               CASE 
                   WHEN DATE_DIFF(DATETIME(b.estimatedarrivaldate, 'Turkey'), DATETIME(a.detail_acceptdate, 'Turkey'), WEEK) > 0 THEN DATE_DIFF(DATETIME(b.estimatedarrivaldate, 'Turkey'), DATETIME(a.detail_acceptdate, 'Turkey'), DAY) - (DATE_DIFF(DATETIME(b.estimatedarrivaldate, 'Turkey'), DATETIME(a.detail_acceptdate, 'Turkey'), WEEK) * 1)
                   ELSE DATE_DIFF(DATETIME(b.estimatedarrivaldate, 'Turkey'), DATETIME(a.detail_acceptdate, 'Turkey'), DAY)
               END
           ELSE NULL
       END AS ead2_ac_glance,
       CASE 
           WHEN description LIKE '%TR%' THEN 
               CASE 
                   WHEN DATE_DIFF(DATE(a.detail_delivereddate), DATE(a.detail_acceptdate), WEEK) > 0 THEN DATE_DIFF(DATE(a.detail_delivereddate), DATE(a.detail_acceptdate), DAY) - (DATE_DIFF(DATE(a.detail_delivereddate), DATE(a.detail_acceptdate), WEEK) * 1)
                   ELSE DATE_DIFF(DATE(a.detail_delivereddate), DATE(a.detail_acceptdate), DAY)
               END
           WHEN description LIKE '%UTC%' THEN 
               CASE 
                   WHEN DATE_DIFF(DATETIME(a.detail_delivereddate, 'Turkey'), DATETIME(a.detail_acceptdate, 'Turkey'), WEEK) > 0 THEN DATE_DIFF(DATETIME(a.detail_delivereddate, 'Turkey'), DATETIME(a.detail_acceptdate, 'Turkey'), DAY) - (DATE_DIFF(DATETIME(a.detail_delivereddate, 'Turkey'), DATETIME(a.detail_acceptdate, 'Turkey'), WEEK) * 1)
                   ELSE DATE_DIFF(DATETIME(a.detail_delivereddate, 'Turkey'), DATETIME(a.detail_acceptdate, 'Turkey'), DAY)
               END
           ELSE NULL
       END AS dd_ac_sunday_off,
       CASE 
           WHEN description LIKE '%TR%' THEN 
               CASE 
                   WHEN DATE_DIFF(DATE(a.detail_delivereddate), DATE(a.detail_acceptdate), WEEK) > 0 THEN DATE_DIFF(DATE(a.detail_delivereddate), DATE(a.detail_acceptdate), DAY) - (DATE_DIFF(DATE(a.detail_delivereddate), DATE(a.detail_acceptdate), WEEK) * 1)
                   ELSE DATE_DIFF(DATE(a.detail_delivereddate), DATE(a.detail_acceptdate), DAY)
               END
           WHEN description LIKE '%UTC%' THEN 
               CASE 
                   WHEN DATE_DIFF(DATETIME(a.detail_delivereddate, 'Turkey'), DATETIME(a.detail_acceptdate, 'Turkey'), WEEK) > 0 THEN DATE_DIFF(DATETIME(a.detail_delivereddate, 'Turkey'), DATETIME(a.detail_acceptdate, 'Turkey'), DAY) - (DATE_DIFF(DATETIME(a.detail_delivereddate, 'Turkey'), DATETIME(a.detail_acceptdate, 'Turkey'), WEEK) * 1)
                   ELSE DATE_DIFF(DATETIME(a.detail_delivereddate, 'Turkey'), DATETIME(a.detail_acceptdate, 'Turkey'), DAY)
               END
           ELSE NULL
       END AS dd_ac_glance,
       CASE 
           WHEN description LIKE '%TR%' THEN 
               CASE 
                   WHEN DATE_DIFF(DATE(a.detail_delivereddate), DATE(b.orderdatetime), WEEK) > 0 THEN DATE_DIFF(DATE(a.detail_delivereddate), DATE(b.orderdatetime), DAY) - (DATE_DIFF(DATE(a.detail_delivereddate), DATE(b.orderdatetime), WEEK) * 1)
                   ELSE DATE_DIFF(DATE(a.detail_delivereddate), DATE(b.orderdatetime), DAY)
               END
           WHEN description LIKE '%UTC%' THEN 
               CASE 
                   WHEN DATE_DIFF(DATETIME(a.detail_delivereddate, 'Turkey'), DATETIME(b.orderdatetime, 'Turkey'), WEEK) > 0 THEN DATE_DIFF(DATETIME(a.detail_delivereddate, 'Turkey'), DATETIME(b.orderdatetime, 'Turkey'), DAY) - (DATE_DIFF(DATETIME(a.detail_delivereddate, 'Turkey'), DATETIME(b.orderdatetime, 'Turkey'), WEEK) * 1)
                   ELSE DATE_DIFF(DATETIME(a.detail_delivereddate, 'Turkey'), DATETIME(b.orderdatetime, 'Turkey'), DAY)
               END
           ELSE NULL
       END AS dd_od_sunday_off,
       CASE 
           WHEN description LIKE '%TR%' THEN 
               CASE 
                   WHEN DATE_DIFF(DATE(a.detail_delivereddate), DATE(b.orderdatetime), WEEK) > 0 THEN DATE_DIFF(DATE(a.detail_delivereddate), DATE(b.orderdatetime), DAY) - (DATE_DIFF(DATE(a.detail_delivereddate), DATE(b.orderdatetime), WEEK) * 1)
                   ELSE DATE_DIFF(DATE(a.detail_delivereddate), DATE(b.orderdatetime), DAY)
               END
           WHEN description LIKE '%UTC%' THEN 
               CASE 
                   WHEN DATE_DIFF(DATETIME(a.detail_delivereddate, 'Turkey'), DATETIME(b.orderdatetime, 'Turkey'), WEEK) > 0 THEN DATE_DIFF(DATETIME(a.detail_delivereddate, 'Turkey'), DATETIME(b.orderdatetime, 'Turkey'), DAY) - (DATE_DIFF(DATETIME(a.detail_delivereddate, 'Turkey'), DATETIME(b.orderdatetime, 'Turkey'), WEEK) * 1)
                   ELSE DATE_DIFF(DATETIME(a.detail_delivereddate, 'Turkey'), DATETIME(b.orderdatetime, 'Turkey'), DAY)
               END
           ELSE NULL
       END AS dd_od_glance,
       CASE 
           WHEN description LIKE '%TR%' THEN 
               CASE 
                   WHEN DATE_DIFF(DATE(c.estimatedarrivaldate), DATE(b.orderdatetime), WEEK) > 0 THEN DATE_DIFF(DATE(c.estimatedarrivaldate), DATE(b.orderdatetime), DAY) - (DATE_DIFF(DATE(c.estimatedarrivaldate), DATE(b.orderdatetime), WEEK) * 1)
                   ELSE DATE_DIFF(DATE(c.estimatedarrivaldate), DATE(b.orderdatetime), DAY)
               END
           WHEN description LIKE '%UTC%' THEN 
               CASE 
                   WHEN DATE_DIFF(DATETIME(c.estimatedarrivaldate, 'Turkey'), DATETIME(b.orderdatetime, 'Turkey'), WEEK) > 0 THEN DATE_DIFF(DATETIME(c.estimatedarrivaldate, 'Turkey'), DATETIME(b.orderdatetime, 'Turkey'), DAY) - (DATE_DIFF(DATETIME(c.estimatedarrivaldate, 'Turkey'), DATETIME(b.orderdatetime, 'Turkey'), WEEK) * 1)
                   ELSE DATE_DIFF(DATETIME(c.estimatedarrivaldate, 'Turkey'), DATETIME(b.orderdatetime, 'Turkey'), DAY)
               END
           ELSE NULL
       END AS ead1_od_sunday_off,
       CASE 
           WHEN description LIKE '%TR%' THEN 
               CASE 
                   WHEN DATE_DIFF(DATE(c.estimatedarrivaldate), DATE(b.orderdatetime), WEEK) > 0 THEN DATE_DIFF(DATE(c.estimatedarrivaldate), DATE(b.orderdatetime), DAY) - (DATE_DIFF(DATE(c.estimatedarrivaldate), DATE(b.orderdatetime), WEEK) * 1)
                   ELSE DATE_DIFF(DATE(c.estimatedarrivaldate), DATE(b.orderdatetime), DAY)
               END
           WHEN description LIKE '%UTC%' THEN 
               CASE 
                   WHEN DATE_DIFF(DATETIME(c.estimatedarrivaldate, 'Turkey'), DATETIME(b.orderdatetime, 'Turkey'), WEEK) > 0 THEN DATE_DIFF(DATETIME(c.estimatedarrivaldate, 'Turkey'), DATETIME(b.orderdatetime, 'Turkey'), DAY) - (DATE_DIFF(DATETIME(c.estimatedarrivaldate, 'Turkey'), DATETIME(b.orderdatetime, 'Turkey'), WEEK) * 1)
                   ELSE DATE_DIFF(DATETIME(c.estimatedarrivaldate, 'Turkey'), DATETIME(b.orderdatetime, 'Turkey'), DAY)
               END
           ELSE NULL
       END AS ead1_od_glance,
       CASE 
           WHEN description LIKE '%TR%' THEN 
               CASE 
                   WHEN DATE_DIFF(DATE(a.detail_acceptdate), DATE(b.orderdatetime), WEEK) > 0 THEN DATE_DIFF(DATE(a.detail_acceptdate), DATE(b.orderdatetime), DAY) - (DATE_DIFF(DATE(a.detail_acceptdate), DATE(b.orderdatetime), WEEK) * 1)
                   ELSE DATE_DIFF(DATE(a.detail_acceptdate), DATE(b.orderdatetime), DAY)
               END
           WHEN description LIKE '%UTC%' THEN 
               CASE 
                   WHEN DATE_DIFF(DATETIME(a.detail_acceptdate, 'Turkey'), DATETIME(b.orderdatetime, 'Turkey'), WEEK) > 0 THEN DATE_DIFF(DATETIME(a.detail_acceptdate, 'Turkey'), DATETIME(b.orderdatetime, 'Turkey'), DAY) - (DATE_DIFF(DATETIME(a.detail_acceptdate, 'Turkey'), DATETIME(b.orderdatetime, 'Turkey'), WEEK) * 1)
                   ELSE DATE_DIFF(DATETIME(a.detail_acceptdate, 'Turkey'), DATETIME(b.orderdatetime, 'Turkey'), DAY)
               END
           ELSE NULL
       END AS ac_od_sunday_off,
       CASE 
           WHEN description LIKE '%TR%' THEN 
               CASE 
                   WHEN DATE_DIFF(DATE(a.detail_acceptdate), DATE(b.orderdatetime), WEEK) > 0 THEN DATE_DIFF(DATE(a.detail_acceptdate), DATE(b.orderdatetime), DAY) - (DATE_DIFF(DATE(a.detail_acceptdate), DATE(b.orderdatetime), WEEK) * 1)
                   ELSE DATE_DIFF(DATE(a.detail_acceptdate), DATE(b.orderdatetime), DAY)
               END
           WHEN description LIKE '%UTC%' THEN 
               CASE 
                   WHEN DATE_DIFF(DATETIME(a.detail_acceptdate, 'Turkey'), DATETIME(b.orderdatetime, 'Turkey'), WEEK) > 0 THEN DATE_DIFF(DATETIME(a.detail_acceptdate, 'Turkey'), DATETIME(b.orderdatetime, 'Turkey'), DAY) - (DATE_DIFF(DATETIME(a.detail_acceptdate, 'Turkey'), DATETIME(b.orderdatetime, 'Turkey'), WEEK) * 1)
                   ELSE DATE_DIFF(DATETIME(a.detail_acceptdate, 'Turkey'), DATETIME(b.orderdatetime, 'Turkey'), DAY)
               END
           ELSE NULL
       END AS ac_od_glance,
       CASE 
           WHEN description LIKE '%TR%' THEN 
               CASE 
                   WHEN DATE_DIFF(CASE 
                       WHEN COALESCE(DATE(b.estimatedShippingDatePredictedByHB, 'Turkey'), "0001-01-01") <> "0001-01-01" THEN DATE(b.estimatedShippingDatePredictedByHB)
                       ELSE DATE(b.estimatedShippingDate)
                   END, DATE(b.orderdatetime), WEEK) > 0 THEN DATE_DIFF(CASE 
                       WHEN COALESCE(DATE(b.estimatedShippingDatePredictedByHB, 'Turkey'), "0001-01-01") <> "0001-01-01" THEN DATE(b.estimatedShippingDatePredictedByHB)
                       ELSE DATE(b.estimatedShippingDate)
                   END, DATE(b.orderdatetime), DAY) - (DATE_DIFF(CASE 
                       WHEN COALESCE(DATE(b.estimatedShippingDatePredictedByHB, 'Turkey'), "0001-01-01") <> "0001-01-01" THEN DATE(b.estimatedShippingDatePredictedByHB)
                       ELSE DATE(b.estimatedShippingDate)
                   END, DATE(b.orderdatetime), WEEK) * 1)
                   ELSE DATE_DIFF(CASE 
                       WHEN COALESCE(DATE(b.estimatedShippingDatePredictedByHB, 'Turkey'), "0001-01-01") <> "0001-01-01" THEN DATE(b.estimatedShippingDatePredictedByHB)
                       ELSE DATE(b.estimatedShippingDate)
                   END, DATE(b.orderdatetime), DAY)
               END
           WHEN description LIKE '%UTC%' THEN 
               CASE 
                   WHEN DATE_DIFF(CASE 
                       WHEN COALESCE(DATETIME(b.estimatedShippingDatePredictedByHB, 'Turkey'), "0001-01-01") <> "0001-01-01" THEN DATETIME(b.estimatedShippingDatePredictedByHB)
                       ELSE DATETIME(b.estimatedShippingDate)
                   END, DATETIME(b.orderdatetime, 'Turkey'), WEEK) > 0 THEN DATE_DIFF(CASE 
                       WHEN COALESCE(DATETIME(b.estimatedShippingDatePredictedByHB, 'Turkey'), "0001-01-01") <> "0001-01-01" THEN DATETIME(b.estimatedShippingDatePredictedByHB)
                       ELSE DATETIME(b.estimatedShippingDate)
                   END, DATETIME(b.orderdatetime, 'Turkey'), DAY) - (DATE_DIFF(CASE 
                       WHEN COALESCE(DATETIME(b.estimatedShippingDatePredictedByHB, 'Turkey'), "0001-01-01") <> "0001-01-01" THEN DATETIME(b.estimatedShippingDatePredictedByHB)
                       ELSE DATETIME(b.estimatedShippingDate)
                   END, DATETIME(b.orderdatetime, 'Turkey'), WEEK) * 1)
                   ELSE DATE_DIFF(CASE 
                       WHEN COALESCE(DATETIME(b.estimatedShippingDatePredictedByHB, 'Turkey'), "0001-01-01") <> "0001-01-01" THEN DATETIME(b.estimatedShippingDatePredictedByHB)
                       ELSE DATETIME(b.estimatedShippingDate)
                   END, DATETIME(b.orderdatetime, 'Turkey'), DAY)
               END
           ELSE NULL
       END AS esd_od_sunday_off,
       CASE 
           WHEN description LIKE '%TR%' THEN 
               CASE 
                   WHEN DATE_DIFF(CASE 
                       WHEN COALESCE(DATE(b.estimatedShippingDatePredictedByHB, 'Turkey'), "0001-01-01") <> "0001-01-01" THEN DATE(b.estimatedShippingDatePredictedByHB)
                       ELSE DATE(b.estimatedShippingDate)
                   END, DATE(b.orderdatetime), DAY) > 0 THEN DATE_DIFF(CASE 
                       WHEN COALESCE(DATE(b.estimatedShippingDatePredictedByHB, 'Turkey'), "0001-01-01") <> "0001-01-01" THEN DATE(b.estimatedShippingDatePredictedByHB)
                       ELSE DATE(b.estimatedShippingDate)
                   END, DATE(b.orderdatetime), DAY) - (DATE_DIFF(CASE 
                       WHEN COALESCE(DATE(b.estimatedShippingDatePredictedByHB, 'Turkey'), "0001-01-01") <> "0001-01-01" THEN DATE(b.estimatedShippingDatePredictedByHB)
                       ELSE DATE(b.estimatedShippingDate)
                   END, DATE(b.orderdatetime), DAY) * 1)
                   ELSE DATE_DIFF(CASE 
                       WHEN COALESCE(DATE(b.estimatedShippingDatePredictedByHB, 'Turkey'), "0001-01-01") <> "0001-01-01" THEN DATE(b.estimatedShippingDatePredictedByHB)
                       ELSE DATE(b.estimatedShippingDate)
                   END, DATE(b.orderdatetime), DAY)
               END
           WHEN description LIKE '%UTC%' THEN 
               CASE 
                   WHEN DATE_DIFF(CASE 
                       WHEN COALESCE(DATETIME(b.estimatedShippingDatePredictedByHB, 'Turkey'), "0001-01-01") <> "0001-01-01" THEN DATETIME(b.estimatedShippingDatePredictedByHB)
                       ELSE DATETIME(b.estimatedShippingDate)
                   END, DATETIME(b.orderdatetime, 'Turkey'), DAY) > 0 THEN DATE_DIFF(CASE 
                       WHEN COALESCE(DATETIME(b.estimatedShippingDatePredictedByHB, 'Turkey'), "0001-01-01") <> "0001-01-01" THEN DATETIME(b.estimatedShippingDatePredictedByHB)
                       ELSE DATETIME(b.estimatedShippingDate)
                   END, DATETIME(b.orderdatetime, 'Turkey'), DAY) - (DATE_DIFF(CASE 
                       WHEN COALESCE(DATETIME(b.estimatedShippingDatePredictedByHB, 'Turkey'), "0001-01-01") <> "0001-01-01" THEN DATETIME(b.estimatedShippingDatePredictedByHB)
                       ELSE DATETIME(b.estimatedShippingDate)
                   END, DATETIME(b.orderdatetime, 'Turkey'), DAY) * 1)
                   ELSE DATE_DIFF(CASE 
                       WHEN COALESCE(DATETIME(b.estimatedShippingDatePredictedByHB, 'Turkey'), "0001-01-01") <> "0001-01-01" THEN DATETIME(b.estimatedShippingDatePredictedByHB)
                       ELSE DATETIME(b.estimatedShippingDate)
                   END, DATETIME(b.orderdatetime, 'Turkey'), DAY)
               END
           ELSE NULL
       END AS esd_od_glance,
       a.deliverytype,
       CASE 
           WHEN description LIKE '%TR%' THEN DATE(a.detail_postponedEstimatedDeliveryDate)
           WHEN description LIKE '%UTC%' THEN DATETIME(a.detail_postponedEstimatedDeliveryDate, 'Turkey')
           ELSE NULL
       END AS oteleme_tarihi,
       CASE 
           WHEN b.initialdelivery_optionid = '15' THEN 'HJ Randevulu'
           WHEN b.initialdelivery_optionid = '14' THEN 'HJXL Randevulu'
           ELSE 'Randevulu Teslimat Değil'
       END AS Randevulu_Teslimat_Durumu,
       CASE 
           WHEN description LIKE '%TR%' THEN DATE(a.detail_estimatedArrivalDate1)
           WHEN description LIKE '%UTC%' THEN DATETIME(a.detail_estimatedArrivalDate1, 'Turkey')
           ELSE NULL
       END AS randevu_tarihi_delivery,
       CASE 
           WHEN description LIKE '%TR%' THEN DATE(a.detail_addressChangedOnCargo_datePromised)
           WHEN description LIKE '%UTC%' THEN DATETIME(a.detail_addressChangedOnCargo_datePromised, 'Turkey')
           ELSE NULL
       END AS address_change,
       a.detail_addressChangedOnCargo_isComingFromCargo,
       CASE 
           WHEN b.extension_flowThrough = TRUE AND (b.cancel_reasonCode <> 'BundleProduct' OR b.cancel_reasonCode IS NULL) THEN 'FT'
           ELSE NULL
       END AS FT_Durum,
       b.merchant_sellerpays,
       CASE 
           WHEN mt.taglist IS NOT NULL THEN FALSE
           ELSE TRUE
       END AS is_esd_ai_merchant,
       CASE 
           WHEN description LIKE '%TR%' THEN DATE(b.estimatedshippingdate)
           WHEN description LIKE '%UTC%' THEN DATETIME(b.estimatedshippingdate, 'Turkey')
           ELSE NULL
       END AS esd_merchant,
       CASE 
           WHEN CAST(JSON_VALUE(b.extension_additionalFields, '$.ShipmentDays') AS INT) IS NULL OR JSON_VALUE(b.extension_additionalFields, '$.ShipmentDays') = "" THEN b.estimatedShippingDay
           ELSE CAST(JSON_VALUE(b.extension_additionalFields, '$.ShipmentDays') AS INT)
       END AS esd_ai,
       b.estimatedShippingDay,
       CASE 
           WHEN city_normalize(a.sender_city) = 'Kocaeli' AND city_normalize(b.receiver_city) IN ('Istanbul', 'Bursa', 'Kocaeli') THEN TRUE
           WHEN city_normalize(a.sender_city) = 'Izmir' AND city_normalize(b.receiver_city) IN ('Izmir', 'Aydin', 'Manisa') THEN TRUE
           WHEN city_normalize(a.sender_city) = 'Duzce' AND city_normalize(b.receiver_city) IN ('Istanbul', 'Ankara', 'Sakarya', 'Kocaeli') THEN TRUE
           WHEN city_normalize(a.sender_city) = 'Bilecik' AND city_normalize(b.receiver_city) IN ('Istanbul', 'Ankara', 'Sakarya', 'Kocaeli') THEN TRUE
           WHEN city_normalize(a.sender_city) = 'Istanbul' AND city_normalize(b.receiver_city) IN ('Istanbul', 'Bursa', 'Sakarya', 'Kocaeli') THEN TRUE
           WHEN city_normalize(a.sender_city) NOT IN ('Kocaeli', 'Izmir', 'Duzce', 'Bilecik', 'Istanbul') AND city_normalize(a.sender_city) = city_normalize(b.receiver_city) THEN TRUE
           ELSE FALSE
       END AS is_local
FROM `hb-delivery-prod.delivery_flat.delivery` a
JOIN `hb-oms-shared-prod.oms_flat.orderline` b ON a.deliveryid = b.deliverycode
LEFT JOIN `hb-oms-shared-prod.oms_flat.order_initialorderline` c ON c.sku = b.sku
                                                                  AND c.ordernumber = b.orderNumber
                                                                  AND c.index = b.index
                                                                  AND DATE(c.orderdatetime, 'Turkey') >= DATE_ADD(CURRENT_DATE(), INTERVAL -60 DAY)
LEFT JOIN `hb-merchant-prod.merchant_flat.merchant_tagList` mt ON mt.merchantId = b.merchant_id
                                                                 AND taglist = 'ExcludeESDAI'
WHERE DATE(a.detail_delivereddate, 'Turkey') >= DATE_ADD(CURRENT_DATE(), INTERVAL -30 DAY)
      AND DATE(a.detail_delivereddate, 'Turkey') <= DATE_ADD(CURRENT_DATE, INTERVAL -1 DAY )
      AND deliverydirection = 'MERCHANT_TO_CUSTOMER'
      ----and a.cargocompany in ('YK','AR','PK','BL','HZ','HX','MK','SK','HL','CL','UP','AY')
      AND DATE(a.deliverydatetime, 'Turkey') >= DATE_ADD(CURRENT_DATE(), INTERVAL -60 DAY)
      AND DATE(b.estimatedarrivaldate, 'Turkey') >= DATE_ADD(CURRENT_DATE(), INTERVAL -60 DAY)
      AND DATE(b.estimatedarrivaldate, 'Turkey') <= DATE_ADD(CURRENT_DATE, INTERVAL 45 DAY )
      AND DATE(c.estimatedarrivaldate, 'Turkey') >= DATE_ADD(CURRENT_DATE(), INTERVAL -60 DAY)
      AND DATE(c.estimatedarrivaldate, 'Turkey') <= DATE_ADD(CURRENT_DATE, INTERVAL 45 DAY )
      AND DATE(b.orderdatetime, 'Turkey') >= DATE_ADD(CURRENT_DATE(), INTERVAL -60 DAY)
      AND DATE(a.detail_acceptdate, 'Turkey') >= DATE_ADD(CURRENT_DATE(), INTERVAL -60 DAY)
      AND DATE(a.detail_acceptdate, 'Turkey') <= DATE_ADD(CURRENT_DATE, INTERVAL 45 DAY )
      AND b.definitionname NOT IN ('Çekiliş', 'Hediye Kartları', 'Hizmet Bedeli', 'Gümrük, Taşıma')
      AND b.tenant = 'Hepsiburada'
      AND b.initialDelivery_optionId != '99'
      AND b.lineitemtype IN ('Standard')
      AND b.merchant_isinternational = FALSE
      AND COALESCE(a.customdata, 'Empty') NOT LIKE '%"IsPhysicalDelivery":"false"%'
      AND a.currentstatus IN ('Accepted', 'AttemptFailed', 'OutForDelivered', 'Delivered');

DELETE FROM `hb-dagitim-gelistirme.kpi.time_differences_all`
WHERE delivery_date BETWEEN DATE_ADD(CURRENT_DATE(), INTERVAL -30 DAY) AND DATE_ADD(CURRENT_DATE(), INTERVAL -1 DAY);

INSERT INTO `hb-dagitim-gelistirme.kpi.time_differences_all`
SELECT * FROM `hb-dagitim-gelistirme.kpi.time_differences_all_delta`;