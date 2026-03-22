-- 1. Comparación de canales en el "morning rush" (7:00 a 9:00 AM)
SELECT 
    order_channel, 
    ROUND(AVG(fulfillment_time_min), 2) AS avg_fulfillment_min,
    COUNT(*) AS total_orders
FROM starbucks.vw_orders_starbucks 
WHERE time_period = 'Morning Rush' 
GROUP BY order_channel 
ORDER BY avg_fulfillment_min DESC;

-- 2. Complejidad del pedido vs demoras en cada canal (Morning Rush)
SELECT 
    order_channel,
    ROUND(AVG(cart_size), 2) AS avg_cart_size,
    ROUND(AVG(num_customizations), 2) AS avg_customizations,
    ROUND(AVG(fulfillment_time_min), 2) AS avg_fulfillment_min,
    ROUND(CORR(num_customizations, fulfillment_time_min)::numeric, 4) AS correlation_custom_delay,
    COUNT(*) AS total_orders
FROM starbucks.vw_orders_starbucks 
WHERE time_period = 'Morning Rush' 
GROUP BY order_channel;

-- 3. Diferencias geográficas y tipología de tienda
SELECT 
    store_location_type,
    region,
    ROUND(AVG(fulfillment_time_min), 2) AS avg_fulfillment_min,
    ROUND(AVG(customer_satisfaction), 2) AS avg_satisfaction
FROM starbucks.vw_orders_starbucks 
WHERE time_period = 'Morning Rush' 
GROUP BY store_location_type, region
ORDER BY avg_fulfillment_min DESC
LIMIT 10;

-- 4. Patrones semanales críticos
SELECT 
    day_of_week, 
    ROUND(AVG(fulfillment_time_min), 2) AS avg_fulfillment_min,
    COUNT(*) AS total_orders
FROM starbucks.vw_orders_starbucks 
GROUP BY day_of_week 
ORDER BY avg_fulfillment_min DESC;
