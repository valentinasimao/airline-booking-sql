# ✈️ Airline Booking & Seat Management — SQL Analytics Project

A relational database and a set of analytical SQL queries for a (fictional) airline operating out of **Barcelona (BCN)**,
covering the whole journey of its booking website: search → seat selection → passenger details → promo code → payment → seat on the plane.
The queries answer the questions a revenue-management, payments, operations or customer-experience team asks every day:
where customers abandon the checkout, which payment methods fail, whether every ticket was actually paid for,
which promo campaigns paid off and which codes were accepted when they shouldn't have been,
which flights are overbooked, which families were seated apart, who gets the free upgrade, and is anyone under 15
sitting in an emergency-exit row?

> **Skills shown:** relational data modelling · CTEs · window functions (`ROW_NUMBER`, `RANK`, `LAG`, moving averages, `SUM() OVER`) ·
> anti-joins · conditional aggregation · views · funnel analysis · payment reconciliation · promo-code rule auditing · data-quality rules ·
> a seat-assignment algorithm written in pure SQL.
> Runs on **PostgreSQL 16** and **DuckDB** with the same results.

---

## The data

| Table | Rows | What it holds |
|---|---:|---|
| `airports` | 8 | BCN plus 7 destinations (MAD, LIS, FCO, CDG, LHR, JFK, GRU) |
| `aircraft_types` | 3 | A320neo, Boeing 737-800, A330-300 |
| `seat_map` | 662 | Every physical seat: row, letter, cabin, Window/Middle/Aisle, exit row |
| `flights` | 232 | 3 weeks of flights (15 Oct – 4 Nov 2026), departed and scheduled |
| `passengers` | ~10,000 | Adults and children, loyalty tier and points |
| `bookings` | ~22,000 | Booking reference, channel; one booking can hold a whole family |
| `tickets` | ~38,500 | One passenger on one flight: cabin, fare, seat preference, status |
| `seat_assignments` | ~33,000 | Which seat each ticket got, and how (self-selected or auto) |
| `upgrade_requests` | ~600 | Upgrade bids from Economy/Premium passengers |
| `checkout_sessions` | ~57,600 | Every visit to the booking flow and the furthest step reached; linked to a booking if paid |
| `payments` | ~26,900 | Every payment attempt (card, Bizum, PayPal, Apple/Google Pay, bank transfer), succeeded or failed, with reason |
| `refunds` | ~1,600 | Money returned for cancelled tickets (Economy keeps a €30 fee) |
| `promo_codes` | 6 | Campaign codes and their rules: % or € off, dates, minimum spend, usage limit, channel, destination |
| `booking_promotions` | ~3,600 | Which booking used which code, the price before discount and the discount given |

The data is synthetic and reproducible (`scripts/generate_data.py`, fixed random seed). It deliberately contains realistic problems
— oversold flights, split families, a few children in exit rows, tickets issued without payment, double charges,
missing refunds and promo codes accepted against their own rules — so the queries have something real to find.

```mermaid
erDiagram
    AIRCRAFT_TYPES ||--o{ SEAT_MAP : "has seats"
    AIRCRAFT_TYPES ||--o{ FLIGHTS : "operates"
    AIRPORTS ||--o{ FLIGHTS : "origin / destination"
    BOOKINGS ||--|{ TICKETS : "contains"
    PASSENGERS ||--o{ TICKETS : "travels on"
    FLIGHTS ||--o{ TICKETS : "carries"
    TICKETS ||--o| SEAT_ASSIGNMENTS : "seated in"
    TICKETS ||--o{ UPGRADE_REQUESTS : "requests"
    FLIGHTS ||--o{ CHECKOUT_SESSIONS : "searched for"
    CHECKOUT_SESSIONS ||--o{ PAYMENTS : "payment attempts"
    CHECKOUT_SESSIONS |o--o| BOOKINGS : "becomes (if paid)"
    PAYMENTS ||--o{ REFUNDS : "refunded by"
    TICKETS ||--o| REFUNDS : "cancelled ticket"
    PROMO_CODES ||--o{ BOOKING_PROMOTIONS : "redeemed as"
    BOOKINGS ||--o| BOOKING_PROMOTIONS : "uses"
```

A `UNIQUE (flight_id, seat_no)` constraint guarantees a seat can never be sold twice on the same flight.

---

## Business questions answered

| # | Question | Key SQL techniques |
|---|---|---|
| [Q1](queries/01_seat_availability.sql) | How many seats are left on each upcoming flight, by cabin? | View, conditional aggregation |
| [Q2](queries/02_load_factor_by_route.sql) | Load factor per flight, rank within route, 7-flight rolling average | `RANK()`, `AVG() OVER (ROWS BETWEEN 6 PRECEDING …)` |
| [Q3](queries/03_overbooking_risk.sql) | Which flights are overbooked after expected no-shows? | Multiple CTEs, historical rate applied to future demand |
| [Q4](queries/04_split_families.sql) | Which booking groups were seated apart, and which travel with children? | `LAG()` seat-adjacency logic, `STRING_AGG` |
| [Q5](queries/05_auto_assign_seats.sql) | Propose seats for unseated passengers, honouring Window/Aisle preference and loyalty | Two-pass matching with `ROW_NUMBER()`, anti-joins, `UNION ALL` |
| [Q6](queries/06_upgrade_waitlist.sql) | Who gets upgraded to Business? | Waitlist ranking with `ROW_NUMBER()`, capacity CTE |
| [Q7](queries/07_revenue_per_seat.sql) | Which route/cabin earns most per available seat? | Revenue per seat, `SUM() OVER (PARTITION BY …)` share |
| [Q8](queries/08_seat_preference_fulfilment.sql) | Do passengers get the seat type they asked for? | Conditional aggregation |
| [Q9](queries/09_exit_row_safety_check.sql) | Safety audit: any under-15s in an exit row? | Age at departure, data-quality rule |
| [Q10](queries/10_checkout_funnel.sql) | Where do customers drop out of the booking flow, by channel? | `VALUES` step table, non-equi join, `FIRST_VALUE()`, `LAG()` |
| [Q11](queries/11_payment_method_performance.sql) | Which payment methods fail, why, and how much revenue is lost? | `ROW_NUMBER()` for first attempt and top reason, session outcome CTE |
| [Q12](queries/12_payment_reconciliation.sql) | Does what we charged match what we sold? Are refunds owed? | Expected-vs-actual CTEs, `COALESCE`, issue classification |
| [Q13](queries/13_daily_net_revenue.sql) | Daily cash in minus refunds, with trend | `UNION` of event streams, 7-day moving average, month-to-date `SUM() OVER` |
| [Q14](queries/14_promo_campaign_performance.sql) | How did each promo campaign perform? | Promo vs. no-code benchmark, scalar subquery, `SUM() OVER ()` share |
| [Q15](queries/15_promo_rule_violations.sql) | Which promo redemptions broke the code's rules? | `ROW_NUMBER()` for the n-th use, six rule checks combined with `UNION ALL` |

Full outputs for every query are in [`results/`](results).

---

## Highlights

**Overbooking (Q3).** 23 upcoming Economy cabins are sold above 95% of capacity. Applying each route's historical no-show rate
(≈6–7%) shows that 12 are covered by expected no-shows, but **8 still won't fit and need action now**:

| flight_no | destination | departure | seats | confirmed | hist. no-show % | expected show-ups | risk_flag |
|---|---|---|---:|---:|---:|---:|---|
| ZZ1501 | LHR | 2026-10-31 10:30 | 162 | 191 | 6.9 | 178 | Overbooked - act now |
| ZZ1003 | MAD | 2026-10-31 13:30 | 162 | 190 | 6.7 | 177 | Overbooked - act now |
| ZZ1501 | LHR | 2026-10-30 10:00 | 162 | 187 | 6.9 | 174 | Overbooked - act now |

**Split families (Q4).** Of ~9,500 multi-passenger bookings, **1,415 were not seated in one continuous block**,
and **483 of those include children** — the cases a customer-service team should fix first.
The query finds them by ordering each group's seats with `LAG()` and checking whether every passenger sits directly next to the previous one.

| booking_ref | flight_no | group_size | children | rows_apart | seating |
|---|---|---:|---:|---:|---|
| UT77H7 | ZZ1203 | 4 | 2 | 28 | Sofia 4C, Jordi 6B, Elena 14B, Lucía 32F |
| 27AFWT | ZZ1201 | 4 | 2 | 27 | Hugo 4A, Marta 20C, Olivia 25A, Ana 31C |

**Automatic seat assignment in pure SQL (Q5).** For 3,211 confirmed passengers without a seat, the query first matches
Window/Aisle requests to free seats of that type (loyal customers first), then places everyone else in the best remaining seat.
Result: **1,950 preferences met, 1,040 with no preference, only 221 preferences that couldn't be met.** Exit rows are excluded
from automatic assignment.

**Upgrade waitlist (Q6).** 589 Business upgrade requests ranked by tier → points → request time against the real number of
free Business seats: **371 upgrades, 218 waitlisted.**

**Revenue per available seat (Q7).** Long-haul Business earns the most per seat flown (JFK €1,123, GRU €959), but Premium Economy
on JFK brings in more total revenue than Business (21.6% vs 20.2% of the route).

**Seat preference (Q8).** Self-selected seats match the requested type far more often than auto-assigned ones
(Aisle 65% vs 52%, Window 55% vs 42%) — an argument for nudging passengers to choose their seat in the app.

**Safety (Q9).** 12 passengers under 15 were assigned an emergency-exit row; one is on an upcoming flight and is flagged
*Reseat before departure*.

**Checkout funnel (Q10).** Of ~57,700 checkout sessions, about 38–39% end in a payment on every channel — but they lose people at
different places. Agency users drop most at search (only 63% reach the seat map). On Web and App, after the search page the weakest
step is **payment itself: 1 in 4 people who reach the payment page don't complete it** (Web 76%, App 75% pay vs. 86% via agencies).

| channel | Search | Seats | Passenger details | Payment | Paid |
|---|---:|---:|---:|---:|---:|
| Web | 23,051 | 17,103 | 14,256 | 11,707 | 8,928 |
| App | 23,064 | 16,704 | 14,650 | 11,862 | 8,933 |
| Agency | 11,536 | 7,261 | 6,246 | 5,149 | 4,424 |

**Payment failures (Q11).** That payment-step loss is driven by failed payments. Cards fail most (24.5% of attempts, mainly *Card declined*),
and only 48% of customers whose first card attempt fails go on to pay. Across all methods, **€880k of sales walked away after a failed
first payment** — €339k of it on cards. Wallets fail less, but customers who hit a wallet failure rarely retry (Apple Pay 15% recover),
which points to offering a fallback method on the error screen.

| method | attempts | failure rate | most common reason | recovered after failing | sales lost |
|---|---:|---:|---|---:|---:|
| Card | 9,395 | 24.5% | Card declined | 47.8% | €339,354 |
| Apple Pay | 5,404 | 14.7% | Card declined | 15.4% | €199,409 |
| Bizum | 3,664 | 16.6% | Insufficient funds | 24.0% | €135,331 |

**Payment reconciliation (Q12).** Comparing every booking's expected amount (fares + €12 per chosen seat − promo discount) with what was actually
captured and refunded finds **404 bookings that need action**:

| issue | bookings | money at stake |
|---|---:|---:|
| Ticketed but never paid | 98 | €36,849 to collect |
| Charged twice | 67 | €27,379 to give back |
| Under-charged | 65 | €1,544 missing |
| Refund owed for a cancelled ticket | 174 | €36,190 to give back |

**Daily cash (Q13).** October 2026 to date: **€2.42M taken, €219k refunded, €2.20M net**, with a 7-day moving average to smooth out
weekday effects. (Sales fall in the second half of the month only because the sample contains flights up to 4 November.)

**Promo campaigns (Q14).** Six codes gave away €127k in discounts on ~3,600 bookings. The always-on WELCOME10 accounts for
two-thirds of all discount money, and its customers spend *less* than people who book without a code (€390 vs €413 average basket).
Fixed-amount codes with a minimum spend work better: SUMMER25 cost just 5.4% of the booking value and came with bigger baskets (€476).
FLASH48 was the most expensive campaign relative to what it brought in (20% of gross).

| code | offer | bookings | discount given | net revenue | discount % of gross | avg basket |
|---|---|---:|---:|---:|---:|---:|
| WELCOME10 | 10% | 2,081 | €85,305 | €726,194 | 10.5% | €390 |
| SUMMER25 | €25 (min €150) | 452 | €11,550 | €203,515 | 5.4% | €476 |
| APPONLY12 | €12, app only | 757 | €9,216 | €299,160 | 3.0% | €407 |
| LONDON15 | 15%, London only | 125 | €7,352 | €37,278 | 16.5% | €357 |
| NYC50 | €50 (min €500), New York only | 132 | €6,950 | €139,931 | 4.7% | €1,113 |
| FLASH48 | 20%, 2 days, max 60 uses | 78 | €6,241 | €24,834 | 20.1% | €398 |

**Promo code audit (Q15).** Every redemption is checked against its code's own rules. **184 bookings (5% of all redemptions) got a
discount they shouldn't have**, worth €12.5k — a sign that the checkout wasn't validating codes properly:

| rule broken | redemptions |
|---|---:|
| Code for another route (e.g. LONDON15 on a Paris flight) | 66 |
| Used before or after the campaign dates | 64 |
| Discount larger than allowed (fixed amount applied per passenger) | 54 |
| Below the minimum spend | 26 |
| Usage limit exceeded (FLASH48: 78 uses, limit 60) | 18 |
| App-only code used on the website | 13 |

---

## How to run

**Option A — DuckDB (no database server needed)**
```bash
pip install duckdb
python scripts/run_all.py          # builds the DB in memory, runs every query, writes results/*.md
```

**Option B — PostgreSQL**
```bash
createdb airline
psql -d airline -f sql/01_schema.sql -f sql/02_load_postgres.sql -f sql/03_views.sql
psql -d airline -f queries/12_payment_reconciliation.sql
```

To regenerate the sample data: `python scripts/generate_data.py`.

## Repository structure

```
sql/        01_schema.sql · 02_load_duckdb.sql · 02_load_postgres.sql · 03_views.sql
queries/    01 … 15 — one business question per file, commented
data/       CSV sample data (synthetic)
results/    query outputs as Markdown tables
scripts/    generate_data.py · run_all.py
```

---

*Author: **Valentina Simao** — Industrial Engineer & Data Analyst, Barcelona ·
[LinkedIn](https://www.linkedin.com/in/valentina-s-b79264150)*
*All airline names, flight numbers and passengers are fictional.*
