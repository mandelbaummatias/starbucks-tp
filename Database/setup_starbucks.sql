-- ============================================================
-- STEP 2: RUN THIS SCRIPT CONNECTED TO 'starbucks_dw_raw'
-- ============================================================

CREATE SCHEMA IF NOT EXISTS starbucks;

-- ============================================================
-- PASO 2: Tabla staging (volcado crudo del CSV)
-- ============================================================

CREATE TABLE IF NOT EXISTS starbucks.raw_orders (
    customer_id           VARCHAR(20),
    order_id              VARCHAR(20),
    order_date            DATE,
    order_time            TIME,
    day_of_week           VARCHAR(10),
    order_channel         VARCHAR(30),
    store_id              VARCHAR(20),
    store_location_type   VARCHAR(20),
    region                VARCHAR(30),
    customer_age_group    VARCHAR(20),
    customer_gender       VARCHAR(20),
    is_rewards_member     BOOLEAN,
    cart_size             INT,
    num_customizations    INT,
    total_spend           DECIMAL(10,2),
    fulfillment_time_min  DECIMAL(5,2),
    drink_category        VARCHAR(40),
    has_food_item         BOOLEAN,
    order_ahead           BOOLEAN,
    customer_satisfaction INT
);

-- ============================================================
-- PASO 3: Carga de Datos desde CSV
-- ============================================================

\copy starbucks.raw_orders FROM 'c:/prueba/Database/starbucks_customer_ordering_patterns.csv' WITH (FORMAT csv, HEADER true);

-- ============================================================
-- Verificación de Carga
-- ============================================================

SELECT COUNT(*) AS total_registros
FROM starbucks.raw_orders;

-- ============================================================
-- Verificación de Datos
-- ============================================================

SELECT *
FROM starbucks.raw_orders
LIMIT 10;

-- ============================================================
-- Vista con Campos Derivados
-- ============================================================

DROP VIEW IF EXISTS starbucks.vw_orders_starbucks;

CREATE VIEW starbucks.vw_orders_starbucks AS
SELECT
    customer_id,
    order_id,
    order_date,
    order_time,
    day_of_week,
    order_channel,
    store_id,
    store_location_type,
    region,
    customer_age_group,
    customer_gender,
    is_rewards_member,
    cart_size,
    num_customizations,
    total_spend,
    fulfillment_time_min,
    drink_category,
    has_food_item,
    order_ahead,
    customer_satisfaction,
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
