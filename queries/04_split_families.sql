-- Q4. Which booking groups were seated apart — and which of them are travelling with children?
-- Techniques: LAG() over seat order, adjacency logic, HAVING, boolean aggregation
WITH group_seats AS (
    SELECT
        booking_ref, flight_id, flight_no, departure_ts, ticket_id,
        first_name, age_at_departure, seat_no, row_no, letter_pos,
        COUNT(*) OVER (PARTITION BY booking_id, flight_id)                 AS group_size,
        LAG(row_no)     OVER (PARTITION BY booking_id, flight_id ORDER BY row_no, letter_pos) AS prev_row,
        LAG(letter_pos) OVER (PARTITION BY booking_id, flight_id ORDER BY row_no, letter_pos) AS prev_pos
    FROM v_ticket_detail
    WHERE seat_no IS NOT NULL
      AND ticket_status <> 'Cancelled'
),
scored AS (
    SELECT
        *,
        CASE WHEN row_no = prev_row AND letter_pos = prev_pos + 1 THEN 1 ELSE 0 END AS next_to_previous
    FROM group_seats
    WHERE group_size >= 2
),
groups AS (
    SELECT
        booking_ref, flight_no, departure_ts, group_size,
        SUM(next_to_previous)                                         AS adjacent_pairs,
        MAX(row_no) - MIN(row_no)                                     AS rows_apart,
        SUM(CASE WHEN age_at_departure < 12 THEN 1 ELSE 0 END)        AS children,
        STRING_AGG(first_name || ' ' || seat_no, ', ' ORDER BY row_no, letter_pos) AS seating
    FROM scored
    GROUP BY booking_ref, flight_no, departure_ts, group_size
)
SELECT
    booking_ref, flight_no, departure_ts, group_size, children, rows_apart, seating,
    CASE WHEN children > 0 THEN 'HIGH - group with children' ELSE 'Medium' END AS priority
FROM groups
WHERE adjacent_pairs < group_size - 1          -- not everyone sits in one continuous block
ORDER BY children DESC, rows_apart DESC, departure_ts
;
