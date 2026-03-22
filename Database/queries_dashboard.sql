-- Dashboard Queries for Starbucks Data
-- Total spend and average spend per time period
SELECT 
    time_period, 
    COUNT(*) AS total_orders, 
    ROUND(SUM(total_spend), 2) AS total_revenue,
    ROUND(AVG(total_spend), 2) AS avg_order_value
FROM starbucks.vw_orders_starbucks
GROUP BY time_period
ORDER BY total_orders DESC;

-- Customer demographics analysis: Spend by Age Group
SELECT 
    customer_age_group, 
    COUNT(*) AS total_orders, 
    ROUND(AVG(total_spend), 2) AS avg_spend,
    ROUND(AVG(customer_satisfaction), 2) AS avg_satisfaction
FROM starbucks.vw_orders_starbucks
GROUP BY customer_age_group
ORDER BY avg_spend DESC;

-- Satisfaction by Rewards Member Status
SELECT 
    is_rewards_member, 
    COUNT(*) AS total_orders, 
    ROUND(AVG(customer_satisfaction), 2) AS avg_satisfaction
FROM starbucks.vw_orders_starbucks
GROUP BY is_rewards_member;

-- Popular Drink Categories
SELECT 
    drink_category, 
    COUNT(*) AS total_orders, 
    ROUND(SUM(total_spend), 2) AS total_revenue
FROM starbucks.vw_orders_starbucks
GROUP BY drink_category
ORDER BY total_orders DESC;
