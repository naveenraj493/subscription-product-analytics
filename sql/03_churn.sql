/*
===========================================================
Project : Subscription Product Analytics

File    : 03_churn.sql

Purpose :
Analyze customer churn among paying subscribers and
identify segments with the highest customer loss.

Business Questions:
1. What is the overall churn rate?
2. Which acquisition channels have the highest churn?
3. Does churn differ by device?
4. Which countries experience the highest churn?
5. Which subscription plans have the highest churn?
6. How much monthly recurring revenue is lost to churn?

Notes:
- Churn is calculated only for paying subscribers.
- Users with status = 'trial_expired' are excluded because
  they never became paying customers.
- Trial conversion is analyzed separately in 01_funnel.sql.

Author  : Naveen Raj
===========================================================
*/


-- =========================================================
-- Query 1: Overall Churn Rate
-- =========================================================

SELECT

    COUNT(*) AS paying_customers,

    COUNT(*) FILTER (WHERE status = 'churned') AS churned_customers,

    COUNT(*) FILTER (WHERE status = 'active') AS active_customers,

    ROUND(
        COUNT(*) FILTER (WHERE status = 'churned')
        * 100.0
        / COUNT(*),
        2
    ) AS churn_rate

FROM subscriptions

WHERE status IN ('active', 'churned');



-- =========================================================
-- Query 2: Churn Rate by Acquisition Channel
-- =========================================================

SELECT

    u.acquisition_channel,

    COUNT(DISTINCT s.user_id) AS paying_customers,

    COUNT(DISTINCT s.user_id)
        FILTER (WHERE s.status = 'churned') AS churned_customers,

    COUNT(DISTINCT s.user_id)
        FILTER (WHERE s.status = 'active') AS active_customers,

    ROUND(
        COUNT(DISTINCT s.user_id)
            FILTER (WHERE s.status = 'churned')
        * 100.0
        / COUNT(DISTINCT s.user_id),
        2
    ) AS churn_rate

FROM subscriptions s

JOIN users u
    ON s.user_id = u.user_id

WHERE s.status IN ('active', 'churned')

GROUP BY
    u.acquisition_channel

ORDER BY
    churn_rate DESC;



-- =========================================================
-- Query 3: Churn Rate by Device
-- =========================================================

SELECT

    u.device,

    COUNT(DISTINCT s.user_id) AS paying_customers,

    COUNT(DISTINCT s.user_id)
        FILTER (WHERE s.status = 'churned') AS churned_customers,

    COUNT(DISTINCT s.user_id)
        FILTER (WHERE s.status = 'active') AS active_customers,

    ROUND(
        COUNT(DISTINCT s.user_id)
            FILTER (WHERE s.status = 'churned')
        * 100.0
        / COUNT(DISTINCT s.user_id),
        2
    ) AS churn_rate

FROM subscriptions s

JOIN users u
    ON s.user_id = u.user_id

WHERE s.status IN ('active', 'churned')

GROUP BY
    u.device

ORDER BY
    churn_rate DESC;



-- =========================================================
-- Query 4: Churn Rate by Country
-- =========================================================

SELECT

    COALESCE(u.country, 'Unknown') AS country,

    COUNT(DISTINCT s.user_id) AS paying_customers,

    COUNT(DISTINCT s.user_id)
        FILTER (WHERE s.status = 'churned') AS churned_customers,

    COUNT(DISTINCT s.user_id)
        FILTER (WHERE s.status = 'active') AS active_customers,

    ROUND(
        COUNT(DISTINCT s.user_id)
            FILTER (WHERE s.status = 'churned')
        * 100.0
        / COUNT(DISTINCT s.user_id),
        2
    ) AS churn_rate

FROM subscriptions s

JOIN users u
    ON s.user_id = u.user_id

WHERE s.status IN ('active', 'churned')

GROUP BY
    COALESCE(u.country, 'Unknown')

ORDER BY
    churn_rate DESC;



-- =========================================================
-- Query 5: Churn Rate by Subscription Plan
-- =========================================================

SELECT

    plan,

    COUNT(*) AS paying_customers,

    COUNT(*) FILTER (WHERE status = 'churned') AS churned_customers,

    COUNT(*) FILTER (WHERE status = 'active') AS active_customers,

    ROUND(
        COUNT(*) FILTER (WHERE status = 'churned')
        * 100.0
        / COUNT(*),
        2
    ) AS churn_rate

FROM subscriptions

WHERE status IN ('active', 'churned')

GROUP BY
    plan

ORDER BY
    churn_rate DESC;



-- =========================================================
-- Query 6: Monthly Revenue Lost to Churn
-- =========================================================

SELECT

    COUNT(*) AS churned_customers,

    SUM(monthly_price) AS monthly_revenue_lost,

    ROUND(
        AVG(monthly_price),
        2
    ) AS avg_monthly_revenue_per_churned_customer

FROM subscriptions

WHERE status = 'churned';