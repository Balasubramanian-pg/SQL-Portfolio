## MiniSprint 2.2 Delivery

**Chicago Crime & Weather 2021 Analysis**
**Sprint Theme: Closing the Loop Between Prediction and Action**

---

### 1. Objective

Move from one-way decision output to a **feedback-driven system**.

Until now:

* System predicts → suggests actions

Now:

* System predicts → actions taken → outcomes measured → system updated

This is the shift from analytics to **adaptive operations**.

---

### 2. What Was Built

#### A. Feedback Capture Layer

A structured mechanism to record what actually happened after recommendations.

**Captured Signals**

* Actual crime count (post-decision window)
* Crime type distribution
* Location-level deviations from prediction
* Intervention proxy:

  * Whether a zone was flagged as high priority

Constraint:
No real patrol deployment data available
→ Using proxy feedback

---

#### B. Prediction vs Outcome Tracking

For each scoring cycle:

* Predicted risk score
* Actual crime outcome
* Error metrics at location level

**New Constructs**

* Overprediction zones
* Underprediction zones

Purpose:
Not accuracy scoring, but **pattern correction**

---

#### C. Performance Layer (Operational Metrics)

Shift away from generic ML metrics.

**Tracked**

* Precision@Top N zones
* Miss rate:

  * High-crime zones not flagged
* Stability under changing conditions

**New Metric Introduced**

* **Decision Efficiency Ratio (DER)**
  High-risk zones correctly identified / Total zones flagged

---

#### D. Adaptive Rule Tuning

Rules are no longer static.

System now:

* Tracks rule-trigger success rate
* Adjusts thresholds based on performance

Example:

* If heat-based trigger overfires → increase threshold
* If anomaly trigger underfires → lower sensitivity

---

#### E. Error Segmentation

Errors classified into categories:

1. **Temporal Errors**

   * Wrong day prediction

2. **Spatial Errors**

   * Right pattern, wrong location

3. **Magnitude Errors**

   * Spike detected but underestimated

Each category feeds different improvements.

---

### 3. Key Findings

#### 1. Model Weakness is System Strength

Where the model fails consistently:

* Low-crime areas with sudden spikes

These become high-value targets for:

* Rule-based anomaly detection

---

#### 2. High Confidence Does Not Equal High Accuracy

Top-ranked zones:

* Often correct directionally
* But overestimate magnitude

Implication:

* Use scores for prioritization, not forecasting

---

#### 3. Feedback Reveals Bias Loops

Model bias discovered:

* Reinforces historically high-crime zones
* Underreacts to emerging areas

Mitigation started:

* Volatility weighting increased
* Exploration logic introduced

---

### 4. Unorthodox Addition: Exploration vs Exploitation Layer

Borrowed from reinforcement learning logic.

System now splits decisions:

* **Exploitation**

  * Focus on known high-risk zones

* **Exploration**

  * Allocate limited attention to uncertain zones

Mechanism:

* Randomized selection among mid-risk zones
* Weighted by volatility

Tradeoff:

* Short-term inefficiency
* Long-term learning gain

---

### 5. System Evolution

From Sprint 2.1 → 2.2:

* Static evaluation → Continuous feedback
* Fixed rules → Adaptive thresholds
* Single loop → Closed loop system

---

### 6. Metrics Snapshot

* Precision@Top zones improved marginally
* Miss rate reduced in volatile areas
* DER stabilized across weeks

More important:

* System behavior became more predictable

---

### 7. Failure Modes

#### 1. Feedback Quality Limitation

* No direct intervention data
  → Cannot measure true causal impact

Workaround:

* Use relative performance comparisons

---

#### 2. Exploration Risk

* May allocate resources to low-risk zones

Mitigation:

* Cap exploration percentage

---

#### 3. Feedback Delay

* Daily cycle limits responsiveness

Future need:

* Shorter feedback loops

---

### 8. Definition of Done

* Feedback loop operational
* Error tracking implemented
* Adaptive rule tuning active
* Exploration mechanism integrated
* Performance metrics evolving over time

---

### 9. What This System Has Become

Not a model. Not a dashboard.

It is now a **learning system**:

* It observes
* It acts
* It evaluates
* It adjusts

---

### 10. Next Step (MiniSprint 2.3 Preview)

Push toward **causal impact and intervention design**:

* Introduce quasi-experimental methods
* Measure effect of actions vs no-action
* Refine allocation strategy based on impact, not prediction

---

At this stage, the system has a memory.

And once a system remembers its mistakes,
it stops being a tool and starts behaving like an operator.
