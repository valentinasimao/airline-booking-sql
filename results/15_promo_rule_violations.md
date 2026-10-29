# Q15. Promo code audit: which redemptions broke the code's own rules?

Query: [`queries/15_promo_rule_violations.sql`](../queries/15_promo_rule_violations.sql) · **241 rows** (first 15 shown)

| promo_code | rule_broken | booking_ref | channel | destination | redeemed_at | gross_eur | discount_eur | allowed_discount_eur | discount_at_risk_eur |
|---|---|---|---|---|---|---|---|---|---|
| APPONLY12 | Discount larger than allowed | MHA3DA | App | CDG | 2026-08-22 01:30:00 | 306.45 | 24.00 | 12 | 12 |
| APPONLY12 | Discount larger than allowed | D1L5SV | App | FCO | 2026-09-09 18:30:00 | 438.78 | 36.00 | 12 | 24 |
| APPONLY12 | Discount larger than allowed | 9TIFO3 | App | MAD | 2026-09-12 22:00:00 | 338.56 | 24.00 | 12 | 12 |
| APPONLY12 | Discount larger than allowed | 52A3HU | App | LIS | 2026-09-21 13:45:00 | 366.38 | 36.00 | 12 | 24 |
| APPONLY12 | Discount larger than allowed | IKUW9G | App | LHR | 2026-09-22 23:15:00 | 399.92 | 36.00 | 12 | 24 |
| APPONLY12 | Discount larger than allowed | CG4U74 | App | MAD | 2026-10-19 12:15:00 | 596.98 | 48.00 | 12 | 36 |
| APPONLY12 | Wrong channel | Q9F53P | Web | GRU | 2026-07-30 19:15:00 | 1301.65 | 12.00 | 12 | 12 |
| APPONLY12 | Wrong channel | AAW2IX | Web | FCO | 2026-07-31 22:00:00 | 255.86 | 12.00 | 12 | 12 |
| APPONLY12 | Wrong channel | GV4B3Z | Web | CDG | 2026-08-08 02:30:00 | 91.19 | 12.00 | 12 | 12 |
| APPONLY12 | Wrong channel | YNDB45 | Web | GRU | 2026-08-13 17:30:00 | 1041.52 | 12.00 | 12 | 12 |
| APPONLY12 | Wrong channel | R6MOVQ | Web | JFK | 2026-08-21 14:15:00 | 1037.45 | 12.00 | 12 | 12 |
| APPONLY12 | Wrong channel | AO80J3 | Web | LHR | 2026-08-22 19:30:00 | 98.36 | 12.00 | 12 | 12 |
| APPONLY12 | Wrong channel | 9P4M3J | Web | CDG | 2026-09-09 00:30:00 | 218.32 | 12.00 | 12 | 12 |
| APPONLY12 | Wrong channel | M594BY | Web | MAD | 2026-09-20 04:00:00 | 785.98 | 12.00 | 12 | 12 |
| APPONLY12 | Wrong channel | CS4APX | Web | FCO | 2026-09-20 08:15:00 | 690.20 | 12.00 | 12 | 12 |
