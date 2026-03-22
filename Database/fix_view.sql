-- Fix the view
DROP VIEW IF EXISTS starbucks.vw_orders_starbucks;
CREATE VIEW starbucks.vw_orders_starbucks AS
SELECT
    *,
    CAST(order_date AS timestamp) + order_time AS order_datetime,
    EXTRACT(DAY FROM order_date)     AS day_of_month,
    EXTRACT(MONTH FROM order_date)   AS month_num,
    EXTRACT(QUARTER FROM order_date) AS quarter_num,
    EXTRACT(YEAR FROM order_date)    AS year_num,
    EXTRACT(HOUR FROM order_time)    AS hour_of_day,
    CASE
        WHEN EXTRACT(HOUR FROM order_time) BETWEEN 7  AND 9  THEN 'Morning Rush'
        WHEN EXTRACT(HOUR FROM order_time) BETWEEN 10 AND 13 THEN 'Mid-Day'
        WHEN EXTRACT(HOUR FROM order_time) BETWEEN 14 AND 17 THEN 'Afternoon'
        WHEN EXTRACT(HOUR FROM order_time) BETWEEN 18 AND 21 THEN 'Evening'
        ELSE 'Other'
    END AS time_period
FROM starbucks.raw_orders;
