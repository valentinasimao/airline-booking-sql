# Q10. Where do customers drop out of the booking flow? Funnel from search to payment, by channel.

Query: [`queries/10_checkout_funnel.sql`](../queries/10_checkout_funnel.sql) · **15 rows** (first 15 shown)

| channel | step_no | step_name | sessions | pct_of_searches | pct_from_previous_step | lost_at_this_step |
|---|---|---|---|---|---|---|
| Agency | 1 | Search | 11536 | 100 |  |  |
| Agency | 2 | Seats | 7261 | 62.9 | 62.9 | 4275 |
| Agency | 3 | Passenger details | 6246 | 54.1 | 86 | 1015 |
| Agency | 4 | Payment | 5149 | 44.6 | 82.4 | 1097 |
| Agency | 5 | Paid | 4424 | 38.3 | 85.9 | 725 |
| App | 1 | Search | 23064 | 100 |  |  |
| App | 2 | Seats | 16704 | 72.4 | 72.4 | 6360 |
| App | 3 | Passenger details | 14650 | 63.5 | 87.7 | 2054 |
| App | 4 | Payment | 11862 | 51.4 | 81 | 2788 |
| App | 5 | Paid | 8933 | 38.7 | 75.3 | 2929 |
| Web | 1 | Search | 23051 | 100 |  |  |
| Web | 2 | Seats | 17103 | 74.2 | 74.2 | 5948 |
| Web | 3 | Passenger details | 14256 | 61.8 | 83.4 | 2847 |
| Web | 4 | Payment | 11707 | 50.8 | 82.1 | 2549 |
| Web | 5 | Paid | 8928 | 38.7 | 76.3 | 2779 |
