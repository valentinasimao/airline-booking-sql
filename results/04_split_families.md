# Q4. Which booking groups were seated apart — and which of them are travelling with children?

Query: [`queries/04_split_families.sql`](../queries/04_split_families.sql) · **1,415 rows** (first 15 shown)

| booking_ref | flight_no | departure_ts | group_size | children | rows_apart | seating | priority |
|---|---|---|---|---|---|---|---|
| UT77H7 | ZZ1203 | 2026-10-24 17:00:00 | 4 | 2 | 28 | Sofia 4C, Jordi 6B, Elena 14B, Lucía 32F | HIGH - group with children |
| GSYTVI | ZZ1403 | 2026-10-31 18:45:00 | 4 | 2 | 28 | Beatriz 4A, Sofia 25F, Chloé 28C, Sofia 32F | HIGH - group with children |
| 27AFWT | ZZ1201 | 2026-10-17 09:15:00 | 4 | 2 | 27 | Hugo 4A, Marta 20C, Olivia 25A, Ana 31C | HIGH - group with children |
| T1T88S | ZZ1401 | 2026-10-22 07:30:00 | 4 | 2 | 27 | Noah 5F, Lucía 7D, Matteo 22D, Marta 32A | HIGH - group with children |
| 76J826 | ZZ1401 | 2026-10-30 07:15:00 | 4 | 2 | 27 | Pau 5F, David 25F, Pedro 28A, Pau 32A | HIGH - group with children |
| M6LP4A | ZZ1403 | 2026-10-18 18:15:00 | 4 | 2 | 26 | Àlex 5F, Giulia 15A, Àlex 20E, Laura 31B | HIGH - group with children |
| J7H86T | ZZ1301 | 2026-10-19 08:00:00 | 4 | 2 | 26 | Chloé 5A, Beatriz 13A, Ana 15A, Rafael 31E | HIGH - group with children |
| OM9BC8 | ZZ1301 | 2026-10-21 08:30:00 | 4 | 2 | 26 | Marc 5B, Noah 6F, Pedro 11E, David 31B | HIGH - group with children |
| N940V0 | ZZ1403 | 2026-10-22 18:45:00 | 4 | 2 | 26 | Pau 6F, Olivia 24D, Olivia 25B, Chloé 32C | HIGH - group with children |
| 9FL3RT | ZZ1003 | 2026-10-24 13:45:00 | 4 | 2 | 26 | Luca 5C, Mia 29D, Giulia 29E, Lucía 31C | HIGH - group with children |
| 1JHJT5 | ZZ1401 | 2026-10-16 07:30:00 | 4 | 2 | 25 | Júlia 7E, Marc 13F, Chloé 14F, Hugo 32C | HIGH - group with children |
| Q4AO6E | ZZ1203 | 2026-10-19 17:15:00 | 4 | 2 | 25 | Noah 5D, Hugo 12D, Elena 15A, João 30E | HIGH - group with children |
| 7L7MK2 | ZZ1401 | 2026-10-21 07:30:00 | 4 | 2 | 25 | Marc 5E, Carlos 16A, Lucía 22B, James 30A | HIGH - group with children |
| LTHLMK | ZZ1203 | 2026-10-21 17:00:00 | 4 | 2 | 25 | Pau 4A, Pau 6F, Olivia 10B, Beatriz 29E | HIGH - group with children |
| W3W8WN | ZZ1401 | 2026-10-22 07:30:00 | 4 | 2 | 25 | Pedro 7E, Àlex 16E, Marc 25E, Mariana 32E | HIGH - group with children |
