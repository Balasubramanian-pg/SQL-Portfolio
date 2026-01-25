## Project Scope

### Electronic Health Records Optimization

This scope document defines exactly what this project is responsible for delivering, where the boundaries are drawn, and why those boundaries exist. The intent is to prevent scope creep, anchor expectations, and make the engineering focus explicit.

This project is deliberately narrow and deep. It optimizes the data foundation of an EHR system, not the entire healthcare technology stack.

![Uploading image.png…]()


## Scope Definition Philosophy

The scope is guided by one principle:

If it does not directly improve data correctness, query performance, or long-term stability of the EHR database, it is out of scope.

This constraint is intentional. EHR systems fail when too many concerns are mixed together. This project isolates the data layer and treats it as a first-class system.

## In-Scope Components

### 1. EHR Data Model Design

The project includes the full design of a patient-centric relational schema.

This covers:

* Core patient entity modeling
* Clinical event tables such as appointments, prescriptions, lab results, and medical records
* Provider reference modeling
* Definition of primary and foreign keys
* Timestamp and lifecycle fields required for auditability

The scope explicitly includes decisions around normalization, relationship cardinality, and data ownership between tables.

What matters here is structural correctness, not completeness of every possible healthcare entity.

### 2. Patient-Centric Query Design

The project includes writing and optimizing SQL queries that reflect real clinical access patterns.

This includes:

* Patient-first retrieval queries
* Multi-table joins that assemble longitudinal patient views
* Queries designed to tolerate missing or partial data
* Clear separation between operational lookups and exploratory queries

The focus is on the queries that are executed most frequently and are most sensitive to latency.

This project does not aim to cover every reporting or analytical query imaginable.

### 3. Performance Optimization at the Data Layer

The project includes performance tuning that is native to **Snowflake** and realistic for production systems.

This includes:

* Designing tables to align with common filter patterns
* Optimizing column selection and predicate usage
* Structuring data to enable efficient micro-partition pruning
* Evaluating query plans and execution behavior

The scope is limited to design-driven optimization. Manual query hacks or one-off tuning for synthetic benchmarks are excluded.

### 4. Data Integrity and Constraint Enforcement

Ensuring correctness is explicitly in scope.

This includes:

* Primary key enforcement
* Foreign key relationships between patients and clinical events
* Prevention of orphaned records
* Consistent identifier usage across tables

The goal is to make invalid states difficult or impossible to represent at the database level.

Business rule enforcement beyond structural integrity is intentionally limited.

### 5. Validation and Quality Checks

The project includes defining and executing validation checks that prove the model behaves as intended.

This includes:

* Referential integrity validation
* Cardinality checks
* Duplicate detection
* Query result consistency checks across joins

Validation is focused on trustworthiness of the data, not statistical correctness or analytics accuracy.

### 6. Scalability and Growth Planning

The scope includes designing for realistic data growth.

This covers:

* Multi-year patient history retention
* Increasing volume of clinical events
* Higher concurrency during peak usage windows

The project explicitly considers how performance degrades over time and designs to avoid nonlinear slowdowns.

## Out-of-Scope Components

### 1. Application Layer Development

This project does not include:

* UI development
* API design
* Backend service logic
* Authentication or authorization flows

The application is treated as a consumer of the database, not part of the solution.

### 2. Healthcare Standards and External Integration

The following are intentionally excluded:

* HL7 or FHIR schema implementation
* Integration with external labs, pharmacies, or insurers
* Real-time messaging systems
* Data ingestion pipelines from third-party systems

The project assumes data arrives correctly formatted and focuses on storage and access once it is in the system.

### 3. Advanced Analytics and Machine Learning

This project does not include:

* Predictive modeling
* Clinical decision support systems
* Risk scoring or AI-driven insights
* Data science workflows

Analytical use cases are acknowledged but not implemented.

### 4. Regulatory Compliance Implementation

While healthcare data is regulated, this project does not implement:

* HIPAA compliance workflows
* Access auditing systems
* Data masking or tokenization strategies
* Legal or regulatory reporting logic

The project focuses on technical correctness, not legal certification.

### 5. Production Operations and Monitoring

The following operational concerns are out of scope:

* Alerting systems
* SLA enforcement
* Cost optimization strategies
* Disaster recovery automation

The project assumes a managed platform environment where these concerns are handled externally.

## Explicit Non-Goals

To avoid ambiguity, this project does not aim to:

* Build a complete EHR product
* Replace existing healthcare software
* Optimize every possible query
* Handle real patient data
* Solve organizational or workflow problems

It solves a specific technical problem: stabilizing and optimizing the EHR data layer.

## Assumptions Underlying the Scope

ASSUMPTION:

* Data is anonymized or synthetic
* Clinical workflows are representative but simplified
* The database is the primary bottleneck, not the application
* Snowflake is the target execution environment

These assumptions keep the scope controlled and the outcomes defensible.

## Scope Summary

In simple terms, this project is responsible for:

* Designing a patient-centric EHR schema
* Making critical patient queries fast and reliable
* Enforcing correctness where it matters most
* Ensuring the system scales as data grows

Everything else is intentionally excluded.

That clarity is what makes the project realistic, maintainable, and explainable in real engineering conversations.

