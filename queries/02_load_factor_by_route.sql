-- Q2. What was the load factor of each departed flight, how does it rank within its route,
--     and what is the rolling trend?
-- Techniques: CTE, RANK() and a moving-average window frame
WITH flight_load AS (
    SELECT
        f.flight_id, f.flight_no, f.destination, f.departure_ts,
        ac.total_seats,
        COUNT(t.ticket_id)                                    AS passengers_boarded,
        ROUND(100.0 * COUNT(t.ticket_id) / ac.total_seats, 1) AS load_factor_pct
    FROM flights f
    JOIN aircraft_types ac ON ac.aircraft_type_id = f.aircraft_type_id
    LEFT JOIN tickets t    ON t.flight_id = f.flight_id AND t.status = 'Boarded'
    WHERE f.status = 'Departed'
    GROUP BY f.flight_id, f.flight_no, f.destination, f.departure_ts, ac.total_seats
)
SELECT
    destination,
    flight_no,
    departure_ts,
    passengers_boarded,
    total_seats,
    load_factor_pct,
    RANK() OVER (PARTITION BY destination ORDER BY load_factor_pct DESC)          AS rank_in_route,
    ROUND(AVG(load_factor_pct) OVER (PARTITION BY destination ORDER BY departure_ts
                                     ROWS BETWEEN 6 PRECEDING AND CURRENT ROW), 1) AS rolling_7_flight_avg
FROM flight_load
ORDER BY destination, departure_ts;
