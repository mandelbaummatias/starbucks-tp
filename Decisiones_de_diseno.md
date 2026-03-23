# Decisiones de Diseño — Data Warehouse Starbucks TP

Este documento justifica las decisiones técnicas y de modelado tomadas durante
la construcción del Data Warehouse del TP.

---

## 1. Elección del Modelo Star Schema

**Decisión:** Se implementó un Star Schema físico en el esquema `star`
([02_CREATE_STAR_SCHEMA.sql](Database/02_CREATE_STAR_SCHEMA.sql)) compuesto  
por 5 dimensiones (`dim_channel`, `dim_store`, `dim_customer`, `dim_date`,
`dim_time`) y 1 tabla de hechos (`fact_orders`).

**Justificación:**

| Criterio               | Star Schema                              | Alternativa (vista plana)              |
|------------------------|------------------------------------------|----------------------------------------|
| **Rendimiento**        | Índices sobre FKs; JOINs sobre tablas pequeñas | Full scan sobre tabla grande        |
| **Claridad**           | Vocabulario de negocio expuesto en dimensiones | Columnas mezcladas sin jerarquía    |
| **Compatibilidad OLAP**| Nativo en Power BI (relaciones automáticas) | Requiere configuración manual       |
| **Escalabilidad**      | Nuevas métricas → sólo agrego en `fact_orders` | Rompe la vista existente           |
| **Estándar académico** | Modelo esperado en TP de Data Warehousing | No cumple la consigna de la materia |

> **Nota:** Se eligió Star Schema (desnormalizado) sobre Snowflake Schema para
> mantener la simplicidad de los JOINs y el rendimiento de las consultas OLAP,
> que son las prioridades de este TP.

---

## 2. Uso de Python para el ETL

**Decisión:** El pipeline ETL se implementó en Python
([etl_starbucks.py](Scripts/etl_starbucks.py)) usando `pandas` + `sqlalchemy`
+ `psycopg2`.

**Justificación:**

- **Flexibilidad de transformación:** Pandas permite manipulación de DataFrames
  de forma expresiva (generación de surrogate keys con `reset_index()`, merges,
  `apply()` para clasificar períodos horarios, etc.), lógica que sería más
  verbosa en SQL puro.

- **Reutilización:** El mismo script puede ser invocado desde Power BI (Python
  visual), desde un cron job, o desde un orquestador como Airflow sin cambios.

- **Depuración:** Los logs de consola permiten rastrear el estado de cada paso
  (extracción, transformación, carga, verificación).

- **Integración con el stack académico:** El equipo ya utiliza Python para
  inyección de medidas DAX (`inject_measures.py`), por lo que esta herramienta
  es coherente con el ecosistema del proyecto.

---

## 3. Implementación de Surrogate Keys (Claves Subrogadas)

**Decisión:** Todas las dimensiones utilizan claves subrogadas (`SERIAL` en
PostgreSQL). Para las dimensiones `dim_date` y `dim_time` se utilizan claves
de negocio inteligentes (`YYYYMMDD` y `hora 0-23`) en lugar de `SERIAL`.

**Justificación:**

- **`SERIAL` para dimensiones de entidades** (`dim_channel`, `dim_store`,
  `dim_customer`): Protege contra cambios en los valores de negocio (por ej.,
  si un canal se renombra, la clave subrogada no cambia y la integridad del
  historial se preserva).

- **Claves de negocio para tiempo** (`dim_date`, `dim_time`): Los enteros
  `YYYYMMDD` y `hour` son auto-descriptivos, fáciles de filtrar en SQL
  (`WHERE date_sk BETWEEN 20240101 AND 20240131`), y eliminan la necesidad de
  un lookup adicional para entender el rango temporal.

- **Integridad Referencial:** `fact_orders` declara `FOREIGN KEY` a cada tabla
  de dimensión, garantizando consistencia en la base de datos.

---

## 4. Estrategia Full Refresh (Carga Completa)

**Decisión:** Cada ejecución del ETL realiza un `TRUNCATE ... RESTART IDENTITY CASCADE`
seguido de un `INSERT` completo (no incremental).

**Justificación:**

- **Simplicidad:** El dataset del TP es estático (un CSV histórico de ~100k
  filas). No existe un flujo de datos en tiempo real que requiera carga
  incremental.

- **Idempotencia:** Permite re-ejecutar el ETL cualquier cantidad de veces sin
  acumulación de duplicados. Cada ejecución produce exactamente el mismo estado
  final.

- **Sin complejidad de Change Data Capture (CDC):** Implementar CDC requeriría
  columnas `updated_at`, manejo de `UPSERT` (ON CONFLICT), y una lógica de
  staging adicional, lo cual está fuera del alcance del TP.

- **Velocidad aceptable:** Para 100k filas, el tiempo de carga completa
  (TRUNCATE + INSERT vía `to_sql`) es del orden de segundos, que es totalmente
  aceptable en este contexto académico.

---

## 5. Esquema Separado (`star`)

**Decisión:** El Star Schema se creó en el esquema `star`, separado del esquema
`starbucks` (que contiene `raw_orders` y `vw_orders_starbucks`).

**Justificación:**

- **Separación de capas:** Siguiendo la arquitectura Medallion (Bronze/Silver/Gold),
  el esquema `starbucks` actúa como capa de *staging* (Bronze/Silver) y el
  esquema `star` como capa analítica (Gold/Serving).

- **Permisos granulares:** En entornos de producción, se pueden otorgar permisos
  de lectura sobre `star` a usuarios de BI sin exponer los datos crudos.

- **Claridad para Power BI:** Al importar al Semantic Model, las tablas del
  esquema `star` son directamente identificables como el modelo analítico.

---

## Resumen

| Decisión                    | Elección                         | Alternativa descartada           |
|-----------------------------|----------------------------------|----------------------------------|
| Modelo analítico            | Star Schema físico               | Vista plana / Snowflake Schema   |
| Herramienta ETL             | Python (pandas + sqlalchemy)     | SQL puro / SSIS / dbt            |
| Tipo de clave en dimensiones| Surrogate Key (SERIAL)           | Natural Key                      |
| Clave en dim_date/dim_time  | Business Key inteligente (int)   | SERIAL anónimo                   |
| Estrategia de carga         | Full Refresh (TRUNCATE + INSERT) | Carga incremental / UPSERT       |
| Separación de capas         | Schema `star` separado           | Mismo schema que raw             |
