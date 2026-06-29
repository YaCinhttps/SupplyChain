# Phase 3 — SQL Analysis


---

## Overview

This phase loads all 5 clean tables into PostgreSQL and runs structured queries to answer real business questions across revenue, sales performance, customer behavior, logistics, and product/geographic analysis.

---

## Database

| Item | Detail |
|------|--------|
| Engine | PostgreSQL |
| Database | postgres |
| Tables | 5 (customers, products, orders, order_items, shipping) |
| Total records | ~180K+ rows across all tables |


---

## Business Questions & Key Findings

### 1. Revenue & Profitability

**Q: What is total revenue, profit, and margin across the full period?**

| Metric | Value |
|--------|-------|
| Total Revenue | $36,784,734 |
| Total Profit | $3,966,902 |
| Profit Margin | 10.78% |

> A 10.78% profit margin is relatively thin — meaning for every $100 in sales, only $10.78 flows through to profit. This makes cost control and discount strategy critical levers for the business.

---

**Q: Which product categories generate the most revenue vs the most profit?**

Top 3 categories by both revenue and profit are **Fishing**, **Cleats**, and **Camping & Hiking** — the ranking holds across both metrics, meaning high-revenue categories are also the most profitable here. No hidden drag from the top.

---

**Q: Which departments are most profitable?**

| Rank | Department | 
|------|------------|
| 1 | Fan Shop |
| 2 | Apparel |
| 3 | Golf |

> Fan Shop dominates both revenue and profit. Golf punches above its volume weight in profitability.

---

**Q: Which categories drag average profit per order down?**

| Worst (Lowest Avg Profit) | Best (Highest Avg Profit) |
|--------------------------|--------------------------|
| CDs | Computers |
| Toys | Garden |
| Books | Crafts |

> CDs, Toys, and Books are likely high-volume but low-margin categories — possibly being sold near cost or heavily discounted.

---

**Q: Does discounting hurt profit?**

| Discount Bucket | Orders | Avg Profit Ratio | Total Profit |
|----------------|--------|-----------------|--------------|
| 0% — No discount | 10,028 | 0.1275 | $267,412 |
| 21–30% | 10,029 | 0.1272 | $191,896 |
| 6–10% | 40,116 | 0.1227 | $926,511 |
| 1–5% | 50,143 | 0.1210 | $1,171,682 |
| 11–20% | 70,203 | 0.1173 | $1,409,400 |

**Insight:** Discounting does not significantly hurt profit ratio — the difference between no discount (0.1275) and the 21–30% bucket (0.1272) is negligible. The 11–20% bucket drives the most total profit ($1.4M) purely through volume. The business appears to have built discounts into its pricing model — margins hold regardless of discount level.

---

**Q: Which markets are most profitable?**

| Market | Orders | Revenue | Profit | Margin % | Avg Order Value |
|--------|--------|---------|--------|----------|----------------|
| Europe | 18,561 | $10,872,396 | $1,169,442 | 10.76% | $216.36 |
| LATAM | 17,181 | $10,277,612 | $1,123,321 | 10.93% | $199.20 |
| Pacific Asia | 17,577 | $8,273,743 | $857,753 | 10.37% | $200.53 |
| USCA | 8,579 | $5,066,528 | $564,313 | 11.14% | $196.38 |
| Africa | 3,854 | $2,294,452 | $252,071 | 10.99% | $197.56 |

**Insight:** Europe leads in total revenue and profit by a significant margin. USCA has the highest profit margin (11.14%) and the second-highest average order value ($196.38) despite having the fewest orders — suggesting a higher quality buyer base. Africa has the smallest volume but a healthy margin (10.99%), pointing to growth potential if logistics are improved.

---

**Q: Are there categories or markets selling at a loss?**

| Category | Market | Orders | Avg Profit/Order | Total Profit |
|----------|--------|--------|-----------------|--------------|
| As Seen On TV! | LATAM | 26 | -$15.33 | -$398.52 |
| Boxing & MMA | Africa | 31 | -$4.87 | -$151.05 |

**Insight:** Only 2 category/market combinations are loss-making, and the absolute losses are small (-$398 and -$151 total). This is not a critical problem, but both are worth monitoring — especially As Seen On TV! in LATAM which has the highest per-order loss.

---

