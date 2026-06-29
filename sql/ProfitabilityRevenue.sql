

-- ============================================================
-- Supply Chain & E-Commerce Project
-- Script: 01_revenue_profitability.sql
-- Business Questions: Revenue & Profitability
-- ============================================================

-- ─────────────────────────────────────────────
-- Q1. Total revenue, total profit, and overall profit margin
-- ─────────────────────────────────────────────
SELECT
    ROUND(SUM(sales)::NUMERIC, 2)                                        AS total_revenue,
    ROUND(SUM(profit_per_order)::NUMERIC, 2)                             AS total_profit,
    ROUND((SUM(profit_per_order) / NULLIF(SUM(sales), 0) * 100)::NUMERIC, 2) AS profit_margin_pct
FROM order_items;


-- ─────────────────────────────────────────────
-- Q2. Revenue vs profit by product category
--     (they won't be the same — find the gap)
-- ─────────────────────────────────────────────
SELECT
    p.category_name,
    COUNT(DISTINCT oi.order_id)                                              AS total_orders,
    ROUND(SUM(oi.sales)::NUMERIC, 2)                                         AS total_revenue,
    ROUND(SUM(oi.profit_per_order)::NUMERIC, 2)                              AS total_profit,
    ROUND((SUM(oi.profit_per_order) / NULLIF(SUM(oi.sales), 0) * 100)::NUMERIC, 2) AS profit_margin_pct,
    ROUND(AVG(oi.sales)::NUMERIC, 2)                                         AS avg_order_value
FROM order_items oi
JOIN products p ON oi.product_id = p.product_id
GROUP BY p.category_name
ORDER BY total_profit DESC;


-- ─────────────────────────────────────────────
-- Q3. Revenue and profit by department
-- ─────────────────────────────────────────────
SELECT
    p.department_name,
    COUNT(DISTINCT oi.order_id)                                              AS total_orders,
    ROUND(SUM(oi.sales)::NUMERIC, 2)                                         AS total_revenue,
    ROUND(SUM(oi.profit_per_order)::NUMERIC, 2)                              AS total_profit,
    ROUND((SUM(oi.profit_per_order) / NULLIF(SUM(oi.sales), 0) * 100)::NUMERIC, 2) AS profit_margin_pct
FROM order_items oi
JOIN products p ON oi.product_id = p.product_id
GROUP BY p.department_name
ORDER BY total_revenue DESC;


-- ─────────────────────────────────────────────
-- Q4. Average profit per order — and what drags it down
--     Bottom 10 categories by avg profit per order
-- ─────────────────────────────────────────────
SELECT
    p.category_name,
    ROUND(AVG(oi.profit_per_order)::NUMERIC, 2) AS avg_profit_per_order,
    ROUND(AVG(oi.sales)::NUMERIC, 2)             AS avg_revenue_per_order,
    COUNT(*)                                      AS total_line_items
FROM order_items oi
JOIN products p ON oi.product_id = p.product_id
GROUP BY p.category_name
ORDER BY avg_profit_per_order DESC
LIMIT 10;   



-- ─────────────────────────────────────────────
-- Q5. Does discounting hurt profit?
--     Discount rate buckets vs avg profit ratio
-- ─────────────────────────────────────────────
SELECT
    CASE
        WHEN discount_rate = 0            THEN '0% — No discount'
        WHEN discount_rate <= 0.05        THEN '1–5%'
        WHEN discount_rate <= 0.10        THEN '6–10%'
        WHEN discount_rate <= 0.20        THEN '11–20%'
        WHEN discount_rate <= 0.30        THEN '21–30%'
        ELSE '30%+'
    END                                                  AS discount_bucket,
    COUNT(*)                                             AS total_orders,
    ROUND(AVG(profit_ratio)::NUMERIC, 4)                 AS avg_profit_ratio,
    ROUND(AVG(sales)::NUMERIC, 2)                        AS avg_sales,
    ROUND(SUM(profit_per_order)::NUMERIC, 2)             AS total_profit
FROM order_items
GROUP BY discount_bucket
ORDER BY avg_profit_ratio DESC;


-- ─────────────────────────────────────────────
-- Q6. Profitability by market
--     Revenue vs profit — are all markets equally profitable?
-- ─────────────────────────────────────────────
SELECT
    o.market,
    COUNT(DISTINCT o.order_id)                                               AS total_orders,
    ROUND(SUM(oi.sales)::NUMERIC, 2)                                         AS total_revenue,
    ROUND(SUM(oi.profit_per_order)::NUMERIC, 2)                              AS total_profit,
    ROUND((SUM(oi.profit_per_order) / NULLIF(SUM(oi.sales), 0) * 100)::NUMERIC, 2) AS profit_margin_pct,
    ROUND(AVG(oi.sales)::NUMERIC, 2)                                         AS avg_order_value
FROM order_items oi
JOIN orders o ON oi.order_id = o.order_id
GROUP BY o.market
ORDER BY total_profit DESC;


-- ─────────────────────────────────────────────
-- Q7. Categories or markets where we sell at a loss
--     (negative avg profit per order)
-- ─────────────────────────────────────────────
SELECT
    p.category_name,
    o.market,
    COUNT(*)                                              AS total_orders,
    ROUND(AVG(oi.profit_per_order)::NUMERIC, 2)          AS avg_profit_per_order,
    ROUND(SUM(oi.profit_per_order)::NUMERIC, 2)          AS total_profit
FROM order_items oi
JOIN products p ON oi.product_id = p.product_id
JOIN orders o    ON oi.order_id = o.order_id
GROUP BY p.category_name, o.market
HAVING AVG(oi.profit_per_order) < 0
ORDER BY avg_profit_per_order ASC;