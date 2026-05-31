# Project Chaos and Cure

## Reconstructing Reality from Healthcare EMR and Claims Data

Most healthcare SQL projects are fake-clean.

A few joins.
Some dashboards.
Maybe a star schema.

That is not what this is.

This project simulates the actual operational chaos inside healthcare data systems where biological reality, financial systems, provider behavior, payer incentives, and broken backend architecture constantly collide with each other.

The goal is not to generate random rows.

The goal is to reconstruct reality from fragmented, corrupted, disconnected healthcare systems.

This repository contains a production-scale Synthetic Healthcare Ecosystem Generator along with a complete end-to-end Data Engineering pipeline capable of generating nearly 2.9 million rows of highly interdependent healthcare data across two disconnected systems:

* Clinical EMR systems
* Financial Claims/PBM systems

The generated data intentionally contains:

* identity fragmentation
* timestamp conflicts
* unit conversion errors
* behavioral inconsistencies
* provider-level referral dynamics
* payer-induced treatment failures
* operational leakage
* biologically constrained anomalies

This is designed to mirror what healthcare analytics teams actually deal with in production environments.

Not textbook healthcare data.

Real healthcare data.

## Architecture Philosophy

The entire project follows Medallion Architecture principles and is structured for implementation inside modern analytics stacks like:

* dbt
* Snowflake
* Databricks
* PostgreSQL
* BigQuery

### Bronze Layer: Raw Operational Chaos

Disconnected CSV files representing independent healthcare systems with no guaranteed interoperability.

Problems intentionally embedded:

* missing patient identifiers
* conflicting demographic updates
* raw ICD/NDC operational coding
* null explosions
* inconsistent timestamps
* duplicate identities
* broken encounter sequencing

### Silver Layer: Clinical Data Reconstruction

This layer focuses on repairing operational damage.

Core engineering tasks include:

* probabilistic identity resolution (MPI)
* temporal correction
* unit normalization
* anomaly quarantine pipelines
* survivorship logic
* referential reconstruction
* operational deduplication

This is where fragmented records become clinically interpretable entities.

### Gold Layer: Analytics-Ready Intelligence

The final layer converts reconstructed healthcare activity into business-grade analytical models inspired by OMOP-style healthcare warehousing.

Includes entities such as:

* PERSON
* CONDITION_OCCURRENCE
* DRUG_EXPOSURE
* ENCOUNTER_FACT
* PROVIDER_NETWORK
* THERAPY_LIFECYCLE

This layer is designed for:

* BI dashboards
* provider analytics
* payer intelligence
* treatment adherence analysis
* commercialization analytics
* healthcare fraud detection
* patient journey reconstruction

# Synthetic Ecosystem Structure

## System A: Clinical EMR

### 01_emr_patients_raw.csv

Demographic instability, typographical corruption, identity fragmentation, null-heavy patient profiles.

### 03_emr_encounters_raw.csv

Clinical visits, diagnosis capture, provider relationships, vitals, encounter chronology.

### 04_emr_labs_raw.csv

Biometric distributions, disease progression patterns, intentional unit-entry failures, physiological variance.

### 05_emr_rx_raw.csv

Prescription intent data including dosage-default failures and provider prescribing behavior.

## System B: Claims/PBM

### 02_claims_patients_raw.csv

Enrollment-side demographic drift caused by marriage, relocation, insurance transitions, payer-side updates.

### 06_claims_dispenses_raw.csv

Financial fulfillment behavior including:

* copays
* deductibles
* abandonment
* refill gaps
* mail-order fulfillment
* payer restrictions

## Master Reference Data

### 00_provider_master.csv

Healthcare provider network graph including:

* specialty hierarchy
* referral structures
* KOL influence propagation
* centrality scoring

# Hidden Analytical Narratives

Inside the dataset are 27 embedded healthcare scenarios that require advanced SQL and data engineering logic to uncover.

These are not isolated rows.

They are causal systems.

Solving them requires:

* window functions
* recursive logic
* graph traversal
* temporal joins
* probabilistic matching
* geospatial reasoning
* longitudinal patient tracking

## Example Use Cases

### The Ghost Clinic

Detect an outpatient clinic generating abnormal Schedule II cash-pay volume with impossible patient travel patterns and zero supporting clinical evidence.

### Q1 Deductible Abandonment

Prove that medication adherence collapses during deductible resets specifically among low-income ZIP populations.

### KOL Network Contagion

Reconstruct provider referral graphs to identify how therapy adoption spreads outward from a small cluster of influential physicians.

### Polypharmacy Tipping Point

Identify elderly patients simultaneously managed by disconnected specialists whose medication burden eventually triggers ER admissions for fracture events.

### Newborn Identity Crisis

Build MPI logic capable of linking neonatal EMR records with delayed Medicaid enrollment records despite incomplete identifiers.

### Step Therapy Death Spiral

Quantify downstream hospitalization costs caused by aggressive payer formulary restrictions.

# Biological and Operational Rule Engine

The dataset generator enforces hard healthcare realism constraints.

This is not unrestricted random generation.

Examples include:

* systolic BP must remain physiologically higher than diastolic BP
* patient encounters terminate after mortality events
* male patients cannot receive biologically impossible diagnoses
* pediatric growth trajectories follow age-constrained curves
* dispense events cannot violate temporal prescription logic beyond allowed operational glitch thresholds

The generator intentionally balances:

* realism
* operational corruption
* analytical recoverability

# Reporting and Validation Layer

The reporting framework validates more than row-level quality.

It evaluates systemic realism.

The pipeline includes:

* anomaly detection
* distribution validation
* synthetic detectability analysis
* temporal continuity scoring
* hierarchy consistency validation
* ranking volatility analysis
* entropy profiling
* dashboard realism testing
* correlation instability checks
* outlier analysis
* Seaborn distribution visualization
* longitudinal trend diagnostics

The distinction matters.

Most synthetic healthcare datasets fail because they only imitate schema structure.

This framework attempts to imitate behavior.

That is the difference between:
“random mock data”
and
“commercial simulation-grade synthetic healthcare ecosystems.”

# Deployment

## Dataset Generation

Requirements:

```bash
pip install pandas numpy faker networkx
```

Execution:

```bash
python generate_healthcare_chaos.py
```

Generation characteristics:

* ~2.9 million rows
* ~400MB output
* ~2–5 minute runtime
* ~8GB RAM usage

## Warehouse Ingestion

Load all generated CSVs into a raw bronze schema inside:

* Snowflake
* PostgreSQL
* BigQuery
* Databricks

## Engineering Objectives

Core implementation tasks include:

* EMR ↔ Claims identity resolution
* temporal leakage correction
* OMOP dimensional mapping
* provider graph reconstruction
* longitudinal therapy tracking
* hidden narrative extraction
* operational anomaly isolation

# Technology Stack

## Data Generation

* Python
* Pandas
* NumPy
* Faker
* NetworkX

## Data Engineering

* dbt
* Advanced SQL

## Warehousing

* Snowflake
* PostgreSQL
* Databricks
* BigQuery

