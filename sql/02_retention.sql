/*
===========================================================
Project : Subscription Product Analytics

File    : 02_retention.sql

Purpose :
Build a monthly cohort retention analysis using recurring
payment activity.

Business Questions:
1. When did each paying user first convert?
2. How many months after conversion did users remain active?
3. What is the monthly retention rate for each cohort?

Notes:
- Cohorts are defined by the user's first payment month.
- Output is intentionally kept in long format for Tableau.
- The final incomplete cohort (2025-01) is excluded to
  avoid skewing retention analysis.

Author  : Naveen Raj
===========================================================
*/


-- =========================================================
-- Query 1: Assign Users to a Cohort
-- =========================================================
-- Each user's cohort is the month of their first payment.

WITH user_cohorts AS (

    SELECT
        user_id,
        DATE_TRUNC('month', MIN(payment_date))::DATE AS cohort_month

    FROM payments

    GROUP BY user_id

)

SELECT
    user_id,
    cohort_month

FROM user_cohorts

ORDER BY
    cohort_month,
    user_id;



-- =========================================================
-- Query 2: Calculate Months Since Cohort
-- =========================================================
-- Determine how many months after the first payment
-- each payment occurred.

WITH user_cohorts AS (

    SELECT
        user_id,
        DATE_TRUNC('month', MIN(payment_date))::DATE AS cohort_month

    FROM payments

    GROUP BY user_id

),

cohort_activity AS (

    SELECT

        uc.user_id,

        uc.cohort_month,

        DATE_TRUNC('month', p.payment_date)::DATE AS payment_month,

        (
            EXTRACT(YEAR FROM AGE(DATE_TRUNC('month', p.payment_date), uc.cohort_month)) * 12
            +
            EXTRACT(MONTH FROM AGE(DATE_TRUNC('month', p.payment_date), uc.cohort_month))
        ) AS month_number

    FROM user_cohorts uc

    JOIN payments p
        ON uc.user_id = p.user_id

)

SELECT
    user_id,
    cohort_month,
    payment_month,
    month_number

FROM cohort_activity

ORDER BY
    cohort_month,
    user_id,
    month_number;



-- =========================================================
-- Query 3: Monthly Cohort Retention
-- =========================================================
-- Calculates retention for every cohort by month.
-- Expected validation:
-- Every cohort should have 100% retention at Month 0.

WITH user_cohorts AS (

    SELECT
        user_id,
        DATE_TRUNC('month', MIN(payment_date))::DATE AS cohort_month

    FROM payments

    GROUP BY user_id

),

cohort_activity AS (

    SELECT

        uc.user_id,

        uc.cohort_month,

        (
            EXTRACT(YEAR FROM AGE(DATE_TRUNC('month', p.payment_date), uc.cohort_month)) * 12
            +
            EXTRACT(MONTH FROM AGE(DATE_TRUNC('month', p.payment_date), uc.cohort_month))
        ) AS month_number

    FROM user_cohorts uc

    JOIN payments p
        ON uc.user_id = p.user_id

),

cohort_size AS (

    SELECT

        cohort_month,

        COUNT(DISTINCT user_id) AS cohort_size

    FROM user_cohorts

    GROUP BY cohort_month

)

SELECT

    ca.cohort_month,

    ca.month_number,

    COUNT(DISTINCT ca.user_id) AS active_users,

    cs.cohort_size,

    ROUND(
        COUNT(DISTINCT ca.user_id) * 100.0
        / cs.cohort_size,
        2
    ) AS retention_rate

FROM cohort_activity ca

JOIN cohort_size cs
    ON ca.cohort_month = cs.cohort_month

WHERE ca.cohort_month < DATE '2025-01-01'

GROUP BY

    ca.cohort_month,

    ca.month_number,

    cs.cohort_size

ORDER BY

    ca.cohort_month,

    ca.month_number;