## MiniSprint 3.1 Planning

**Chicago Crime & Weather 2021 Analysis**
**Sprint Theme: From Prediction Quality to Real-World Validity**

---

### 1. Objective

Test whether the system’s decisions would have **actually mattered**.

Up to now:

* We validated patterns
* We validated predictions
* We built a feedback loop

None of that proves impact.

This sprint asks a harder question:

> If this system were deployed, would it reduce crime or just rearrange attention?

---

### 2. Problem Reframing

The current system optimizes:

* Risk identification
* Resource prioritization

But the real target is:

* **Outcome change**

Reframed problem:

> Do system-driven interventions causally reduce high-impact crime relative to doing nothing or doing the default?

---

### 3. Validation Strategy Overview

Three layers of validation:

1. **Predictive Validity**

   * Are we identifying risk correctly?

2. **Counterfactual Validity**

   * What would have happened without intervention?

3. **Intervention Validity**

   * Does action change outcomes?

Most systems stop at layer 1. This sprint focuses on 2 and 3.

---

### 4. Core Methodologies

#### A. Backtesting with Intervention Simulation

Simulate decisions across 2021:

* For each day:

  * Identify top risk zones
  * Assume intervention applied

Compare:

* Actual crime vs simulated “controlled” baseline

Problem:
No true counterfactual exists

Solution:

* Construct synthetic baselines

---

#### B. Difference-in-Differences (DiD) Framework

Compare:

* **Treatment group**

  * Zones flagged as high-risk

* **Control group**

  * Similar zones not flagged

Measure:

* Change in crime before vs after intervention window

Goal:

* Is there a statistically meaningful divergence?

---

#### C. Matched Pair Analysis

For each high-risk zone:

* Find similar zone (historical crime, volatility, location type)

Compare:

* Outcomes under “treated” vs “untreated” assumption

Purpose:

* Reduce geographic bias

---

#### D. Temporal Displacement Testing

Check:

* Does crime reduce or just shift in time?

Example:

* Intervention reduces evening crime
* But increases late-night crime

---

#### E. Spatial Displacement Testing

Check:

* Does crime move to adjacent communities?

If yes:

* System is redistributing crime, not reducing it

---

### 5. Key Questions

* Are high-risk interventions reducing total crime or just visible crime?
* Does the system perform better than naive strategies:

  * Always patrol top historical hotspots
* Where does intervention fail completely?

---

### 6. Metrics

**Impact Metrics**

* Estimated crime reduction %
* Reduction in violent crime incidents
* Change in peak-day intensity

**Causal Confidence Metrics**

* DiD effect size
* Statistical significance
* Stability across time slices

**System Comparison Metrics**

* System vs baseline strategy performance

---

### 7. Baselines for Comparison

You need something to beat.

**Baseline 1: Static Hotspot Strategy**

* Always deploy to top historical crime zones

**Baseline 2: Random Allocation**

* Random patrol distribution

**Baseline 3: Lag-Only Model**

* Use yesterday’s crime only

If system cannot beat these, it is useless operationally.

---

### 8. Risks & Pitfalls

#### 1. False Causality

Correlation mistaken as intervention effect

Mitigation:

* Use multiple validation methods

---

#### 2. Selection Bias

High-risk zones are inherently different

Mitigation:

* Matching + DiD

---

#### 3. Overfitting Validation

Designing validation that favors the model

Mitigation:

* Blind comparison against baselines

---

### 9. Unorthodox Angle: Negative Testing

Instead of asking:

* “Where does the system work?”

Ask:

* “Where does it fail consistently?”

Focus on:

* Low-density areas
* Sudden spikes
* Edge-case weather conditions

Failure patterns often reveal structural flaws faster than success cases.

---

### 10. Definition of Done

* Backtesting simulation complete
* At least one causal framework implemented (DiD or matching)
* Baseline comparisons established
* Evidence of impact or lack of impact documented

---

### 11. Expected Outcomes

Three possible outcomes:

1. **System Shows Measurable Impact**

   * Proceed to optimization

2. **System Matches Baselines**

   * Model is redundant

3. **System Underperforms**

   * Architecture needs redesign

All three are valuable. Only ambiguity is useless.

---

### 12. Next Step (MiniSprint 3.2 Preview)

* Execute validation experiments
* Quantify causal impact
* Identify where system creates real leverage

---

This sprint is a reality check.

Up to now, the system has been internally consistent.
Now it faces the only question that matters:

Does it change anything outside itself?
