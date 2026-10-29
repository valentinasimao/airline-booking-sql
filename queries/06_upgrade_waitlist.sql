-- Q6. Who gets upgraded to Business on each upcoming flight?
--     Rank requests by loyalty tier, then points, then request time; compare with free seats.
-- Techniques: ROW_NUMBER() waitlist, capacity CTE, LEFT JOIN with COALESCE
WITH business_free AS (
    SELECT fs.flight_id,
           SUM(1 - fs.is_taken)
           - COALESCE(MAX(unseated.n), 0)          AS free_business_seats   -- keep seats for unseated Business ticket holders
    FROM v_flight_seats fs
    LEFT JOIN (
        SELECT t.flight_id, COUNT(*) AS n
        FROM tickets t
        WHERE t.cabin_booked = 'Business' AND t.status = 'Confirmed'
          AND NOT EXISTS (SELECT 1 FROM seat_assignments sa WHERE sa.ticket_id = t.ticket_id)
        GROUP BY t.flight_id
    ) unseated ON unseated.flight_id = fs.flight_id
    WHERE fs.cabin = 'Business' AND fs.flight_status = 'Scheduled'
    GROUP BY fs.flight_id
),
waitlist AS (
    SELECT
        td.flight_id, td.flight_no, td.departure_ts, td.ticket_id,
        td.first_name || ' ' || td.last_name AS passenger,
        td.loyalty_tier, td.loyalty_points, td.cabin_booked, ur.requested_at,
        ROW_NUMBER() OVER (
            PARTITION BY td.flight_id
            ORDER BY CASE td.loyalty_tier WHEN 'Platinum' THEN 1 WHEN 'Gold' THEN 2
                                          WHEN 'Silver' THEN 3 ELSE 4 END,
                     td.loyalty_points DESC,
                     ur.requested_at
        ) AS waitlist_position
    FROM upgrade_requests ur
    JOIN v_ticket_detail td ON td.ticket_id = ur.ticket_id
    WHERE ur.requested_cabin = 'Business'
      AND td.ticket_status = 'Confirmed'
)
SELECT
    w.flight_no, w.departure_ts, w.waitlist_position, w.passenger,
    w.loyalty_tier, w.loyalty_points, w.cabin_booked,
    GREATEST(COALESCE(b.free_business_seats, 0), 0) AS free_business_seats,
    CASE WHEN w.waitlist_position <= COALESCE(b.free_business_seats, 0)
         THEN 'UPGRADE' ELSE 'Waitlisted' END       AS decision
FROM waitlist w
LEFT JOIN business_free b ON b.flight_id = w.flight_id
ORDER BY w.departure_ts, w.flight_no, w.waitlist_position;
