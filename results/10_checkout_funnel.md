# Q10. Where do customers drop out of the booking flow? Funnel from search to payment, by channel.

Query: [`queries/10_checkout_funnel.sql`](../queries/10_checkout_funnel.sql) · **15 rows** (first 15 shown)

| channel | step_no | step_name | sessions | pct_of_searches | pct_from_previous_step | lost_at_this_step |
|---|---|---|---|---|---|---|
| Agency | 1 | Search | 11491 | 100 |  |  |
| Agency | 2 | Seats | 7233 | 62.9 | 62.9 | 4258 |
| Agency | 3 | Passenger details | 6238 | 54.3 | 86.2 | 995 |
| Agency | 4 | Payment | 5136 | 44.7 | 82.3 | 1102 |
| Agency | 5 | Paid | 4424 | 38.5 | 86.1 | 712 |
| App | 1 | Search | 23176 | 100 |  |  |
| App | 2 | Seats | 16841 | 72.7 | 72.7 | 6335 |
| App | 3 | Passenger details | 14764 | 63.7 | 87.7 | 2077 |
| App | 4 | Payment | 11919 | 51.4 | 80.7 | 2845 |
| App | 5 | Paid | 8933 | 38.5 | 74.9 | 2986 |
| Web | 1 | Search | 22977 | 100 |  |  |
| Web | 2 | Seats | 17073 | 74.3 | 74.3 | 5904 |
| Web | 3 | Passenger details | 14219 | 61.9 | 83.3 | 2854 |
| Web | 4 | Payment | 11680 | 50.8 | 82.1 | 2539 |
| Web | 5 | Paid | 8928 | 38.9 | 76.4 | 2752 |
