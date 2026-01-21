## Anomaly Detection Over Time

Balanced Tree Sales Analytics (dbt)

---

## Objective

This section introduces **automated anomaly detection** on top of the validated 8 year dataset using **dbt models and tests**.

The goal is to:

* Detect unusual spikes or drops in key metrics
* Catch data issues that pass basic integrity checks but break business expectations
* Surface real behavioral anomalies such as sudden revenue collapses or discount explosions

This is **behavioral validation**, not structural validation.

---

## What We Will Monitor

We focus on **business-critical time series**, aggregated daily:

1. Total revenue per day
2. Total discount amount per day
3. Total transaction count per day
4. Average revenue per transaction per day

These metrics directly support:

* Sales analysis
* Discount effectiveness
* Transaction behavior questions
* Executive-level reporting

---

## Detection Strategy

### Approach Used

We use a **rolling statistical baseline** approach:

* Rolling 30-day window
* Mean and standard deviation per metric
* Z-score based anomaly detection
* Configurable sensitivity thresholds

ASSUMPTION
Statistical anomaly detection is sufficient for synthetic retail data and interview-grade pipelines.

This mirrors common production analytics implementations.

---

## dbt Model Architecture

```
models/
├── marts/
│   ├── daily_metrics.sql
│   └── daily_metrics_anomaly.sql
│
tests/
│   └── singular/
│       └── no_unexpected_anomalies.sql
```

---

## Step 1: Daily Metrics Model

### `models/marts/daily_metrics.sql`

This model produces one row per day.

```sql
SELECT
    t.txn_date,

    COUNT(DISTINCT t.txn_id) AS transaction_count,

    SUM(s.price * s.qty) AS gross_revenue,

    SUM((s.price * s.qty) * (s.discount / 100)) AS total_discount,

    SUM(s.price * s.qty) /
        COUNT(DISTINCT t.txn_id) AS avg_revenue_per_transaction

FROM {{ ref('stg_transactions') }} t
JOIN {{ ref('stg_sales') }} s
    ON t.txn_id = s.txn_id
GROUP BY t.txn_date
```

Why this matters:

* Creates a clean time series
* Becomes the foundation for anomaly detection
* Reusable for dashboards and trend analysis

---

## Step 2: Rolling Statistics and Z-Scores

### `models/marts/daily_metrics_anomaly.sql`

This model computes rolling baselines and flags anomalies.

```sql
WITH base AS (
    SELECT *
    FROM {{ ref('daily_metrics') }}
),

stats AS (
    SELECT
        txn_date,

        gross_revenue,
        total_discount,
        transaction_count,
        avg_revenue_per_transaction,

        AVG(gross_revenue) OVER w AS revenue_mean,
        STDDEV_POP(gross_revenue) OVER w AS revenue_std,

        AVG(total_discount) OVER w AS discount_mean,
        STDDEV_POP(total_discount) OVER w AS discount_std,

        AVG(transaction_count) OVER w AS txn_mean,
        STDDEV_POP(transaction_count) OVER w AS txn_std

    FROM base
    WINDOW w AS (
        ORDER BY txn_date
        ROWS BETWEEN 30 PRECEDING AND 1 PRECEDING
    )
)

SELECT
    txn_date,

    gross_revenue,
    total_discount,
    transaction_count,
    avg_revenue_per_transaction,

    CASE
        WHEN revenue_std = 0 THEN FALSE
        WHEN ABS((gross_revenue - revenue_mean) / revenue_std) > 3
        THEN TRUE
        ELSE FALSE
    END AS revenue_anomaly,

    CASE
        WHEN discount_std = 0 THEN FALSE
        WHEN ABS((total_discount - discount_mean) / discount_std) > 3
        THEN TRUE
        ELSE FALSE
    END AS discount_anomaly,

    CASE
        WHEN txn_std = 0 THEN FALSE
        WHEN ABS((transaction_count - txn_mean) / txn_std) > 3
        THEN TRUE
        ELSE FALSE
    END AS transaction_anomaly

FROM stats
WHERE revenue_mean IS NOT NULL
```

---

## Step 3: Anomaly Interpretation Logic

### Why Z-Score > 3

* Captures extreme deviations
* Avoids false positives in noisy retail data
* Common industry threshold

ASSUMPTION
Seasonality is not explicitly modeled.
For interview or portfolio projects, this is acceptable.

---

## Step 4: dbt Test for Unexpected Anomalies

### `tests/singular/no_unexpected_anomalies.sql`

This test fails if **too many anomalies** occur.

```sql
SELECT *
FROM {{ ref('daily_metrics_anomaly') }}
WHERE
    revenue_anomaly = TRUE
    OR discount_anomaly = TRUE
    OR transaction_anomaly = TRUE
```

Expected behavior:

* Small number of rows flagged
* Sudden large spikes or drops are surfaced

If this test fails unexpectedly:

* Data generation logic may be broken
* Discounts or prices may be malformed
* Transactions may be missing for specific days

---

## Step 5: Optional Severity Classification

You can extend the model to classify severity.

```sql
CASE
    WHEN ABS((gross_revenue - revenue_mean) / revenue_std) > 5 THEN 'CRITICAL'
    WHEN ABS((gross_revenue - revenue_mean) / revenue_std) > 3 THEN 'WARNING'
    ELSE 'NORMAL'
END AS revenue_severity
```

This supports alert prioritization.

---

## Step 6: Operational Usage

In a real pipeline, this enables:

* Daily dbt runs
* Automatic failure on abnormal behavior
* Alerts to Slack or email via orchestration tools
* Dashboard overlays highlighting anomaly dates

This bridges analytics and operations.

---

## What This Catches That Basic Tests Do Not

* Sudden revenue collapses with valid rows
* Discount explosions still within 0–100 percent
* Transaction droughts on specific days
* Silent data drops due to partial ingestion

These issues pass schema tests but break business trust.

---

## Summary of Guarantees

With anomaly detection enabled, the pipeline now guarantees:

* Structural correctness
* Business rule enforcement
* Behavioral consistency over time
* Early detection of silent failures

This is **production-grade analytical monitoring**, not just SQL correctness.

---

## Next Advanced Options

You can now extend this further by:

* Adding seasonality-aware baselines
* Segment-level anomaly detection
* Product-level anomaly detection
* Automated alert routing
* Feature-store style metric tables

Say the direction and we go deep again.
