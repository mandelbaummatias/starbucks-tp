# Specification: Power BI & PostgreSQL Connectivity & Validation

## 1. Objective
Ensure the Power BI project (`.pbip`) correctly consumes data from the newly aligned PostgreSQL database (`starbucks_dw_raw`) and validates the Star Schema implementation.

## 2. Prerequisites
- **PostgreSQL Service**: Running on `localhost:5432`.
- **Database**: `starbucks_dw_raw` must be populated (already completed in previous steps).
- **Power BI Desktop**: Installed.
- **Npgsql Driver**: The PostgreSQL .NET provider must be installed for Power BI to connect to Postgres.

## 3. Connectivity Alignment Details
The semantic model is already configured via `expressions.tmdl` to point to:
- **Source**: `PostgreSQL.Database("localhost", "starbucks_dw_raw")`
- **Schema**: `starbucks`
- **Entry Point**: `vw_orders_starbucks`

## 4. Implementation Steps

### Step 4.1: Open Project
1. Open `c:\prueba\Starbucks_PowerBI.pbip` using Power BI Desktop.
2. If prompted for credentials, use:
    - **User**: `postgres`
    - **Password**: `123456` (or the one configured on your system).

### Step 4.2: Data Refresh
1. Go to the **Home** tab and click **Refresh**.
2. Monitor the refresh of the following tables:
    - `FactOrders` (Main transactions)
    - `DimCustomer`, `DimStore`, `DimDate`, `DimTime`, `DimChannel` (Dimensions)
3. Ensure no "Expression.Error" occurs related to the database name or column names.

### Step 4.3: Model Validation (Star Schema)
1. Navigate to the **Model View**.
2. Verify the following relationships (all should be 1:Many, Single Direction):
    - `DimCustomer[customer_id]` -> `FactOrders[customer_id]`
    - `DimStore[store_id]` -> `FactOrders[store_id]`
    - `DimDate[order_date]` -> `FactOrders[order_date]`
    - `DimTime[order_time]` -> `FactOrders[order_time]`
    - `DimChannel[channel_key]` -> `FactOrders[channel_key]`

### Step 4.4: Data Integrity Check (DAX)
1. Create a simple measure to check the record count:
   ```dax
   Total Orders = COUNTROWS('FactOrders')
   ```
2. Expected result: **100,000**.
3. Create a measure for total revenue:
   ```dax
   Total Revenue = SUM('FactOrders'[total_spend])
   ```

## 5. Success Criteria
- [ ] All tables in the Power BI model refreshed without errors.
- [ ] `Total Orders` measure returns exactly 100,000.
- [ ] Visuals in the Report view correctly filter data across dimensions (e.g., Revenue by Region, Revenue by Age Group).

## 6. Rollback / Troubleshooting
- If the connection fails, check **Data Source Settings** in Power BI and ensure "localhost" is accessible and "starbucks_dw_raw" is the selected database.
- If columns are missing, verify the `vw_orders_starbucks` view in the database using:
  `SELECT * FROM starbucks.vw_orders_starbucks LIMIT 1;`
