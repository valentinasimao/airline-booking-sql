-- Q8. How often do passengers get the seat type they asked for — self-selected vs auto-assigned?
-- Techniques: conditional aggregation, percentages
SELECT
    assignment_type,
    seat_preference,
    COUNT(*)                                                            AS passengers,
    SUM(CASE WHEN seat_type = seat_preference THEN 1 ELSE 0 END)        AS got_preference,
    ROUND(100.0 * SUM(CASE WHEN seat_type = seat_preference THEN 1 ELSE 0 END) / COUNT(*), 1)
                                                                        AS fulfilment_pct
FROM v_ticket_detail
WHERE seat_preference IS NOT NULL
  AND seat_no IS NOT NULL
GROUP BY assignment_type, seat_preference
ORDER BY assignment_type, seat_preference;
