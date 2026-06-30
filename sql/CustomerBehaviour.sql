-- ============================================================
-- Supply Chain & E-Commerce Project
-- Business Questions: Customer Behavior
-- ============================================================


-- ─────────────────────────────────────────────
-- Q1. Revenue and profit by customer segment
-- ─────────────────────────────────────────────
SELECT
    c.segment,
    COUNT(DISTINCT o.order_id)                                               AS total_orders,
    COUNT(DISTINCT c.customer_id)                                            AS total_customers,
    ROUND(SUM(oi.sales)::NUMERIC, 2)                                         AS total_revenue,
    ROUND(SUM(oi.profit_per_order)::NUMERIC, 2)                              AS total_profit,
    ROUND(AVG(oi.sales)::NUMERIC, 2)                                         AS avg_order_value,
    ROUND((SUM(oi.profit_per_order) / NULLIF(SUM(oi.sales), 0) * 100)::NUMERIC, 2) AS profit_margin_pct
FROM customers c
JOIN orders o     ON c.customer_id = o.customer_id
JOIN order_items oi ON o.order_id = oi.order_id
GROUP BY c.segment
ORDER BY total_revenue DESC;


-- ─────────────────────────────────────────────
-- Q2. Average order value per segment
--     Is Corporate higher value than Consumer?
-- ─────────────────────────────────────────────
SELECT
    c.segment,
    ROUND(AVG(oi.sales)::NUMERIC, 2)              AS avg_order_value,
    ROUND(AVG(oi.profit_per_order)::NUMERIC, 2)   AS avg_profit_per_order,
    ROUND(AVG(oi.quantity)::NUMERIC, 2)           AS avg_quantity_per_order
FROM customers c
JOIN orders o       ON c.customer_id = o.customer_id
JOIN order_items oi ON o.order_id = oi.order_id
WHERE o.order_status NOT IN ('Canceled', 'Suspected_Fraud')
GROUP BY c.segment
ORDER BY avg_order_value DESC;


-- ─────────────────────────────────────────────
-- Q3. Top 10 countries by revenue
-- ─────────────────────────────────────────────
SELECT
    o.order_country,
    o.market,
    COUNT(DISTINCT o.order_id)               AS total_orders,
    ROUND(SUM(oi.sales)::NUMERIC, 2)         AS total_revenue,
    ROUND(AVG(oi.sales)::NUMERIC, 2)         AS avg_order_value
FROM orders o
JOIN order_items oi ON o.order_id = oi.order_id
WHERE o.order_status NOT IN ('Canceled', 'Suspected_Fraud')
GROUP BY o.order_country, o.market
ORDER BY total_revenue DESC
LIMIT 10;


-- ─────────────────────────────────────────────
-- Q4. Top 10 cities by revenue
-- ─────────────────────────────────────────────
SELECT
    o.order_city,
    o.order_country,
    COUNT(DISTINCT o.order_id)               AS total_orders,
    ROUND(SUM(oi.sales)::NUMERIC, 2)         AS total_revenue,
    ROUND(AVG(oi.sales)::NUMERIC, 2)         AS avg_order_value
FROM orders o
JOIN order_items oi ON o.order_id = oi.order_id
WHERE o.order_status NOT IN ('Canceled', 'Suspected_Fraud')
GROUP BY o.order_city, o.order_country
ORDER BY total_revenue DESC
LIMIT 10;


-- ─────────────────────────────────────────────
-- Q5. Sales per customer by segment
--     Who spends more per visit?
-- ─────────────────────────────────────────────
SELECT
    c.segment,
    ROUND(AVG(oi.sales_per_customer)::NUMERIC, 2)  AS avg_sales_per_customer,
    ROUND(MAX(oi.sales_per_customer)::NUMERIC, 2)  AS max_sales_per_customer,
    ROUND(MIN(oi.sales_per_customer)::NUMERIC, 2)  AS min_sales_per_customer
FROM customers c
JOIN orders o       ON c.customer_id = o.customer_id
JOIN order_items oi ON o.order_id = oi.order_id
GROUP BY c.segment
ORDER BY avg_sales_per_customer DESC;


-- ─────────────────────────────────────────────
-- Q6. Repeat vs one-time customers
-- ─────────────────────────────────────────────
WITH customer_order_counts AS (
    SELECT
        customer_id,
        COUNT(DISTINCT order_id) AS order_count
    FROM orders
    WHERE order_status NOT IN ('Canceled', 'Suspected_Fraud')
    GROUP BY customer_id
),
customer_segments AS (
    SELECT
        customer_id,
        order_count,
        CASE
            WHEN order_count = 1  THEN 'One-time'
            WHEN order_count <= 3 THEN 'Returning'
            ELSE 'Loyal'
        END AS customer_type
    FROM customer_order_counts
)
SELECT
    customer_type,
    COUNT(*)                                          AS customer_count,
    ROUND(COUNT(*) * 100.0 / SUM(COUNT(*)) OVER (), 2) AS pct_of_total,
    ROUND(AVG(order_count)::NUMERIC, 2)               AS avg_orders
FROM customer_segments
GROUP BY customer_type
ORDER BY customer_count DESC;


-- ─────────────────────────────────────────────
-- Q7. RFM Customer Segmentation
--     Recency / Frequency / Monetary
-- ─────────────────────────────────────────────
--
WITH rfm_base AS (
    SELECT
        o.customer_id,
        MAX(o.order_date::TIMESTAMP)                        AS last_order_date,
        COUNT(DISTINCT o.order_id)                          AS frequency,
        ROUND(SUM(oi.sales)::NUMERIC, 2)                    AS monetary
    FROM orders o
    JOIN order_items oi ON o.order_id = oi.order_id
    WHERE o.order_status NOT IN ('Canceled', 'Suspected_Fraud')
    GROUP BY o.customer_id
),
rfm_scores AS (
    SELECT
        customer_id,
        last_order_date,
        frequency,
        monetary,
        EXTRACT(DAY FROM (MAX(last_order_date) OVER () - last_order_date)) AS recency_days,
        NTILE(4) OVER (ORDER BY last_order_date ASC)         AS r_score,
        NTILE(4) OVER (ORDER BY frequency ASC)               AS f_score,
        NTILE(4) OVER (ORDER BY monetary ASC)                AS m_score
    FROM rfm_base
),
rfm_segments AS (
    SELECT
        customer_id,
        recency_days,
        frequency,
        monetary,
        r_score,
        f_score,
        m_score,
        CASE
            WHEN r_score = 4 AND f_score >= 2               THEN 'Champions'
            WHEN r_score >= 3 AND f_score >= 3               THEN 'Loyal'
            WHEN r_score >= 3 AND f_score < 3                THEN 'Recent'
            WHEN r_score < 3  AND f_score >= 3               THEN 'At Risk'
            ELSE 'Lost'
        END AS segment
    FROM rfm_scores
)
SELECT
    segment,
    COUNT(*)                                             AS customer_count,
    ROUND(AVG(monetary)::NUMERIC, 2)                     AS avg_spend,
    ROUND(AVG(frequency)::NUMERIC, 2)                    AS avg_orders,
    ROUND(AVG(recency_days)::NUMERIC, 0)                 AS avg_recency_days
FROM rfm_segments
GROUP BY segment
ORDER BY avg_spend DESC;
 