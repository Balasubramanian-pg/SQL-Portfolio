## MiniSprint 1.1 Planning

**Chicago Crime & Weather 2021 Analysis**
**Sprint Theme: From Insight to Intervention Architecture**

---

### 1. Objective

Stop describing crime. Start shaping response systems.

This sprint designs an **operational architecture** that can:

* Anticipate high-risk conditions
* Allocate resources dynamically
* Reduce response latency
* Convert analysis into deployable decisions

The goal is not a dashboard. It is a **decision engine**.

---

### 2. Problem Reframing

The current framing is weak:

> “How does weather affect crime?”

This is observational and low leverage.

**Reframed Problem:**

> “Given evolving environmental and temporal conditions, how do we optimally deploy limited enforcement and prevention resources to minimize high-impact crime?”

This shifts:

* From correlation → optimization
* From insight → action
* From static → adaptive systems

---

### 3. System Vision

Design a **Crime Risk Orchestration Layer (CROL)**

Core idea:
A lightweight intelligence layer that continuously scores risk and triggers actions.

**Three Pillars:**

1. **Risk Scoring Engine**
2. **Spatial Prioritization Model**
3. **Action Recommendation System**

---

### 4. Key Questions

**Operational**

* Where should patrol density increase today, not historically?
* Which crime types need pre-emptive attention under current conditions?

**System Design**

* What signals are fast-moving vs slow-moving?
* How frequently should risk be recomputed?

**Resource Optimization**

* What is the marginal impact of one additional patrol unit?
* Where does intervention produce the highest reduction per unit effort?

---

### 5. Architecture Blueprint

#### A. Input Layer

Streams and batch inputs:

* Crime history (lag features)
* Weather (current + forecast)
* Temporal signals (hour, weekday, season)
* Optional future inputs:

  * Events
  * Mobility proxies

---

#### B. Feature Layer

**Static Features**

* Community baseline crime rate
* Historical hotspot intensity

**Dynamic Features**

* Temperature band (current + lagged)
* Weekend indicator
* Rolling crime averages (3-day, 7-day)

**Interaction Features**

* Temperature × weekend
* Location × crime type
* Lagged temperature × violent crime

---

#### C. Risk Scoring Engine

Output:

* Risk score per (location, time window)

Approach:

* Start simple: logistic regression or gradient boosting
* Target:

  * Probability of high-crime day
  * Probability of violent crime spike

Key design decision:

* Optimize for **ranking**, not absolute prediction accuracy

---

#### D. Spatial Prioritization

Convert scores into action zones:

* Top N high-risk communities
* Street-level hotspot refinement

Introduce:

* **Risk Density Index (RDI)**
  Crime probability × population/activity proxy

---

#### E. Action Layer

System outputs must be prescriptive:

* Patrol allocation suggestions
* Time-window targeting (e.g., 6 PM–2 AM)
* Crime-type alerts (violent vs property)

No vague outputs. Only decisions.

---

### 6. Analytical Strategy

**Phase 1: Baseline Model**

* Predict high-crime days using:

  * Temperature
  * Lagged crime
  * Weekend flag

**Phase 2: Interaction Modeling**

* Capture compounding effects:

  * Heat + weekend + hotspot

**Phase 3: Ranking Evaluation**

* Precision@K:

  * Are top predicted zones actually high crime?

---

### 7. Metrics That Matter

Forget generic accuracy.

**Operational Metrics**

* Precision@Top 10 hotspots
* Recall of high-crime days
* Reduction potential (simulated)

**System Metrics**

* Latency of scoring
* Stability of predictions (day-to-day volatility)

**Impact Proxy**

* Crimes per patrol unit deployed

---

### 8. Constraints & Tradeoffs

**1. Data Lag**

* Real-time crime data may not exist
  → Use lagged proxies

**2. Overfitting to Geography**

* Model may just memorize hotspots
  → Force temporal features to matter

**3. Interpretability vs Power**

* Black-box models may perform better
  → But decisions require trust

---

### 9. Unorthodox Levers

These are not standard, but high leverage:

**A. Threshold-Based Triggers Instead of Continuous Scores**

* Example:

  * If temp > 80°F AND weekend AND prior 3-day spike → trigger escalation
* Advantage:

  * Transparent, fast, deployable

**B. “Quiet Area Alerting”**

* Focus not just on hotspots
* Detect unusual spikes in normally low-crime areas
* These are often ignored but operationally critical

**C. Volatility as a Signal**

* Stable high-crime zones are predictable
* Sudden variance is where intervention matters most

---

### 10. Definition of Done

* End-to-end architecture defined
* Feature schema finalized
* Modeling approach selected
* Evaluation framework locked
* Clear mapping from model output → action

---

### 11. Next Step (MiniSprint 1.2 Preview)

Build the first working system:

* Feature pipeline implementation
* Baseline model training
* Risk scoring prototype
* Initial action recommendations

---

This sprint draws the machine before building it.
If Sprint 0 mapped the terrain, Sprint 1 decides how to move through it with intent, not hindsight.
