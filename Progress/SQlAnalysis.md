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
### Sales Performance

**Q: How has revenue trended month over month? Are we growing or declining?**
 
Revenue was remarkably stable from January 2015 through September 2017 — hovering between $880K–$1.09M per month with order counts in the 1,500–1,730 range. Average order value sat consistently around $195–$220.
 
**Then something breaks sharply starting October 2017:**
 
| Month | Orders | Revenue | Avg Order Value |
|-------|--------|---------|-----------------|
| Sep 2017 | 1,640 | $1,088,272 | $220.70 |
| Oct 2017 | 2,019 | $1,029,832 | $474.80 |
| Nov 2017 | 1,956 | $598,789 | $306.13 |
| Dec 2017 | 2,031 | $480,845 | $236.75 |
| Jan 2018 | 2,037 | $316,712 | $155.48 |
 
**Insight:** Order *count* actually increases in the final months (2,037 orders in Jan 2018 vs ~1,650 average), but revenue collapses by 70% from September to January. Average order value spikes oddly in October ($474.80 — more than double the historical average) then crashes to $155 by January. This pattern — rising order volume with collapsing revenue and erratic average order value — strongly suggests either a data quality issue in the final months (incomplete period, broken price field, currency issue) or a genuine business event (mass discounting, product mix shift, or a data export cutoff mid-month). **This needs to be flagged and investigated before using these final months in the dashboard** — they will distort any trend visual if plotted as-is. A likely explanation: the dataset simply ends mid-January 2018, so that month is a partial period and shouldn't be compared directly to full months.
 
---
 
**Q: Which days of the week drive the most revenue?**
 
| Weekday | Orders | Total Revenue | Avg Daily Revenue |
|---------|--------|---------------|-------------------|
| Saturday | 9,012 | $5,139,735 | $207.63 |
| Friday | 9,020 | $5,098,745 | $204.97 |
| Sunday | 8,959 | $5,083,627 | $204.71 |
| Monday | 8,931 | $5,029,044 | $204.78 |
| Thursday | 8,997 | $5,026,264 | $203.39 |
| Tuesday | 9,003 | $4,984,662 | $202.75 |
| Wednesday | 8,975 | $4,852,348 | $198.48 |
 
**Insight:** Unlike typical B2C e-commerce, this business shows almost no weekday/weekend split — order volume is nearly flat across all 7 days (8,930–9,020 range). Saturday is marginally the strongest day and Wednesday the weakest, but the gap is small (~5.6% between highest and lowest). This suggests the customer base isn't purely consumer-driven, or that demand is genuinely distributed evenly — useful context for inventory and staffing planning since there's no major "slow day" to plan around.
 
---
 
**Q: What is the average order value by market and shipping mode?**
 
| Market | Best AOV Mode | Best AOV | Weakest AOV Mode |
|--------|---------------|----------|-------------------|
| Europe | Standard Class | $217.62 | Same Day ($209.54) |
| Pacific Asia | First Class | $201.44 | Same Day ($192.88) |
| Africa | Same Day | $201.31 | First Class ($195.04) |
| LATAM | First Class | $199.88 | Same Day ($196.88) |
| USCA | Standard Class | $196.99 | Same Day ($194.46) |
 
**Insight:** Europe has the highest average order value across every shipping mode, reinforcing it as the strongest market overall. Interestingly, **Same Day shipping has the lowest average order value in 4 of 5 markets** — suggesting Same Day is being used for smaller, lower-value urgent orders rather than premium high-value purchases. Standard Class dominates order volume everywhere, which is expected, but it's reassuring it isn't cannibalizing value — customers aren't just defaulting to cheap shipping at the expense of order size.
 
---
 
**Q: What percentage of orders are canceled, fraud, or on hold — and what is the revenue impact?**
 
| Status | Orders | Revenue at Risk | % of Total Orders |
|--------|--------|-----------------|--------------------|
| Complete | 21,716 | $12,095,314 | 33.03% |
| Pending Payment | 14,382 | $8,106,697 | 21.87% |
| Processing | 7,901 | $4,504,063 | 12.02% |
| Pending | 7,321 | $4,120,532 | 11.13% |
| Closed | 7,249 | $4,022,624 | 11.02% |
| On Hold | 3,624 | $1,981,542 | 5.51% |
| **Suspected Fraud** | 1,488 | **$825,934** | 2.26% |
| **Canceled** | 1,367 | **$744,370** | 2.08% |
| Payment Review | 704 | $383,653 | 1.07% |
 
**Insight:** Only 33% of orders are marked "Complete" — the remaining 67% sit across various pending, processing, and risk states. Suspected Fraud and Canceled orders combined represent **$1.57M in revenue at risk** (about 4.3% of total order volume) — a meaningful number worth flagging to a risk/fraud team. The large "Pending Payment" bucket (21.87% of orders, $8.1M) is also worth a closer look — that's a lot of revenue sitting unconfirmed.
 
---
 
**Q: How do customers prefer to pay?**
 
| Transaction Type | Orders | Total Revenue | Avg Order Value | % of Orders |
|------------------|--------|----------------|------------------|-------------|
| Debit | 25,340 | $14,076,857 | $203.14 | 38.54% |
| Transfer | 18,077 | $10,194,901 | $204.38 | 27.49% |
| Payment | 15,086 | $8,490,351 | $203.48 | 22.94% |
| Cash | 7,249 | $4,022,624 | $205.07 | 11.02% |
 
**Insight:** Debit dominates at nearly 39% of transactions, followed by Transfer and Payment fairly evenly. Average order value is remarkably consistent across all 4 payment types (~$203–205) — payment method doesn't influence how much customers spend per order, simplifying any payment-related strategy since there's no "high value" payment channel to prioritize.
 
---
 
**Q: What does a typical order look like in value? (Basket size)**
 
| Q1 | Median | Q3 | Min | Max | Avg | Total Line Items |
|----|--------|----|----|----|-----|-------------------|
| $119.98 | $199.92 | $299.95 | $9.99 | $1,999.99 | $203.83 | 172,765 |
 
**Insight:** The median basket ($199.92) sits very close to the average ($203.83), which is unusual and a good sign — it means the distribution isn't being heavily skewed by extreme outliers, unlike typical e-commerce datasets where a few huge orders drag the mean far above the median. 50% of all orders fall between $119.98 and $299.95, a fairly tight and predictable range. The max order ($1,999.99) is only ~10x the median, not the 100x+ spread often seen in retail data — this points to a business with relatively standardized product pricing rather than a mix of cheap accessories and high-ticket items.
 
---

### 3. Customer Behavior
 
**Q: Which customer segment generates the most revenue and profit?**
 
| Segment | Orders | Customers | Total Revenue | Total Profit | Margin % |
|---------|--------|-----------|----------------|---------------|----------|
| Consumer | 34,119 | 10,695 | $19,095,789 | $2,073,487 | 10.86% |
| Corporate | 19,856 | 6,239 | $11,168,406 | $1,202,574 | 10.77% |
| Home Office | 11,777 | 3,718 | $6,520,537 | $690,840 | 10.59% |
 
**Insight:** Consumer is by far the largest segment by both volume and revenue (~58% of total revenue), which makes sense given it has the most customers. Margins are nearly identical across all three segments (10.59%–10.86%) — no segment is meaningfully more profitable per dollar than another, so growth strategy should focus on volume and acquisition rather than chasing a "better margin" segment.
 
---
 
**Q: Is Corporate more valuable per order than Consumer despite fewer orders?**
 
| Segment | Avg Order Value | Avg Profit/Order | Avg Quantity/Order |
|---------|------------------|--------------------|----------------------|
| Consumer | $204.25 | $22.17 | 2.13 |
| Corporate | $203.92 | $22.04 | 2.13 |
| Home Office | $202.44 | $21.60 | 2.12 |
 
**Insight:** No — the assumption that Corporate orders are bigger or more profitable per transaction doesn't hold here. All three segments are nearly identical on AOV, profit per order, and quantity per order. This is a useful finding: segment-level personalization (e.g. different pricing or promotions per segment) wouldn't be justified by order economics — the segments only differ in volume, not behavior.
 
---
 
**Q: Which countries generate the most revenue?**
 
| Rank | Country | Market | Orders | Revenue | AOV |
|------|---------|--------|--------|---------|-----|
| 1 | Estados Unidos (USA) | USCA | 7,887 | $4,659,618 | $196.44 |
| 2 | Francia (France) | Europe | 4,648 | $2,753,970 | $218.36 |
| 3 | México | LATAM | 4,201 | $2,522,997 | $200.16 |
| 4 | Alemania (Germany) | Europe | 3,368 | $1,986,194 | $216.98 |
| 5 | Australia | Pacific Asia | 3,633 | $1,623,923 | $199.60 |
| 6 | Reino Unido (UK) | Europe | 2,661 | $1,544,403 | $220.88 |
| 7 | Brasil | LATAM | 2,520 | $1,513,085 | $199.64 |
| 8 | China | Pacific Asia | 2,495 | $1,123,516 | $204.31 |
| 9 | Italia | Europe | 1,793 | $1,021,387 | $214.44 |
| 10 | India | Pacific Asia | 2,070 | $925,155 | $201.60 |
 
**Insight:** The USA leads in raw volume and revenue, but **European countries dominate average order value** — UK ($220.88), France ($218.36), and Germany ($216.98) all sit well above the global average (~$203). This means European customers buy less often but spend more per order when they do, reinforcing Europe's position as the highest-margin, highest-value market identified in the profitability section.
 
---
 
**Q: Which cities generate the most revenue?**
 
Top cities are dominated by **Latin American capitals** alongside major US cities — Santo Domingo, Tegucigalpa, and Managua all rank in the top 5, ahead of cities like Philadelphia and San Francisco. London stands out as the only city in the top 10 with an AOV above $200 ($216.54), consistent with the European AOV pattern. New York City leads overall with 714 orders and $417,997 in revenue.
 
---
 
**Q: What proportion of customers come back?**
 
| Customer Type | Count | % of Total | Avg Orders |
|----------------|-------|------------|------------|
| One-time | 8,617 | 42.53% | 1.00 |
| Loyal | 8,036 | 39.66% | 5.60 |
| Returning | 3,608 | 17.81% | 2.58 |
 
**Insight:** This is a strong retention profile — only 42.5% of customers are one-time buyers, and nearly 40% are Loyal customers averaging 5.6 orders each. Compare this to the Olist e-commerce project where 97% of customers never returned — this business has a fundamentally healthier repeat-purchase model, likely because it isn't a pure marketplace but a B2B/B2C hybrid (note the Consumer/Corporate/Home Office segments).
 
---
 
**Q: Who are the most valuable customers? (RFM Segmentation)**
 
**Note on methodology:** The initial RFM query had two bugs that were identified and fixed during analysis: (1) the recency NTILE ordering was inverted, scoring the most recently active customers as least recent; (2) the standard "Champions" threshold (recent AND high-frequency) matched zero customers, because this dataset shows an inverse relationship between recency and frequency — see insight below. The Champions threshold was adjusted from `f_score >= 3` to `f_score >= 2` to reflect this real pattern in the data rather than force-fit a textbook definition. Corrected query available in `sql/CustomerBehaviour.sql`.
 
| Segment | Customers | Avg Spend | Avg Orders | Avg Recency (days) |
|---------|-----------|-----------|------------|----------------------|
| Loyal | 2,010 | $3,370.64 | 5.58 | 142 |
| At Risk | 8,120 | $2,939.07 | 4.93 | 337 |
| Lost | 2,011 | $1,008.51 | 1.69 | 532 |
| Recent | 5,808 | $331.00 | 1.02 | 76 |
| Champions | 2,312 | $269.74 | 1.00 | 26 |
 
**Insight:** The most important finding here is a structural one — **recency and value are inversely related in this dataset.** Customers who ordered most recently (Champions, 26 days; Recent, 76 days) have the lowest average spend and order exactly once. Customers with the highest lifetime spend (Loyal, $3,370.64; At Risk, $2,939.07) haven't ordered in 142–337 days on average.
 
This points to one of two realities: either the business has a strong cohort of historically loyal, high-value customers who are now going quiet (a retention risk worth investigating), or there's been a recent shift toward acquiring new, lower-value customers rather than nurturing repeat high-spenders (an acquisition strategy question). Either way, **At Risk (8,120 customers, $2,939.07 avg spend) is the single most important segment to act on** — it's the largest group by far and holds substantial historical value, but recency is slipping (337 days since last order). A win-back campaign targeted at this segment alone touches nearly $23.9M in historical spend ($2,939.07 × 8,120).
---

