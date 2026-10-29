-- Reusable views that the analysis queries build on

-- Every physical seat on every flight, with who (if anyone) is sitting in it
CREATE VIEW v_flight_seats AS
SELECT
    f.flight_id, f.flight_no, f.destination, f.departure_ts, f.status AS flight_status,
    sm.seat_no, sm.row_no, sm.letter_pos, sm.cabin, sm.seat_type, sm.is_exit_row,
    sa.ticket_id,
    CASE WHEN sa.ticket_id IS NULL THEN 0 ELSE 1 END AS is_taken
FROM flights f
JOIN seat_map sm
  ON sm.aircraft_type_id = f.aircraft_type_id
LEFT JOIN seat_assignments sa
  ON sa.flight_id = f.flight_id
 AND sa.seat_no   = sm.seat_no;

-- One row per ticket with passenger, flight and seat details
CREATE VIEW v_ticket_detail AS
SELECT
    t.ticket_id, t.booking_id, b.booking_ref, t.flight_id, f.flight_no, f.destination,
    f.departure_ts, f.status AS flight_status, t.cabin_booked, t.fare_eur,
    t.seat_preference, t.status AS ticket_status,
    p.passenger_id, p.first_name, p.last_name, p.loyalty_tier, p.loyalty_points,
    FLOOR((CAST(f.departure_ts AS DATE) - p.birth_date) / 365.25) AS age_at_departure,
    sa.seat_no, sa.assignment_type, sm.row_no, sm.letter_pos, sm.seat_type, sm.is_exit_row
FROM tickets t
JOIN bookings   b ON b.booking_id   = t.booking_id
JOIN flights    f ON f.flight_id    = t.flight_id
JOIN passengers p ON p.passenger_id = t.passenger_id
LEFT JOIN seat_assignments sa ON sa.ticket_id = t.ticket_id
LEFT JOIN seat_map sm
       ON sm.aircraft_type_id = f.aircraft_type_id
      AND sm.seat_no          = sa.seat_no;
