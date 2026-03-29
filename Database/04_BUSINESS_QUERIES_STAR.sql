SELECT
    dc.order_channel,
    ROUND(AVG(fo.fulfillment_time_min)::numeric, 2) AS avg_fulfillment_min,
    COUNT(*)                                         AS total_orders
FROM      star.fact_orders fo
JOIN      star.dim_channel dc  USING (channel_id)
JOIN      star.dim_time    dt  USING (time_id)
WHERE     dt.time_period = 'Morning Rush'
GROUP BY  dc.order_channel
ORDER BY  avg_fulfillment_min DESC;


SELECT
    dc.order_channel,
    ROUND(AVG(fo.cart_size)::numeric,           2) AS avg_cart_size,
    ROUND(AVG(fo.num_customizations)::numeric,  2) AS avg_customizations,
    ROUND(AVG(fo.fulfillment_time_min)::numeric, 2) AS avg_fulfillment_min,
    ROUND(CORR(fo.num_customizations, fo.fulfillment_time_min)::numeric, 4)
                                                   AS correlation_custom_delay,
    COUNT(*)                                       AS total_orders
FROM      star.fact_orders fo
JOIN      star.dim_channel dc  USING (channel_id)
JOIN      star.dim_time    dt  USING (time_id)
WHERE     dt.time_period = 'Morning Rush'
GROUP BY  dc.order_channel
ORDER BY  avg_fulfillment_min DESC;


SELECT
    ds.store_location_type,
    ds.region,
    ROUND(AVG(fo.fulfillment_time_min)::numeric,  2) AS avg_fulfillment_min,
    ROUND(AVG(fo.customer_satisfaction)::numeric, 2) AS avg_satisfaction
FROM      star.fact_orders fo
JOIN      star.dim_store   ds  USING (store_id_pk)
JOIN      star.dim_time    dt  USING (time_id)
WHERE     dt.time_period = 'Morning Rush'
GROUP BY  ds.store_location_type, ds.region
ORDER BY  avg_fulfillment_min DESC
LIMIT 10;


SELECT
    dd.day_of_week,
    ROUND(AVG(fo.fulfillment_time_min)::numeric, 2) AS avg_fulfillment_min,
    COUNT(*)                                         AS total_orders
FROM      star.fact_orders fo
JOIN      star.dim_date    dd  USING (date_id)
GROUP BY  dd.day_of_week
ORDER BY  avg_fulfillment_min DESC;
