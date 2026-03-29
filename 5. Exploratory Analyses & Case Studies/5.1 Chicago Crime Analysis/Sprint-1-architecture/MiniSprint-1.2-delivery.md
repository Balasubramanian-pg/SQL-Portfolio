## MiniSprint 1.2 Delivery

**Chicago Crime & Weather 2021 Analysis**
**Sprint Theme: First Working Decision System**

---

### 1. Objective

Turn the architecture into a functioning system.
Not perfect. Not complete. But operational.

This sprint delivers a **working risk scoring pipeline + action layer prototype** that can:

* Score crime risk daily
* Rank high-risk zones
* Generate deployable recommendations

---

### 2. What Was Built

#### A. Feature Pipeline (Implemented)

A reproducible pipeline that transforms raw data into model-ready features.

**Inputs Processed**

* Crime data (daily aggregation)
* Weather data (temperature, bands)
* Temporal signals

**Features Generated**

* Lag features:

  * Previous day crime count
  * Rolling 3-day and 7-day averages
* Weather:

  * Temperature band
  * Lagged temperature
* Time:

  * Weekend flag
  * Month

**Interaction Features**

* Temp × Weekend
* Lagged crime × Temp
* Location × Crime baseline

Pipeline is deterministic and rerunnable.

---

#### B. Baseline Risk Model

**Model Type**

* Gradient Boosting (chosen over linear models for interaction capture)

**Prediction Target**

* Binary:

  * 1 = High crime day (top percentile threshold)
  * 0 = Normal day

**Why this framing**

* Operational systems care about spikes, not averages

---

#### C. Risk Scoring Output

Generated daily:

* Risk score per community
* Ranked list of high-risk zones
* Confidence proxy (relative score spread)

**Example Output Structure**

* Austin → 0.87
* Englewood → 0.82
* Loop → 0.76

Interpretation:
Not probability. Priority.

---

#### D. Spatial Prioritization Layer

Introduced **Risk Density Index (RDI)**:

RDI = Risk Score × Historical Crime Intensity

Purpose:

* Avoid over-prioritizing low-volume anomalies
* Balance spike detection with baseline reality

---

#### E. Action Recommendation Engine

Converted scores into decisions:

**Outputs**

* Top N communities requiring patrol intensification
* Suggested time windows:

  * Evenings for violent crime risk
* Crime-type alerts:

  * Violent crime escalation flags

**Example Recommendation**

* Deploy additional patrols in Austin and Englewood
* Focus window: 6 PM – 1 AM
* Expected risk: violent crime surge under hot-weekend condition

---

### 3. Evaluation Results

**Precision@Top Zones**

* Top 10 predicted zones captured majority of high-crime occurrences

**Recall of High-Crime Days**

* Moderate but acceptable for baseline model

**Key Insight**

* Model is better at **ranking risk** than predicting exact counts

This validates design choice.

---

### 4. System Behavior Insights

**1. Lag Features Dominate**

* Yesterday predicts today better than temperature alone

**2. Weather Still Matters**

* Acts as a conditional amplifier
* Strongest when combined with temporal features

**3. Geography is Sticky**

* High-risk zones remain consistently high
* Model must fight this bias to detect emerging risks

---

### 5. Failures & Gaps

**1. Over-Reliance on Historical Patterns**

* Model leans heavily on past crime density
* Risk: blind to emerging hotspots

**2. Binary Framing Loss**

* Treating crime as spike vs normal discards nuance

**3. No True Real-Time Capability**

* Daily batch system limits responsiveness

---

### 6. Unorthodox Additions (Implemented)

#### A. Rule-Based Override Layer

Alongside model predictions:

Trigger conditions:

* Temp > 85°F
* Weekend
* Prior 3-day upward trend

Action:

* Force high-risk classification

Why:

* Handles edge cases where model underestimates spikes

---

#### B. Volatility Signal

Computed:

* Standard deviation of last 7 days crime

Used to:

* Flag unstable regions

Insight:

* Volatility predicts emerging risk better than raw counts

---

### 7. Definition of Done

* End-to-end pipeline functional
* Risk scores generated consistently
* Action recommendations mapped
* Evaluation metrics computed
* Known limitations documented

---

### 8. What This System Is (and Is Not)

**Is**

* A prioritization engine
* A decision support layer
* A foundation for real deployment

**Is Not**

* A causal model
* A real-time system
* A perfect predictor

---

### 9. Next Step (MiniSprint 1.3 Preview)

Now comes pressure testing and refinement:

* Introduce hourly granularity
* Add anomaly detection layer
* Reduce geographic bias
* Improve generalization beyond known hotspots

---

This sprint crosses a line.

The system no longer explains crime.
It makes choices about where attention goes.

That is where models start carrying consequences.
