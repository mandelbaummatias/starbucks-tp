# Starbucks Operations Data Warehouse: Team Setup Guide

This guide provides a zero-to-hero, step-by-step plan for any team member to set up the Starbucks Operations Database and integrate it into Power BI for analysis.

## Overview of the Business Problem
Our primary goal is to identify operational bottlenecks during peak times (particularly the Morning Rush). We are analyzing how fulfillment times are impacted by order channel (Mobile vs. Drive-Thru), order complexity (cart size and customizations), and day-of-week patterns, to allocate staffing resources more efficiently.

---

## Phase 1: Database Setup (PostgreSQL)
To run the analysis, the raw data must be loaded into our relational database.

1. **Install PostgreSQL** (if you haven't already).
2. **Execute the Setup Script**:
   Find the database script in the repository (e.g., `Scripts/Setup_Database.sql`) and physically run it.
   - This script creates the `starbucks_dw_raw` database.
   - It stages the data and creates the central view `vw_orders_starbucks`, which performs crucial ETL like adding the `time_period` column (e.g., calculating "Morning Rush" for times between 7 AM and 9 AM).
3. **Verify Data Logic**:
   Run the queries in `solve_business_problem.sql`. These are the "ground truth" queries that validate the aggregation mathematical models for the business problem natively in SQL before it hits Power BI.

---

## Phase 2: Power BI Semantic Model Integration
We use a **Star Schema** to connect PostgreSQL to Power BI.

1. **Open the Model**: Double-click `Starbucks_PowerBI.pbip` to open the Power BI project workspace.
2. **Configure Data Source**:
   - Go to `Transform Data` (Power Query).
   - Ensure the PostgreSQL database credentials point to your local machine (typically `localhost:5432` with database `starbucks_dw_raw`).
3. **Refresh Semantic Model**:
   - Click **Refresh** to pull the latest tables: `FactOrders`, `DimTime`, `DimDate`, `DimChannel`, `DimCustomer`, `DimStore`.

---

## Phase 3: Visual Generation & Analysis
Instead of building visuals manually, our repository features a programmatic layout generator.

1. **Run the PowerShell Generator**:
   - Open PowerShell.
   - Execute: `.\Scripts\Create_Report_Visuals.ps1`
   - *What this does:* It dynamically scaffolds the `visual.json` layouts directly into the PBIR structure without needing to use Power BI Desktop manually.
2. **Bind Data and Deploy**:
   - Reopen Power BI Desktop. The visuals (Bar Chart, Line Chart) will appear automatically.
   - Drag the metrics (e.g., `fulfillment_time_min`) from the *Data* pane into the visuals to finalize the analysis.

---

### Key Takeaway for the Team
The analytical engine is fully decoupled. The mathematical proofs run in PostgreSQL (`solve_business_problem.sql`), the dimensionality runs in Power BI Semantic Model, and the visual placement is abstracted via code (`Create_Report_Visuals.ps1`). This workflow allows version control of logic without binary conflicts.
