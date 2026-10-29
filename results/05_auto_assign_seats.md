# Q5. Propose seats for confirmed passengers on upcoming flights who have no seat yet,

Query: [`queries/05_auto_assign_seats.sql`](../queries/05_auto_assign_seats.sql) · **323 rows** (first 15 shown)

| flight_no | departure_ts | cabin | match_type | passengers |
|---|---|---|---|---|
| ZZ1401 | 2026-10-29 07:00:00 | Business | Preference met | 2 |
| ZZ1401 | 2026-10-29 07:00:00 | Economy | No preference | 20 |
| ZZ1401 | 2026-10-29 07:00:00 | Economy | Preference met | 27 |
| ZZ1401 | 2026-10-29 07:00:00 | Economy | Preference not available | 8 |
| ZZ1001 | 2026-10-29 07:15:00 | Business | Preference met | 1 |
| ZZ1001 | 2026-10-29 07:15:00 | Economy | No preference | 18 |
| ZZ1001 | 2026-10-29 07:15:00 | Economy | Preference met | 24 |
| ZZ1001 | 2026-10-29 07:15:00 | Economy | Preference not available | 11 |
| ZZ1301 | 2026-10-29 08:15:00 | Business | No preference | 1 |
| ZZ1301 | 2026-10-29 08:15:00 | Business | Preference met | 2 |
| ZZ1301 | 2026-10-29 08:15:00 | Business | Preference not available | 1 |
| ZZ1301 | 2026-10-29 08:15:00 | Economy | No preference | 12 |
| ZZ1301 | 2026-10-29 08:15:00 | Economy | Preference met | 18 |
| ZZ1301 | 2026-10-29 08:15:00 | Economy | Preference not available | 2 |
| ZZ1201 | 2026-10-29 09:00:00 | Business | Preference met | 1 |
