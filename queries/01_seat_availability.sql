-- Q1. How many seats are still available on each upcoming flight, by cabin?
-- Techniques: view, conditional aggregation
SELECT
    flight_no,
    destination,
    departure_ts,
    cabin,
    COUNT(*)                                    AS total_seats,
    SUM(is_taken)                               AS seats_taken,
    COUNT(*) - SUM(is_taken)                    AS seats_available,
    ROUND(100.0 * SUM(is_taken) / COUNT(*), 1)  AS pct_taken
FROM v_flight_seats
WHERE flight_status = 'Scheduled'
GROUP BY flight_no, destination, departure_ts, cabin
ORDER BY departure_ts, flight_no,
         CASE cabin WHEN 'Business' THEN 1 WHEN 'Premium' THEN 2 ELSE 3 END;
