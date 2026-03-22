# ☕ Starbucks Power BI - Teammate Setup Guide

This guide will walk you through setting up the **Starbucks Ordering Patterns** project on your local machine.

---

## 🛠️ Prerequisites
1.  **PostgreSQL (v16+)**: [Download here](https://www.postgresql.org/download/windows/)
2.  **Power BI Desktop**: [Download here](https://powerbi.microsoft.com/desktop/)
3.  **Git**: [Download here](https://git-scm.com/downloads)

---

## 🚀 Phase 1: Database Setup (The "Dump")

The first step is to "dump" the raw dataset into a single SQL table, as per the project requirements.

1.  **Start PostgreSQL**: Ensure your local server is running.
2.  **Initialize the Database**: 
    Open a terminal and run `01_SETUP_DATABASE.sql` (use password `123456` if prompted):
    ```powershell
    psql -U postgres -d postgres -f c:\prueba\Database\01_SETUP_DATABASE.sql
    ```
    *This creates the `starbucks_dw_raw` database.*

3.  **Loading the Raw Data**:
    Run the setup script against the new database:
    ```powershell
    psql -U postgres -d starbucks_dw_raw -f c:\prueba\Database\setup_starbucks.sql
    ```
    *This creates the `starbucks.raw_orders` table and loads 100,000 rows from the CSV.*

---

## 📊 Phase 2: Power BI Connection

1.  **Open the Project**: Navigate to the folder and open `Starbucks_PowerBI.pbip`.
2.  **Data Source Credentials**:
    - If Power BI asks for credentials, select **Database** (not Windows).
    - **User**: `postgres`
    - **Password**: `123456` (or whatever you set during installation).
3.  **Refresh**: Click **Refresh** in the top ribbon to pull the latest 100k rows.

---

## 🧩 Phase 3: How the Star Model works ("Another Tool")

The requirement states we must build the **Star Model** using Power BI ("another tool") instead of SQL views. Here is how we achieved that:

-   **One Single Source**: Power BI connects to the **single raw table** (`raw_orders`) for everything.
-   **Power Query Logic**: I have implemented the "Business Logic" in **M (Power Query)**. 
-   **Dimension Creation**: Each dimension (Customers, Stores, Date, Time, Channel) is created by "cloning" the raw table and removing irrelevant columns and duplicates inside Power BI.
-   **Fact Creation**: The `FactOrders` table is similarly created by keeping only the transaction IDs and numerical measures.

### Why this approach?
It keeps the SQL database very simple (just a data dump) and uses Power BI's powerful engine to handle the analytical architecture.

---

## ✅ Checklist before working:
- [ ] Check `raw_orders` table exists: `SELECT COUNT(*) FROM starbucks.raw_orders;` should return 100,000.
- [ ] Ensure `Power BI` shows 5 Dimension tables and 1 Fact table in the **Model View**.
- [ ] Verify that relationships are established (one-to-many from Dims to Fact).

*Happy analyzing!* 🥤📊
