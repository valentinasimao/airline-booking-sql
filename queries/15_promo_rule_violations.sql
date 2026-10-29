-- Q15. Promo code audit: which redemptions broke the code's own rules?
--      Checks dates, channel, destination, minimum spend, usage limit and the discount amount itself.
-- Techniques: ROW_NUMBER() for the n-th use of a code, rule checks with CASE, UNION ALL of rule failures
WITH redemptions AS (
    SELECT
        bp.booking_id, b.booking_ref, b.channel, bp.promo_code, bp.redeemed_at,
        bp.gross_eur, bp.discount_eur,
        pc.discount_type, pc.discount_value, pc.min_spend_eur, pc.valid_from, pc.valid_to,
        pc.max_uses, pc.channel_only, pc.destination_only,
        (SELECT MIN(f.destination) FROM tickets t JOIN flights f ON f.flight_id = t.flight_id
          WHERE t.booking_id = bp.booking_id)                                     AS destination,
        ROW_NUMBER() OVER (PARTITION BY bp.promo_code ORDER BY bp.redeemed_at, bp.booking_id) AS use_no,
        CASE WHEN pc.discount_type = 'Percent'
             THEN ROUND(bp.gross_eur * pc.discount_value / 100, 2)
             ELSE LEAST(pc.discount_value, bp.gross_eur) END                      AS allowed_discount_eur
    FROM booking_promotions bp
    JOIN promo_codes pc ON pc.promo_code = bp.promo_code
    JOIN bookings b     ON b.booking_id  = bp.booking_id
),
violations AS (
    SELECT *, 'Used outside valid dates'      AS rule_broken FROM redemptions
     WHERE redeemed_at < valid_from OR redeemed_at > valid_to
    UNION ALL
    SELECT *, 'Wrong channel'                 FROM redemptions
     WHERE channel_only IS NOT NULL AND channel <> channel_only
    UNION ALL
    SELECT *, 'Wrong destination'             FROM redemptions
     WHERE destination_only IS NOT NULL AND destination <> destination_only
    UNION ALL
    SELECT *, 'Below minimum spend'           FROM redemptions
     WHERE min_spend_eur IS NOT NULL AND gross_eur < min_spend_eur
    UNION ALL
    SELECT *, 'Usage limit exceeded'          FROM redemptions
     WHERE max_uses IS NOT NULL AND use_no > max_uses
    UNION ALL
    SELECT *, 'Discount larger than allowed'  FROM redemptions
     WHERE discount_eur > allowed_discount_eur + 0.01
)
SELECT
    promo_code, rule_broken, booking_ref, channel, destination, redeemed_at,
    gross_eur, discount_eur, allowed_discount_eur,
    CASE WHEN rule_broken = 'Discount larger than allowed'
         THEN discount_eur - allowed_discount_eur                -- only the extra part was wrong
         ELSE discount_eur END                                   AS discount_at_risk_eur
FROM violations
ORDER BY promo_code, rule_broken, redeemed_at;
