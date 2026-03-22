# Plan de Resolución Programática: Starbucks Operational Analysis

Este documento detalla la estrategia para transformar el modelo de datos actual en una herramienta analítica capaz de identificar cuellos de botella operativos, utilizando un enfoque 100% programático basado en archivos `.pbip` (TMDL) y scripting en Python.

## 1. Análisis de Enfoques Posibles

### A. Enfoque "Semantic-First" (Recomendado)
Consiste en enriquecer el archivo `FactOrders.tmdl` con **Medidas DAX** que encapsulan la lógica de negocio.
*   **Pros**: El análisis se vuelve dinámico. Los gerentes pueden filtrar por cualquier dimensión y la métrica se recalcula.
*   **Contras**: Requiere manipulación cuidadosa de archivos de texto TMDL.

### B. Enfoque "Pre-Calculated" (Python + SQL)
Realizar los cálculos complejos (correlaciones, promedios de horas pico) directamente en Python o en la vista SQL y traer los resultados como tablas estáticas.
*   **Pros**: Ejecución de algoritmos estadísticos avanzados (regresiones lineales, clustering).
*   **Contras**: Pierde la interactividad "drill-down" nativa de Power BI.

---

## 2. Propuesta de Solución: Programmatic TMDL Injection

Utilizaremos Python para "inyectar" las medidas de negocio directamente en el archivo `FactOrders.tmdl`, evitando el uso de la interfaz gráfica.

### A. Medidas DAX Críticas a Implementar

| Medida | Lógica DAX | Propósito |
| :--- | :--- | :--- |
| **Tiempo Promedio Entrega** | `AVERAGE(FactOrders[fulfillment_time_min])` | Métrica base de eficiencia. |
| **Morning Rush Wait** | `CALCULATE([Tiempo Promedio Entrega], DimTime[time_period] = "Morning Rush")` | Enfoque específico en el problema planteado. |
| **Channel Gap (DT vs Mobile)** | `CALCULATE([Tiempo Promedio Entrega], DimChannel[order_channel] = "Drive-Thru") - CALCULATE([Tiempo Promedio Entrega], DimChannel[order_channel] = "Mobile App")` | Identificar disparidad de eficiencia. |
| **Índice de Complejidad** | `AVERAGE(FactOrders[cart_size]) + (AVERAGE(FactOrders[num_customizations]) * 0.5)` | Cuantificar la carga de trabajo por pedido. |

---

## 3. Scripts de Implementación

### Python: Automatizador de Metadatos (.pbip)
Este script lee el archivo `FactOrders.tmdl` e inserta las medidas necesarias.

```python
import os

tmdl_path = r"c:\prueba\Starbucks_PowerBI.SemanticModel\definition\tables\FactOrders.tmdl"

measures_to_add = """
	measure 'Avg Fulfillment Time' = AVERAGE(FactOrders[fulfillment_time_min])
		formatString: 0.00
		lineageTag: a1b2c3d4-e5f6-4a5b-8c9d-0e1f2a3b4c5d

	measure 'Morning Rush Avg' = 
		CALCULATE(
			[Avg Fulfillment Time], 
			DimTime[time_period] = "Morning Rush"
		)
		formatString: 0.00

	measure 'Complexity vs Delay Correlation' = 
		VAR Correlation = 
			COALESCE(
				CORRELATE(
					FactOrders, 
					FactOrders[num_customizations], 
					FactOrders[fulfillment_time_min]
				), 0
			)
		RETURN Correlation
"""

def inject_measures():
    with open(tmdl_path, 'r', encoding='utf-8') as f:
        lines = f.readlines()
    
    # Encontrar la posición después de la definición de columnas y antes de partitions
    insert_pos = 0
    for i, line in enumerate(lines):
        if 'column' in line:
            insert_pos = i
        if 'partition' in line:
            insert_pos = i - 1
            break
            
    lines.insert(insert_pos + 1, measures_to_add)
    
    with open(tmdl_path, 'w', encoding='utf-8') as f:
        f.writelines(lines)
    print("Medidas inyectadas exitosamente en el modelo .pbip")

if __name__ == "__main__":
    inject_measures()
```

### Power BI: M Script (Power Query) Refinement
Para asegurar que el "Morning Rush" sea consistente, propondremos un ajuste en `DimTime.tmdl` para que el script de Python también asegure la lógica de periodos:

```powerquery
let
    Origen = vw_orders_starbucks,
    # "Filas filtradas" = Table.SelectColumns(Origen, {"hour_of_day"}),
    # "Duplicados quitados" = Table.Distinct(#"Filas filtradas"),
    # "Periodo Agregado" = Table.AddColumn(#"Duplicados quitados", "time_period", each 
        if [hour_of_day] >= 7 and [hour_of_day] <= 9 then "Morning Rush" 
        else if [hour_of_day] >= 11 and [hour_of_day] <= 14 then "Mid-day"
        else "Other"),
    # "ID Agregado" = Table.AddColumn(#"Periodo Agregado", "time_id", each [hour_of_day])
in
    #"ID Agregado"
```

---

## 4. Plan de Ejecución

1.  **Fase 1: Preparación de Datos**: Validar la vista `vw_orders_starbucks` en PostgreSQL para asegurar que las columnas numéricas no tengan nulos.
2.  **Fase 2: Programática TMDL**: Ejecutar el script Python para inyectar las medidas DAX. Al ser un archivo de texto, Power BI lo reconocerá en la próxima actualización de metadatos.
3.  **Fase 3: Validación Operativa**:
    *   Verificar que `Avg Fulfillment Time` correlacione positivamente con `num_customizations`.
    *   Generar un reporte visual (vía DAX Queries si es necesario) para confirmar que el Drive-Thru es o no más lento que el Mobile order durante el Rush.

> [!IMPORTANT]
> Al manipular el `.pbip` directamente, no es necesario abrir Desktop. Solo se requiere que los servicios de Power BI o un proceso de CI/CD procesen estos cambios de metadatos.
