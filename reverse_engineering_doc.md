# Starbucks Analytical Solution: Reverse Engineering Documentation

This document reverse-engineers the solution built to address the operational bottlenecks in Starbucks' order fulfillment process, specifically targeting the "morning rush" (7:00 AM - 9:00 AM).

## 1. How SQL Resolves the Business Problem
The core logic resides in `solve_business_problem.sql`. We use SQL to strictly answer the four business questions mathematically before visualizing them. The queries hit `vw_orders_starbucks`, a view that pre-calculates the `time_period` (e.g., categorizing 7 AM to 9 AM directly as 'Morning Rush').

* **Problema 1: ¿Qué canal presenta mayores demoras en el "morning rush"?**
  * **SQL Script (`solve_business_problem.sql` - Query 1):** Groups by `order_channel` and calculates the `AVG(fulfillment_time_min)`. This definitively proves which channel (Drive-Thru vs. Mobile) is structurally slower during peak hours.
* **Problema 2: ¿Influye la complejidad del pedido en las demoras?**
  * **SQL Script (`solve_business_problem.sql` - Query 2):** Calculates the average cart size and customizations, but most importantly uses `CORR(num_customizations, fulfillment_time_min)` to find the statistical correlation. A positive correlation mathematically proves that custom drinks cause the delays.
* **Problema 3: ¿Existen diferencias geográficas?**
  * **SQL Script (`solve_business_problem.sql` - Query 3):** Aggregates delays by `store_location_type` and `region`. This highlights if Urban stores (higher foot traffic) are significantly slower than Rural or Suburban locations, helping regional managers reallocate staff.
* **Problema 4: ¿Qué días de la semana son los más críticos?**
  * **SQL Script (`solve_business_problem.sql` - Query 4):** Groups average delays by `day_of_week`. This gives scheduling managers the exact blueprint indicating which days require the heaviest barista shifts.

---

## 2. Power BI Visuals & Configuration Guide
Once the `Makefile` or `Create_Report_Visuals.ps1` runs, it programmatically scaffolds the PBIR JSON structural templates into Power BI. 

Because paths are robustly structured using `$PSScriptRoot\..`, the generator works for any teammate regardless of whether the project is in `C:\prueba` or `C:\Users\...\Downloads\`.

Once you open `Starbucks_PowerBI.pbip`, **you must click each empty visual and drag the following attributes into the Data Pane:**

### Visual 1: Channel Comparison (Clustered Column Chart)
*Answers Question 1.*
*   **X-axis:** Drag `order_channel` (from `DimChannel`).
*   **Y-axis:** Drag `fulfillment_time_min` (from `FactOrders`) -> Ensure it is set to **Average**.
*   **Filters on this visual:** Drag `time_bucket` or `time_period` and filter strictly for "Morning Rush".

### Visual 2: Complexity Impact (Clustered Bar Chart)
*Answers Question 2.*
*   **Y-axis:** Drag `cart_size` (from `FactOrders`).
*   **X-axis:** Drag `fulfillment_time_min` (from `FactOrders`) -> Ensure it is set to **Average**.
*   *(Interpretation: As the Y-axis moves down to larger cart sizes, you will visually see the X-axis bars stretch further to the right, showing increased delays).*

### Visual 3: Weekly Patterns (Line Chart)
*Answers Question 4.*
*   **X-axis:** Drag `day_of_week` (from `DimDate`).
*   **Y-axis:** Drag `fulfillment_time_min` (from `FactOrders`) -> Ensure it is set to **Average**.
*   **Legend:** Drag `order_channel` (from `DimChannel`). This will split the line into two distinct trends, showing if Drive-Thru is consistently slower than Mobile across all days.

> **Note on Question 3 (Geography):** The map visual was removed from the Power BI dashboard to keep the layout clean, as requested. The geographical analysis relies strictly on the output of SQL Query 3.
