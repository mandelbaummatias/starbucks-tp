# Validación de Insights de Negocio - Proyecto Starbucks

Este documento valida las observaciones de negocio obtenidas a través de la herramienta OLAP y el *Star Schema* implementado en el Data Warehouse, contrastándolas directamente con las consultas en la base de datos `starbucks_dw_raw`.

---

## 📌 Pregunta 1: ¿Qué canal tiene los delays más largos durante hora punta?

**Conclusión Original:** Drive-Thru es significativamente más lento (5.79 min).
**Validación con Datos:** ✅ **Correcto.**

| Canal | Tiempo Promedio | Volumen de Órdenes |
| :--- | :--- | :--- |
| **Drive-Thru** | **5.79 min** | 6,875 |
| **Mobile App** | 4.50 min | 10,413 |
| **Kiosk** | 4.00 min | 1,799 |
| **In-Store Cashier** | **3.22 min** | 5,384 |

> **Insight Verificado:** Existe un *gap* de **2.57 minutos** entre Drive-Thru e In-Store, lo que representa un cuello de botella sistémico crudo limitando el servicio.

---

## 📌 Pregunta 2: ¿La complejidad de orden causa delays?

**Conclusión Original:** El delay no está correlacionado con la complejidad. Mobile procesa pedidos más complejos, más rápido.
**Validación con Datos:** ✅ **Correcto.**

El factor de correlación matemática entre el número de personalizaciones y el tiempo de entrega es **casi cero**:
- **Drive-Thru:** `0.0047`
- **Mobile App:** `-0.0102`
- **In-Store / Kiosk:** `-0.015` a `0.023`

> **Insight Crítico Verificado:** El canal *Mobile App* tiene en promedio **2.51 personalizaciones** por orden frente a las **1.30 personalizaciones** del *Drive-Thru*. Aún así, la Mobile App procesa los pedidos **22% más rápido**. El problema de demoras no reside en los baristas (preparación), sino en la fricción física del canal (pagos/interacción/handoff).

---

## 📌 Pregunta 3: ¿Existen diferencias geográficas significativas?

**Conclusión Original:** Mínimas. Procedimientos altamente estandarizados a nivel nacional.
**Validación con Datos:** ✅ **Correcto.**

- **Peor Tiempo:** Rural - Northeast (`4.67 min`)
- **Mejor Tiempo:** Suburban - West / Southeast (`4.52 min`)

> **Insight Verificado:** El rango de variación es de **solo 0.15 minutos**. La ubicación geográfica y el tipo de tienda tienen un impacto mínimo comparado con el canal de atención elegido por el cliente, demostrando excelente estandarización de procedimientos en el ecosistema físico.

---

## 📌 Pregunta 4: ¿Hay patrones semanales críticos?

**Conclusión Original:** Demanda y delays completamente planos.
**Validación con Datos:** ✅ **Correcto.**

| Día   | Promedio Espera | Frecuencia de Órdenes |
| :---: | :---:           | :---:                 |
| Jue   | 4.56 min        | 14,214                |
| Sáb   | 4.55 min        | 14,443                |
| Lun   | 4.54 min        | 14,386                |
| Dom   | 4.53 min        | 14,175                |
| Mié   | 4.53 min        | 14,120                |

> **Insight Verificado:** El problema es un cuello de botella dependiente del equipo o infraestructura que se satura recurrentemente cada día. Retirar el enfoque en re-staffing diario y enfocar la energía gerencial en resolver la limitación sistemática por canal y horario.
