# Q11. Which payment methods fail most, why, how many customers still complete the purchase after a

Query: [`queries/11_payment_method_performance.sql`](../queries/11_payment_method_performance.sql) · **6 rows** (first 6 shown)

| method | attempts | failure_rate_pct | most_common_reason | checkouts_failed_first_try | recovered_pct | sales_lost_eur |
|---|---|---|---|---|---|---|
| Card | 9395 | 24.5 | Card declined | 2185 | 47.8 | 339354 |
| Apple Pay | 5404 | 14.7 | Card declined | 791 | 15.4 | 199409 |
| Bizum | 3664 | 16.6 | Insufficient funds | 599 | 24 | 135331 |
| Bank transfer | 4773 | 7.5 | Transfer not received | 355 | 9.9 | 94749 |
| Google Pay | 1772 | 14.5 | Card declined | 255 | 22.7 | 56807 |
| PayPal | 1864 | 15.7 | Insufficient funds | 282 | 30.9 | 54006 |
