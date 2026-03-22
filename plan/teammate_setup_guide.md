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
-   **Fact Creation**: The
### **4. Pre-Calculated Analysis (The "Magic" Part)**
I have **programmatically injected** the following measures into the project. Your teammates don't need to calculate anything; they just need to find them in the **`FactOrders`** table (they have a calculator icon 🧮).

| Measure | What it shows | Where to use it? |
| :--- | :--- | :--- |
| **`Avg Fulfillment Time`** | The average minutes per order. | Bar Chart Y-Axis. |
| **`Morning Rush Fulfillment`** | Automatically filters to 7-9 AM. | Card Visual or Comparison Chart. |
| **`Complexity Correlation`** | Statistical link between custom items and delay. | Scatter Plot tooltip or Card. |
| **`Avg Satisfaction`** | Customer happiness level (0-5). | Comparison with Wait Time. |

### **5. For Developers: The Automation Script**
If you want to see how this is done programmatically or need to re-apply it, use the script in:
`c:\prueba\Scripts\Setup_PowerBI_Measures.ps1`
It keeps the SQL database very simple (just a data dump) and uses Power BI's powerful engine to handle the analytical architecture.

## 📈 Phase 4: Running the Analysis (The Results)

Once the model is loaded, you can verify the business conclusions:

1.  **SQL Method**: Run the analysis script to see raw numbers in the terminal:
    ```powershell
    psql -U postgres -d starbucks_dw_raw -f c:\prueba\Database\solve_business_problem.sql
    ```
    *Look for the "Morning Rush" bottleneck in Drive-Thru.*

2.  **Power BI Method**:
    - Go to the **Report View** in Power BI Desktop.
    - Drag **'Avg Fulfillment Time'** into a Bar Chart.
    - Use **'order_channel'** as the Axis.
    - Filter by **'time_period' = "Morning Rush"**.
    - *You will see Drive-Thru as the tallest bar (slowest).*

---

## 🔬 Concepts: OLAP vs DBMS

For the project delivery, it is important to distinguish these two components:

| Component | Technology | Role | Type |
| :--- | :--- | :--- | :--- |
| **Data Source** | **PostgreSQL** | Stores the 100k raw records, handles staging. | **DBMS** |
| **Star Model / Analytics** | **Power BI** | Transforms raw data into a Star Schema, calculates DAX measures (OLAP cube). | **OLAP Tool** |

**Why Postgres?** It is a robust, open-source Relational DBMS that supports the large volume of data (100k rows) and allows us to perform initial cleaning before the Power BI load.

---

## ✅ Checklist before working:
- [ ] Check `raw_orders` table exists: `SELECT COUNT(*) FROM starbucks.raw_orders;` should return 100,000.
- [ ] Ensure `Power BI` shows 5 Dimension tables and 1 Fact table in the **Model View**.
- [ ] Verify that relationships are established (one-to-many from Dims to Fact).

*Happy analyzing!* 🥤📊
