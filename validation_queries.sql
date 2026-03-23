-- VALIDATION QUERIES
-- Purpose: Verify key metrics from the data warehouse

-- Overall metrics
SELECT
    ROUND(AVG(fo.fulfillment_time_min)::numeric, 2) AS overall_avg_fulfillment,
    ROUND(AVG(fo.customer_satisfaction)::numeric, 2) AS overall_avg_satisfaction,
    COUNT(*) AS total_records
FROM star.fact_orders fo;

-- Weekly patterns
SELECT
    dd.day_of_week,
    ROUND(AVG(fo.fulfillment_time_min)::numeric, 2) AS avg_fulfillment_min,
    COUNT(*) AS total_orders
FROM star.fact_orders fo
JOIN star.dim_date dd USING (date_id)
GROUP BY dd.day_of_week
ORDER BY avg_fulfillment_min DESC;

-- Geographic - Top 10 slowest
SELECT
    ds.store_location_type,
    ds.region,
    ROUND(AVG(fo.fulfillment_time_min)::numeric, 2) AS avg_fulfillment_min,
    ROUND(AVG(fo.customer_satisfaction)::numeric, 2) AS avg_satisfaction
FROM star.fact_orders fo
JOIN star.dim_store ds USING (store_id_pk)
JOIN star.dim_time dt USING (time_id)
WHERE dt.time_period = 'Morning Rush'
GROUP BY ds.store_location_type, ds.region
ORDER BY avg_fulfillment_min DESC
LIMIT 10;
