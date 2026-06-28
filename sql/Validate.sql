
-- ─────────────────────────────────────────────
-- 1. Row counts
-- ─────────────────────────────────────────────
SELECT 'customers'   AS table_name, COUNT(*) AS row_count FROM customers
UNION ALL
SELECT 'products',                  COUNT(*)              FROM products
UNION ALL
SELECT 'orders',                    COUNT(*)              FROM orders
UNION ALL
SELECT 'order_items',               COUNT(*)              FROM order_items
UNION ALL
SELECT 'shipping',                  COUNT(*)              FROM shipping
ORDER BY table_name;

-- ─────────────────────────────────────────────
-- 2. Check for nulls in key columns
-- ─────────────────────────────────────────────
SELECT 'orders - null customer_id'  AS check_name, COUNT(*) AS issues FROM orders      WHERE customer_id IS NULL
UNION ALL
SELECT 'orders - null order_date',                 COUNT(*)           FROM orders      WHERE order_date IS NULL
UNION ALL
SELECT 'order_items - null order_id',              COUNT(*)           FROM order_items WHERE order_id IS NULL
UNION ALL
SELECT 'order_items - null product_id',            COUNT(*)           FROM order_items WHERE product_id IS NULL
UNION ALL
SELECT 'order_items - null sales',                 COUNT(*)           FROM order_items WHERE sales IS NULL
UNION ALL
SELECT 'shipping - null delivery_status',          COUNT(*)           FROM shipping    WHERE delivery_status IS NULL
UNION ALL
SELECT 'shipping - null shipping_mode',            COUNT(*)           FROM shipping    WHERE shipping_mode IS NULL;

-- ─────────────────────────────────────────────
-- 3. Validate foreign keys manually
-- ─────────────────────────────────────────────
-- Orders referencing customers that don't exist
SELECT 'orders with missing customer' AS check_name, COUNT(*) AS issues
FROM orders o
WHERE NOT EXISTS (
    SELECT 1 FROM customers c WHERE c.customer_id = o.customer_id
);

-- Order items referencing orders that don't exist
SELECT 'order_items with missing order' AS check_name, COUNT(*) AS issues
FROM order_items oi
WHERE NOT EXISTS (
    SELECT 1 FROM orders o WHERE o.order_id = oi.order_id
);

-- Order items referencing products that don't exist
SELECT 'order_items with missing product' AS check_name, COUNT(*) AS issues
FROM order_items oi
WHERE NOT EXISTS (
    SELECT 1 FROM products p WHERE p.product_id = oi.product_id
);

-- Shipping referencing orders that don't exist
SELECT 'shipping with missing order' AS check_name, COUNT(*) AS issues
FROM shipping s
WHERE NOT EXISTS (
    SELECT 1 FROM orders o WHERE o.order_id = s.order_id
);

-- ─────────────────────────────────────────────
-- 4. Validate numeric ranges
-- ─────────────────────────────────────────────
SELECT 'negative sales'             AS check_name, COUNT(*) AS issues FROM order_items WHERE sales < 0
UNION ALL
SELECT 'zero or negative quantity',               COUNT(*)            FROM order_items WHERE quantity <= 0
UNION ALL
SELECT 'invalid discount rate',                   COUNT(*)            FROM order_items WHERE discount_rate < 0 OR discount_rate > 1
UNION ALL
SELECT 'negative shipping days',                  COUNT(*)            FROM shipping    WHERE days_for_shipping_real < 0
UNION ALL
SELECT 'invalid late_delivery_risk',              COUNT(*)            FROM shipping    WHERE late_delivery_risk NOT IN (0, 1)
UNION ALL
SELECT 'negative product price',                  COUNT(*)            FROM products    WHERE product_price <= 0;

-- ─────────────────────────────────────────────
-- 5. Value distributions — spot check
-- ─────────────────────────────────────────────
-- Customer segments
SELECT segment, COUNT(*) AS customer_count
FROM customers
GROUP BY segment
ORDER BY customer_count DESC;

-- Delivery status breakdown
SELECT delivery_status, COUNT(*) AS order_count
FROM shipping
GROUP BY delivery_status
ORDER BY order_count DESC;

-- Shipping mode breakdown
SELECT shipping_mode, COUNT(*) AS order_count
FROM shipping
GROUP BY shipping_mode
ORDER BY order_count DESC;

-- Market breakdown
SELECT market, COUNT(*) AS order_count
FROM orders
GROUP BY market
ORDER BY order_count DESC;

-- Order status breakdown
SELECT order_status, COUNT(*) AS order_count
FROM orders
GROUP BY order_status
ORDER BY order_count DESC;

-- ─────────────────────────────────────────────
-- 6. Date range check
-- ─────────────────────────────────────────────
SELECT
    MIN(order_date)    AS earliest_order,
    MAX(order_date)    AS latest_order,
    COUNT(DISTINCT DATE_TRUNC('month', order_date)) AS months_covered
FROM orders;

-- ─────────────────────────────────────────────
-- 7. Quick revenue sanity check
-- ─────────────────────────────────────────────
SELECT
    ROUND(SUM(sales)::NUMERIC, 2)            AS total_sales,
    ROUND(AVG(sales)::NUMERIC, 2)            AS avg_sales_per_item,
    ROUND(SUM(profit_per_order)::NUMERIC, 2) AS total_profit,
    COUNT(*)                                  AS total_line_items
FROM order_items;