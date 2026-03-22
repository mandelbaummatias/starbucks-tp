# Starbucks Ordering Patterns Database Documentation

This database contains customer ordering patterns from Starbucks, processed for analytical purposes.

## 🗄️ Database Connection Details
- **Database Name**: `starbucks_db`
- **User**: `postgres`
- **Password**: `123456`
- **Main Schema**: `starbucks`

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

### Check Satisfaction by Loyalty
```sql
SELECT 
    is_rewards_member, 
    ROUND(AVG(customer_satisfaction), 2) as avg_satisfaction
FROM starbucks.vw_orders_starbucks
GROUP BY is_rewards_member;
```

## 🛠️ Setup Script
The database was set up using `c:\prueba\Database\setup_starbucks.sql`.
If the view needs to be updated, use `c:\prueba\Database\fix_view.sql`.
