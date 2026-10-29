# Q7. Which routes and cabins earn the most per available seat (departed flights)?

Query: [`queries/07_revenue_per_seat.sql`](../queries/07_revenue_per_seat.sql) · **16 rows** (first 15 shown)

| destination | cabin | revenue_eur | seats_flown | revenue_per_seat_eur | pct_of_route_revenue | rank_overall |
|---|---|---|---|---|---|---|
| JFK | Business | 188670 | 168 | 1,123.04 | 20.2 | 1 |
| GRU | Business | 161150 | 168 | 959.23 | 17.6 | 2 |
| JFK | Premium | 201737 | 280 | 720.49 | 21.6 | 3 |
| GRU | Premium | 176164 | 280 | 629.16 | 19.2 | 4 |
| FCO | Business | 184424 | 448 | 411.66 | 24.4 | 5 |
| MAD | Business | 266222 | 672 | 396.16 | 24 | 6 |
| CDG | Business | 131651 | 336 | 391.82 | 17.6 | 7 |
| LHR | Business | 87583 | 224 | 391 | 22.1 | 8 |
| LIS | Business | 131303 | 336 | 390.78 | 17.4 | 9 |
| GRU | Economy | 580265 | 1638 | 354.25 | 63.2 | 10 |
| JFK | Economy | 542710 | 1638 | 331.32 | 58.2 | 11 |
| LHR | Economy | 307976 | 2268 | 135.79 | 77.9 | 12 |
| LIS | Economy | 622004 | 4872 | 127.67 | 82.6 | 13 |
| CDG | Economy | 616357 | 4872 | 126.51 | 82.4 | 14 |
| FCO | Economy | 570553 | 4536 | 125.78 | 75.6 | 15 |
