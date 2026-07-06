# Phase 5 — Power BI Dashboard


---

## Overview

An interactive three-page Power BI dashboard built on the DataCo Supply Chain dataset, connected directly to PostgreSQL. Designed to give business teams a clear, actionable view of sales performance, logistics operations, and customer behavior — without needing to touch a single line of code.

---

## Technical Setup

| Item | Detail |
|------|--------|
| Data source | PostgreSQL (direct connection) |
| Tables loaded | customers, products, orders, order_items, shipping |
| Date table | DAX CALENDAR() table (Jan 2015 – Nov 2017) |
| Relationships | DateTable → orders[order_date_key] (date-only column, Power Query) |


## Page 1 — Sales Overview

### What this page answers

This page gives leadership a bird's-eye view of the full business — how much was made, where it came from, and what risks sit beneath the headline numbers.

---

### The story this page tells

**The business is stable and profitable — but thin margins and hidden risks deserve attention.**

Over 35 months from January 2015 to November 2017, the company generated **$36.8M in total revenue** with a profit of **$3.97M** — a margin of **10.78%**. For every $100 in sales, $10.78 flows through to profit. That's not a bad number, but it leaves little room for error on costs, discounting, or fraud.

Revenue was remarkably consistent throughout the period — hovering between $880K and $1.09M per month with no dramatic swings. This is a business running at a steady pace rather than a hypergrowth story, which actually makes it easier to plan around. Order volume tracks revenue closely, and average order value has been flat at around $203 — suggesting pricing has been stable and customers are not trading up or down over time.

**Fan Shop, Apparel, and Golf are the engine.** These three departments account for the majority of both revenue and profit. Within categories, Fishing ($6.9M), Cleats ($4.4M), and Camping & Hiking ($4.1M) are the top three — and crucially, the revenue ranking and profit ranking match. There are no hidden loss-makers dragging down the top-line numbers. High-revenue categories are also high-profit categories, which means the product mix is working.

**Europe leads globally, but USCA punches above its weight.** Europe generates the most revenue ($10.9M) and profit ($1.17M), driven by higher average order values — UK ($220.88), France ($218.36), and Germany ($216.98) all sit well above the global average. USCA, despite having far fewer orders (only 2 countries), has the highest profit margin of any market at 11.14%. Africa has the smallest volume but a healthy 10.99% margin, pointing to growth potential if logistics improve.

**The risk sits below the headline.** Only 33% of orders are marked "Complete." The remaining 67% sit across various pending, processing, and unconfirmed states. Suspected Fraud and Canceled orders combined represent **$1.57M in revenue at risk** — about 4.3% of total order value. A further $8.1M sits in "Pending Payment" status, unconfirmed. These numbers don't show up in the headline KPIs, but they matter for cash flow planning and fraud management.

**Discounting is not the problem.** Across all discount rate buckets — from 0% to 30%+ — profit ratios barely move. The business has effectively built discounting into its pricing model. This is useful context for any commercial team considering whether to reduce promotions to protect margin — the data suggests it won't make much difference either way.


---
