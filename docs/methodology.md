# Methodology

This document describes the analytical methodology used throughout the Subscription Product Analytics project.

---

# Data Generation

The project uses a synthetic subscription SaaS dataset containing approximately 40,000 users.

Rather than reproducing a real company's proprietary data, the dataset was generated to simulate realistic subscription behavior while providing a known analytical ground truth for validating the A/B experiment.

Simulation parameters include:

- Signup timing
- Acquisition channel quality
- Device mix
- Trial conversion
- Customer churn
- Experiment assignment
- Treatment effect

This approach enables complete validation of the analytical workflow while avoiding privacy concerns associated with production customer data.

---

# SQL Analysis

## Funnel Analysis

Subscription conversion was measured using user-level intent-to-treat denominators.

Conversion rates were calculated from:

- All signups for Signup → Paid conversion
- All trial starters for Trial → Paid conversion

Using intent-to-treat denominators avoids survivorship bias and produces unbiased conversion estimates.

---

## Cohort Retention

Customers were assigned to cohorts based on their first paid month.

Monthly retention was calculated as the percentage of each cohort that remained active after N months.

The analysis was implemented using Common Table Expressions (CTEs), date arithmetic, and window functions before being exported to Tableau.

---

## Churn

Churn was calculated only among paying customers.

Users whose trial expired without converting were excluded because they never became paying customers.

Lost Monthly Recurring Revenue (MRR) equals the sum of monthly subscription prices associated with churned customers.

---

## Validation

Every SQL query was independently validated against the underlying data before being incorporated into Tableau dashboards.

---

# A/B Experiment

The experiment (`paywall_onboarding_v1`) randomly assigned users to:

- Variant A (Control)
- Variant B (Treatment)

Analysis followed a validity-first framework.

## 1. Sample Ratio Mismatch (SRM)

A chi-square goodness-of-fit test verified that traffic allocation matched the intended 50/50 split.

A significance level of α = 0.001 was used.

Any SRM failure would invalidate interpretation of the experiment regardless of outcome.

---

## 2. Primary Metric

Paid conversion rate.

Statistical significance was evaluated using a two-sided two-proportion z-test.

---

## 3. Effect Size

A 95% confidence interval was calculated for the absolute conversion lift.

---

## 4. Segment Analysis

Treatment effects were evaluated separately for:

- Mobile
- Desktop

---

## 5. Guardrail Metrics

To ensure conversion gains did not reduce downstream value, guardrail metrics included:

- Revenue per User (ARPU)
- Customer retention

---

## Result

Variant B increased paid conversion from **17.4% to 20.2%**.

- Absolute lift: **+2.9 percentage points**
- Relative lift: **+16%**
- 95% CI: **[+2.1 pp, +3.6 pp]**
- **p < 0.001**

The largest improvement occurred on mobile devices.

Revenue per User also increased, indicating no evidence of revenue regression.

Based on these results, Variant B is recommended for production rollout.

---

# Limitations

This project uses synthetic data generated to model realistic subscription behavior while validating the analytical workflow against a known experimental effect.

The churn model intentionally treats churn as a one-time event at first renewal, causing cohort retention to plateau after the initial decline. On production data, retention would typically decline more gradually.

Outside the randomized A/B experiment, findings describe associations rather than causal relationships.

Although the dataset contains a pre-experiment engagement covariate (`pre_engagement_7d`), no variance reduction techniques (e.g., CUPED) were applied. This represents a potential extension for future work.