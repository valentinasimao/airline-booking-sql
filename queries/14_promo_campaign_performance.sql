-- Q14. How did each promo campaign perform? Bookings, discount given, net revenue, basket size vs. bookings
--      without a code, and what each extra booking cost us in discount.
-- Techniques: LEFT JOIN to find non-promo bookings, scalar subquery benchmark, SUM() OVER share of total
WITH booking_value AS (                        -- value of every paid web/app booking, with or without a code
    SELECT b.booking_id, b.channel, bp.promo_code,
           COALESCE(bp.discount_eur, 0)                          AS discount_eur,
           SUM(p.amount_eur)                                     AS paid_eur
    FROM bookings b
    JOIN payments p                 ON p.booking_id = b.booking_id AND p.status = 'Succeeded'
    LEFT JOIN booking_promotions bp ON bp.booking_id = b.booking_id
    WHERE b.channel IN ('Web', 'App')
    GROUP BY b.booking_id, b.channel, bp.promo_code, bp.discount_eur
),
by_code AS (
    SELECT promo_code,
           COUNT(*)                                              AS bookings,
           SUM(discount_eur)                                     AS discount_eur,
           SUM(paid_eur)                                         AS net_revenue_eur,
           AVG(paid_eur + discount_eur)                          AS avg_basket_before_discount
    FROM booking_value
    WHERE promo_code IS NOT NULL
    GROUP BY promo_code
)
SELECT
    pc.promo_code,
    pc.campaign,
    CASE WHEN pc.discount_type = 'Percent'
         THEN CAST(CAST(pc.discount_value AS INTEGER) AS VARCHAR) || '%'
         ELSE '€' || CAST(CAST(pc.discount_value AS INTEGER) AS VARCHAR) END        AS offer,
    bc.bookings,
    ROUND(bc.discount_eur, 0)                                                     AS discount_given_eur,
    ROUND(bc.net_revenue_eur, 0)                                                  AS net_revenue_eur,
    ROUND(100.0 * bc.discount_eur / (bc.net_revenue_eur + bc.discount_eur), 1)    AS discount_pct_of_gross,
    ROUND(bc.avg_basket_before_discount, 0)                                       AS avg_basket_eur,
    ROUND((SELECT AVG(paid_eur) FROM booking_value WHERE promo_code IS NULL), 0)  AS avg_basket_no_code_eur,
    ROUND(100.0 * bc.discount_eur / SUM(bc.discount_eur) OVER (), 1)              AS share_of_all_discounts_pct
FROM promo_codes pc
JOIN by_code bc ON bc.promo_code = pc.promo_code
ORDER BY discount_given_eur DESC;
