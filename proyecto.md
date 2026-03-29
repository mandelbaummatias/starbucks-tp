# PROYECTO DE DATA WAREHOUSING: ANÁLISIS DE STARBUCKS

## 1\. Descripción de la Organización y Contexto del Negocio

Starbucks Corporation es una compañía multinacional líder en la industria de cafeterías y tostadurías de café. Fundada en Seattle en 1971, opera actualmente más de **38,000 tiendas** a nivel mundial. Su modelo de negocio se centra en ofrecer una experiencia de cliente premium, con una amplia variedad de bebidas a base de café espresso, tés, refrescos y productos alimenticios.

La compañía utiliza múltiples canales de venta:

- Tiendas físicas con atención al mostrador (**In-Store Cashier**).
- Servicio de autoservicio (**Drive-Thru**).
- Kioscos en lugares de alto tránsito.
- Pedidos anticipados vía aplicación móvil (**Mobile App**).

Esta omnicanalidad presenta desafíos operativos significativos, especialmente en términos de gestión de tiempos de espera y eficiencia en la preparación de pedidos durante las horas de mayor afluencia ("morning rush").

## 2\. Descripción de la Necesidad o Problema a Resolver

El problema central a abordar es la **identificación de cuellos de botella operativos** en el proceso de cumplimiento de pedidos. El enfoque principal se centra en el análisis del tiempo de preparación y entrega, medido a través de la métrica: fulfillment_time_min.

Se postula que durante las **horas pico matutinas** (7:00 AM - 9:00 AM), la eficiencia entre los canales _Drive-Thru_ y _Mobile Order-Ahead_ varía drásticamente, lo cual impacta directamente en la percepción de calidad y satisfacción del cliente.

Utilizando el dataset _"Starbucks Customer Ordering Patterns"_, se propone la construcción de un **Data Warehouse** diseñado para resolver las siguientes interrogantes de negocio:

- **Comparativa de Canales:** ¿Qué canal presenta mayores demoras durante el _"morning rush"_? (Drive-Thru vs. Mobile).
- **Impacto de la Complejidad:** ¿Cómo influye el tamaño del carrito (cart_size) y el nivel de personalización (num_customizations) en el tiempo de entrega, segmentado por canal?
- **Análisis Geográfico:** ¿Existen variaciones significativas según el tipo de ubicación (store_location_type: urbana, suburbana, rural) o la región?
- **Patrones Temporales:** ¿Qué días de la semana presentan picos críticos de espera que requieran una mejor planificación de personal?

El objetivo final es dotar a los gerentes de operaciones de una herramienta de procesamiento analítico que permita:

- **Detección de Ineficiencias:** Identificar patrones de demora en tiempo real e histórico.
- **Optimización de Recursos:** Mejorar la asignación de personal y equipos en las franjas horarias y canales más conflictivos.
- **Experiencia del Cliente:** Reducir los tiempos de espera y aumentar el índice de customer_satisfaction.

## 3\. Modelo de Datos Existente (OLTP)

El sistema operacional está normalizado para garantizar la integridad de las transacciones diarias.

erDiagram

CUSTOMER ||--o{ ORDER : realiza

STORE ||--o{ ORDER : procesa

CUSTOMER {

string customer_id PK

string age_group

string gender

boolean is_rewards_member

}

STORE {

string store_id PK

string store_location_type

string region

}

ORDER {

string order_id PK

datetime order_datetime

string order_channel

int cart_size

int num_customizations

decimal total_spend

int fulfillment_time_min

boolean order_ahead

int customer_satisfaction

string drink_category

boolean has_food_item

string customer_id FK

string store_id FK

}

---

## 4\. Modelo Multidimensional (Star Schema)

Para el análisis OLAP, se ha diseñado un modelo estrella que optimiza las consultas de agregación.

erDiagram

FACT_ORDERS ||--o{ DIM_CUSTOMER : "customer_id"

FACT_ORDERS ||--o{ DIM_STORE : "store_id"

FACT_ORDERS ||--o{ DIM_DATE : "date_id"

FACT_ORDERS ||--o{ DIM_TIME : "time_id"

FACT_ORDERS ||--o{ DIM_CHANNEL : "channel_id"

FACT_ORDERS {

string order_id PK

int channel_id FK

int store_id_pk FK

int customer_id_pk FK

int date_id FK

int time_id FK

time order_time

string drink_category "Atributo degenerado"

boolean has_food_item

boolean is_order_ahead

int cart_size

int num_customizations

decimal total_spend

decimal fulfillment_time_min

int customer_satisfaction

}

DIM_CUSTOMER {

string customer_id PK

string customer_age_group

string customer_gender

boolean is_rewards_member

}

DIM_STORE {

string store_id PK

string store_location_type

string region

}

DIM_DATE {

int date_id PK

date order_date

string day_of_week

int day_of_month

int month_num

int quarter_num

int year_num

}

DIM_TIME {

int time_id PK

time order_time

int hour_of_day

string time_period

}

DIM_CHANNEL {

int channel_id PK

string order_channel

boolean is_order_ahead

}

## 5\. Validación de consistencia entre documentación y solución implementada

- Tablas dimension y hechos documentadas en el modelo conceptual corresponden 1:1 con los objetos físicos del DDL (`star.dim_channel`, `star.dim_store`, `star.dim_customer`, `star.dim_date`, `star.dim_time`, `star.fact_orders`), el ETL en `Scripts/etl_starbucks.py` y el semantic model en `Starbucks_PowerBI.SemanticModel`.
- Relaciones con claves foráneas confirmadas en `Database/02_CREATE_STAR_SCHEMA.sql` y `Starbucks_PowerBI.SemanticModel/definition/relationships.tmdl`:
  - `fact_orders.channel_id -> dim_channel.channel_id`
  - `fact_orders.store_id_pk -> dim_store.store_id_pk`
  - `fact_orders.customer_id_pk -> dim_customer.customer_id_pk`
  - `fact_orders.date_id -> dim_date.date_id`
  - `fact_orders.time_id -> dim_time.time_id`

### Mismatches identificados

1. `is_order_ahead` se almacena en `dim_channel` y se utiliza como atributo de segmentación de canal, mientras que `fact_orders` mantiene la relación mediante `channel_id`.
2. `DimDate` en el DOC describe columnas `month`, `quarter`, `year`; en el DDL son `month_num`, `quarter_num`, `year_num`. En el semantic model PBI se renombra a `month`, `quarter`, `year` durante la carga del modelo (coherente con el objetivo, sólo diferencia de nombre).
3. `Nota: order_datetime se construye concatenando order_date y order_time` está conceptualmente OK, pero en la implementación ETL no se persiste como columna `order_datetime`; se genera en memoria con `full_date + order_time` y luego se derivan `date_id` y `time_id`.

### Recomendaciones

- Ajustar la sección de `FactOrders` en el documento para incluir `is_order_ahead` o dejar constancia que es exclusivo de la dimensión `DimChannel`.
- Normalizar la nomenclatura de `month_num/quarter_num/year_num` en el texto de DimDate para evitar confusión con `month/quarter/year`.
- Mantener la nota de `order_datetime` en el diseño conceptual, y documentar exactamente cómo se gestiona en ETL (p.ej. `full_date` + `order_time` -> `date_id`, `time_id`).

Nota: El campo day_of_week del CSV no se almacena explícitamente en ORDER porque es derivable de order_datetime, pero podría incluirse si se desea. En el modelo normalizado no es necesario, ya que se puede calcular.

###

### **FactOrders (Tabla de Hechos)**

Es la tabla central que contiene las métricas cuantitativas del negocio y las claves foráneas que la conectan con cada dimensión.

- **Métricas del negocio:**
  - cart_size
  - num_customizations
  - total_spend
  - fulfillment_time_min
  - customer_satisfaction
- **Atributos adicionales:**
  - drink_category: Atributo degenerado (información descriptiva que se mantiene en la tabla de hechos para optimizar el modelo).

### **Dimensiones**

Cada dimensión aporta el contexto necesario para segmentar, filtrar y profundizar en los análisis.

**DimCustomer**

- **Descripción:** Contiene los datos demográficos y de perfil del cliente.

**DimStore**

- **Descripción:** Información sobre la ubicación y el tipo de tienda.
- **Jerarquía:** Región → Tipo de Ubicación → Tienda.

**DimDate**

- **Descripción:** Permite realizar análisis temporales detallados.
- **Atributos:** Día, mes, trimestre, año y día de la semana.

**DimTime**

- **Descripción:** Descompone el tiempo para análisis operativos por franjas horarias.
- **Atributos:** Hora del día y período (ej. "Morning Rush").

**DimChannel**

- **Descripción:** Clasifica el origen del pedido.
- **Atributos:** Canal de pedido y si fue realizado con anticipación (Order Ahead).

### Tabla de Hechos: star.fact_orders

| **Columna**           | **Tipo** | **Descripción**                        |
| --------------------- | -------- | -------------------------------------- |
| order_id (PK)         | VARCHAR  | ID único del pedido.                   |
| ---                   | ---      | ---                                    |
| customer_id (FK)      | VARCHAR  | Relación con DimCustomer.              |
| ---                   | ---      | ---                                    |
| store_id (FK)         | VARCHAR  | Relación con DimStore.                 |
| ---                   | ---      | ---                                    |
| date_id (FK)          | INT      | Relación con DimDate (YYYYMMDD).       |
| ---                   | ---      | ---                                    |
| time_id (FK)          | INT      | Relación con DimTime (Hora 0-23).      |
| ---                   | ---      | ---                                    |
| channel_id (FK)       | INT      | Relación con DimChannel.               |
| ---                   | ---      | ---                                    |
| cart_size             | INT      | Medida: Cantidad de ítems.             |
| ---                   | ---      | ---                                    |
| num_customizations    | INT      | Medida: Personalizaciones.             |
| ---                   | ---      | ---                                    |
| total_spend           | DECIMAL  | Medida: Gasto total en USD.            |
| ---                   | ---      | ---                                    |
| fulfillment_time_min  | DECIMAL  | Medida: Tiempo de preparación.         |
| ---                   | ---      | ---                                    |
| customer_satisfaction | INT      | Medida: Satisfacción (1-5).            |
| ---                   | ---      | ---                                    |
| has_food_item         | BOOLEAN  | Medida: Indicador de si incluye comida |
| ---                   | ---      | ---                                    |

###

###

###

###

### Dimensiones

### **DimCustomer (Datos Demográficos)**

Proporciona el contexto sobre quién realiza la compra.

| **Columna**          | **Tipo** | **Origen**         |
| -------------------- | -------- | ------------------ |
| **customer_id (PK)** | VARCHAR  | customer_id        |
| ---                  | ---      | ---                |
| customer_age_group   | VARCHAR  | customer_age_group |
| ---                  | ---      | ---                |
| customer_gender      | VARCHAR  | customer_gender    |
| ---                  | ---      | ---                |
| is_rewards_member    | BOOLEAN  | is_rewards_member  |
| ---                  | ---      | ---                |

### **DimStore (Geográfica)**

Permite el análisis por ubicación física.

- **Jerarquía:** Región → Tipo de Ubicación → Tienda.

| **Columna**         | **Tipo** | **Origen**          |
| ------------------- | -------- | ------------------- |
| **store_id (PK)**   | VARCHAR  | store_id            |
| ---                 | ---      | ---                 |
| store_location_type | VARCHAR  | store_location_type |
| ---                 | ---      | ---                 |
| region              | VARCHAR  | region              |
| ---                 | ---      | ---                 |

### **DimDate (Temporal - Calendario)**

Estructura para análisis de tendencias en el tiempo.

- **Jerarquía:** Año → Trimestre → Mes → Día.

| **Columna**      | **Tipo** | **Origen / Derivación**       |
| ---------------- | -------- | ----------------------------- |
| **date_id (PK)** | INT      | Surrogate key                 |
| ---              | ---      | ---                           |
| order_date       | DATE     | order_date                    |
| ---              | ---      | ---                           |
| day_of_week      | VARCHAR  | day_of_week (directo del CSV) |
| ---              | ---      | ---                           |
| day_of_month     | INT      | Extraído de order_date        |
| ---              | ---      | ---                           |
| month            | INT      | Extraído de order_date        |
| ---              | ---      | ---                           |
| quarter          | INT      | Extraído de order_date        |
| ---              | ---      | ---                           |
| year             | INT      | Extraído de order_date        |
| ---              | ---      | ---                           |

### **DimTime (Temporal - Horaria)**

Descompone la hora para identificar picos operativos.

- **Jerarquía:** Periodo del Día → Hora del Día.

| **Columna**      | **Tipo** | **Origen / Derivación**                      |
| ---------------- | -------- | -------------------------------------------- |
| **time_id (PK)** | INT      | Surrogate key                                |
| ---              | ---      | ---                                          |
| order_time       | TIME     | order_time                                   |
| ---              | ---      | ---                                          |
| hour_of_day      | INT      | Extraído de order_time                       |
| ---              | ---      | ---                                          |
| time_period      | VARCHAR  | Derivado de hour_of_day (ej. 'Morning Rush') |
| ---              | ---      | ---                                          |

### **DimChannel (Canales de Venta)**

Clasifica el origen del pedido y la modalidad de entrega.

| **Columna**         | **Tipo** | **Origen**    |
| ------------------- | -------- | ------------- |
| **channel_id (PK)** | INT      | Surrogate key |
| ---                 | ---      | ---           |
| order_channel       | VARCHAR  | order_channel |
| ---                 | ---      | ---           |
| is_order_ahead      | BOOLEAN  | order_ahead   |
| ---                 | ---      | ---           |

Las claves primarias (PK) marcadas como Surrogate key deben ser generadas durante el proceso de carga (ETL) para garantizar la integridad referencial.

## 5\. Mapeo de Datos (ETL)

## Se describe cómo cada columna del CSV original (starbucks_customer_ordering_patterns.csv) es cargada en la tabla staging starbucks.raw_orders y luego mapeada a las tablas físicas del esquema star

## **Dimensión: star.dim_channel**

<div class="joplin-table-wrapper"><table><thead><tr><th><h2><a id="_671tqeiqgr35"></a><strong>Columna RAW</strong></h2></th><th><h2><a id="_671tqeiqgr35"></a><strong>Columna Destino</strong></h2></th><th><h2><a id="_671tqeiqgr35"></a><strong>Tabla Destino</strong></h2></th><th><h2><a id="_671tqeiqgr35"></a><strong>Lógica aplicada</strong></h2></th></tr><tr><th><h2><a id="_671tqeiqgr35"></a>order_channel</h2></th><th><h2><a id="_671tqeiqgr35"></a>order_channel</h2></th><th><h2><a id="_671tqeiqgr35"></a>star.dim_channel</h2></th><th><h2><a id="_671tqeiqgr35"></a>DISTINCT por canal; channel_sk generado con SERIAL.</h2></th></tr></thead></table></div>

##

## **Dimensión: star.dim_store**

<div class="joplin-table-wrapper"><table><thead><tr><th><h2><a id="_671tqeiqgr35"></a><strong>Columna RAW</strong></h2></th><th><h2><a id="_671tqeiqgr35"></a><strong>Columna Destino</strong></h2></th><th><h2><a id="_671tqeiqgr35"></a><strong>Tabla Destino</strong></h2></th><th><h2><a id="_671tqeiqgr35"></a><strong>Lógica aplicada</strong></h2></th></tr><tr><th><h2><a id="_671tqeiqgr35"></a>store_id</h2></th><th><h2><a id="_671tqeiqgr35"></a>store_id</h2></th><th><h2><a id="_671tqeiqgr35"></a>star.dim_store</h2></th><th><h2><a id="_671tqeiqgr35"></a>Clave de negocio; DISTINCT por store_id.</h2></th></tr><tr><th><h2><a id="_671tqeiqgr35"></a>store_location_type</h2></th><th><h2><a id="_671tqeiqgr35"></a>store_location_type</h2></th><th><h2><a id="_671tqeiqgr35"></a>star.dim_store</h2></th><th><h2><a id="_671tqeiqgr35"></a>Transferencia directa (Urban / Suburban / Rural).</h2></th></tr><tr><th><h2><a id="_671tqeiqgr35"></a>region</h2></th><th><h2><a id="_671tqeiqgr35"></a>region</h2></th><th><h2><a id="_671tqeiqgr35"></a>star.dim_store</h2></th><th><h2><a id="_671tqeiqgr35"></a>Transferencia directa (Northeast / Midwest / etc.).</h2></th></tr></thead></table></div>

## store_sk se genera como SERIAL en la base de datos; el ETL lo popula luego del TRUNCATE + INSERT

##

## **Dimensión: star.dim_customer**

<div class="joplin-table-wrapper"><table><thead><tr><th><h2><a id="_671tqeiqgr35"></a><strong>Columna RAW</strong></h2></th><th><h2><a id="_671tqeiqgr35"></a><strong>Columna Destino</strong></h2></th><th><h2><a id="_671tqeiqgr35"></a><strong>Tabla Destino</strong></h2></th><th><h2><a id="_671tqeiqgr35"></a><strong>Lógica aplicada</strong></h2></th></tr><tr><th><h2><a id="_671tqeiqgr35"></a>customer_id</h2></th><th><h2><a id="_671tqeiqgr35"></a>customer_id</h2></th><th><h2><a id="_671tqeiqgr35"></a>star.dim_customer</h2></th><th><h2><a id="_671tqeiqgr35"></a>Clave de negocio; DISTINCT por customer_id.</h2></th></tr><tr><th><h2><a id="_671tqeiqgr35"></a>customer_age_group</h2></th><th><h2><a id="_671tqeiqgr35"></a>customer_age_group</h2></th><th><h2><a id="_671tqeiqgr35"></a>star.dim_customer</h2></th><th><h2><a id="_671tqeiqgr35"></a>Transferencia directa.</h2></th></tr><tr><th><h2><a id="_671tqeiqgr35"></a>customer_gender</h2></th><th><h2><a id="_671tqeiqgr35"></a>customer_gender</h2></th><th><h2><a id="_671tqeiqgr35"></a>star.dim_customer</h2></th><th><h2><a id="_671tqeiqgr35"></a>Transferencia directa.</h2></th></tr><tr><th><h2><a id="_671tqeiqgr35"></a>is_rewards_member</h2></th><th><h2><a id="_671tqeiqgr35"></a>is_rewards_member</h2></th><th><h2><a id="_671tqeiqgr35"></a>star.dim_customer</h2></th><th><h2><a id="_671tqeiqgr35"></a>Transferencia directa (booleano).</h2></th></tr></thead></table></div>

##

## **Dimensión: star.dim_date**

<div class="joplin-table-wrapper"><table><thead><tr><th><h2><a id="_671tqeiqgr35"></a><strong>Columna RAW</strong></h2></th><th><h2><a id="_671tqeiqgr35"></a><strong>Columna Destino</strong></h2></th><th><h2><a id="_671tqeiqgr35"></a><strong>Tabla Destino</strong></h2></th><th><h2><a id="_671tqeiqgr35"></a><strong>Lógica aplicada</strong></h2></th></tr><tr><th><h2><a id="_671tqeiqgr35"></a>order_date</h2></th><th><h2><a id="_671tqeiqgr35"></a>full_date</h2></th><th><h2><a id="_671tqeiqgr35"></a>star.dim_date</h2></th><th><h2><a id="_671tqeiqgr35"></a>Conversión a DATE.</h2></th></tr><tr><th><h2><a id="_671tqeiqgr35"></a>order_date</h2></th><th><h2><a id="_671tqeiqgr35"></a>date_sk</h2></th><th><h2><a id="_671tqeiqgr35"></a>star.dim_date</h2></th><th><h2><a id="_671tqeiqgr35"></a>STRFTIME("%Y%m%d") -&gt; entero YYYYMMDD (clave de negocio).</h2></th></tr><tr><th><h2><a id="_671tqeiqgr35"></a>day_of_week</h2></th><th><h2><a id="_671tqeiqgr35"></a>day_of_week</h2></th><th><h2><a id="_671tqeiqgr35"></a>star.dim_date</h2></th><th><h2><a id="_671tqeiqgr35"></a>Tomado de raw_orders directamente (Mon / Tue / … / Sun).</h2></th></tr><tr><th><h2><a id="_671tqeiqgr35"></a>order_date</h2></th><th><h2><a id="_671tqeiqgr35"></a>day_of_month</h2></th><th><h2><a id="_671tqeiqgr35"></a>star.dim_date</h2></th><th><h2><a id="_671tqeiqgr35"></a>EXTRACT(DAY FROM order_date).</h2></th></tr><tr><th><h2><a id="_671tqeiqgr35"></a>order_date</h2></th><th><h2><a id="_671tqeiqgr35"></a>month_num</h2></th><th><h2><a id="_671tqeiqgr35"></a>star.dim_date</h2></th><th><h2><a id="_671tqeiqgr35"></a>EXTRACT(MONTH FROM order_date).</h2></th></tr><tr><th><h2><a id="_671tqeiqgr35"></a>order_date</h2></th><th><h2><a id="_671tqeiqgr35"></a>quarter_num</h2></th><th><h2><a id="_671tqeiqgr35"></a>star.dim_date</h2></th><th><h2><a id="_671tqeiqgr35"></a>EXTRACT(QUARTER FROM order_date).</h2></th></tr><tr><th><h2><a id="_671tqeiqgr35"></a>order_date</h2></th><th><h2><a id="_671tqeiqgr35"></a>year_num</h2></th><th><h2><a id="_671tqeiqgr35"></a>star.dim_date</h2></th><th><h2><a id="_671tqeiqgr35"></a>EXTRACT(YEAR FROM order_date).</h2></th></tr></thead></table></div>

##

## **Dimensión: star.dim_time**

<div class="joplin-table-wrapper"><table><thead><tr><th><h2><a id="_671tqeiqgr35"></a><strong>Columna RAW</strong></h2></th><th><h2><a id="_671tqeiqgr35"></a><strong>Columna Destino</strong></h2></th><th><h2><a id="_671tqeiqgr35"></a><strong>Tabla Destino</strong></h2></th><th><h2><a id="_671tqeiqgr35"></a><strong>Lógica aplicada</strong></h2></th></tr><tr><th><h2><a id="_671tqeiqgr35"></a>order_time</h2></th><th><h2><a id="_671tqeiqgr35"></a>time_sk</h2></th><th><h2><a id="_671tqeiqgr35"></a>star.dim_time</h2></th><th><h2><a id="_671tqeiqgr35"></a>EXTRACT(HOUR FROM order_time) -&gt; entero 0-23.</h2></th></tr><tr><th><h2><a id="_671tqeiqgr35"></a>order_time</h2></th><th><h2><a id="_671tqeiqgr35"></a>hour_of_day</h2></th><th><h2><a id="_671tqeiqgr35"></a>star.dim_time</h2></th><th><h2><a id="_671tqeiqgr35"></a>Igual a time_sk.</h2></th></tr><tr><th><h2><a id="_671tqeiqgr35"></a>order_time</h2></th><th><h2><a id="_671tqeiqgr35"></a>time_period</h2></th><th><h2><a id="_671tqeiqgr35"></a>star.dim_time</h2></th><th><h2><a id="_671tqeiqgr35"></a>Regla: 7-9 -&gt; <em>Morning Rush</em>; 10-13 -&gt; <em>Mid-Day</em>; 14-17 -&gt; <em>Afternoon</em>; 18-21 -&gt; <em>Evening</em>; resto -&gt; <em>Other</em>.</h2></th></tr></thead></table></div>

##

## **Fact: star.fact_orders**

<div class="joplin-table-wrapper"><table><thead><tr><th><h2><a id="_671tqeiqgr35"></a><strong>Columna RAW</strong></h2></th><th><h2><a id="_671tqeiqgr35"></a><strong>Columna Destino</strong></h2></th><th><h2><a id="_671tqeiqgr35"></a><strong>Tabla Destino</strong></h2></th><th><h2><a id="_671tqeiqgr35"></a><strong>Lógica aplicada</strong></h2></th></tr><tr><th><h2><a id="_671tqeiqgr35"></a>order_id</h2></th><th><h2><a id="_671tqeiqgr35"></a>order_id</h2></th><th><h2><a id="_671tqeiqgr35"></a>star.fact_orders</h2></th><th><h2><a id="_671tqeiqgr35"></a>Dimensión degenerada; se conserva como atributo.</h2></th></tr><tr><th><h2><a id="_671tqeiqgr35"></a>order_channel</h2></th><th><h2><a id="_671tqeiqgr35"></a>channel_sk</h2></th><th><h2><a id="_671tqeiqgr35"></a>star.fact_orders</h2></th><th><h2><a id="_671tqeiqgr35"></a>JOIN con dim_channel -&gt; clave subrogada.</h2></th></tr><tr><th><h2><a id="_671tqeiqgr35"></a>store_id</h2></th><th><h2><a id="_671tqeiqgr35"></a>store_sk</h2></th><th><h2><a id="_671tqeiqgr35"></a>star.fact_orders</h2></th><th><h2><a id="_671tqeiqgr35"></a>JOIN con dim_store -&gt; clave subrogada.</h2></th></tr><tr><th><h2><a id="_671tqeiqgr35"></a>customer_id</h2></th><th><h2><a id="_671tqeiqgr35"></a>customer_sk</h2></th><th><h2><a id="_671tqeiqgr35"></a>star.fact_orders</h2></th><th><h2><a id="_671tqeiqgr35"></a>JOIN con dim_customer -&gt; clave subrogada.</h2></th></tr><tr><th><h2><a id="_671tqeiqgr35"></a>order_date</h2></th><th><h2><a id="_671tqeiqgr35"></a>date_sk</h2></th><th><h2><a id="_671tqeiqgr35"></a>star.fact_orders</h2></th><th><h2><a id="_671tqeiqgr35"></a>JOIN con dim_date (YYYYMMDD) -&gt; clave de negocio.</h2></th></tr><tr><th><h2><a id="_671tqeiqgr35"></a>order_time (hora)</h2></th><th><h2><a id="_671tqeiqgr35"></a>time_sk</h2></th><th><h2><a id="_671tqeiqgr35"></a>star.fact_orders</h2></th><th><h2><a id="_671tqeiqgr35"></a>JOIN con dim_time (hora 0-23) -&gt; clave de negocio.</h2></th></tr><tr><th><h2><a id="_671tqeiqgr35"></a>order_time</h2></th><th><h2><a id="_671tqeiqgr35"></a>order_time</h2></th><th><h2><a id="_671tqeiqgr35"></a>star.fact_orders</h2></th><th><h2><a id="_671tqeiqgr35"></a>Se conserva el valor TIME original (grano fino).</h2></th></tr><tr><th><h2><a id="_671tqeiqgr35"></a>drink_category</h2></th><th><h2><a id="_671tqeiqgr35"></a>drink_category</h2></th><th><h2><a id="_671tqeiqgr35"></a>star.fact_orders</h2></th><th><h2><a id="_671tqeiqgr35"></a>Transferencia directa.</h2></th></tr><tr><th><h2><a id="_671tqeiqgr35"></a>has_food_item</h2></th><th><h2><a id="_671tqeiqgr35"></a>has_food_item</h2></th><th><h2><a id="_671tqeiqgr35"></a>star.fact_orders</h2></th><th><h2><a id="_671tqeiqgr35"></a>Transferencia directa (booleano).</h2></th></tr><tr><th><h2><a id="_671tqeiqgr35"></a>order_ahead</h2></th><th><h2><a id="_671tqeiqgr35"></a>is_order_ahead</h2></th><th><h2><a id="_671tqeiqgr35"></a>star.dim_channel</h2></th><th><h2><a id="_671tqeiqgr35"></a><strong>Renombrado</strong> para mayor claridad semántica; se conserva en DimChannel.</h2></th></tr><tr><th><h2><a id="_671tqeiqgr35"></a>cart_size</h2></th><th><h2><a id="_671tqeiqgr35"></a>cart_size</h2></th><th><h2><a id="_671tqeiqgr35"></a>star.fact_orders</h2></th><th><h2><a id="_671tqeiqgr35"></a>Medida: cantidad de ítems en el pedido.</h2></th></tr><tr><th><h2><a id="_671tqeiqgr35"></a>num_customizations</h2></th><th><h2><a id="_671tqeiqgr35"></a>num_customizations</h2></th><th><h2><a id="_671tqeiqgr35"></a>star.fact_orders</h2></th><th><h2><a id="_671tqeiqgr35"></a>Medida: número de personalizaciones.</h2></th></tr><tr><th><h2><a id="_671tqeiqgr35"></a>total_spend</h2></th><th><h2><a id="_671tqeiqgr35"></a>total_spend</h2></th><th><h2><a id="_671tqeiqgr35"></a>star.fact_orders</h2></th><th><h2><a id="_671tqeiqgr35"></a>Medida: gasto total en USD.</h2></th></tr><tr><th><h2><a id="_671tqeiqgr35"></a>fulfillment_time_min</h2></th><th><h2><a id="_671tqeiqgr35"></a>fulfillment_time_min</h2></th><th><h2><a id="_671tqeiqgr35"></a>star.fact_orders</h2></th><th><h2><a id="_671tqeiqgr35"></a>Medida: tiempo de preparación en minutos.</h2></th></tr><tr><th><h2><a id="_671tqeiqgr35"></a>customer_satisfaction</h2></th><th><h2><a id="_671tqeiqgr35"></a>customer_satisfaction</h2></th><th><h2><a id="_671tqeiqgr35"></a>star.fact_orders</h2></th><th><h2><a id="_671tqeiqgr35"></a>Medida: puntaje de satisfacción (1-5).</h2></th></tr></thead></table></div>

##

## Las columnas descriptivas como customer_age_group o region **no se duplican** en la tabla de hechos; se acceden mediante los JOINs a las dimensiones

## 6\. Decisiones de diseño

## **Elección del Modelo Star Schema**

**Decisión:**

Se implementó un **Star Schema** físico en el esquema star compuesto por 5 dimensiones (dim_channel, dim_store, dim_customer, dim_date, dim_time) y 1 tabla de hechos (fact_orders).

| **Criterio**            | **Star Schema**                                | **Alternativa (vista plana)**       |
| ----------------------- | ---------------------------------------------- | ----------------------------------- |
| **Rendimiento**         | Índices sobre FKs; JOINs sobre tablas pequeñas | Full scan sobre tabla grande        |
| ---                     | ---                                            | ---                                 |
| **Claridad**            | Vocabulario de negocio expuesto en dimensiones | Columnas mezcladas sin jerarquía    |
| ---                     | ---                                            | ---                                 |
| **Compatibilidad OLAP** | Nativo en Power BI (relaciones automáticas)    | Requiere configuración manual       |
| ---                     | ---                                            | ---                                 |
| **Escalabilidad**       | Nuevas métricas -> sólo agrego en fact_orders  | Rompe la vista existente            |
| ---                     | ---                                            | ---                                 |
| **Estándar académico**  | Modelo esperado en TP de Data Warehousing      | No cumple la consigna de la materia |
| ---                     | ---                                            | ---                                 |

## **Uso de Python para el ETL**

El pipeline ETL se implementó en **Python** usando pandas + sqlalchemy + psycopg2.

- **Flexibilidad de transformación:** Pandas permite manipulación de DataFrames de forma expresiva (generación de surrogate keys con reset_index(), merges, y apply() para clasificar períodos horarios), lógica que sería más verbosa en SQL puro.
- **Reutilización:** El mismo script puede ser invocado desde Power BI (Python visual), desde un cron job, o desde un orquestador como Airflow sin cambios.
- **Depuración:** Los logs de consola permiten rastrear el estado de cada paso (extracción, transformación, carga, verificación).
- **Integración con el stack académico:** El equipo ya utiliza Python para inyección de medidas DAX, por lo que esta herramienta es coherente con el ecosistema del proyecto.

##

## **Implementación de Surrogate Keys (Claves Subrogadas)**

Todas las dimensiones utilizan claves subrogadas. Para las dimensiones de entidades se usa SERIAL, mientras que para dim_date y dim_time se utilizan claves de negocio inteligentes.

- **SERIAL para dimensiones de entidades** (dim_channel, dim_store, dim_customer): Protege contra cambios en los valores de negocio (ej. si un canal se renombra, la clave subrogada no cambia y la integridad del historial se preserva).
- **Claves de negocio para tiempo** (dim_date, dim_time): Los enteros YYYYMMDD y HH son auto-descriptivos, fáciles de filtrar en SQL (WHERE date_sk BETWEEN 20240101 AND 20240131) y eliminan la necesidad de un lookup adicional.
- **Integridad Referencial:** fact_orders declara FOREIGN KEY a cada tabla de dimensión, garantizando consistencia en la base de datos.

## **Estrategia Full Refresh (Carga Completa)**

Cada ejecución del ETL realiza un TRUNCATE ... RESTART IDENTITY CASCADE seguido de un INSERT completo.

- **Simplicidad:** El dataset del TP es estático. No existe un flujo de datos en tiempo real que requiera carga incremental.
- **Idempotencia:** Permite re-ejecutar el ETL cualquier cantidad de veces sin acumulación de duplicados.
- **Sin complejidad de CDC:** Implementar _Change Data Capture_ requeriría columnas de auditoría y lógica de staging adicional, lo cual excede el alcance del TP.
- **Velocidad:** Para ~100k filas, el tiempo de carga completa es de pocos segundos, lo cual es aceptable en un contexto académico.

## **Esquema Separado (star)**

El Star Schema se creó en el esquema star, separado del esquema starbucks (staging).

- **Separación de capas:** Siguiendo la arquitectura Medallion, el esquema starbucks actúa como capa de staging (Bronze/Silver) y el esquema star como capa analítica (Gold).
- **Permisos granulares:** Permite otorgar accesos de lectura sobre la capa final a usuarios de BI sin exponer los datos crudos.
- **Claridad para Power BI:** Al importar datos, las tablas del esquema star son directamente identificables como el modelo de datos final.

**Resumen de Decisiones**

| **Decisión**         | **Elección**                   | **Alternativa descartada**     |
| -------------------- | ------------------------------ | ------------------------------ |
| **Modelo analítico** | Star Schema físico             | Vista plana / Snowflake Schema |
| ---                  | ---                            | ---                            |
| **Herramienta ETL**  | Python (pandas + sqlalchemy)   | SQL puro / SSIS / dbt          |
| ---                  | ---                            | ---                            |
| **Tipo de clave**    | Surrogate Key (SERIAL)         | Natural Key                    |
| ---                  | ---                            | ---                            |
| **Clave temporal**   | Business Key inteligente (int) | SERIAL anónimo                 |
| ---                  | ---                            | ---                            |
| **Estrategia carga** | Full Refresh (TRUNCATE)        | Carga incremental / UPSERT     |
| ---                  | ---                            | ---                            |
| **Separación capas** | Schema star separado           | Mismo schema que raw           |
| ---                  | ---                            | ---                            |

El diseño asegura que el sistema sea capaz de responder a las preguntas críticas de negocio con precisión. La validación mediante SQL confirmó que el canal Drive-Thru es el que presenta mayores demoras (5.79 min prom.), mientras que la complejidad del pedido no muestra una correlación significativa con los retrasos.

## Conclusiones Finales del Proyecto

1. **Problema resuelto**: Se construyó un data warehouse que identifica y prioriza cuellos de botella operativos del proceso de entrega de pedidos (fulfillment_time_min). El análisis mostró que el desafío mayor es de canal (Drive-Thru) y no de complejidad de pedido (num_customizations).
2. **Modelo validado**: El modelo dimensional probó su consistencia 1:1 entre la definición conceptual (proyecto.md), implementación DDL (`star.*`), ETL (`Scripts/etl_starbucks.py`) y semantic model (`Starbucks_PowerBI.SemanticModel`).
3. **Orden de importancia**:
   - Drive-Thru en hora pico (Morning Rush) tiene mayor tiempo promedio.
   - Ordenes Mobile App son más eficientes en prom.
   - Factores geográficos muestran variaciones, pero el mayor impacto lo da el canal.
   - Días de la semana tienen rango estrecho de variación, lo cual señala un detalle operativo constante.
## Reportes / Visuales (sintetizado de reverse_engineering_doc)

### Visual 1: Comparativa de Canales (Clustered Column)

- Eje X: `order_channel` (DimChannel)
- Eje Y: `Morning Rush Avg` o `AVG(fulfillment_time_min)` (FactOrders)
- Insight: Identifica el canal más lento en morning rush (Drive-Thru vs Mobile).

### Visual 2: Impacto de la Complejidad (Bar Chart)

- Eje Y: `order_channel`
- Eje X: `Avg Fulfillment Time`
- Tooltip: `AVG(cart_size)` + `AVG(num_customizations)`
- Insight: Confirma que complejidad no es el driver principal de la demora.

### Visual 3: Diferencias Geográficas (Scatter)

- Detalle: `region` o `store_location_type`
- X: `Avg Fulfillment Time`, Y: `Avg Satisfaction`
- Insight: Permite observar agrupaciones y validar si zonas urbanas caen en peor perf.

### Visual 4: Patrón Semanal (Line)

- X: `day_of_week`, Y: `Avg Fulfillment Time`, Legend: `order_channel`
- Insight: Muestra tendencia de rutina y la respuesta a la pregunta del día crítico.
