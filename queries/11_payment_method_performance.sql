-- Q11. Which payment methods fail most, why, how many customers still complete the purchase after a
--      failed first try, and how much money walks away with the ones who don't?
-- Techniques: CTEs per checkout session, ROW_NUMBER() to pick the most common reason and the first attempt,
--             BOOL-style MAX(CASE …), conditional SUM
WITH attempts AS (
    SELECT method,
           COUNT(*)                                              AS attempts,
           SUM(CASE WHEN status = 'Failed' THEN 1 ELSE 0 END)    AS failed
    FROM payments
    GROUP BY method
),
top_reason AS (
    SELECT method, failure_reason,
           ROW_NUMBER() OVER (PARTITION BY method ORDER BY COUNT(*) DESC, failure_reason) AS rn
    FROM payments
    WHERE status = 'Failed'
    GROUP BY method, failure_reason
),
first_attempt AS (                             -- the first payment attempt of every checkout session
    SELECT session_id, method, status, amount_eur,
           ROW_NUMBER() OVER (PARTITION BY session_id ORDER BY attempt_no) AS rn
    FROM payments
),
session_outcome AS (
    SELECT session_id,
           MAX(CASE WHEN status = 'Succeeded' THEN 1 ELSE 0 END) AS eventually_paid
    FROM payments
    GROUP BY session_id
),
failed_first AS (
    SELECT f.method, f.session_id, f.amount_eur, o.eventually_paid
    FROM first_attempt f
    JOIN session_outcome o ON o.session_id = f.session_id
    WHERE f.rn = 1 AND f.status = 'Failed'
)
SELECT
    a.method,
    a.attempts,
    ROUND(100.0 * a.failed / a.attempts, 1)                                  AS failure_rate_pct,
    tr.failure_reason                                                        AS most_common_reason,
    COUNT(ff.session_id)                                                     AS checkouts_failed_first_try,
    ROUND(100.0 * SUM(ff.eventually_paid) / NULLIF(COUNT(ff.session_id), 0), 1) AS recovered_pct,
    ROUND(SUM(CASE WHEN ff.eventually_paid = 0 THEN ff.amount_eur ELSE 0 END), 0) AS sales_lost_eur
FROM attempts a
LEFT JOIN top_reason tr   ON tr.method = a.method AND tr.rn = 1
LEFT JOIN failed_first ff ON ff.method = a.method
GROUP BY a.method, a.attempts, a.failed, tr.failure_reason
ORDER BY sales_lost_eur DESC;
