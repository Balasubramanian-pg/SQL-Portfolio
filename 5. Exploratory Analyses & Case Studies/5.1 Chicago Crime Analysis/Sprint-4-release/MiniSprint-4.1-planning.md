## MiniSprint 4.1 Planning

**Chicago Crime & Weather 2021 Analysis**
**Sprint Theme: From System to Deployable Product**

---

### 1. Objective

Stop building models. Start shipping something that gets used.

Up to now:

* The system predicts
* The system ranks
* The system learns

But nobody is accountable to it.

This sprint designs a **deployable decision product** that:

* Fits into real workflows
* Forces interaction
* Survives human skepticism

---

### 2. Problem Reframing

The system does not fail because of poor modeling.
It fails because **no one is obligated to act on it**.

Reframed problem:

> How do you embed this system into decision-making such that ignoring it becomes harder than using it?

---

### 3. Product Definition

Not a dashboard. Dashboards get ignored.

Design a **Daily Crime Risk Brief (DCRB)**

A compact, opinionated artifact that:

* Tells you where to act
* Tells you why
* Tells you when

Think:

* Less analytics tool
* More operational directive

---

### 4. Core Components

#### A. Daily Risk Brief

Delivered once per day before operational planning.

**Structure**

* Top 5 priority zones
* Time windows of concern
* Primary risk drivers
* Confidence level

Example:

* Austin

  * Risk: High
  * Window: 6 PM – 1 AM
  * Drivers: Heat + weekend + recent spike

---

#### B. Action Playbook

Predictions are useless without predefined responses.

For each risk pattern:

* Suggested patrol strategy
* Resource allocation guidance
* Escalation rules

Example:

* High volatility zone:

  * Increase patrol frequency
  * Shorter patrol loops
* Stable hotspot:

  * Maintain baseline coverage

---

#### C. Alert Layer

Triggered only for edge cases:

* Extreme temperature + crime spike
* Unusual activity in low-crime zone

Design principle:

* Alerts must be rare
* If everything is urgent, nothing is

---

#### D. Explanation Layer

Every recommendation must answer:

* Why this zone?
* Why today?

Use:

* Top contributing features
* Simple reasoning, not model internals

---

### 5. Delivery Mechanism

Options considered:

* Dashboard
* Email
* API

**Chosen approach:**

* Daily structured output (email or report format)

Reason:

* Fits existing workflows
* No learning curve
* Forces visibility

---

### 6. Behavioral Design

The real challenge is human, not technical.

#### A. Friction Engineering

Make ignoring costly:

* Require acknowledgment of brief
* Track whether recommendations were followed

---

#### B. Trust Calibration

Do not oversell:

* Show confidence levels
* Highlight uncertainty explicitly

---

#### C. Consistency Over Brilliance

Users trust systems that:

* Behave predictably
* Do not change logic daily

---

### 7. Metrics for This Sprint

Not model metrics.

**Adoption Metrics**

* % of days brief is reviewed
* % of recommendations acknowledged

**Behavioral Metrics**

* Alignment between recommendations and actions taken

**Outcome Proxy**

* Change in crime patterns in acted vs ignored zones

---

### 8. Constraints

#### 1. No Direct User Feedback Loop

* Cannot yet measure real user decisions

---

#### 2. Limited Intervention Data

* Still relying on proxy outcomes

---

#### 3. Over-Precision Risk

* Too much detail reduces usability

---

### 9. Unorthodox Moves

#### A. Force Ranking Only

No full list of zones.

* Only top priorities shown
* Everything else hidden

Effect:

* Forces focus
* Prevents analysis paralysis

---

#### B. Kill the Score

Do not show numeric risk scores.

Show:

* High / Medium / Low

Reason:

* Numbers create false precision
* Decisions need clarity, not decimals

---

#### C. Contrarian Signal

Include:

* “Unexpected Low Risk” zones

Purpose:

* Prevent over-deployment
* Build trust in system restraint

---

### 10. Definition of Done

* Daily Risk Brief format finalized
* Action playbook defined
* Output pipeline integrated with product layer
* Explanation layer implemented
* Delivery mechanism established

---

### 11. What This Sprint Changes

Before:

* System produces insights

After:

* System produces decisions people must react to

---

### 12. Next Step (MiniSprint 4.2 Preview)

* Deliver first live version of the Daily Risk Brief
* Simulate user interaction
* Measure adoption and friction

---

This sprint is where the system grows a spine.

If nobody changes behavior because of it,
then everything built so far is just well-organized hindsight.
