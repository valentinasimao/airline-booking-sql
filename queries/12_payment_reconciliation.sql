-- Q12. Payment reconciliation: does what we charged match what we sold, and were cancellations refunded?
--      Flags tickets issued without payment, double charges, under-charges and refunds still owed.
-- Techniques: expected-vs-actual CTEs, LEFT JOINs with COALESCE, CASE issue classification
WITH expected AS (                             -- fares + €12 for each self-selected seat outside Business
    SELECT t.booking_id,
           SUM(t.fare_eur)
         + SUM(CASE WHEN sa.assignment_type = 'Selected' AND t.cabin_booked <> 'Business'
                    THEN 12 ELSE 0 END)                          AS expected_eur
    FROM tickets t
    LEFT JOIN seat_assignments sa ON sa.ticket_id = t.ticket_id
    GROUP BY t.booking_id
),
captured AS (
    SELECT booking_id, SUM(amount_eur) AS paid_eur, COUNT(*) AS captures
    FROM payments
    WHERE status = 'Succeeded'
    GROUP BY booking_id
),
cancellations AS (                             -- refund due = fare minus €30 fee in Economy
    SELECT t.booking_id,
           COUNT(*)                                                         AS cancelled_tickets,
           COUNT(r.refund_id)                                               AS refunded_tickets,
           SUM(CASE WHEN r.refund_id IS NULL
                    THEN t.fare_eur - CASE WHEN t.cabin_booked = 'Economy' THEN 30 ELSE 0 END
                    ELSE 0 END)                                             AS refund_owed_eur
    FROM tickets t
    LEFT JOIN refunds r ON r.ticket_id = t.ticket_id
    WHERE t.status = 'Cancelled'
    GROUP BY t.booking_id
),
checked AS (
    SELECT
        b.booking_ref, b.channel, b.booked_at,
        e.expected_eur,
        COALESCE(c.paid_eur, 0)                                  AS paid_eur,
        COALESCE(c.captures, 0)                                  AS captures,
        COALESCE(x.refund_owed_eur, 0)                           AS refund_owed_eur,
        CASE
            WHEN c.booking_id IS NULL                     THEN '1 Ticketed but never paid'
            WHEN c.captures > 1                           THEN '2 Charged twice'
            WHEN c.paid_eur < e.expected_eur              THEN '3 Under-charged'
            WHEN x.refunded_tickets < x.cancelled_tickets THEN '4 Refund owed to customer'
        END                                                      AS issue
    FROM bookings b
    JOIN expected e            ON e.booking_id = b.booking_id
    LEFT JOIN captured c       ON c.booking_id = b.booking_id
    LEFT JOIN cancellations x  ON x.booking_id = b.booking_id
)
SELECT
    issue, booking_ref, channel, booked_at, expected_eur, paid_eur, captures,
    CASE
        WHEN issue LIKE '1%' THEN expected_eur                  -- money we never collected
        WHEN issue LIKE '2%' THEN paid_eur - expected_eur       -- money to give back
        WHEN issue LIKE '3%' THEN expected_eur - paid_eur       -- money we're missing
        ELSE refund_owed_eur                                    -- money to give back
    END                                                          AS amount_at_stake_eur
FROM checked
WHERE issue IS NOT NULL
ORDER BY issue, amount_at_stake_eur DESC;
