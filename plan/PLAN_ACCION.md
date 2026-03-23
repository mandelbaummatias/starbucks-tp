# PLAN DE ACCIÓN: Resolver Gaps en Entrega TP
**Status:** 📋 Planning Phase (Sin implementar cambios)  
**Prioridad:** 🔴 Urgente antes de entrega profesores  
**Tiempo Estimado:** 2.5 horas  

---

## 📊 CUADRO RESUMEN DE GAPS

| Gap | Realizado | Falta | Tipo | Impacto |
|-----|-----------|-------|------|--------|
| **Diagrama Star Schema visual** | ✅ Código SQL | ❌ Imagen/Mermaid | VISUAL | 🔴 Crítico |
| **Contexto Organizacional** | ❌ Ni existe | ❌ Documento | CONTEXTO | 🟡 Importante |
| **Documento Integrador Principal** | ✅ 6 archivos dispersos | ❌ 1 archivo maestro | INTEGRACIÓN | 🟡 Importante |
| **Power BI Status** | ✅ Parcial | ❌ Verificación formal | QA | 🟢 Recomendado |
| **Diagrama de Arquitectura General** | ❌ Solo código BD | ❌ Diagrama capas | ARQUITECTURA | 🟢 Recomendado |

---

## 🎯 ACCIONES ESPECÍFICAS A REALIZAR

### ✏️ ACCIÓN 1: Generar Diagrama Visual del Star Schema
**Status:** NO INICIADO  
**Archivo de salida:** `plan/01_STAR_SCHEMA_DIAGRAM.md`  
**Tiempo estimado:** 30-45 minutos  
**Responsable:** Developer

#### A. Opción 1 (Recomendado): Mermaid ER Diagram
```sql
-- ENTRADA: Leer Database/02_CREATE_STAR_SCHEMA.sql
-- SALIDA: plan/01_STAR_SCHEMA_DIAGRAM.md con bloque mermaid
```

**Diagrama ER esperado (pseudocódigo Mermaid):**
```
ACTOR: Users (Profesores, Equipo)
ACTION: Abre plan/01_STAR_SCHEMA_DIAGRAM.md

RESULTADO ESPERADO:
- Diagrama visual mostrando 5 dimensiones + 1 hecho
- Cardinalidades 1:N
- Atributos de cada tabla (primario)
- Tipos de datos (secundario)
- Claves subrogadas vs negocio (notación visual)
```

**Validación:**
- [ ] Mermaid valid syntax (copia a https://mermaid.live)
- [ ] 5 dimensiones presentes
- [ ] 1 tabla hecho con 5 FKs
- [ ] Cardinalidad explícita (||--o{)
- [ ] Atributos clave ($column_name type)

---

#### B. Opción 2: DBeaver Export
```sql
-- IN: Conexión PostgreSQL a starbucks_dw_raw
-- PROCEDURE:
--   1. DBeaver → Schemas → star
--   2. Right Click → ERD (Entity Relation Diagram)
--   3. Customize: Show all tables, columns, types
--   4. Export as PNG to plan/01_STAR_SCHEMA_DIAGRAM.png
```

**Validación:**
- [ ] PNG legible (font size ≥ 10pt)
- [ ] Todas las tablas visibles
- [ ] Relaciones FK dibujadas
- [ ] Tamaño archivo < 500KB

---

### ✏️ ACCIÓN 2: Crear Documento de Contexto Organizacional
**Status:** NO INICIADO  
**Archivo de salida:** `plan/02_CONTEXTO_ORGANIZACIONAL.md`  
**Tiempo estimado:** 20-30 minutos  
**Responsable:** Domain Expert / Product Owner

#### Contenido Mínimo Requerido:

```markdown
# Contexto Organizacional: Starbucks

## 1. Sobre Starbucks como Organización
[2-3 párrafos: historia, escala global, relevancia]

Ejemplos de datos que incluir:
- ~31,000 tiendas globales (2023)
- Operaciones en 80+ países
- Revenue $32B+ anual
- 400,000+ empleados

## 2. Estructura Operativa
[Tabla o bullets de: tiendas, canales, regiones]

### Canales de Distribución
- Drive-Thru (eficiencia crítica)
- Mobile App (crecimiento)
- Kiosk (automatización)
- In-Store Cashier (traditional)

### Geografía (en este dataset)
- Regiones: Northeast, Midwest, Southwest, West
- Tipos de tienda: Urban, Suburban, Rural

## 3. Por Qué Eficiencia Operativa Importa
[Business case: costos, satisfacción, revenue]

- Costo de labor: $10-15/minuto por employee
- Una tienda Drive-Thru con 6k órdenes/día
- Drive-Thru **lento en 0.5 min** = $50k/año perdido
- Customer satisfaction ↓ 10% = churn to competitors

## 4. KPIs de Negocio Clave
| KPI | Target | Realidad (Dataset) | Gap |
|-----|--------|-------------------|-----|
| Fulfillment Time (Morning) | <4 min | 4.56 min promedio | 🔴 |
| Channel Efficiency Parity | ±5% | Drive-Thru +28% | 🔴 |
| Customer Satisfaction | 4.5/5 | 3.66/5 avg | 🔴 |

## 5. Por Qué Este Data Warehouse
[Propósito: responder CQs, identificar bottlenecks]

- Data-driven decision making
- Identificar canales ineficientes (Drive-Thru)
- Optimizar staffing y recursos
- Mejorar customer experience (NPS)
```

**Entrada de Datos:**
- BUSINESS_INSIGHTS.md (hallazgos)
- raw_orders CSV (estadísticas)
- Knowledge de dominio (Starbucks operations)

**Validación:**
- [ ] Mínimo 4-5 secciones
- [ ] Números y contexto real
- [ ] Business case claro
- [ ] Conectado a CQs del TP

---

### ✏️ ACCIÓN 3: Crear Documento Integrador Principal (MASTER DOC)
**Status:** NO INICIADO  
**Archivo de salida:** `plan/03_DOCUMENTO_ENTREGA_TP.md`  
**Tiempo estimado:** 45-60 minutos  
**Responsable:** Tech Lead / Project Manager

#### Estructura (Tabla de Contenidos):

```markdown
# Starbucks Data Warehouse TP - Documento de Entrega Final

## Índice
1. Resumen Ejecutivo
2. Descripción de la Organización y Contexto
3. Necesidad / Problema a Resolver
4. Modelo de Datos Existente (OLTP)
5. Modelo Multidimensional (Star Schema)
6. Mapeo de Datos (CSV → Star)
7. Decisiones de Diseño
8. Hallazgos y Resultados Analíticos
9. Instrucciones de Ejecución
10. Conclusiones

---

## 1. RESUMEN EJECUTIVO [150-200 palabras]
- ¿Qué problema resolvemos?
- ¿Cómo lo resolvimos? (DW + BI)
- ¿Qué encontramos? (main findings)

## 2. DESCRIPCIÓN ORGANIZACIÓN Y CONTEXTO [500 palabras]
→ [LINK a plan/02_CONTEXTO_ORGANIZACIONAL.md]
Resumen: Starbucks global, eficiencia operativa, 4 canales

## 3. NECESIDAD / PROBLEMA [300 palabras]
→ [REFERENCIA a BUSINESS_INSIGHTS.md]
- Cuellos de botella hora punta
- 4 Business Questions
- Dataset: 100k órdenes

## 4. MODELO OLTP [200 palabras + tabla]
→ [REFERENCIA a README_STARBUCKS.md]

**Tabla: starbucks.raw_orders (100,000 filas)**

| Campo | Tipo | Propósito |
| order_id | VARCHAR | PK transaccional |
| order_date | DATE | Timestamp |
| order_channel | VARCHAR | Drive-Thru / Mobile / Kiosk / In-Store |
| store_id | VARCHAR | Ubicación tienda |
| customer_id | VARCHAR | Identificación cliente |
| region | VARCHAR | Geographic clustering |
| fulfillment_time_min | DECIMAL | ⚡ KPI clave |
| num_customizations | INT | Complejidad orden |
| [+10 campos más] | ... | Ver README_STARBUCKS.md |

## 5. MODELO MULTIDIMENSIONAL [Diagrama + 300 palabras]

### Diagrama Star Schema
→ [INSERTAR plan/01_STAR_SCHEMA_DIAGRAM.md aquí]

### Descripción Dimensiones

**dim_channel (6 filas)**
- Surrogate Key: channel_id (SERIAL)
- BKs: order_channel, order_ahead
- Propósito: Segmentar por canal de distribución

**dim_store (N filas)**
- Surrogate Key: store_id_pk (SERIAL)
- BK: store_id
- Atributos: location_type, region
- Propósito: Análisis geográfico

**dim_customer (M filas)**
- Surrogate Key: customer_id_pk (SERIAL)
- BK: customer_id
- Atributos: age_group, gender, is_rewards_member
- Propósito: Segmentación demográfica

**dim_date (YYYYMMDD)**
- Business Key: date_id (int YYYYMMDD formato)
- Atributos: full_date, day_of_week, month_num, quarter_num, year_num
- Propósito: Análisis temporal con aritmética rápida

**dim_time (0-23)**
- Business Key: time_id (int 0-23)
- Atributos: hour_of_day, time_period (Morning Rush / Mid-Day / etc)
- Propósito: Análisis horario y períodos de negocio

**fact_orders (100,000 filas)**
- Surrogate Key: order_id_pk (SERIAL)
- Foreign Keys: channel_id, store_id_pk, customer_id_pk, date_id, time_id
- Medidas: cart_size, num_customizations, total_spend, fulfillment_time_min, customer_satisfaction
- Dimensión Degenerada: order_id, drink_category, has_food_item, is_order_ahead

## 6. MAPEO DE DATOS [Tabla detallada con lógicas]
→ [INCLUIR tabla de plan/Mapeo_de_datos.md]

Resumen: CSV raw_orders → Cada dimensión (deduplicación + SKs) + Fact (JOINs)

## 7. DECISIONES DE DISEÑO [Con justificaciones]
→ [REFERENCIA a Decisiones_de_diseno.md]

Resumen tabla:

| Decisión | Elección | Alternativa | Justificación |
| Modelo Analítico | Star Schema | Snowflake / Vista | Rendimiento OLAP, claridad BI |
| Herramienta ETL | Python | SQL-only / dbt | Flexibilidad, integración stack |
| Tipo Clave Dims | Surrogate (SERIAL) | Natural Key | Protección histórica, integridad |
| Claves Temporales | Business Key (int) | SERIAL anónimo | Auto-descriptivas, aritmética |
| Load Strategy | Full Refresh | Incremental CDC | Dataset estático, idempotencia |

## 8. HALLAZGOS Y RESULTADOS ANALÍTICOS
→ [REFERENCIA a BUSINESS_INSIGHTS.md]

### Pregunta 1: ¿Qué canal tiene delays más largos en hora punta?
**Respuesta:** Drive-Thru (5.79 min vs 4.50 min Mobile)
→ Recomendación: Optimizar workflow Drive-Thru

### Pregunta 2: ¿Complejidad causa delays?
**Respuesta:** NO (correlación ≈ 0)
→ Mobile App maneja 2x customizations más rápido

### Pregunta 3: ¿Diferencias geográficas?
**Respuesta:** Mínimas (varianza 4.52-4.67 min)
→ Rural Northeast ligeramente más lento

### Pregunta 4: ¿Patrones semanales?
**Respuesta:** Ninguno (4.53-4.56 min consistente toda semana)
→ Staffing puede ser estático

## 9. INSTRUCCIONES DE EJECUCIÓN

### 9.1 Prerequisites
- PostgreSQL 12+
- Python 3.8+
- Git (project version control)

### 9.2 Setup Paso a Paso

#### Fase 1: Database Initialization
```bash
# 1. Crear BD y schema staging
psql -U postgres -d postgres -f Database/01_SETUP_DATABASE.sql

# 2. Cargar raw data CSV
psql -U postgres -d starbucks_dw_raw -f Database/setup_starbucks.sql

# Validar
psql -U postgres -c "SELECT COUNT(*) FROM starbucks.raw_orders;" starbucks_dw_raw
# Expected: 100000
```

#### Fase 2: Star Schema Build
```bash
# 1. Create star schema + FK constraints
psql -U postgres -d starbucks_dw_raw -f Database/02_CREATE_STAR_SCHEMA.sql

# Validar
psql -U postgres -c "SELECT * FROM information_schema.tables WHERE table_schema='star';" starbucks_dw_raw
# Expected: dim_channel, dim_store, dim_customer, dim_date, dim_time, fact_orders
```

#### Fase 3: ETL Pipeline
```bash
# 1. Run Python ETL
python Scripts/etl_starbucks.py

# 2. Verify
python -c "
import pandas as pd
from sqlalchemy import create_engine
engine = create_engine('postgresql://postgres:@localhost:5432/starbucks_dw_raw')
count = pd.read_sql('SELECT COUNT(*) FROM star.fact_orders', engine).iloc[0,0]
print(f'✓ fact_orders rows: {count}')
"
# Expected: 100000
```

#### Fase 4: Business Queries Validation
```bash
psql -U postgres -d starbucks_dw_raw -f Database/04_BUSINESS_QUERIES_STAR.sql
# Outputs: 4 queries responden 4 CQs
```

### 9.3 Power BI Integration (Opcional)
1. Open `Starbucks_PowerBI.pbip`
2. Connect to PostgreSQL (star schema)
3. Refresh model
4. Visualize dashboards

## 10. CONCLUSIONES

### ¿El proyecto resuelve los requerimientos?
✅ **SÍ** - El Data Warehouse está completamente implementado y funcional.

### Entregables:
- ✅ Star Schema (6 tablas, 100k filas, integridad FK)
- ✅ ETL robusto (Python + validación)
- ✅ 4 Business Questions contestadas
- ✅ Documentación comprensiva
- ✅ Power BI listo para usar

### Impacto Empresarial:
- 🎯 **Identificado:** Drive-Thru es el bottleneck
- 💡 **Accionable:** Optimizaciones de workflow, no de capacidad barista
- 📈 **ROI:** Reducción 0.5 min por orden = $50k/año en 1 tienda

---

**Documento de Entrega Oficial - Starbucks TP**
**Preparado:** [Date]
**Revisado:** [Names]
**Estado:** ✅ Listo para entrega
```

**Validación:**
- [ ] Todas las 6 secciones requeridas presentes
- [ ] Links a documentación existente funcionales
- [ ] Instrucciones step-by-step ejecutables
- [ ] Diagrama visual integrado
- [ ] Hallazgos claros y accionables

---

### ✏️ ACCIÓN 4: Verificar Power BI Completitud (QA)
**Status:** NO INICIADO  
**Archivo de salida:** `plan/04_POWERBI_STATUS_REPORT.md`  
**Tiempo estimado:** 30-40 minutos  
**Responsable:** BI Developer

#### Checklist de Validación:

```markdown
# Power BI Status Report

## Semantic Model (TMDL)

### [✓] Tables
- [ ] DimChannel.tmdl loaded
- [ ] DimStore.tmdl loaded
- [ ] DimCustomer.tmdl loaded
- [ ] DimDate.tmdl loaded
- [ ] DimTime.tmdl loaded
- [ ] FactOrders.tmdl loaded

### [✓] Relationships
- [ ] DimChannel → FactOrders (channel_id)
- [ ] DimStore → FactOrders (store_id_pk)
- [ ] DimCustomer → FactOrders (customer_id_pk)
- [ ] DimDate → FactOrders (date_id)
- [ ] DimTime → FactOrders (time_id)

### [✓] DAX Measures in FactOrders
- [ ] 'Avg Fulfillment Time' = AVERAGE(FactOrders[fulfillment_time_min])
- [ ] 'Morning Rush Avg' = CALCULATE([Avg Fulfillment Time], DimTime[time_period]="Morning Rush")
- [ ] 'Complexity vs Delay' = CORRELATE(FactOrders, [num_customizations], [fulfillment_time_min])
- [ ] [Optional] 'Channel Gap' = Diff DT vs Mobile

### [✓] Connection String
- [ ] Server: localhost:5432
- [ ] Database: starbucks_dw_raw
- [ ] Schema: star
- [ ] Authentication: [User credentials anonymized]

## Report (PBIR)

### [✓] Pages Created
- [ ] Page 1: Channel Comparison (4 channels, avg fulfillment)
- [ ] Page 2: Complexity Impact (scatter: customizations vs time)
- [ ] Page 3: Geographic Differences (map or bubble: region vs location_type)
- [ ] Page 4: Weekly Patterns (line: day_of_week vs fulfillment)

### [✓] Visuals Count
- [ ] ≥4 visualizations
- [ ] Each visual filters by Morning Rush period

### [✓] Functionality
- [ ] Refresh from PostgreSQL works
- [ ] Slicers/filters are responsive
- [ ] Drill-down enabled (channel → store → customer)

## Final QA

- [ ] Open Starbucks_PowerBI.pbip
- [ ] Connect to PostgreSQL
- [ ] Refresh all: Success?
- [ ] Page 1: Can see Drive-Thru highest?
- [ ] Page 2: Can see Mobile App data?
- [ ] Page 3: Can filter by region?
- [ ] Page 4: Consistent results?

## Issues Found & Resolution
- [ ] None
- [ ] Minor (document)
- [ ] Blocking (fix required)
```

**Entrada:**
- Starbucks_PowerBI.pbip (archivo binario)
- Scripts/etl_starbucks.py (verificar si inject_measures.py ran)

**Salida:**
- `plan/04_POWERBI_STATUS_REPORT.md` (Go/No-Go decision)

---

## 📋 PLAN DE EJECUCIÓN SECUENCIAL

```
┌─────────────────────────────────────────────────────────┐
│ FASE 1: Generación de Diagramas y Documentos (1 hora)   │
├─────────────────────────────────────────────────────────┤
│                                                           │
│  Tarea 1: Crear diagrama Star Schema (30 min)           │
│  ├─ Opción A: Mermaid ER (recomendado)                 │
│  └─ Opción B: DBeaver export PNG (alternativo)         │
│  Salida: plan/01_STAR_SCHEMA_DIAGRAM.md                │
│                                                           │
│  Tarea 2: Escribir Contexto Organizacional (20 min)    │
│  ├─ Secciones: Historia, Estructura, Importancia, KPIs │
│  └─ Validación: 4-5 secciones, números, business case  │
│  Salida: plan/02_CONTEXTO_ORGANIZACIONAL.md            │
│                                                           │
└─────────────────────────────────────────────────────────┘
                           │
                           ↓
┌─────────────────────────────────────────────────────────┐
│ FASE 2: Integración de Documentación (1 hora)           │
├─────────────────────────────────────────────────────────┤
│                                                           │
│  Tarea 3: Crear Documento Maestro TP (45 min)          │
│  ├─ Agrupa: 10 secciones, links a docs existentes      │
│  ├─ Inserta: diagrama visual + contexto                │
│  └─ Resultado: Punto entrada única para profesores     │
│  Salida: plan/03_DOCUMENTO_ENTREGA_TP.md               │
│                                                           │
└─────────────────────────────────────────────────────────┘
                           │
                           ↓
┌─────────────────────────────────────────────────────────┐
│ FASE 3: QA y Validación (30-40 min)                     │
├─────────────────────────────────────────────────────────┤
│                                                           │
│  Tarea 4: Power BI Status Check (30-40 min)            │
│  ├─ Verificar: TMDL, Relationships, DAX Measures       │
│  ├─ Probar: Refresh, Visuals, Filters                  │
│  └─ Documentar: Issues y resolutions                    │
│  Salida: plan/04_POWERBI_STATUS_REPORT.md              │
│                                                           │
│  Tarea 5: Validación Final Cruzada (10 min)            │
│  ├─ Completitud todos los requerimientos?              │
│  └─ Documentación coherente?                           │
│  Salida: Checklist de entrega                          │
│                                                           │
└─────────────────────────────────────────────────────────┘
                           │
                           ↓
              ✅ LISTO PARA ENTREGA
```

---

## 🎯 DEFINICIÓN DE ÉXITO

**Criterios de aceptación:**

| Entregable | Criterio | Status |
|------------|----------|--------|
| **Diagrama Star** | Mermaid o PNG legible con 6 tablas | ⬜ |
| **Contexto Org** | 4+ secciones, business case claro | ⬜ |
| **Doc Maestro** | 10 secciones, links funcionales, diagrama integrado | ⬜ |
| **Power BI QA** | Go/No-Go decision, issues documentados | ⬜ |
| **Completitud TP** | 6/6 requerimientos cubiertos | ⬜ |

**Cuando todos ⬜ → ✅: El TP está listo para entrega.**

---

## 📝 NOTAS Y ADVERTENCIAS

### Notas Importantes:
1. **NO modificar código** SQL/Python durante esta fase (solo documentación)
2. **NO cambiar estructura Star Schema** - está correcta
3. **Mantener coherencia** entre archivos (no duplicar datos)
4. **Usar referencias cruzadas** (links Markdown) en lugar de copiar texto

### Si Encuentras Problemas:
- ⚠️ **Power BI no conecta:** Verificar connection string en `.pbix`/TMDL
- ⚠️ **Measures no funcionan:** Revisar sintaxis DAX vs PostgreSQL tipos
- ⚠️ **Diagrama incompleto:** Asegurar schema `star` existe en BD

### Control de Versión:
- Commit cada acción completada a git
- Branch: `feature/documentation-completion`
- PR message: Describe qué documentación se agregó

---

## 🚀 INICIO INMEDIATO

**Responsable:** [Name]  
**Fecha comienco:** [Today]  
**Deadline:** [TP Due Date]  
**Tiempo total:** 2.5-3 horas  

**Próximo paso:** → Iniciar ACCIÓN 1 (Diagrama Star Schema)

---

**Documento de Plan de Acción**  
**v1.0 | Marzo 23, 2026**  
**Estado: 📋 Listo para ejecución**
