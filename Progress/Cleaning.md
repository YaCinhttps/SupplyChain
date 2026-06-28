# Phase 1 & 2 — Data Cleaning & Database Setup

## Status: ✅ Complete

---

## Overview

This phase takes the raw DataCo Supply Chain flat CSV, cleans it, splits it into 5 relational tables, and loads them into PostgreSQL ready for SQL analysis.

---

## Input

| File | Format | Description |
|------|--------|-------------|
| `DataCoSupplyChainDataset.csv` | Flat CSV | Raw dataset — all fields in one file |

---

## What Gets Cleaned

### Global Cleaning (full flat file)

| Step | What We Do | Why |
|------|-----------|-----|
| Strip column name whitespace | Remove leading/trailing spaces from all headers | Prevents column mismatch errors |
| Drop 5 useless columns | Remove email, password, product description, image URL, duplicate product ID | PII removal + no analytical value |
| Parse date columns | Convert order date and shipping date from object to datetime | Required for time-based analysis |
| Standardise string columns | Title case + strip whitespace on all categoricals | Consistent grouping in SQL and Power BI |
| Remove duplicate rows | Drop fully identical rows | Data integrity |
| Validate numeric ranges | Check sales > 0, quantity > 0, discount rate 0–1, shipping days ≥ 0 | Catch bad data before it reaches the database |
| Handle missing values | Zipcodes → "Unknown", Product Status → 0 | No nulls in key fields |

### Columns Dropped

| Column | Reason |
|--------|--------|
| `Customer Email` | PII — no analytical value |
| `Customer Password` | PII — no analytical value |
| `Product Description` | Unstructured text — not useful for SQL/BI |
| `Product Image` | URL string — not useful |
| `Order Item Cardprod Id` | Duplicate of Product Card Id |

---

## Table Split — Raw Flat File → 5 Relational Tables

The flat CSV contains all fields in one row per order item. We split it into a proper relational schema before loading into PostgreSQL.

```
DataCoSupplyChainDataset.csv (flat)
            │
            ▼
    ┌───────────────┐
    │   customers   │  ← Who bought
    └───────────────┘
    ┌───────────────┐
    │   products    │  ← What was sold
    └───────────────┘
    ┌───────────────┐
    │    orders     │  ← Transaction header
    └───────────────┘
    ┌───────────────┐
    │  order_items  │  ← Transaction line items (financial detail)
    └───────────────┘
    ┌───────────────┐
    │   shipping    │  ← Delivery & logistics info
    └───────────────┘
```

### Table Definitions

**customers** — one row per unique customer
| Column | Type | Description |
|--------|------|-------------|
| customer_id | INTEGER PK | Unique customer identifier |
| first_name | VARCHAR | Customer first name |
| last_name | VARCHAR | Customer last name |
| segment | VARCHAR | Consumer / Corporate / Home Office |
| city | VARCHAR | Customer city |
| country | VARCHAR | Customer country |
| state | VARCHAR | Customer state |
| street | VARCHAR | Customer street |
| zipcode | VARCHAR | Customer zipcode |
| latitude | NUMERIC | Store latitude |
| longitude | NUMERIC | Store longitude |

**products** — one row per unique product
| Column | Type | Description |
|--------|------|-------------|
| product_id | INTEGER PK | Unique product identifier |
| product_name | VARCHAR | Product name |
| product_price | NUMERIC | Product list price |
| product_category_id | INTEGER | FK to category |
| category_id | INTEGER | Category code |
| category_name | VARCHAR | Category description |
| department_id | INTEGER | Department code |
| department_name | VARCHAR | Department name |
| product_status | SMALLINT | 0 = available, 1 = not available |

**orders** — one row per unique order
| Column | Type | Description |
|--------|------|-------------|
| order_id | INTEGER PK | Unique order identifier |
| customer_id | INTEGER FK | Links to customers |
| order_date | TEXT → TIMESTAMP | Date and time of order |
| order_status | VARCHAR | COMPLETE / PENDING / CANCELED etc. |
| market | VARCHAR | Africa / Europe / LATAM / Pacific Asia / USCA |
| order_region | VARCHAR | Specific world region |
| order_city | VARCHAR | Destination city |
| order_country | VARCHAR | Destination country |
| order_state | VARCHAR | Destination state |
| transaction_type | VARCHAR | Payment type |

**order_items** — one row per order line item
| Column | Type | Description |
|--------|------|-------------|
| order_item_id | INTEGER PK | Unique line item identifier |
| order_id | INTEGER FK | Links to orders |
| product_id | INTEGER FK | Links to products |
| quantity | INTEGER | Units ordered |
| sales | NUMERIC | Revenue for this line item |
| order_item_total | NUMERIC | Total amount including adjustments |
| discount | NUMERIC | Discount value applied |
| discount_rate | NUMERIC | Discount as a ratio (0–1) |
| item_product_price | NUMERIC | Unit price at time of order |
| profit_ratio | NUMERIC | Profit ratio for this item |
| benefit_per_order | NUMERIC | Earnings per order |
| profit_per_order | NUMERIC | Profit per order |
| sales_per_customer | NUMERIC | Total sales attributed to customer |

**shipping** — one row per order
| Column | Type | Description |
|--------|------|-------------|
| order_id | INTEGER PK/FK | Links to orders |
| shipping_mode | VARCHAR | Standard / First Class / Second Class / Same Day |
| shipping_date | TEXT → TIMESTAMP | Actual ship date |
| days_for_shipping_real | INTEGER | Actual days taken to ship |
| days_for_shipment_scheduled | INTEGER | Planned days to ship |
| delivery_status | VARCHAR | Advance Shipping / Late Delivery / On Time / Canceled |
| late_delivery_risk | SMALLINT | 0 = on time, 1 = late |
| delivery_delay_days | INTEGER | Real − Scheduled (positive = late, negative = early) |

---

## Engineered Columns

| Column | Table | Formula | Purpose |
|--------|-------|---------|---------|
| `delivery_delay_days` | shipping | `days_for_shipping_real − days_for_shipment_scheduled` | Quantifies how late or early each delivery was |

---

## Database Setup

### SQL Scripts

| Script | Purpose | Run Order |
|--------|---------|-----------|
| `sql/Supply.sql` | Create all 5 tables with PKs, FKs, and indexes | 1st |
| `sql/Load.sql` | COPY clean CSVs into PostgreSQL | 2nd |
| `sql/Validate.sql` | Sanity checks — nulls, FK integrity, numeric ranges | 3rd |

### Known Issues & Fixes Applied

| Issue | Fix |
|-------|-----|
| Date columns saved as `object` in CSV | Declared as `TEXT` in schema, cast to `TIMESTAMP` after load using `ALTER TABLE ... USING order_date::TIMESTAMP` |
| `function to_timestamp(timestamp, unknown) does not exist` | Removed `TO_TIMESTAMP()` — column already typed, used direct `::TIMESTAMP` cast instead |
| `invalid input syntax for type integer: "Advance Shipping"` | Column order in COPY statement didn't match CSV — fixed column mapping in `Load.sql` |
| `function date_trunc(unknown, character varying) does not exist` | Added explicit `::TIMESTAMP` cast in validation script `DATE_TRUNC('month', order_date::TIMESTAMP)` |
| `shipping_date` missing from shipping CSV | Column was not included in the split — loaded shipping table without it; can be added via `ALTER TABLE shipping ADD COLUMN shipping_date TIMESTAMP` |

---

## Output Files

```
data/
└── clean/
    ├── customers_clean.csv
    ├── products_clean.csv
    ├── orders_clean.csv
    ├── order_items_clean.csv
    └── shipping_clean.csv
```

---

## Before & After

| Table | Unique Key | Rows (approx) | Columns |
|-------|-----------|---------------|---------|
| customers | customer_id | ~20K | 11 |
| products | product_id | ~1.8K | 9 |
| orders | order_id | ~65K | 10 |
| order_items | order_item_id | ~180K | 13 |
| shipping | order_id | ~65K | 8 |

---

## Skills Demonstrated

| Skill | How |
|-------|-----|
| Data modelling | Decomposed a flat file into a normalised 5-table relational schema |
| Python / pandas | Cleaning, splitting, validating, and exporting structured data |
| PostgreSQL | Schema design, COPY loading, ALTER TABLE casting, indexing |
| Data quality | Null handling, range validation, FK integrity checks |
| Documentation | README, inline comments, issue log |

---

## Phase Timeline

| Phase | Status |
|-------|--------|
| Phase 1 — Data Cleaning | ✅ Done |
| Phase 2 — Database Setup | ✅ Done |
| **Phase 3 — SQL Analysis** | 🔄 Up Next |
| Phase 4 — Python EDA | ⬜ Pending |
| Phase 5 — Power BI Dashboard | ⬜ Pending |
| Phase 6 — README & Publishing | ⬜ Pending |