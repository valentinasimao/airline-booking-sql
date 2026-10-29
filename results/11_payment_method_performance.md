# Q11. Which payment methods fail most, why, how many customers still complete the purchase after a

Query: [`queries/11_payment_method_performance.sql`](../queries/11_payment_method_performance.sql) · **6 rows** (first 6 shown)

| method | attempts | failure_rate_pct | most_common_reason | checkouts_failed_first_try | recovered_pct | sales_lost_eur |
|---|---|---|---|---|---|---|
| Card | 9315 | 24.2 | Card declined | 2137 | 46.5 | 341106 |
| Apple Pay | 5345 | 15.2 | Card declined | 805 | 15.9 | 202948 |
| Bizum | 3754 | 17.3 | Insufficient funds | 636 | 25.2 | 139924 |
| Bank transfer | 4787 | 7.7 | Transfer not received | 366 | 14.2 | 94168 |
| Google Pay | 1806 | 15 | Card declined | 268 | 23.1 | 61426 |
| PayPal | 1890 | 16 | Insufficient funds | 292 | 29.5 | 54849 |
