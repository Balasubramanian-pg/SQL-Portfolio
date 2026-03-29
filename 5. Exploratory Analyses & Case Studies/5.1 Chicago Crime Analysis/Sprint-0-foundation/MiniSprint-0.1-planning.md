## MiniSprint 0.1 Planning

**Chicago Crime & Weather 2021 Analysis**

### 1. Objective

Establish the analytical foundation for exploring relationships between crime patterns and weather conditions in Chicago during 2021.
Focus is not prediction yet, but structural understanding: distribution, anomalies, and signal candidates.

---

### 2. Key Questions

This sprint is about framing the battlefield correctly.

**Descriptive Layer**

* What is the baseline crime volume and distribution?
* Which geographies dominate crime occurrence?
* How does crime vary across time (month, weekday, season)?

**Behavioral Layer**

* Do crime patterns shift with temperature extremes?
* Are certain crime types more sensitive to environmental conditions?

**Anomaly Layer**

* What explains spikes like the June–July homicide streak?
* Are hotspots persistent or transient?

---

### 3. Hypotheses (First Principles Driven)

1. **Temperature–Crime Elasticity**

   * Warmer temperatures increase outdoor activity → higher interaction density → higher crime probability.
   * Expect non-linear behavior, not monotonic.

2. **Weekend Effect**

   * Social aggregation peaks → higher assault/battery rates.

3. **Geospatial Concentration**

   * Crime is not evenly distributed.
   * A few communities (e.g., Austin) dominate volume due to structural factors.

4. **Street-Level Clustering**

   * High-footfall commercial corridors act as crime attractors.

---

### 4. Data Scope

**Primary Datasets**

* Chicago Crime Data (2021)
* Weather Data (Daily granularity)

**Key Fields**

* Crime: type, date, location, arrest, domestic flag
* Weather: temperature (min, max, avg)

**Derived Features**

* Month, weekday, seasonality buckets
* Temperature bands (cold, moderate, hot)
* Rolling averages for trend smoothing

---

### 5. Analytical Approach

**Phase 1: Structural Profiling**

* Frequency distributions (crime types, locations)
* Temporal aggregation (monthly, weekday)

**Phase 2: Spatial Analysis**

* Community-level crime density
* Street-level hotspot identification

**Phase 3: Temporal Dynamics**

* Trend lines across months
* Spike detection (e.g., homicide streak)

**Phase 4: Weather Correlation**

* Map crime counts against temperature ranges
* Identify thresholds rather than linear relationships

---

### 6. Metrics & KPIs

**Core Metrics**

* Total crime count
* Crime count by type
* Crime count by location

**Derived Metrics**

* Crime per day
* Crime per temperature band
* Arrest rate by crime type
* Domestic violence proportion

**Signal Metrics**

* Peak crime day
* Longest continuous homicide streak
* Crime variance across months

---

### 7. Expected Outputs

* Cleaned and structured dataset
* Aggregated summary tables
* Initial visualizations:

  * Monthly crime trends
  * Crime by community
  * Temperature vs crime scatter
* Insight summary (already drafted)

---

### 8. Risks & Failure Modes

* **Correlation trap**: Temperature may correlate but not cause crime spikes.
* **Aggregation bias**: Monthly views may hide daily volatility.
* **Data imbalance**: High-frequency crimes dominate patterns.

Mitigation:

* Use multi-level aggregation
* Validate patterns across slices
* Avoid causal claims at this stage

---

### 9. Definition of Done

* Dataset validated and cleaned
* All core aggregations reproducible
* Key patterns identified and documented
* No unresolved data integrity issues

---

### 10. Next Step (MiniSprint 0.2 Preview)

Shift from descriptive to **relationship modeling**:

* Temperature band segmentation
* Crime-type sensitivity analysis
* Early feature engineering for predictive modeling

---

This sprint is about building a map, not drawing conclusions. The terrain is now visible. The next sprint decides where to dig.
