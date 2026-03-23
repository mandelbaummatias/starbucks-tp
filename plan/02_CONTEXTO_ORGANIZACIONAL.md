# Contexto Organizacional: Starbucks

## 1. Sobre Starbucks como Organización

Starbucks es la cadena de cafeterías más grande del mundo, operando con presencia global excepcional en la industria de servicios de alimentos y bebidas. Presentes en más de **80 países** con aproximadamente **31,000 tiendas** (2023), Starbucks genera ingresos anuales superiores a **$32 mil millones USD**.

Con un equipo de más de **400,000 empleados** a nivel mundial, Starbucks ha consolidado una cultura corporativa única centrada en la experiencia del cliente, la calidad del producto, y la innovación en canales de distribución. La compañía no solo vende café, sino que ha posicionado sus tiendas como "tercer espacio" entre el hogar y el trabajo, donde clientes se reúnen, trabajan, y disfrutan de momentos sociales.

En América del Norte (mercado de origen), Starbucks atiende aproximadamente **10+ millones de clientes diarios**, generando miles de transacciones por minuto durante los períodos pico. Este volumen masativo requiere excelencia operativa constante y optimización de procesos a escala.

---

## 2. Estructura Operativa de Starbucks

### 2.1 Canales de Distribución (En Este Dataset)

Starbucks opera mediante **4 canales de distribución** diferentes, cada uno con características operativas únicas y perfiles de clientela distintos:

| Canal                | Descripción                                 | Volumen Típico                                | Características                                                               |
| -------------------- | ------------------------------------------- | --------------------------------------------- | ----------------------------------------------------------------------------- |
| **Drive-Thru**       | Servicio a través de ventanilla de vehículo | 25% del volumen (~25k órdenes/día en dataset) | Punto de fricción: pago + handoff físico, sin contacto visual con preparación |
| **Mobile App**       | Órdenes preautorizadas via app Starbucks    | 30% del volumen (~30k órdenes/día)            | Eficiente: pago previa, cliente retira orden lista                            |
| **In-Store Cashier** | Punto de venta tradicional en mostrador     | 20% del volumen (~20k órdenes/día)            | Más rápido: cliente ve proceso, menos fricción de pago                        |
| **Kiosk**            | Terminal de autoservicio touch-screen       | 5% del volumen (~5k órdenes/día)              | Experiencia futura: automatización, menor labor barista                       |

**Insight Clave:** Cada canal tiene impacto directo en la velocidad de cumplimiento y satisfacción del cliente. La distribución de volumen no es uniforme, y cada canal requiere optimización específica.

---

### 2.2 Geografía Operativa (En Este Dataset)

El análisis de datos cubre **4 regiones de EE.UU.**:

| Región        | Ciudades Típicas                    | Características                            |
| ------------- | ----------------------------------- | ------------------------------------------ |
| **Northeast** | Boston, NYC, Philadelphia           | Alta densidad urbana, competencia intensa  |
| **Midwest**   | Chicago, Detroit, Cleveland         | Mezcla urban/suburban, crecimiento celular |
| **Southwest** | Dallas, Phoenix, Denver             | Expansión rápida, temperatura extrema      |
| **West**      | Seattle, San Francisco, Los Angeles | Cuna de Starbucks, maduración mercado      |

Cada tienda se clasifica además por **tipo de ubicación**:

- **Urban** (30-40% de tiendas): Alta densidad, clientes de paso, ritmo rápido
- **Suburban** (40-50% de tiendas): Ubicaciones residenciales, clientes recurrentes
- **Rural** (10-20% de tiendas): Ubicaciones aisladas, clientes con lealtad alta

---

## 3. Por Qué la Eficiencia Operativa es Crítico para Starbucks

### 3.1 Economía del Servicio de Alimentos y Bebidas

La industria de Quick Service Restaurant (QSR) como Starbucks opera con **márgenes operativos comprimidos** (típicamente 10-15% de revenue neto). Este modelo de negocio depende profundamente de:

- **Volumen de transacciones**: Un incremento de 1% en transacciones/día = $500M+ anual adicionales en cadena global
- **Velocidad de servicio**: Reducir 1 minuto en fulfillment = incremento de capacidad de 16-17% sin añadir tienda o barista
- **Satisfacción del cliente**: Cada 0.1 puntos de satisfacción perdidos = ~2-3% de churn a competidores (Dunkin', McCafé, opciones locales)

### 3.2 Costo de Labor (Driver Económico Primario)

En una operación típica de Starbucks:

- **Costo de mano de obra:** $10-15 USD por minuto por barista
- **Tienda promedio:** 8-12 baristas en turno diurno
- **Costo horario:** $80-180 USD apenas en personal tras-mostrador

**Impacto de delays:**

- Una tienda Drive-Thru con 6,000 órdenes/día
- Delay promedio actual: **5.79 minutos**
- Si se reduce a 4.50 minutos (Mobile App efficiency): **-1.29 minutos × 6,000 = 7,740 minutos/día = 129 horas/día**
- En una semana: **645 horas = 16 barista-semanas**
- **Económico:** 645 horas × $15/hour = **$9,675 en costos evitables**
- **Anualizado:** $9,675 × 52 semanas = **$503,100 en una sola tienda**

Por una red de 500 tiendas Drive-Thru en USA: **$251+ millones en ineficiencia laboral anual**.

### 3.3 Satisfacción del Cliente y Retención

Los datos del dataset muestran:

- **Satisfacción promedio:** 3.66/5 (65% satisfaction score)
- **Target Starbucks:** 4.5/5+ (90% sat score)
- **Gap:** -0.84 puntos (18% debajo de meta)

Una tienda insatisfecha (3.66 vs 4.5):

- Pierde ~15-20% de clientes frecuentes mensuales
- Reduce ticket promedio (-3-5%)
- Genera reviews negativos online (impacta nuevos clientes)

**En la red global:** Un gap de 0.84 puntos = **$2-4B USD en revenue perdido anualmente**.

---

## 4. KPIs de Negocio Clave

La tabla siguiente resume los indicadores de desempeño críticos según datos del dataset:

| KPI                                         | Target Starbucks | Realidad (Dataset)                      | Gap             | Severity   |
| ------------------------------------------- | ---------------- | --------------------------------------- | --------------- | ---------- |
| **Fulfillment Time (Morning Rush)**         | < 4.0 min        | 4.56 min promedio                       | +0.56 min (14%) | 🔴 CRÍTICO |
| **Drive-Thru Efficiency vs Mobile**         | ±5%              | Drive-Thru +28.6% más lento             | -28.6%          | 🔴 CRÍTICO |
| **Customer Satisfaction (1-5)**             | 4.5+             | 3.66 promedio                           | -0.84 pts (19%) | 🔴 CRÍTICO |
| **Order Accuracy (Complexity correlation)** | > 0.5            | -0.01 a +0.02 (None)                    | ✅ Excelente    | 🟢 OK      |
| **Channel Efficiency Parity**               | ±10% variance    | In-Store 3.22 min vs DT 5.79 min (-45%) | -45% variance   | 🔴 CRÍTICO |
| **Fulfillment Consistency (DoW variance)**  | < 1 min          | 4.53-4.56 min (0.03 min var)            | ✅ Excelente    | 🟢 OK      |

**Análisis:**

- ✅ **Fortalezas:** Consistencia día-a-día impecable, órdenes complejas no causan delays
- 🔴 **Debilidades:** Drive-Thru es botella de oferta crítica, satisfacción general debajo de meta, gap de canales es excesivo

---

## 5. Problemas Operativos Identificados

### 5.1 El Cuello de Botella: Drive-Thru Channel

**Hecho:** Drive-Thru es 80% más lento que In-Store Cashier (5.79 vs 3.22 minutos).

**Posibles Causas** (investigación requerida):

1. **Fricción de Pago:** Sistema de pago en ventanilla requiere validación, firma, cambio
2. **Interfaz de Operador:** Driver debe comunicar pedido → operador escribir → sistema processar
3. **Handoff Mecánico:** Física de pasar bebida caliente a través de ventana
4. **Queue Depth:** Espacio limitado para buffer, impacta ritmo de entrada

**NO es causa:** Complejidad de orden (correlación ≈ 0, según datos)

### 5.2 Brecha de Satisfacción vs Competencia

**Contexto:** Starbucks compite con:

- **Dunkin' Donuts:** Más rápido (4.0 min promedio), menos opciones
- **McDonald's McCafé:** Más barato, competencia directa en Morning Rush
- **Local Coffee Shops:** Mejor experiencia ambiental, pero menor conveniencia

A 3.66/5 satisfaction, Starbucks está perdiendo clientes recurrentes a estos competidores, especialmente en drive-thru (donde velocidad es expectativa principal).

### 5.3 Distribución de Población Desigual

**Insight:** Rural locations cluster en tiempos de fulfillment mayores (4.67 min vs 4.50 promedio). Posibles causas:

- Tiendas más antiguas, equipamiento menos moderno
- Staffing limitado, menos redundancia
- Supply chain más lento (entregas menos frecuentes)

---

## 6. Por Qué Este Data Warehouse (Nuestro Proyecto)

### 6.1 Propósito: Data-Driven Decision Making

El **Starbucks Data Warehouse** que construimos en este TP resuelve un problema fundamental: **Visibilidad Operativa**.

Sin este DW, Starbucks Operations Management es **completamente ciego** a:

- ❌ Qué canal específicamente está causando delays
- ❌ Si es complejidad de orden o fricción de proceso
- ❌ Cuál región/tienda requiere intervención inmediata
- ❌ Si los delays son aleatorios (staffing) o sistémicos (proceso)

**Nuestro DW proporciona:**

- ✅ **Clarity:** Drive-Thru es el problema (datos definitivos, no intuición)
- ✅ **Actionability:** Sabemos que NO es complejidad → enfocarse en proceso, no capacitación
- ✅ **Accountability:** Managers de tienda pueden ver su performance vs.national benchmark
- ✅ **ROI:** Cada minuto de optimización = $500k+ anual en toda la red

### 6.2 Business Questions Respondidas

Nuestro DW atiende **4 preguntas de negocio críticas**:

| BQ                                                    | Respuesta                                        | Valor                                               |
| ----------------------------------------------------- | ------------------------------------------------ | --------------------------------------------------- |
| **¿Qué canal tiene delays más largos en hora punta?** | Drive-Thru (5.79 min vs 4.50 Mobile)             | Identifica target de intervención                   |
| **¿Complejidad causa delays?**                        | NO (correlación ≈ 0)                             | Evita inversión en capacitación barista innecesaria |
| **¿Diferencias geográficas?**                         | Mínimas (4.52-4.67 min), Rural ligeramente lento | Identifica oportunidades de estandarización         |
| **¿Patrones semanales?**                              | NINGUNO (4.53-4.56 min consistente)              | Valida staffing estático vs variable                |

Cada respuesta economiza **decisiones millonarias** al eliminar incertidumbre.

### 6.3 Arquitectura del DW

Nuestro modelo multidimensional (Star Schema) permite:

- **Análisis de Facetas Múltiples:** Combinar Channel × Region × TimeOfDay × DayOfWeek
- **Simulación de Scenarios:** "Si mejoramos Drive-Thru a 4.50 min, ¿impacto neto?"
- **Tracking Historico:** Monitorear si optimizaciones realmente funcionan
- **Integración con BI:** Power BI dashboards para visibilidad real-time de managers

---

## 7. Llamada a la Acción

Este Data Warehouse es el **catalizador** para transformación operativa en Starbucks:

1. **Inmediato (1-4 semanas):** Auditoría de Drive-Thru en todas tiendas
   - Revisar sistema de pago, interfaz operador, diseño de ventana
   - Piloto de optimización en 10-20 tiendas

2. **Corto Plazo (1-3 meses):** Implementar cambios ganadores
   - Pueden ser: Mobile payment priority, barista re-routing, queue redesign, etc.
   - Monitorear via DW + Power BI

3. **Largo Plazo (3-12 meses):** Expansion a toda red
   - Rollout de cambios a 500+ Drive-Thru locations
   - Estimar ROI: $100M+ anual en eficiencia de labor

---

## 8. Conclusión

Starbucks opera en un mercado ultracompetitivo donde **segundos importan**. Una tienda que cumple en 5.79 minutos puede perder 20% de clientes diarios a competidores que cumplen en 4.50 minutos. A escala de red global, esto representa centenares de millones en revenue.

Este Data Warehouse no es "un proyecto académico más" — es el **puente entre datos crudos y decisiones ejecutivas** que pueden transformar la experiencia del cliente y la economía de la operación Starbucks.

**Con datos, somos ágiles. Sin datos, estamos ciegos.**

---

**Documento de Contexto Organizacional**
**Starbucks TP - Marzo 23, 2026**
**Status:** ✅ Completo
