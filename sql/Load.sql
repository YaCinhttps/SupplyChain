
-- ─────────────────────────────────────────────
-- 1. Load customers
-- ─────────────────────────────────────────────
COPY customers (
    customer_id,
    first_name,
    last_name,
    segment,
    city,
    country,
    state,
    street,
    zipcode,
    latitude,
    longitude
)
FROM 'C:\Projects\Supply Chain\data\clean\customers_clean.csv'
DELIMITER ','
CSV HEADER
NULL '';

SELECT 'customers loaded:' AS status, COUNT(*) AS rows FROM customers;

-- ─────────────────────────────────────────────
-- 2. Load products
-- ─────────────────────────────────────────────
COPY products (
    product_id,
    product_name,
    product_price,
    product_category_id,
    category_id,
    category_name,
    department_id,
    department_name,
    product_status
)
FROM 'C:\Projects\Supply Chain\data\clean\products_clean.csv'
DELIMITER ','
CSV HEADER
NULL '';

SELECT 'products loaded:' AS status, COUNT(*) AS rows FROM products;

-- ─────────────────────────────────────────────
-- 3. Load orders
-- ─────────────────────────────────────────────
COPY orders (
    order_id,
    customer_id,
    order_date,
    order_status,
    market,
    order_region,
    order_city,
    order_country,
    order_state,
    transaction_type
)
FROM 'C:\Projects\Supply Chain\data\clean\orders_clean.csv'
DELIMITER ','
CSV HEADER
NULL '';

SELECT 'orders loaded:' AS status, COUNT(*) AS rows FROM orders;



-- ─────────────────────────────────────────────
-- 4. Load order_items
-- ─────────────────────────────────────────────
COPY order_items (
    order_item_id,
    order_id,
    product_id,
    quantity,
    sales,
    order_item_total,
    discount,
    discount_rate,
    item_product_price,
    profit_ratio,
    benefit_per_order,
    profit_per_order,
    sales_per_customer
)
FROM 'C:\Projects\Supply Chain\data\clean\order_items_clean.csv'
DELIMITER ','
CSV HEADER
NULL '';

SELECT 'order_items loaded:' AS status, COUNT(*) AS rows FROM order_items;

-- ─────────────────────────────────────────────
-- 5. Load shipping
-- ─────────────────────────────────────────────
COPY shipping (
    order_id,
    shipping_mode,
    days_for_shipping_real,
    days_for_shipment_scheduled,
    delivery_status,
    late_delivery_risk,
    delivery_delay_days
)
FROM 'C:\Projects\Supply Chain\data\clean\shipping_clean.csv'
DELIMITER ','
CSV HEADER
NULL '';

SELECT 'shipping loaded:' AS status, COUNT(*) AS rows FROM shipping;

-- ─────────────────────────────────────────────
-- Final row count check — all tables
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




ALTER TABLE orders
ALTER COLUMN order_date TYPE TIMESTAMP
USING order_date::TIMESTAMP;

ALTER TABLE shipping
ALTER COLUMN shipping_date TYPE TIMESTAMP
USING shipping_date::TIMESTAMP;

-- Verify
SELECT pg_typeof(order_date)    FROM orders   LIMIT 1;
SELECT pg_typeof(shipping_date) FROM shipping LIMIT 1;