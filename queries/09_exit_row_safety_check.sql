-- Q9. Safety audit: are any passengers under 15 assigned to an emergency-exit row?
-- Techniques: view reuse, age calculation, data-quality rule
SELECT
    flight_no,
    departure_ts,
    flight_status,
    booking_ref,
    first_name || ' ' || last_name  AS passenger,
    age_at_departure,
    seat_no,
    CASE WHEN flight_status = 'Scheduled' THEN 'Reseat before departure'
         ELSE 'Flown - report to safety team' END AS action
FROM v_ticket_detail
WHERE is_exit_row
  AND age_at_departure < 15
  AND ticket_status <> 'Cancelled'
ORDER BY flight_status DESC, departure_ts;
