-- ============================================================
-- Supply Chain & E-Commerce Project
-- Business Questions: Logistics & Delivery Performance
-- ============================================================


-- ─────────────────────────────────────────────
-- Q1. Overall late delivery rate
-- ─────────────────────────────────────────────
SELECT
    delivery_status,
    COUNT(*)                                              AS total_orders,
    ROUND(COUNT(*) * 100.0 / SUM(COUNT(*)) OVER (), 2)   AS pct_of_total
FROM shipping
GROUP BY delivery_status
ORDER BY total_orders DESC;


-- ─────────────────────────────────────────────
-- Q2. Late delivery rate by shipping mode
--     Which mode fails most often?
-- ─────────────────────────────────────────────
SELECT
    shipping_mode,
    COUNT(*)                                              AS total_orders,
    SUM(late_delivery_risk)                               AS late_orders,
    ROUND(SUM(late_delivery_risk) * 100.0 / COUNT(*), 2) AS late_delivery_rate_pct,
    ROUND(AVG(days_for_shipping_real)::NUMERIC, 2)        AS avg_actual_days,
    ROUND(AVG(days_for_shipment_scheduled)::NUMERIC, 2)   AS avg_scheduled_days,
    ROUND(AVG(delivery_delay_days)::NUMERIC, 2)           AS avg_delay_days
FROM shipping
GROUP BY shipping_mode
ORDER BY late_delivery_rate_pct DESC;


-- ─────────────────────────────────────────────
-- Q3. Gap between scheduled and actual delivery days
--     by shipping mode
-- ─────────────────────────────────────────────
SELECT
    shipping_mode,
    ROUND(AVG(days_for_shipment_scheduled)::NUMERIC, 2)   AS avg_scheduled_days,
    ROUND(AVG(days_for_shipping_real)::NUMERIC, 2)        AS avg_actual_days,
    ROUND(AVG(delivery_delay_days)::NUMERIC, 2)           AS avg_delay_days,
    ROUND(MAX(delivery_delay_days)::NUMERIC, 0)           AS max_delay_days,
    ROUND(MIN(delivery_delay_days)::NUMERIC, 0)           AS min_delay_days
FROM shipping
GROUP BY shipping_mode
ORDER BY avg_delay_days DESC;


-- ─────────────────────────────────────────────
-- Q4. Late delivery rate by market
--     Which global markets have the worst performance?
-- ─────────────────────────────────────────────
SELECT
    o.market,
    COUNT(s.order_id)                                     AS total_orders,
    SUM(s.late_delivery_risk)                             AS late_orders,
    ROUND(SUM(s.late_delivery_risk) * 100.0 / COUNT(*), 2) AS late_rate_pct,
    ROUND(AVG(s.days_for_shipping_real)::NUMERIC, 2)      AS avg_actual_days,
    ROUND(AVG(s.delivery_delay_days)::NUMERIC, 2)         AS avg_delay_days
FROM shipping s
JOIN orders o ON s.order_id = o.order_id
GROUP BY o.market
ORDER BY late_rate_pct DESC;


-- ─────────────────────────────────────────────
-- Q5. Late delivery rate by order region
--     Drill below market level
-- ─────────────────────────────────────────────
SELECT
    o.order_region,
    o.market,
    COUNT(s.order_id)                                      AS total_orders,
    SUM(s.late_delivery_risk)                              AS late_orders,
    ROUND(SUM(s.late_delivery_risk) * 100.0 / COUNT(*), 2) AS late_rate_pct,
    ROUND(AVG(s.delivery_delay_days)::NUMERIC, 2)          AS avg_delay_days
FROM shipping s
JOIN orders o ON s.order_id = o.order_id
GROUP BY o.order_region, o.market
ORDER BY late_rate_pct DESC
LIMIT 20;


-- ─────────────────────────────────────────────
-- Q6. Late delivery by product category
--     Are certain product types more often late?
-- ─────────────────────────────────────────────
SELECT
    p.category_name,
    COUNT(DISTINCT s.order_id)                             AS total_orders,
    SUM(s.late_delivery_risk)                              AS late_orders,
    ROUND(SUM(s.late_delivery_risk) * 100.0 / COUNT(*), 2) AS late_rate_pct
FROM shipping s
JOIN order_items oi ON s.order_id = oi.order_id
JOIN products p     ON oi.product_id = p.product_id
GROUP BY p.category_name
ORDER BY late_rate_pct DESC;


-- ─────────────────────────────────────────────
-- Q7. Financial cost of late deliveries
--     Are late orders less profitable?
-- ─────────────────────────────────────────────
SELECT
    CASE WHEN s.late_delivery_risk = 1 THEN 'Late' ELSE 'On Time' END AS delivery_type,
    COUNT(DISTINCT o.order_id)                                          AS total_orders,
    ROUND(AVG(oi.sales)::NUMERIC, 2)                                    AS avg_revenue,
    ROUND(AVG(oi.profit_per_order)::NUMERIC, 2)                         AS avg_profit,
    ROUND(SUM(oi.profit_per_order)::NUMERIC, 2)                         AS total_profit,
    ROUND((SUM(oi.profit_per_order) / NULLIF(SUM(oi.sales), 0) * 100)::NUMERIC, 2) AS profit_margin_pct
FROM shipping s
JOIN orders o       ON s.order_id = o.order_id
JOIN order_items oi ON o.order_id = oi.order_id
Group BY delivery_type
ORDER BY delivery_type;


-- ─────────────────────────────────────────────
-- Q8. Same Day shipping — is it actually faster?
--     Actual vs scheduled by mode
-- ─────────────────────────────────────────────
SELECT
    shipping_mode,
    COUNT(*)                                               AS total_orders,
    ROUND(AVG(days_for_shipping_real)::NUMERIC, 2)         AS avg_actual_days,
    ROUND(AVG(days_for_shipment_scheduled)::NUMERIC, 2)    AS avg_scheduled_days,
    ROUND(SUM(CASE WHEN late_delivery_risk = 0 THEN 1 ELSE 0 END) * 100.0 / COUNT(*), 2) AS on_time_rate_pct
FROM shipping
GROUP BY shipping_mode
ORDER BY avg_actual_days ASC;


-- ─────────────────────────────────────────────
-- Q9. Shipping cancellation rate by market
-- ─────────────────────────────────────────────
SELECT
    o.market,
    COUNT(s.order_id)                                                         AS total_orders,
    SUM(CASE WHEN s.delivery_status = 'Shipping Canceled' THEN 1 ELSE 0 END) AS canceled_orders,
    ROUND(SUM(CASE WHEN s.delivery_status = 'Shipping Canceled' THEN 1 ELSE 0 END)
        * 100.0 / COUNT(*), 2)                                                AS cancellation_rate_pct
FROM shipping s
JOIN orders o ON s.order_id = o.order_id
GROUP BY o.market
ORDER BY cancellation_rate_pct DESC;