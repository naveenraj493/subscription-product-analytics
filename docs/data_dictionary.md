# Data Dictionary

This document describes the relational schema used throughout the Subscription Product Analytics project. Unless otherwise stated, all tables are stored in PostgreSQL.

---

## users

One row per registered user.

**Grain:** One record per `user_id`.

| Column | Type | Description |
|--------|------|-------------|
| user_id | INTEGER (PK) | Unique user identifier |
| signup_date | DATE | Date the user created an account |
| acquisition_channel | VARCHAR | Marketing acquisition source (Paid Search, Organic, Referral, Social, Email) |
| country | VARCHAR | User country (nullable; ~3% missing values) |
| device | VARCHAR | Signup device (mobile or desktop) |
| pre_engagement_7d | INTEGER | Number of engagement events during the first seven days after signup (pre-experiment covariate) |

---

## subscriptions

One row per user who started a free trial.

**Grain:** One record per `subscription_id`.

| Column | Type | Description |
|--------|------|-------------|
| subscription_id | INTEGER (PK) | Unique subscription identifier |
| user_id | INTEGER (FK → users.user_id) | User who owns the subscription |
| plan | VARCHAR | Subscription plan (Standard or Pro) |
| monthly_price | NUMERIC | Monthly subscription price (Standard = 12, Pro = 24) |
| trial_start_date | DATE | Trial start date |
| paid_start_date | DATE | First successful paid subscription date; NULL if never converted |
| end_date | DATE | Subscription end date; NULL if still active |
| status | VARCHAR | Current subscription status (trial_expired, active, churned) |

---

## events

Application engagement log.

**Grain:** One record per event.

| Column | Type | Description |
|--------|------|-------------|
| event_id | SERIAL (PK) | Surrogate event identifier |
| user_id | INTEGER (FK → users.user_id) | User who generated the event |
| event_date | DATE | Event timestamp (date) |
| event_type | VARCHAR | Event category (open, feature_use, share, settings) |

---

## payments

Monthly subscription payment history.

**Grain:** One record per payment.

| Column | Type | Description |
|--------|------|-------------|
| payment_id | INTEGER (PK) | Unique payment identifier |
| user_id | INTEGER (FK → users.user_id) | Paying customer |
| payment_date | DATE | Payment date |
| amount | NUMERIC | Amount charged |

---

## experiment_assignment

A/B experiment allocation.

**Grain:** One record per user.

| Column | Type | Description |
|--------|------|-------------|
| user_id | INTEGER (PK, FK → users.user_id) | Assigned user |
| experiment | VARCHAR | Experiment identifier (`paywall_onboarding_v1`) |
| variant | VARCHAR | Assigned variant (A = Control, B = Treatment) |
| assignment_date | DATE | Experiment assignment date |

---

# Derived Datasets

| File | Purpose |
|------|----------|
| experiment_dataset.csv | Canonical user-level dataset used for Python A/B analysis (variant, converted, retained, device, plan, monthly_price, pre_engagement_7d, revenue) |
| funnel_stages.csv | Funnel-stage counts exported for Tableau |
| cohort_retention.csv | Cohort retention matrix exported for the Tableau heatmap |