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
*   **Y-axis:** Drag `Morning Rush Avg` (from `FactOrders`) or `fulfillment_time_min` (set to Average).
*   **What it shows:** You will see vertical columns where the Drive-Thru visually towers over the others, instantly providing a graphical proof that it is the most delayed channel.

### Visual 2: Complexity Impact (Clustered Bar Chart)
*Answers Question 2.*
*   **Y-axis:** Drag `order_channel` (from `DimChannel`).
*   **X-axis:** Drag `Avg Fulfillment Time` (from `FactOrders`).
*   **Tooltip:** Drag `cart_size` and `num_customizations` (set to Average).
*   **What it shows:** You will see horizontal bars stretching to denote delays. Shorter bars (like Mobile App) feature higher complexity tooltips, visibly breaking the intuition that complex orders stretch out wait times.

### Visual 3: Geographic Differences (Scatter Chart)
*Answers Question 3.*
*   **Values / Details:** Drag `region` or `store_location_type` (from `DimStore`) to create the plot points.
*   **X-axis:** Drag `Avg Fulfillment Time` (from `FactOrders`).
*   **Y-axis:** Drag `Avg Satisfaction` (from `FactOrders`).
*   **What it shows:** The scatterplot maps out clusters of wait time vs satisfaction. You'll clearly see quadrants forming—such as Urban locations dropping significantly lower on the Satisfaction Y-axis for identical X-axis delay times compared to Suburban points.

### Visual 4: Weekly Patterns (Line Chart)
*Answers Question 4.*
*   **X-axis:** Drag `day_of_week` (from `DimDate`).
*   **Y-axis:** Drag `Avg Fulfillment Time` (from `FactOrders`).
*   **Legend:** Drag `order_channel` (from `DimChannel`) to generate distinct lines.
*   **What it shows:** This generates a perfectly flat, horizontal line across Monday-Sunday. This rigidly straight-line trend visually communicates to management that the delay issue is systemic, consistent overhead, rather than fluctuating rush intensity depending on the day of the week.
