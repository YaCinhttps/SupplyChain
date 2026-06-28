Create DATABASE "SupplyDB";

-- ============================================================
-- Supply Chain & E-Commerce Project
-- Script: 01_create_schema.sql
-- Description: Create all tables with primary and foreign keys
-- Run this BEFORE loading any data
-- ============================================================

-- Drop tables if they exist (in dependency order)
DROP TABLE IF EXISTS order_items CASCADE;
DROP TABLE IF EXISTS shipping   CASCADE;
DROP TABLE IF EXISTS orders     CASCADE;
DROP TABLE IF EXISTS customers  CASCADE;
DROP TABLE IF EXISTS products   CASCADE;

-- ─────────────────────────────────────────────
-- 1. customers
-- ─────────────────────────────────────────────
CREATE TABLE customers (
    customer_id       INTEGER         PRIMARY KEY,
    first_name        VARCHAR(100),
    last_name         VARCHAR(100),
    segment           VARCHAR(50),
    city              VARCHAR(100),
    country           VARCHAR(100),
    state             VARCHAR(100),
    street            VARCHAR(200),
    zipcode           VARCHAR(20),
    latitude          NUMERIC(10, 6),
    longitude         NUMERIC(10, 6)
);

-- ─────────────────────────────────────────────
-- 2. products
-- ─────────────────────────────────────────────
CREATE TABLE products (
    product_id          INTEGER         PRIMARY KEY,
    product_name        VARCHAR(200),
    product_price       NUMERIC(10, 2),
    product_category_id INTEGER,
    category_id         INTEGER,
    category_name       VARCHAR(100),
    department_id       INTEGER,
    department_name     VARCHAR(100),
    product_status      SMALLINT        DEFAULT 0   -- 0 = available, 1 = not available
);

-- ─────────────────────────────────────────────
-- 3. orders
-- ─────────────────────────────────────────────
CREATE TABLE orders (
    order_id          INTEGER         PRIMARY KEY,
    customer_id       INTEGER         NOT NULL REFERENCES customers(customer_id),
    order_date        VARCHAR(20),
    order_status      VARCHAR(50),
    market            VARCHAR(50),
    order_region      VARCHAR(100),
    order_city        VARCHAR(100),
    order_country     VARCHAR(100),
    order_state       VARCHAR(100),
    transaction_type  VARCHAR(50)
);

-- ─────────────────────────────────────────────
-- 4. order_items
-- ─────────────────────────────────────────────
CREATE TABLE order_items (
    order_item_id           INTEGER         PRIMARY KEY,
    order_id                INTEGER         NOT NULL REFERENCES orders(order_id),
    product_id              INTEGER         NOT NULL REFERENCES products(product_id),
    quantity                INTEGER,
    sales                   NUMERIC(10, 2),
    order_item_total        NUMERIC(10, 2),
    discount                NUMERIC(10, 2),
    discount_rate           NUMERIC(5, 4),
    item_product_price      NUMERIC(10, 2),
    profit_ratio            NUMERIC(8, 4),
    benefit_per_order       NUMERIC(10, 2),
    profit_per_order        NUMERIC(10, 2),
    sales_per_customer      NUMERIC(10, 2)
);

-- ─────────────────────────────────────────────
-- 5. shipping
-- ─────────────────────────────────────────────
CREATE TABLE shipping (
    order_id                    INTEGER         PRIMARY KEY REFERENCES orders(order_id),
    shipping_mode               VARCHAR(50),
    shipping_date               VARCHAR(20),
    days_for_shipping_real      INTEGER,
    days_for_shipment_scheduled INTEGER,
    delivery_status             VARCHAR(50),
    late_delivery_risk          SMALLINT,       -- 0 = on time, 1 = late
    delivery_delay_days         INTEGER         -- real - scheduled (positive = late)
);


-- ─────────────────────────────────────────────
-- Indexes for common join & filter columns
-- ─────────────────────────────────────────────
CREATE INDEX idx_orders_customer_id     ON orders(customer_id);
CREATE INDEX idx_orders_order_date      ON orders(order_date);
CREATE INDEX idx_orders_market          ON orders(market);
CREATE INDEX idx_orders_status          ON orders(order_status);

CREATE INDEX idx_order_items_order_id   ON order_items(order_id);
CREATE INDEX idx_order_items_product_id ON order_items(product_id);

CREATE INDEX idx_shipping_status        ON shipping(delivery_status);
CREATE INDEX idx_shipping_mode          ON shipping(shipping_mode);
CREATE INDEX idx_shipping_late_risk     ON shipping(late_delivery_risk);

CREATE INDEX idx_products_category      ON products(category_name);
CREATE INDEX idx_products_department    ON products(department_name);

CREATE INDEX idx_customers_segment      ON customers(segment);
CREATE INDEX idx_customers_country      ON customers(country);

-- ─────────────────────────────────────────────
-- Verify tables were created
-- ─────────────────────────────────────────────
SELECT
    table_name,
    (SELECT COUNT(*) FROM information_schema.columns c
     WHERE c.table_name = t.table_name
     AND c.table_schema = 'public') AS column_count
FROM information_schema.tables t
WHERE table_schema = 'public'
  AND table_type = 'BASE TABLE'
ORDER BY table_name;