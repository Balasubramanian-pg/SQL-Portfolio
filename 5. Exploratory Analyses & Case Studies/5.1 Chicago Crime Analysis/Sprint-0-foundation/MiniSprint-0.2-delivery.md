## MiniSprint 0.2 Delivery

**Chicago Crime & Weather 2021 Analysis**

### 1. Objective

Move from structural understanding to relationship discovery.
This sprint tests whether weather, especially temperature, meaningfully influences crime behavior across types, locations, and time.

---

### 2. What Was Delivered

**Data Enhancements**

* Temperature banding implemented:

  * Cold: < 40°F
  * Moderate: 40°F–75°F
  * Hot: > 75°F
* Time features enriched:

  * Week segments (weekday vs weekend)
  * Seasonal buckets

**Integrated Dataset**

* Crime and weather joined at daily granularity
* No missing joins for core analysis window

---

### 3. Core Analyses Performed

#### A. Temperature vs Crime Volume

* Crime counts mapped across temperature bands
* Identified non-linear pattern:

  * Moderate to hot temperatures show increased crime activity
  * Extreme cold suppresses crime volume

#### B. Crime Type Sensitivity

* Violent crimes (battery, assault, homicide) show higher sensitivity to temperature shifts
* Property crimes (theft, burglary) less temperature-dependent, more location-driven

#### C. Weekend Amplification

* Weekend crime consistently higher across all temperature bands
* Interaction effect observed:

  * Hot + Weekend = peak crime density

#### D. Temporal Micro-Trends

* Daily-level analysis reveals volatility hidden in monthly aggregates
* June–July homicide streak aligns with sustained high-temperature window

---

### 4. Key Findings

**1. Temperature Acts as a Multiplier, Not a Root Cause**

* Heat increases probability of interaction, not intent
* Crime rises where people converge, not simply where it is hot

**2. Non-Linearity Confirmed**

* Crime does not increase uniformly with temperature
* Threshold effect observed around ~75°F

**3. Violent Crime is More Climate-Sensitive**

* Suggests behavioral escalation tied to environmental stress and exposure

**4. Spatial Dominance Persists**

* High-crime communities remain dominant regardless of weather
* Weather amplifies existing patterns, does not redistribute them

---

### 5. Metrics Produced

* Crime count by temperature band
* Crime type distribution across temperature bands
* Weekend vs weekday crime ratio
* Daily crime variance
* Homicide streak duration and alignment with temperature

---

### 6. Visual Artifacts Generated

* Temperature band vs crime volume bar charts
* Daily crime trend lines
* Crime type distribution heatmaps
* Weekend vs weekday comparison plots

---

### 7. Interpretation Layer

This sprint rejects a naive assumption:
"Hot weather causes crime."

More precise framing:

* Weather modulates opportunity structures
* Crime emerges from interaction density + existing socio-spatial conditions

Think of temperature as a volume knob, not a composer.

---

### 8. Risks & Limitations

* **Confounding Variables Not Modeled**

  * Policing intensity
  * Events, holidays, mobility patterns

* **Single-Year Bias**

  * 2021 may contain anomalies (pandemic effects, behavioral shifts)

* **Granularity Constraint**

  * Daily aggregation may still mask intra-day effects (night vs day)

---

### 9. Definition of Done

* Temperature segmentation validated
* Relationship patterns identified and documented
* No major data inconsistencies
* Visual and metric outputs reproducible

---

### 10. Next Step (MiniSprint 0.3 Preview)

Transition into **causal probing and feature engineering**:

* Introduce lag variables (previous day temperature impact)
* Interaction terms (temperature × weekend × location)
* Begin predictive modeling baseline

---

At this point, the analysis has moved from map-making to pattern detection.
The next sprint asks a harder question: which of these patterns actually hold under pressure.
