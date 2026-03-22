# Starbucks Ordering Patterns Database Documentation

This database contains customer ordering patterns from Starbucks, processed for analytical purposes. It is aligned with the Power BI Model.

## 🗄️ Database Connection Details
- **Server**: `localhost`
- **Database Name**: `starbucks_dw_raw`
- **Schema**: `starbucks`
- **User**: `postgres`
- **Port**: `5432`
- **Main View**: `vw_orders_starbucks`

## 📋 Data Structure
### 1. Raw Data Table: `starbucks.raw_orders`
Contains 100,000 records of raw order data.
- **Fields**: `customer_id`, `order_id`, `order_date`, `order_time`, `day_of_week`, `order_channel`, `store_id`, `store_location_type`, `region`, `customer_age_group`, `customer_gender`, `is_rewards_member`, `cart_size`, `num_customizations`, `total_spend`, `fulfillment_time_min`, `drink_category`, `has_food_item`, `order_ahead`, `customer_satisfaction`.

### 2. Analytical View: `starbucks.vw_orders_starbucks`
An enriched view with calculated fields:
- **`order_datetime`**: Combined date and time.
- **`day_of_month`, `month_num`, `quarter_num`, `year_num`**: Date parts.
- **`hour_of_day`**: Extract of the hour.
- **`time_period`**: Categorized periods (Morning Rush, Mid-Day, Afternoon, Evening, Other).

## 🧪 How to Test

### Simple Count Test
```sql
SELECT COUNT(*) FROM starbucks.raw_orders;
```

### View Data from Analytical View
```sql
SELECT * FROM starbucks.vw_orders_starbucks LIMIT 10;
```

### Analyze Revenue by Region
```sql
SELECT 
    region, 
    ROUND(SUM(total_spend), 2) as total_revenue,
    ROUND(AVG(customer_satisfaction), 2) as avg_satisfaction
FROM starbucks.vw_orders_starbucks
GROUP BY region
ORDER BY total_revenue DESC;
```

## 🛠️ Setup Script (2-Step Alignment)

To align with the Power BI project:

1. **Phase 1: Database Initialization**
   Run the following from a master `postgres` connection:
   - `psql -U postgres -d postgres -f c:\prueba\Database\01_SETUP_DATABASE.sql`

2. **Phase 2: Schema & Data Load**
   Run the following against the newly created database:
   - `psql -U postgres -d starbucks_dw_raw -f c:\prueba\Database\setup_starbucks.sql`

Once complete, the **Power BI project** will be able to "Refresh" successfully without any modifications.
