# Supply Chain & E-Commerce Analysis

A full end-to-end data analytics project built on real supply chain and e-commerce data. The goal was to take a single flat CSV covering hundreds of thousands of transactions, decompose it into a proper relational database, run structured business analysis across sales, logistics, and customer behavior, and deliver an interactive Power BI dashboard a business team could actually use.

This project covers the full pipeline: cleaning and modeling the data in Python, loading it into PostgreSQL, writing SQL queries to answer real business questions, building EDA charts, and finishing with a three-page interactive Power BI dashboard connected directly to the database.

---

## Why this project

Supply chain and logistics analytics is one of the most in-demand skill sets for data analysts in Germany — manufacturing, automotive, and e-commerce companies all need people who can work across sales performance, operational efficiency, and customer behavior simultaneously. This dataset gave me all three in one place, with real data quality issues to solve and enough depth to write 38 SQL queries across five business areas.

The project also gave me the opportunity to practice something most portfolio projects skip — decomposing a flat file into a normalised relational schema before analysis. That decision made the SQL phase significantly more powerful and mirrors what analysts actually do when working with raw operational data.

---

## What the data covers

The dataset comes from the [DataCo Supply Chain Dataset](https://www.kaggle.com/datasets/shashwatwork/dataco-smart-supply-chain-for-big-data-analysis) on Kaggle — a fictional global e-commerce and supply chain company. It covers 180,000+ order line items across a single flat CSV with 53 columns, spanning January 2015 to January 2018 across 5 markets and 50+ countries.

The flat file was decomposed into 5 relational tables:

- Orders, order items, customers, products, shipping

---

## Project structure

```
Supply Chain/
├── data/
│   ├── clean/   
    └── Raw  /
├── notebooks/
│   ├── 01Cleaning.ipynb         # Data cleaning and table split
│   └── 03_eda.ipynb              # EDA charts
├── sql/
│   ├── 01_create_schema.sql      # PostgreSQL schema
│   ├── 02_load_data.sql          # COPY commands
│   ├── 03_validate_load.sql      # Data quality checks
│   └── analysis/
│       ├── 01_revenue_profitability.sql
│       ├── 02_sales_performance.sql
│       ├── 03_customer_behavior.sql
│       ├── 04_logistics_delivery.sql
│       └── 05_product_geo_analysis.sql
├── images/              
├── Progress/       
├── dashboard/
│   └── 04Visual.pbix         # Power BI file
├── requirements.txt
├── Questions.txt       # FAQ
└── README.md
```

---

## Phase 1 — Data cleaning & modeling

Cleaned the raw flat CSV in Python using pandas and decomposed it into 5 relational tables before loading into PostgreSQL.

**Global cleaning steps:**

| Step | What was fixed |
|------|---------------|
| Column names | Stripped leading/trailing whitespace from all 53 headers |
| PII removal | Dropped customer email, password, product description, image URL, duplicate product ID |
| Date columns | Parsed order date and shipping date from object to datetime |
| String columns | Title case and whitespace strip on all categorical fields |
| Duplicates | Removed fully identical rows |
| Numeric validation | Sales > 0, quantity > 0, discount rate 0–1, shipping days ≥ 0 |
| Missing values | Zipcodes filled with "Unknown", Product Status filled with 0 |

**Table split — flat file → 5 relational tables:**

| Table | Key | Rows | Description |
|-------|-----|------|-------------|
| customers | customer_id | ~20K | Who bought |
| products | product_id | ~1.8K | What was sold |
| orders | order_id | ~65K | Transaction header |
| order_items | order_item_id | ~180K | Line items and financials |
| shipping | order_id | ~65K | Delivery and logistics |

**Engineered column:** `delivery_delay_days` = real shipping days − scheduled days. Positive = late, negative = early.

---

## Phase 2 — Database setup

Loaded all 5 clean tables into PostgreSQL with a proper schema — primary keys, foreign keys, and indexes on all common join and filter columns.

**Known issues resolved:**

| Issue | Fix |
|-------|-----|
| Date columns stored as object in CSV | Declared as TEXT in schema, cast to TIMESTAMP after load |
| `function to_timestamp(timestamp, unknown) does not exist` | Used direct `::TIMESTAMP` cast instead of TO_TIMESTAMP() |
| `invalid input syntax for type integer: "Advance Shipping"` | COPY column order didn't match CSV — fixed column mapping |
| `function date_trunc(unknown, character varying) does not exist` | Added explicit `::TIMESTAMP` cast in validation script |

---

## Phase 3 — SQL analysis

Wrote 38 queries across 5 SQL files to answer real business questions covering revenue, sales performance, customer behavior, logistics, and product/geographic analysis.

**Scripts written:**

| Script | Business area | Queries |
|--------|--------------|---------|
| `01_revenue_profitability.sql` | Revenue & profitability | 7 |
| `02_sales_performance.sql` | Sales performance | 7 |
| `03_customer_behavior.sql` | Customer behavior | 7 |
| `04_logistics_delivery.sql` | Logistics & delivery | 9 |
| `05_product_geo_analysis.sql` | Product & geographic | 8 |

**Data quality decision:** December 2017 and January 2018 were excluded from all trend analysis and dashboard visuals. These two months show abnormal revenue and order value patterns inconsistent with the prior 34 months of stable data, indicating an incomplete export period rather than a genuine business event. All analysis is based on January 2015 – November 2017 (35 complete months).

**Key findings from SQL:**

- Total revenue of **$36.8M** across 35 months at a **10.78% profit margin** — stable but thin, making cost control critical
- **54.82% of all orders arrive late** — the single most damaging operational issue in the dataset
- **First Class shipping has a 95.27% late delivery rate** — caused by a systematic 1-day scheduling misconfiguration, not a logistics failure
- **Standard Class is the only mode that meets its promise** — promised 4 days, actual 4 days, 61.87% on-time rate
- **Fixing the First Class scheduled day estimate from 1 to 2 days** would resolve the late delivery problem overnight with no operational change
- **Fishing, Cleats, and Camping & Hiking** are the top 3 categories — revenue and profit rankings match, no hidden drag
- **Europe leads revenue** ($10.9M) but USCA has the best margin (11.14%) despite serving only 2 countries
- **57.5% of customers are repeat buyers** — a strong retention profile compared to typical marketplace datasets
- **At Risk customers (8,120 customers, $2,939 avg spend)** represent the single most important retention opportunity — $23.9M in historical spend at risk of being lost
- **Discounting has negligible impact on margins** — profit ratio barely moves across all discount buckets, suggesting discounts are already baked into pricing
- The **$50–$99 price bucket** is the volume and margin sweet spot — most orders, second-highest profit ratio
- **RFM analysis revealed an inverse recency-value pattern** — most recently active customers are low-spend first-time buyers, while highest-value customers haven't ordered in months

More In Progres Folder (SQlAnalysis.md)



## Phase 5 — Power BI dashboard

Built a three-page interactive dashboard in Power BI Desktop connected directly to PostgreSQL. DAX measures written for all KPIs, time intelligence, RFM segmentation, and dynamic color labels.

**Page 1 — Sales Overview**

A bird's-eye view of overall business performance. Revenue was flat and stable across the full period — the business is predictable rather than high-growth, which has its own value for planning. Fan Shop, Apparel, and Golf drive the majority of revenue and profit. Europe is the largest market but USCA is the most efficient. The most important finding hidden below the headline numbers: $1.57M in suspected fraud and canceled orders, and $8.1M in unconfirmed pending payments.

![Sales Dashboard](/images/Sales.png)


**Page 2 — Logistics & Delivery**

The operational health page. 54.82% of orders arrive late — but the root cause is not a logistics breakdown, it is a scheduling misconfiguration. First Class promises 1 day and takes 2. Second Class promises 2 days and takes 4. Standard Class is the only mode that delivers what it promises. The fix requires no operational change — only a correction to the scheduled delivery day estimates in the system. The map confirms the problem is global and uniform, not concentrated in any region.

![Logistics Dashboard](/images/Logistics.png)


**Page 3 — Customer Segmentation**


The retention and value page. 57.5% of customers are repeat buyers — a strong foundation compared to pure marketplace businesses. But the RFM analysis reveals a structural risk: the highest-value customers are going quiet. At Risk customers average $2,939 in historical spend and haven't ordered in over 300 days. Champions — the most recently active group — spend only $269 on average. The business is acquiring new low-value customers while its most valuable ones disengage.
![Customers Dashboard](/images/Customers.png)

---

## Key business insights

1. **The late delivery problem is a data problem, not a logistics problem** — First Class and Second Class scheduled day estimates are systematically wrong. Correcting them requires no operational investment and would transform reported delivery performance overnight.

2. **Over half of all orders arrive late globally** — all 5 markets sit within 1.2 percentage points of each other, confirming the issue is systemic and not concentrated in any region or carrier.

3. **The business is stable but thin** — 10.78% profit margin across $36.8M in revenue leaves little room for error. Discounting is already priced in and doesn't move the needle either way.

4. **At Risk customers are the most urgent commercial priority** — 8,120 customers with $2,939 average historical spend who haven't ordered in over 300 days. A targeted win-back campaign touches nearly $23.9M in dormant value.

5. **Retention is genuinely strong** — 57.5% repeat buyer rate is a healthy foundation, but the inverse relationship between recency and value suggests new customer acquisition is outpacing high-value customer retention.

6. **Europe leads but USCA is the most efficient market** — highest margin (11.14%), highest average order value, only 2 countries. Africa serves 49 countries with thin penetration — growth potential if logistics improve.

7. **The $50–$99 price bucket is the commercial sweet spot** — highest order volume (61,072 orders) and strong profit ratio. Products priced above $100 sell one at a time; products below $100 sell in bundles of 3.

---

## Tools used

| Tool | Purpose |
|------|---------|
| Python / pandas | Data cleaning, table decomposition, EDA |
| PostgreSQL | Relational database and SQL analysis |
| SQLTools (VS Code) | Query execution and result export |
| matplotlib / seaborn | EDA charts |
| Power BI Desktop | Three-page interactive dashboard |
| DAX | KPI measures, RFM segmentation, time intelligence, dynamic labels |
| Power Query (M) | Date-only column for date table relationship |
| GitHub | Version control and portfolio publishing |

---

