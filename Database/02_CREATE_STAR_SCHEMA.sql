CREATE SCHEMA IF NOT EXISTS star;
DROP TABLE IF EXISTS star.dim_channel CASCADE;

CREATE TABLE star.dim_channel (
    channel_id      SERIAL PRIMARY KEY,
    order_channel   VARCHAR(30) NOT NULL,
    is_order_ahead  BOOLEAN,
    UNIQUE (order_channel, is_order_ahead)
);
DROP TABLE IF EXISTS star.dim_store CASCADE;

CREATE TABLE star.dim_store (
    store_id_pk           SERIAL PRIMARY KEY,
    store_id              VARCHAR(20)  NOT NULL,
    store_location_type   VARCHAR(20),
    region                VARCHAR(30),
    UNIQUE (store_id)
);
DROP TABLE IF EXISTS star.dim_customer CASCADE;

CREATE TABLE star.dim_customer (
    customer_id_pk      SERIAL PRIMARY KEY,
    customer_id         VARCHAR(20) NOT NULL UNIQUE,
    customer_age_group  VARCHAR(20),
    customer_gender     VARCHAR(20),
    is_rewards_member   BOOLEAN
);
DROP TABLE IF EXISTS star.dim_date CASCADE;

CREATE TABLE star.dim_date (
    date_id      INT PRIMARY KEY,
    full_date    DATE    NOT NULL,
    day_of_week  VARCHAR(10),
    day_of_month INT,
    month_num    INT,
    quarter_num  INT,
    year_num     INT
);
DROP TABLE IF EXISTS star.dim_time CASCADE;

CREATE TABLE star.dim_time (
    time_id      INT PRIMARY KEY,
    hour_of_day  INT  NOT NULL,
    order_time   TIME NOT NULL,
    time_period  VARCHAR(20)
);

DROP TABLE IF EXISTS star.fact_orders CASCADE;

CREATE TABLE star.fact_orders (
    order_id_pk           SERIAL PRIMARY KEY,
    order_id              VARCHAR(20),

    channel_id            INT  NOT NULL REFERENCES star.dim_channel(channel_id),
    store_id_pk           INT  NOT NULL REFERENCES star.dim_store(store_id_pk),
    customer_id_pk        INT  NOT NULL REFERENCES star.dim_customer(customer_id_pk),
    date_id               INT  NOT NULL REFERENCES star.dim_date(date_id),
    time_id               INT  NOT NULL REFERENCES star.dim_time(time_id),

    order_time            TIME,
    drink_category        VARCHAR(40),
    has_food_item         BOOLEAN,

    cart_size             INT,
    num_customizations    INT,
    total_spend           DECIMAL(10,2),
    fulfillment_time_min  DECIMAL(5,2),
    customer_satisfaction INT
);
CREATE INDEX IF NOT EXISTS idx_fo_channel  ON star.fact_orders(channel_id);
CREATE INDEX IF NOT EXISTS idx_fo_store    ON star.fact_orders(store_id_pk);
CREATE INDEX IF NOT EXISTS idx_fo_date     ON star.fact_orders(date_id);
CREATE INDEX IF NOT EXISTS idx_fo_time     ON star.fact_orders(time_id);
CREATE INDEX IF NOT EXISTS idx_fo_customer ON star.fact_orders(customer_id_pk);
