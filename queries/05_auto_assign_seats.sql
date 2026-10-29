-- Q5. Propose seats for confirmed passengers on upcoming flights who have no seat yet,
--     honouring Window/Aisle preference first, loyal customers first.
-- Techniques: two-pass matching with ROW_NUMBER(), anti-joins, UNION ALL
WITH unseated AS (
    SELECT t.ticket_id, t.flight_id, t.cabin_booked AS cabin, t.seat_preference,
           p.loyalty_tier, p.loyalty_points, b.booked_at
    FROM tickets t
    JOIN flights f    ON f.flight_id = t.flight_id AND f.status = 'Scheduled'
    JOIN passengers p ON p.passenger_id = t.passenger_id
    JOIN bookings b   ON b.booking_id = t.booking_id
    WHERE t.status = 'Confirmed'
      AND NOT EXISTS (SELECT 1 FROM seat_assignments sa WHERE sa.ticket_id = t.ticket_id)
),
priority AS (
    SELECT *,
           CASE loyalty_tier WHEN 'Platinum' THEN 1 WHEN 'Gold' THEN 2
                             WHEN 'Silver' THEN 3 ELSE 4 END AS tier_rank
    FROM unseated
),
free_seats AS (
    SELECT flight_id, cabin, seat_no, seat_type, row_no, letter_pos
    FROM v_flight_seats
    WHERE flight_status = 'Scheduled' AND is_taken = 0 AND NOT is_exit_row
),
-- Pass 1: match passengers to a free seat of the type they asked for
pref_pax AS (
    SELECT *, ROW_NUMBER() OVER (PARTITION BY flight_id, cabin, seat_preference
                                 ORDER BY tier_rank, loyalty_points DESC, booked_at) AS rn
    FROM priority WHERE seat_preference IS NOT NULL
),
pref_seats AS (
    SELECT *, ROW_NUMBER() OVER (PARTITION BY flight_id, cabin, seat_type
                                 ORDER BY row_no, letter_pos) AS rn
    FROM free_seats
),
pass1 AS (
    SELECT p.ticket_id, p.flight_id, p.cabin, s.seat_no, p.seat_preference, s.seat_type, 'Preference met' AS match_type
    FROM pref_pax p
    JOIN pref_seats s
      ON s.flight_id = p.flight_id AND s.cabin = p.cabin
     AND s.seat_type = p.seat_preference AND s.rn = p.rn
),
-- Pass 2: everyone left gets the best remaining seat
left_pax AS (
    SELECT pr.*, ROW_NUMBER() OVER (PARTITION BY pr.flight_id, pr.cabin
                                    ORDER BY pr.tier_rank, pr.loyalty_points DESC, pr.booked_at) AS rn
    FROM priority pr
    WHERE pr.ticket_id NOT IN (SELECT ticket_id FROM pass1)
),
left_seats AS (
    SELECT fs.*, ROW_NUMBER() OVER (PARTITION BY fs.flight_id, fs.cabin ORDER BY fs.row_no, fs.letter_pos) AS rn
    FROM free_seats fs
    WHERE NOT EXISTS (SELECT 1 FROM pass1 p1 WHERE p1.flight_id = fs.flight_id AND p1.seat_no = fs.seat_no)
),
pass2 AS (
    SELECT l.ticket_id, l.flight_id, l.cabin, s.seat_no, l.seat_preference, s.seat_type,
           CASE WHEN l.seat_preference IS NULL THEN 'No preference' ELSE 'Preference not available' END
    FROM left_pax l
    JOIN left_seats s ON s.flight_id = l.flight_id AND s.cabin = l.cabin AND s.rn = l.rn
),
proposal AS (
    SELECT * FROM pass1
    UNION ALL
    SELECT * FROM pass2
)
SELECT f.flight_no, f.departure_ts, pr.cabin, pr.match_type,
       COUNT(*) AS passengers
FROM proposal pr
JOIN flights f ON f.flight_id = pr.flight_id
GROUP BY f.flight_no, f.departure_ts, pr.cabin, pr.match_type
ORDER BY f.departure_ts, f.flight_no, pr.cabin, pr.match_type;
