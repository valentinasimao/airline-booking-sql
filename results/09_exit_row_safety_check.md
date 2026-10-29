# Q9. Safety audit: are any passengers under 15 assigned to an emergency-exit row?

Query: [`queries/09_exit_row_safety_check.sql`](../queries/09_exit_row_safety_check.sql) · **12 rows** (first 12 shown)

| flight_no | departure_ts | flight_status | booking_ref | passenger | age_at_departure | seat_no | action |
|---|---|---|---|---|---|---|---|
| ZZ1003 | 2026-10-31 13:30:00 | Scheduled | HQRVH5 | Olivia Johnson | 4 | 13F | Reseat before departure |
| ZZ1003 | 2026-10-15 13:00:00 | Departed | 2SLZ2C | Marta Oliveira | 9 | 13E | Flown - report to safety team |
| ZZ1203 | 2026-10-15 17:15:00 | Departed | 22DPTM | Emma Johnson | 6 | 16E | Flown - report to safety team |
| ZZ1201 | 2026-10-16 09:15:00 | Departed | 0HNFN7 | Rafael Rossi | 6 | 16F | Flown - report to safety team |
| ZZ1201 | 2026-10-17 09:15:00 | Departed | PBRXA0 | Laura Romano | 10 | 16B | Flown - report to safety team |
| ZZ2001 | 2026-10-19 11:15:00 | Departed | PZGL3A | Emma Martin | 12 | 33K | Flown - report to safety team |
| ZZ1201 | 2026-10-20 09:00:00 | Departed | ITXNGU | Carlos Romano | 5 | 16D | Flown - report to safety team |
| ZZ1403 | 2026-10-20 18:45:00 | Departed | RCAQBK | Chloé Martínez | 7 | 15F | Flown - report to safety team |
| ZZ1401 | 2026-10-21 07:30:00 | Departed | A30K90 | Mariana Costa | 7 | 15D | Flown - report to safety team |
| ZZ1005 | 2026-10-22 19:45:00 | Departed | JUM2WU | Olivia Dubois | 6 | 13F | Flown - report to safety team |
| ZZ1005 | 2026-10-23 19:15:00 | Departed | QUDSA9 | Olivia Brown | 8 | 12A | Flown - report to safety team |
| ZZ1001 | 2026-10-26 07:30:00 | Departed | G2DGF7 | Ana Romano | 9 | 13E | Flown - report to safety team |
