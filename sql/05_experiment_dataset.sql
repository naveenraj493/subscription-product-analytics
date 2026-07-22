/*
===========================================================
Project : Subscription Product Analytics

File    : 05_experiment_dataset.sql

Purpose :
Build a user-level experiment dataset for Python analysis.

Each row represents one experiment participant.

The dataset is designed for:
1. Segment analysis
2. Guardrail metrics
3. Statistical analysis in Python
4. Future experiment extensions (e.g., CUPED)

Author  : Naveen Raj
===========================================================
*/

-- =========================================================
-- Aggregate Revenue per User
-- =========================================================

WITH user_revenue AS (

    SELECT

        user_id,

        SUM(amount) AS revenue

    FROM payments

    GROUP BY
        user_id

)

-- =========================================================
-- Build User-Level Experiment Dataset
-- =========================================================

SELECT

    ea.user_id,

    ea.variant,

    u.signup_date,

    u.device,

    u.country,

    u.acquisition_channel,

    u.pre_engagement_7d,

    CASE
        WHEN s.paid_start_date IS NOT NULL
        THEN 1
        ELSE 0
    END AS converted,

    CASE
        WHEN s.status = 'active'
        THEN 1
        ELSE 0
    END AS retained,

    COALESCE(ur.revenue, 0) AS revenue

FROM experiment_assignment ea

LEFT JOIN users u
    ON ea.user_id = u.user_id

LEFT JOIN subscriptions s
    ON ea.user_id = s.user_id

LEFT JOIN user_revenue ur
    ON ea.user_id = ur.user_id

ORDER BY
    ea.user_id;