/*
===========================================================
Project : Subscription Product Analytics

File    : 01_funnel.sql

Purpose :
Analyze the subscription conversion funnel and identify
drop-off points across the customer lifecycle.

Business Questions:
1. What is the overall conversion funnel?
2. Which acquisition channels convert best?
3. Does conversion differ by device?
4. Which countries have the highest conversion rates?

Key Insight:
The largest drop-off occurs between the Trial and Paid
stages, indicating trial conversion is the primary
optimization opportunity.

Author  : Naveen Raj
===========================================================
*/


-- =========================================================
-- Query 1: Overall Funnel (Signup → Trial → Paid → Retained)
-- =========================================================

SELECT
    COUNT(DISTINCT u.user_id) AS signup_users,

    COUNT(DISTINCT s.user_id)
        FILTER (WHERE s.trial_start_date IS NOT NULL) AS trial_users,

    COUNT(DISTINCT s.user_id)
        FILTER (WHERE s.paid_start_date IS NOT NULL) AS paid_users,

    COUNT(DISTINCT s.user_id)
        FILTER (WHERE s.status = 'active') AS retained_users,

    ROUND(
        COUNT(DISTINCT s.user_id)
            FILTER (WHERE s.trial_start_date IS NOT NULL)
        * 100.0
        / COUNT(DISTINCT u.user_id),
        2
    ) AS signup_to_trial_pct,

    ROUND(
        COUNT(DISTINCT s.user_id)
            FILTER (WHERE s.paid_start_date IS NOT NULL)
        * 100.0
        / COUNT(DISTINCT s.user_id)
            FILTER (WHERE s.trial_start_date IS NOT NULL),
        2
    ) AS trial_to_paid_pct,

    ROUND(
        COUNT(DISTINCT s.user_id)
            FILTER (WHERE s.status = 'active')
        * 100.0
        / COUNT(DISTINCT s.user_id)
            FILTER (WHERE s.paid_start_date IS NOT NULL),
        2
    ) AS paid_to_retained_pct

FROM users u
LEFT JOIN subscriptions s
    ON u.user_id = s.user_id;


-- =========================================================
-- Query 2: Signup-to-Paid Conversion by Acquisition Channel
-- =========================================================

SELECT
    u.acquisition_channel,

    COUNT(DISTINCT u.user_id) AS total_users,

    COUNT(DISTINCT s.user_id)
        FILTER (WHERE s.paid_start_date IS NOT NULL) AS paid_users,

    ROUND(
        COUNT(DISTINCT s.user_id)
            FILTER (WHERE s.paid_start_date IS NOT NULL)
        * 100.0
        / COUNT(DISTINCT u.user_id),
        2
    ) AS signup_to_paid_conversion_rate

FROM users u
LEFT JOIN subscriptions s
    ON u.user_id = s.user_id

GROUP BY u.acquisition_channel

ORDER BY signup_to_paid_conversion_rate DESC;


-- =========================================================
-- Query 3: Signup-to-Paid Conversion by Device
-- =========================================================

SELECT
    u.device,

    COUNT(DISTINCT u.user_id) AS total_users,

    COUNT(DISTINCT s.user_id)
        FILTER (WHERE s.paid_start_date IS NOT NULL) AS paid_users,

    ROUND(
        COUNT(DISTINCT s.user_id)
            FILTER (WHERE s.paid_start_date IS NOT NULL)
        * 100.0
        / COUNT(DISTINCT u.user_id),
        2
    ) AS signup_to_paid_conversion_rate

FROM users u
LEFT JOIN subscriptions s
    ON u.user_id = s.user_id

GROUP BY u.device

ORDER BY signup_to_paid_conversion_rate DESC;


-- =========================================================
-- Query 4: Signup-to-Paid Conversion by Country
-- =========================================================

SELECT
    COALESCE(u.country, 'Unknown') AS country,

    COUNT(DISTINCT u.user_id) AS total_users,

    COUNT(DISTINCT s.user_id)
        FILTER (WHERE s.paid_start_date IS NOT NULL) AS paid_users,

    ROUND(
        COUNT(DISTINCT s.user_id)
            FILTER (WHERE s.paid_start_date IS NOT NULL)
        * 100.0
        / COUNT(DISTINCT u.user_id),
        2
    ) AS signup_to_paid_conversion_rate

FROM users u
LEFT JOIN subscriptions s
    ON u.user_id = s.user_id

GROUP BY COALESCE(u.country, 'Unknown')

ORDER BY signup_to_paid_conversion_rate DESC;