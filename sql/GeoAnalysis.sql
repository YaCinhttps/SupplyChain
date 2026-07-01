-- ============================================================
-- Supply Chain & E-Commerce Project
-- Business Questions: Product Performance & Geographic Analysis
-- ============================================================


-- ─────────────────────────────────────────────
-- Q1. Top 10 product categories by profit ratio
-- ─────────────────────────────────────────────
SELECT
    p.category_name,
    COUNT(*)                                              AS total_line_items,
    ROUND(AVG(oi.profit_ratio)::NUMERIC, 4)               AS avg_profit_ratio,
    ROUND(AVG(oi.discount_rate)::NUMERIC, 4)              AS avg_discount_rate,
    ROUND(SUM(oi.sales)::NUMERIC, 2)                      AS total_revenue,
    ROUND(SUM(oi.profit_per_order)::NUMERIC, 2)           AS total_profit
FROM order_items oi
JOIN products p ON oi.product_id = p.product_id
GROUP BY p.category_name
ORDER BY avg_profit_ratio DESC
LIMIT 10;


-- ─────────────────────────────────────────────
-- Q2. Discount rate vs profit ratio per category
--     Is heavy discounting killing margins?
-- ─────────────────────────────────────────────
SELECT
    p.category_name,
    ROUND(AVG(oi.discount_rate)::NUMERIC, 4)              AS avg_discount_rate,
    ROUND(AVG(oi.profit_ratio)::NUMERIC, 4)               AS avg_profit_ratio,
    ROUND(AVG(oi.sales)::NUMERIC, 2)                      AS avg_revenue,
    COUNT(*)                                              AS total_orders
FROM order_items oi
JOIN products p ON oi.product_id = p.product_id
GROUP BY p.category_name
ORDER BY avg_discount_rate DESC;


-- ─────────────────────────────────────────────
-- Q3. Categories with consistently negative profit
--     (loss-making product lines)
-- ─────────────────────────────────────────────
SELECT
    p.category_name,
    COUNT(*)                                              AS total_orders,
    ROUND(AVG(oi.profit_per_order)::NUMERIC, 2)           AS avg_profit_per_order,
    ROUND(SUM(oi.profit_per_order)::NUMERIC, 2)           AS total_profit,
    ROUND(AVG(oi.discount_rate)::NUMERIC, 4)              AS avg_discount_rate
FROM order_items oi
JOIN products p ON oi.product_id = p.product_id
GROUP BY p.category_name
HAVING AVG(oi.profit_per_order) < 0
ORDER BY avg_profit_per_order ASC;


-- ─────────────────────────────────────────────
-- Q4. Product price vs order quantity relationship
--     Do cheaper products sell in higher quantities?
-- ─────────────────────────────────────────────
SELECT
    CASE
        WHEN p.product_price < 50    THEN 'Under $50'
        WHEN p.product_price < 100   THEN '$50 – $99'
        WHEN p.product_price < 200   THEN '$100 – $199'
        WHEN p.product_price < 500   THEN '$200 – $499'
        ELSE '$500+'
    END                                                   AS price_bucket,
    COUNT(*)                                              AS total_orders,
    ROUND(AVG(oi.quantity)::NUMERIC, 2)                   AS avg_quantity,
    ROUND(AVG(oi.sales)::NUMERIC, 2)                      AS avg_revenue,
    ROUND(AVG(oi.profit_ratio)::NUMERIC, 4)               AS avg_profit_ratio
FROM order_items oi
JOIN products p ON oi.product_id = p.product_id
GROUP BY price_bucket
ORDER BY MIN(p.product_price);
 


-- ─────────────────────────────────────────────
-- Q5. Top 10 products by total revenue
-- ─────────────────────────────────────────────
SELECT
    p.product_name,
    p.category_name,
    p.department_name,
    COUNT(*)                                              AS total_orders,
    ROUND(SUM(oi.sales)::NUMERIC, 2)                      AS total_revenue,
    ROUND(SUM(oi.profit_per_order)::NUMERIC, 2)           AS total_profit,
    ROUND(AVG(oi.profit_ratio)::NUMERIC, 4)               AS avg_profit_ratio
FROM order_items oi
JOIN products p ON oi.product_id = p.product_id
GROUP BY p.product_name, p.category_name, p.department_name
ORDER BY total_revenue DESC
LIMIT 10;


-- ─────────────────────────────────────────────
-- Q6. Global market performance
--     Volume vs profit — which markets matter most?
-- ─────────────────────────────────────────────
SELECT
    o.market,
    COUNT(DISTINCT o.order_id)                                               AS total_orders,
    COUNT(DISTINCT o.order_country)                                          AS countries_served,
    ROUND(SUM(oi.sales)::NUMERIC, 2)                                         AS total_revenue,
    ROUND(SUM(oi.profit_per_order)::NUMERIC, 2)                              AS total_profit,
    ROUND((SUM(oi.profit_per_order) / NULLIF(SUM(oi.sales), 0) * 100)::NUMERIC, 2) AS profit_margin_pct,
    ROUND(AVG(oi.sales)::NUMERIC, 2)                                         AS avg_order_value
FROM orders o
JOIN order_items oi ON o.order_id = oi.order_id
WHERE o.order_status NOT IN ('Canceled', 'Suspected_Fraud')
GROUP BY o.market
ORDER BY total_revenue DESC;


-- ─────────────────────────────────────────────
-- Q7. Top 10 countries by order volume
--     Emerging markets — volume trend by country
-- ─────────────────────────────────────────────
SELECT
    o.order_country,
    o.market,
    COUNT(DISTINCT o.order_id)               AS total_orders,
    ROUND(SUM(oi.sales)::NUMERIC, 2)         AS total_revenue,
    ROUND(AVG(oi.sales)::NUMERIC, 2)         AS avg_order_value,
    ROUND(SUM(oi.profit_per_order)::NUMERIC, 2) AS total_profit
FROM orders o
JOIN order_items oi ON o.order_id = oi.order_id
WHERE o.order_status NOT IN ('Canceled', 'Suspected_Fraud')
GROUP BY o.order_country, o.market
ORDER BY total_orders DESC
LIMIT 10;


-- ─────────────────────────────────────────────
-- Q8. Suspected fraud orders by market
--     Where is fraud most concentrated?
-- ─────────────────────────────────────────────
SELECT
    o.market,
    o.order_region,
    COUNT(DISTINCT o.order_id)                                                    AS fraud_orders,
    ROUND(SUM(oi.sales)::NUMERIC, 2)                                              AS revenue_at_risk,
    ROUND(COUNT(DISTINCT o.order_id) * 100.0 /
        SUM(COUNT(DISTINCT o.order_id)) OVER (PARTITION BY o.market), 2)          AS pct_of_market_orders
FROM orders o
JOIN order_items oi ON o.order_id = oi.order_id
WHERE o.order_status = 'Suspected_Fraud'
GROUP BY o.market, o.order_region
ORDER BY fraud_orders DESC
LIMIT 15;