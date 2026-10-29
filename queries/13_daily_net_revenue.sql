-- Q13. Daily cash: payments taken minus refunds, with a 7-day moving average and a month-to-date total (October 2026).
-- Techniques: UNION of two event streams, AVG() OVER (ROWS 6 PRECEDING), running SUM() per month
WITH cash_in AS (
    SELECT CAST(attempted_at AS DATE) AS day, SUM(amount_eur) AS taken_eur
    FROM payments WHERE status = 'Succeeded'
    GROUP BY CAST(attempted_at AS DATE)
),
cash_out AS (
    SELECT CAST(refunded_at AS DATE) AS day, SUM(amount_eur) AS refunded_eur
    FROM refunds
    GROUP BY CAST(refunded_at AS DATE)
),
days AS (
    SELECT day FROM cash_in UNION SELECT day FROM cash_out
),
daily AS (
    SELECT d.day,
           COALESCE(i.taken_eur, 0)                              AS taken_eur,
           COALESCE(o.refunded_eur, 0)                           AS refunded_eur,
           COALESCE(i.taken_eur, 0) - COALESCE(o.refunded_eur, 0) AS net_eur
    FROM days d
    LEFT JOIN cash_in  i ON i.day = d.day
    LEFT JOIN cash_out o ON o.day = d.day
),
with_trends AS (
    SELECT day, taken_eur, refunded_eur, net_eur,
           AVG(net_eur) OVER (ORDER BY day ROWS BETWEEN 6 PRECEDING AND CURRENT ROW)           AS net_7day_avg,
           SUM(net_eur) OVER (PARTITION BY DATE_TRUNC('month', day) ORDER BY day)              AS month_to_date
    FROM daily
)
SELECT day,
       CAST(ROUND(taken_eur, 0) AS BIGINT)       AS taken_eur,
       CAST(ROUND(refunded_eur, 0) AS BIGINT)    AS refunded_eur,
       CAST(ROUND(net_eur, 0) AS BIGINT)         AS net_eur,
       CAST(ROUND(net_7day_avg, 0) AS BIGINT)    AS net_7day_avg_eur,
       CAST(ROUND(month_to_date, 0) AS BIGINT)   AS month_to_date_eur
FROM with_trends
WHERE day >= DATE '2026-10-01' AND day < DATE '2026-10-29'
ORDER BY day;
