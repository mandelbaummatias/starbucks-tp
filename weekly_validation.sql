-- WEEKLY PATTERNS VALIDATION
SELECT
    dd.day_of_week,
    ROUND(AVG(fo.fulfillment_time_min)::numeric, 2) AS avg_fulfillment_min,
    COUNT(*) AS total_orders
FROM star.fact_orders fo
JOIN star.dim_date dd USING (date_id)
GROUP BY dd.day_of_week
ORDER BY dd.day_of_week;
