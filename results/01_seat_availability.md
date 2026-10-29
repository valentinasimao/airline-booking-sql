# Q1. How many seats are still available on each upcoming flight, by cabin?

Query: [`queries/01_seat_availability.sql`](../queries/01_seat_availability.sql) · **164 rows** (first 15 shown)

| flight_no | destination | departure_ts | cabin | total_seats | seats_taken | seats_available | pct_taken |
|---|---|---|---|---|---|---|---|
| ZZ1401 | CDG | 2026-10-29 07:00:00 | Business | 12 | 9 | 3 | 75 |
| ZZ1401 | CDG | 2026-10-29 07:00:00 | Economy | 174 | 109 | 65 | 62.6 |
| ZZ1001 | MAD | 2026-10-29 07:15:00 | Business | 16 | 6 | 10 | 37.5 |
| ZZ1001 | MAD | 2026-10-29 07:15:00 | Economy | 162 | 105 | 57 | 64.8 |
| ZZ1301 | FCO | 2026-10-29 08:15:00 | Business | 16 | 8 | 8 | 50 |
| ZZ1301 | FCO | 2026-10-29 08:15:00 | Economy | 162 | 125 | 37 | 77.2 |
| ZZ1201 | LIS | 2026-10-29 09:00:00 | Business | 12 | 8 | 4 | 66.7 |
| ZZ1201 | LIS | 2026-10-29 09:00:00 | Economy | 174 | 118 | 56 | 67.8 |
| ZZ1501 | LHR | 2026-10-29 10:00:00 | Business | 16 | 8 | 8 | 50 |
| ZZ1501 | LHR | 2026-10-29 10:00:00 | Economy | 162 | 111 | 51 | 68.5 |
| ZZ2001 | JFK | 2026-10-29 11:15:00 | Business | 24 | 10 | 14 | 41.7 |
| ZZ2001 | JFK | 2026-10-29 11:15:00 | Premium | 40 | 18 | 22 | 45 |
| ZZ2001 | JFK | 2026-10-29 11:15:00 | Economy | 234 | 170 | 64 | 72.6 |
| ZZ1003 | MAD | 2026-10-29 13:15:00 | Business | 16 | 10 | 6 | 62.5 |
| ZZ1003 | MAD | 2026-10-29 13:15:00 | Economy | 162 | 115 | 47 | 71 |
