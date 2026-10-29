-- Q10. Where do customers drop out of the booking flow? Funnel from search to payment, by channel.
-- Techniques: inline VALUES table for step order, non-equi join (step reached), FIRST_VALUE() and LAG()
WITH steps (step_no, step_name) AS (
    VALUES (1, 'Search'), (2, 'Seats'), (3, 'Passenger details'), (4, 'Payment'), (5, 'Paid')
),
reached AS (                                   -- a session that got to step 4 also passed steps 1-3
    SELECT cs.channel, s.step_no, s.step_name, COUNT(*) AS sessions
    FROM checkout_sessions cs
    JOIN steps furthest ON furthest.step_name = cs.furthest_step
    JOIN steps s        ON s.step_no <= furthest.step_no
    GROUP BY cs.channel, s.step_no, s.step_name
)
SELECT
    channel,
    step_no,
    step_name,
    sessions,
    ROUND(100.0 * sessions / FIRST_VALUE(sessions) OVER w, 1)       AS pct_of_searches,
    ROUND(100.0 * sessions / LAG(sessions) OVER w, 1)               AS pct_from_previous_step,
    LAG(sessions) OVER w - sessions                                 AS lost_at_this_step
FROM reached
WINDOW w AS (PARTITION BY channel ORDER BY step_no)
ORDER BY channel, step_no;
