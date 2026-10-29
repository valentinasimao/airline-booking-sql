-- Q7. Which routes and cabins earn the most per available seat (departed flights)?
-- Techniques: CTEs, revenue per available seat, share of total with SUM() OVER()
WITH revenue AS (
    SELECT f.destination, t.cabin_booked AS cabin, SUM(t.fare_eur) AS revenue_eur
    FROM tickets t
    JOIN flights f ON f.flight_id = t.flight_id
    WHERE f.status = 'Departed'
      AND t.status IN ('Boarded', 'NoShow')           -- no-shows pay; cancellations refunded
    GROUP BY f.destination, t.cabin_booked
),
seats_flown AS (
    SELECT f.destination, sm.cabin, COUNT(*) AS seats_flown
    FROM flights f
    JOIN seat_map sm ON sm.aircraft_type_id = f.aircraft_type_id
    WHERE f.status = 'Departed'
    GROUP BY f.destination, sm.cabin
)
SELECT
    r.destination,
    r.cabin,
    ROUND(r.revenue_eur, 0)                                             AS revenue_eur,
    s.seats_flown,
    ROUND(r.revenue_eur / s.seats_flown, 2)                             AS revenue_per_seat_eur,
    ROUND(100 * r.revenue_eur / SUM(r.revenue_eur) OVER (PARTITION BY r.destination), 1) AS pct_of_route_revenue,
    RANK() OVER (ORDER BY r.revenue_eur / s.seats_flown DESC)           AS rank_overall
FROM revenue r
JOIN seats_flown s ON s.destination = r.destination AND s.cabin = r.cabin
ORDER BY revenue_per_seat_eur DESC;
