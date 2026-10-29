# Q3. Which upcoming flights are overbooked once we account for expected no-shows?

Query: [`queries/03_overbooking_risk.sql`](../queries/03_overbooking_risk.sql) · **23 rows** (first 15 shown)

| flight_no | destination | departure_ts | cabin | seats | confirmed_tickets | hist_no_show_pct | expected_show_ups | risk_flag |
|---|---|---|---|---|---|---|---|---|
| ZZ1501 | LHR | 2026-10-31 10:30:00 | Economy | 162 | 191 | 6.9 | 178 | Overbooked - act now |
| ZZ1003 | MAD | 2026-10-31 13:30:00 | Economy | 162 | 190 | 6.7 | 177 | Overbooked - act now |
| ZZ1501 | LHR | 2026-10-30 10:00:00 | Economy | 162 | 187 | 6.9 | 174 | Overbooked - act now |
| ZZ1203 | LIS | 2026-10-31 17:45:00 | Economy | 174 | 198 | 6.1 | 186 | Overbooked - act now |
| ZZ2101 | GRU | 2026-11-02 23:45:00 | Economy | 234 | 258 | 5.8 | 243 | Overbooked - act now |
| ZZ1005 | MAD | 2026-11-04 19:30:00 | Economy | 162 | 182 | 6.7 | 170 | Overbooked - act now |
| ZZ1301 | FCO | 2026-11-01 08:15:00 | Economy | 162 | 180 | 6.2 | 169 | Overbooked - act now |
| ZZ1301 | FCO | 2026-10-29 08:15:00 | Economy | 162 | 173 | 6.2 | 162 | Overbooked - act now |
| ZZ1403 | CDG | 2026-10-29 18:30:00 | Economy | 174 | 185 | 6.1 | 174 | Oversold - covered by no-shows |
| ZZ2001 | JFK | 2026-10-29 11:15:00 | Economy | 234 | 251 | 7.1 | 233 | Oversold - covered by no-shows |
| ZZ1403 | CDG | 2026-11-02 18:45:00 | Economy | 174 | 184 | 6.1 | 173 | Oversold - covered by no-shows |
| ZZ1201 | LIS | 2026-10-31 09:45:00 | Economy | 174 | 180 | 6.1 | 169 | Oversold - covered by no-shows |
| ZZ1005 | MAD | 2026-10-30 19:15:00 | Economy | 162 | 167 | 6.7 | 156 | Oversold - covered by no-shows |
| ZZ1001 | MAD | 2026-10-31 07:45:00 | Economy | 162 | 167 | 6.7 | 156 | Oversold - covered by no-shows |
| ZZ1005 | MAD | 2026-11-03 19:45:00 | Economy | 162 | 167 | 6.7 | 156 | Oversold - covered by no-shows |
