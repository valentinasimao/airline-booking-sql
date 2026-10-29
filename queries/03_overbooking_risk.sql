-- Q3. Which upcoming flights are overbooked once we account for expected no-shows?
-- Techniques: multiple CTEs, historical rate applied to future demand, CASE flags
WITH historical_no_show AS (           -- no-show rate per route and cabin from past flights
    SELECT
        f.destination,
        t.cabin_booked,
        1.0 * SUM(CASE WHEN t.status = 'NoShow' THEN 1 ELSE 0 END)
            / COUNT(*)                                        AS no_show_rate
    FROM tickets t
    JOIN flights f ON f.flight_id = t.flight_id
    WHERE f.status = 'Departed'
      AND t.status IN ('Boarded', 'NoShow')
    GROUP BY f.destination, t.cabin_booked
),
capacity AS (
    SELECT f.flight_id, sm.cabin, COUNT(*) AS seats
    FROM flights f
    JOIN seat_map sm ON sm.aircraft_type_id = f.aircraft_type_id
    GROUP BY f.flight_id, sm.cabin
),
demand AS (
    SELECT flight_id, cabin_booked AS cabin, COUNT(*) AS confirmed_tickets
    FROM tickets
    WHERE status = 'Confirmed'
    GROUP BY flight_id, cabin_booked
)
SELECT
    f.flight_no,
    f.destination,
    f.departure_ts,
    c.cabin,
    c.seats,
    d.confirmed_tickets,
    ROUND(100 * h.no_show_rate, 1)                          AS hist_no_show_pct,
    ROUND(d.confirmed_tickets * (1 - h.no_show_rate), 0)    AS expected_show_ups,
    CASE
        WHEN d.confirmed_tickets * (1 - h.no_show_rate) > c.seats        THEN 'Overbooked - act now'
        WHEN d.confirmed_tickets > c.seats                               THEN 'Oversold - covered by no-shows'
        WHEN d.confirmed_tickets * (1 - h.no_show_rate) >= 0.95 * c.seats THEN 'Watch'
        ELSE 'OK'
    END                                                     AS risk_flag
FROM flights f
JOIN capacity c           ON c.flight_id = f.flight_id
JOIN demand d             ON d.flight_id = f.flight_id AND d.cabin = c.cabin
JOIN historical_no_show h ON h.destination = f.destination AND h.cabin_booked = c.cabin
WHERE f.status = 'Scheduled'
  AND d.confirmed_tickets >= 0.95 * c.seats
ORDER BY d.confirmed_tickets * (1 - h.no_show_rate) - c.seats DESC, f.departure_ts;
