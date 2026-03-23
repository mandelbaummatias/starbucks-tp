# Mapeo de Datos — starbucks.raw_orders → star schema

Este documento describe cómo cada columna del CSV original
(`starbucks_customer_ordering_patterns.csv`) es cargada en la tabla staging
`starbucks.raw_orders` y luego mapeada a las tablas físicas del esquema `star`.

---

## 1. Dimensión: `star.dim_channel`

| Columna RAW         | Columna Destino    | Tabla Destino      | Lógica aplicada                                    |
|---------------------|--------------------|--------------------|----------------------------------------------------|
| `order_channel`     | `order_channel`    | `star.dim_channel` | `DISTINCT` por canal; `channel_sk` generado con `SERIAL`. |

---

## 2. Dimensión: `star.dim_store`

| Columna RAW           | Columna Destino        | Tabla Destino    | Lógica aplicada                                           |
|-----------------------|------------------------|------------------|-----------------------------------------------------------|
| `store_id`            | `store_id`             | `star.dim_store` | Clave de negocio; `DISTINCT` por `store_id`.              |
| `store_location_type` | `store_location_type`  | `star.dim_store` | Transferencia directa (Urban / Suburban / Rural).         |
| `region`              | `region`               | `star.dim_store` | Transferencia directa (Northeast / Midwest / etc.).       |

> `store_sk` se genera como `SERIAL` en la base de datos; el ETL lo popular luego del
> `TRUNCATE + INSERT`.

---

## 3. Dimensión: `star.dim_customer`

| Columna RAW          | Columna Destino       | Tabla Destino       | Lógica aplicada                                           |
|----------------------|-----------------------|---------------------|-----------------------------------------------------------|
| `customer_id`        | `customer_id`         | `star.dim_customer` | Clave de negocio; `DISTINCT` por `customer_id`.           |
| `customer_age_group` | `customer_age_group`  | `star.dim_customer` | Transferencia directa.                                    |
| `customer_gender`    | `customer_gender`     | `star.dim_customer` | Transferencia directa.                                    |
| `is_rewards_member`  | `is_rewards_member`   | `star.dim_customer` | Transferencia directa (booleano).                         |

---

## 4. Dimensión: `star.dim_date`

| Columna RAW    | Columna Destino | Tabla Destino   | Lógica aplicada                                                |
|----------------|-----------------|-----------------|----------------------------------------------------------------|
| `order_date`   | `full_date`     | `star.dim_date` | Conversión a `DATE`.                                           |
| `order_date`   | `date_sk`       | `star.dim_date` | `STRFTIME("%Y%m%d")` → entero YYYYMMDD (clave de negocio).    |
| `day_of_week`  | `day_of_week`   | `star.dim_date` | Tomado de `raw_orders` directamente (Mon / Tue / … / Sun).    |
| `order_date`   | `day_of_month`  | `star.dim_date` | `EXTRACT(DAY FROM order_date)`.                                |
| `order_date`   | `month_num`     | `star.dim_date` | `EXTRACT(MONTH FROM order_date)`.                              |
| `order_date`   | `quarter_num`   | `star.dim_date` | `EXTRACT(QUARTER FROM order_date)`.                            |
| `order_date`   | `year_num`      | `star.dim_date` | `EXTRACT(YEAR FROM order_date)`.                               |

---

## 5. Dimensión: `star.dim_time`

| Columna RAW  | Columna Destino | Tabla Destino   | Lógica aplicada                                                           |
|--------------|-----------------|-----------------|---------------------------------------------------------------------------|
| `order_time` | `time_sk`       | `star.dim_time` | `EXTRACT(HOUR FROM order_time)` → entero 0-23 (clave de negocio).        |
| `order_time` | `hour_of_day`   | `star.dim_time` | Igual a `time_sk`.                                                        |
| `order_time` | `time_period`   | `star.dim_time` | Regla: 7-9 → *Morning Rush*; 10-13 → *Mid-Day*; 14-17 → *Afternoon*; 18-21 → *Evening*; resto → *Other*. |

---

## 6. Hecho: `star.fact_orders`

| Columna RAW           | Columna Destino       | Tabla Destino      | Lógica aplicada                                                            |
|-----------------------|-----------------------|--------------------|----------------------------------------------------------------------------|
| `order_id`            | `order_id`            | `star.fact_orders` | Dimensión degenerada; se conserva como atributo informativo.               |
| `order_channel`       | `channel_sk`          | `star.fact_orders` | JOIN con `dim_channel` → sustituida por clave subrogada.                   |
| `store_id`            | `store_sk`            | `star.fact_orders` | JOIN con `dim_store` → sustituida por clave subrogada.                     |
| `customer_id`         | `customer_sk`         | `star.fact_orders` | JOIN con `dim_customer` → sustituida por clave subrogada.                  |
| `order_date`          | `date_sk`             | `star.fact_orders` | JOIN con `dim_date` (YYYYMMDD) → clave de negocio.                         |
| `order_time` (hora)   | `time_sk`             | `star.fact_orders` | JOIN con `dim_time` (hora 0-23) → clave de negocio.                        |
| `order_time`          | `order_time`          | `star.fact_orders` | Se conserva el valor TIME original como atributo de grano fino.            |
| `drink_category`      | `drink_category`      | `star.fact_orders` | Transferencia directa.                                                     |
| `has_food_item`       | `has_food_item`       | `star.fact_orders` | Transferencia directa (booleano).                                          |
| `order_ahead`         | `is_order_ahead`      | `star.fact_orders` | **Renombrado** para mayor claridad semántica (`is_` prefix).               |
| `cart_size`           | `cart_size`           | `star.fact_orders` | Medida: cantidad de ítems en el pedido.                                    |
| `num_customizations`  | `num_customizations`  | `star.fact_orders` | Medida: número de personalizaciones.                                       |
| `total_spend`         | `total_spend`         | `star.fact_orders` | Medida: gasto total en USD.                                                |
| `fulfillment_time_min`| `fulfillment_time_min`| `star.fact_orders` | Medida clave: tiempo de preparación/entrega en minutos.                    |
| `customer_satisfaction`| `customer_satisfaction`| `star.fact_orders` | Medida: puntaje de satisfacción del cliente (1-5).                      |

> Las columnas `customer_age_group`, `customer_gender`, `is_rewards_member`,
> `store_location_type` y `region` **no se duplican** en la tabla de hechos; ya
> están disponibles mediante JOIN a las dimensiones correspondientes.
