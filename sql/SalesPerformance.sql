-- ============================================================
-- Supply Chain & E-Commerce Project
-- Script: 02_sales_performance.sql
-- Business Questions: Sales Performance
-- ============================================================


-- ─────────────────────────────────────────────
-- Q1. Monthly revenue trend — are we growing or declining?
-- ─────────────────────────────────────────────
SELECT
    DATE_TRUNC('month', order_date::TIMESTAMP)       AS order_month,
    COUNT(DISTINCT o.order_id)                        AS total_orders,
    ROUND(SUM(oi.sales)::NUMERIC, 2)                  AS total_revenue,
    ROUND(AVG(oi.sales)::NUMERIC, 2)                  AS avg_order_value,
    ROUND(SUM(oi.profit_per_order)::NUMERIC, 2)       AS total_profit
FROM orders o
JOIN order_items oi ON o.order_id = oi.order_id
WHERE o.order_status NOT IN ('Canceled', 'Suspected_Fraud')
GROUP BY order_month
ORDER BY order_month;


-- ─────────────────────────────────────────────
-- Q2. Year over year revenue comparison
-- ─────────────────────────────────────────────
SELECT
    EXTRACT(YEAR FROM order_date::TIMESTAMP)          AS order_year,
    EXTRACT(MONTH FROM order_date::TIMESTAMP)         AS order_month,
    COUNT(DISTINCT o.order_id)                        AS total_orders,
    ROUND(SUM(oi.sales)::NUMERIC, 2)                  AS total_revenue
FROM orders o
JOIN order_items oi ON o.order_id = oi.order_id
WHERE o.order_status NOT IN ('Canceled', 'Suspected_Fraud')
GROUP BY order_year, order_month
ORDER BY order_year, order_month;


-- ─────────────────────────────────────────────
-- Q3. Revenue by weekday — which days perform best?
-- ─────────────────────────────────────────────
SELECT
    TO_CHAR(order_date::TIMESTAMP, 'Day')             AS weekday,
    EXTRACT(DOW FROM order_date::TIMESTAMP)           AS day_number,
    COUNT(DISTINCT o.order_id)                        AS total_orders,
    ROUND(SUM(oi.sales)::NUMERIC, 2)                  AS total_revenue,
    ROUND(AVG(oi.sales)::NUMERIC, 2)                  AS avg_daily_revenue
FROM orders o
JOIN order_items oi ON o.order_id = oi.order_id
WHERE o.order_status NOT IN ('Canceled', 'Suspected_Fraud')
GROUP BY weekday, day_number
ORDER BY day_number;


-- ─────────────────────────────────────────────
-- Q4. Average order value by market and shipping mode
-- ─────────────────────────────────────────────
SELECT
    o.market,
    s.shipping_mode,
    COUNT(DISTINCT o.order_id)                        AS total_orders,
    ROUND(AVG(oi.sales)::NUMERIC, 2)                  AS avg_order_value,
    ROUND(SUM(oi.sales)::NUMERIC, 2)                  AS total_revenue
FROM orders o
JOIN order_items oi ON o.order_id = oi.order_id
JOIN shipping s     ON o.order_id = s.order_id
GROUP BY o.market, s.shipping_mode
ORDER BY o.market, avg_order_value DESC;


-- ─────────────────────────────────────────────
-- Q5. Order status breakdown — financial impact of
--     canceled, fraud, and on-hold orders
-- ─────────────────────────────────────────────
SELECT
    o.order_status,
    COUNT(DISTINCT o.order_id)                        AS total_orders,
    ROUND(SUM(oi.sales)::NUMERIC, 2)                  AS revenue_at_risk,
    ROUND(AVG(oi.sales)::NUMERIC, 2)                  AS avg_order_value,
    ROUND(COUNT(DISTINCT o.order_id) * 100.0 /
        SUM(COUNT(DISTINCT o.order_id)) OVER (), 2)   AS pct_of_total_orders
FROM orders o
JOIN order_items oi ON o.order_id = oi.order_id
GROUP BY o.order_status
ORDER BY total_orders DESC;


-- ─────────────────────────────────────────────
-- Q6. Transaction type breakdown
--     (debit, transfer, cash, payment)
-- ─────────────────────────────────────────────
SELECT
    o.transaction_type,
    COUNT(DISTINCT o.order_id)                        AS total_orders,
    ROUND(SUM(oi.sales)::NUMERIC, 2)                  AS total_revenue,
    ROUND(AVG(oi.sales)::NUMERIC, 2)                  AS avg_order_value,
    ROUND(COUNT(DISTINCT o.order_id) * 100.0 /
        SUM(COUNT(DISTINCT o.order_id)) OVER (), 2)   AS pct_of_total_orders
FROM orders o
JOIN order_items oi ON o.order_id = oi.order_id
GROUP BY o.transaction_type
ORDER BY total_revenue DESC;


-- ─────────────────────────────────────────────
-- Q7. Basket size distribution
--     Median, Q1, Q3, min, max order value
-- ─────────────────────────────────────────────
SELECT
    ROUND(PERCENTILE_CONT(0.25) WITHIN GROUP (ORDER BY oi.sales)::NUMERIC, 2) AS q1_basket,
    ROUND(PERCENTILE_CONT(0.50) WITHIN GROUP (ORDER BY oi.sales)::NUMERIC, 2) AS median_basket,
    ROUND(PERCENTILE_CONT(0.75) WITHIN GROUP (ORDER BY oi.sales)::NUMERIC, 2) AS q3_basket,
    ROUND(MIN(oi.sales)::NUMERIC, 2)                                            AS min_basket,
    ROUND(MAX(oi.sales)::NUMERIC, 2)                                            AS max_basket,
    ROUND(AVG(oi.sales)::NUMERIC, 2)                                            AS avg_basket,
    COUNT(*)                                                                     AS total_line_items
FROM order_items oi
JOIN orders o ON oi.order_id = o.order_id
WHERE o.order_status NOT IN ('Canceled', 'Suspected_Fraud');