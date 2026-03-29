## Sprint 2 – Implementation

**Chicago Crime & Weather 2021 Analysis**
**Sprint Theme: From Prototype to Operational System**

---

### 1. Objective

Take the fragile prototype from Sprint 1 and harden it into a system that can survive contact with reality.

Key shift:

* From “it works” → “it keeps working under stress”

This sprint focuses on:

* Reliability
* Scalability
* Deployment realism
* Decision latency

---

### 2. Problem Reframing

The real problem is not prediction. It is **operational trust**.

A model that is:

* Slightly wrong but consistent → usable
* Highly accurate but unstable → ignored

So the system must optimize for:

* Stability
* Interpretability
* Repeatability

---

### 3. System Architecture (Implemented)

#### A. Data Pipeline Layer

**Design**

* Batch ingestion (daily)
* Idempotent processing

**Key Components**

* Raw data ingestion
* Validation checks:

  * Missing values
  * Date alignment issues
* Feature recomputation (full refresh, not incremental)

**Why full refresh**

* Avoid drift accumulation
* Easier debugging

Tradeoff:

* Higher compute cost

---

#### B. Feature Store (Lightweight)

A structured layer storing:

* Lag features
* Rolling aggregates
* Temperature bands
* Interaction variables

**Design Choice**

* Precompute everything
* Avoid runtime feature engineering

Result:

* Faster scoring
* Reduced runtime complexity

---

#### C. Model Serving Layer

**Approach**

* Batch scoring once per day

**Output**

* Community-level risk scores
* Ranked priority list

**Stability Enhancements**

* Score smoothing:

  * Blend current prediction with previous day score
* Caps on extreme fluctuations

---

#### D. Rule Engine (Now First-Class Citizen)

Previously a side layer. Now integrated.

**Structure**

* Deterministic triggers
* Transparent thresholds

**Examples**

* Heat spike + weekend → escalation
* Sudden crime jump in low-baseline area → anomaly alert

**Why elevate rules**

* Models fail silently
* Rules fail visibly

---

#### E. Decision Output Layer

Final output is not a dataset. It is an **action sheet**.

**Format**

* Top priority zones
* Time windows
* Risk drivers (top features influencing score)

Example:

* Austin

  * Risk: High
  * Driver: Lagged crime + high temp + weekend
  * Action: Increase patrol density

---

### 4. Key Implementation Decisions

#### 1. Daily Cadence Over Real-Time

Real-time sounds powerful but adds fragility.

Daily cadence chosen because:

* Crime data itself is delayed
* Operational decisions are shift-based

---

#### 2. Ranking Over Regression

Exact crime counts are noisy and misleading.

Ranking:

* Aligns with decision-making
* Reduces sensitivity to noise

---

#### 3. Hybrid Intelligence (Model + Rules)

Pure ML is brittle.

System design:

* Model handles patterns
* Rules handle edge conditions

---

### 5. System Enhancements

#### A. Volatility-Aware Scoring

New feature:

* Penalize overly stable predictions
* Boost zones with rising variance

Effect:

* Better detection of emerging hotspots

---

#### B. Drift Monitoring

Tracked:

* Feature distribution shifts
* Prediction distribution shifts

Trigger:

* If drift exceeds threshold → flag for review

---

#### C. Backtesting Framework

Simulated:

* If system was deployed in 2021

Measured:

* How often top predicted zones aligned with actual spikes

Insight:

* System performs well in high-density areas
* Weaker in low-frequency anomaly detection

---

### 6. Metrics

**Operational**

* Precision@Top 10 zones
* Stability of top rankings (day-to-day overlap)

**System**

* Pipeline success rate
* Data validation failure rate

**Decision Quality Proxy**

* % of high-crime days captured in top predictions

---

### 7. Failure Modes Identified

#### 1. Geographic Entrenchment

Model keeps favoring known hotspots

Mitigation:

* Introduced volatility boost
* Added anomaly triggers

---

#### 2. Weather Overweighting Risk

Extreme temperatures can skew predictions

Mitigation:

* Cap temperature influence
* Require interaction with other signals

---

#### 3. Over-Smoothing

Too much smoothing hides real spikes

Mitigation:

* Dynamic smoothing based on volatility

---

### 8. What Changed from Sprint 1

* Prototype → System
* Scores → Decisions
* Model-centric → Hybrid system
* Static outputs → Monitored pipeline

---

### 9. Definition of Done

* Fully reproducible pipeline
* Stable daily scoring
* Actionable outputs generated
* Drift monitoring active
* Backtesting completed

---

### 10. Next Step (Sprint 3 Preview)

Now the system exists. Next question:

**Does it actually reduce crime?**

Future focus:

* Intervention impact measurement
* A/B testing patrol strategies
* Feedback loops into model

---

This sprint is where theory meets friction.

The system now runs, not just once, but repeatedly.
And repetition is where weak ideas collapse.
