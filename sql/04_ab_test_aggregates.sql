/*
===========================================================
Project : Subscription Product Analytics

File    : 04_ab_test_aggregates.sql

Purpose :
Prepare experiment metrics for A/B test analysis.

Business Questions:
1. How many users were assigned to each variant?
2. How many users converted to paid?
3. What is the conversion rate?
4. What is the average revenue?
5. Is Variant B outperforming Variant A?

Author  : Naveen Raj
===========================================================
*/


-- =========================================================
-- Query 1: Experiment Assignment Summary
-- =========================================================

SELECT

    ea.variant,

    COUNT(DISTINCT ea.user_id) AS users,

    COUNT(DISTINCT s.user_id)
        FILTER (WHERE s.paid_start_date IS NOT NULL)
        AS paid_users,

    ROUND(

        COUNT(DISTINCT s.user_id)
            FILTER (WHERE s.paid_start_date IS NOT NULL)

        * 100.0

        /

        COUNT(DISTINCT ea.user_id),

        2

    ) AS conversion_rate

FROM experiment_assignment ea

LEFT JOIN subscriptions s

ON ea.user_id = s.user_id

GROUP BY
    ea.variant

ORDER BY
    ea.variant;



-- =========================================================
-- Query 2: Revenue by Variant
-- =========================================================

SELECT

    ea.variant,

    COUNT(DISTINCT p.user_id) AS paying_users,

    SUM(p.amount) AS total_revenue,

    ROUND(

        AVG(p.amount),

        2

    ) AS avg_payment

FROM experiment_assignment ea

JOIN payments p

ON ea.user_id = p.user_id

GROUP BY
    ea.variant

ORDER BY
    ea.variant;

