# Market Lift Analytics Platform

## 1. Introduction

Market Lift analytics sits at the intersection of commercial strategy, data engineering, and business intelligence. This project formalizes a complete analytical framework to quantify how marketing interventions influence sales performance across geographies, products, and time. The focus is not operational reporting but analytical truth. The system is designed to answer a deceptively simple question that most organizations struggle to answer with confidence: did the campaign actually work?

Unlike transactional systems that record what happened, this project is concerned with why it happened. It separates organic demand from campaign-driven demand and makes that distinction auditable, explainable, and measurable at scale.

This document is a full project bible. It explains the business problem, analytical philosophy, data modeling approach, governance rules, metrics definitions, and downstream analytical use cases. It intentionally excludes data generation or scripting logic and focuses entirely on the project as a real-world analytical system.

Relevant visual reference:

<img width="1170" height="780" alt="image" src="https://github.com/user-attachments/assets/96b7ac13-9aa7-4089-ac97-46c9ed5a9948" />

## 2. Business Problem Statement

Marketing spend is one of the largest discretionary expenses for consumer and healthcare-adjacent organizations. Despite this, most companies rely on proxy metrics such as impressions, clicks, or survey recall to judge effectiveness. These metrics do not answer the core financial question: how many additional units were sold because of this campaign?

The Market Lift project addresses the following core business problems:

* Inability to distinguish baseline demand from campaign-influenced demand
* Overreliance on vanity metrics instead of revenue-linked outcomes
* Fragmented reporting across regions, channels, and products
* Lack of historical comparability between campaigns
* No standardized definition of lift across the organization

By formalizing lift as a first-class analytical metric, this project enables leadership to evaluate campaigns on incremental value rather than activity volume.

Relevant visual reference:

* [https://cdn.sanity.io/images/5p2wh2ny/production/5f9c0e8d9b2cba0c5e0b8c7cbb8cba6b9f4e3f62-1600x900.png](https://cdn.sanity.io/images/5p2wh2ny/production/5f9c0e8d9b2cba0c5e0b8c7cbb8cba6b9f4e3f62-1600x900.png)

## 3. Analytical Philosophy

At the heart of this project is a strict analytical separation between baseline and actual performance. Baseline represents an informed estimate of what sales would have been in the absence of marketing activity. Actual represents observed performance. Lift is the delta between the two.

This philosophy enforces several important principles:

* Marketing does not create all sales, only incremental sales
* Lift must be computed at the lowest possible grain
* Aggregations must always preserve baseline and actual independently
* Lift is not a ratio by default, it is a measurable volume difference

This approach prevents common analytical errors such as attributing all sales during a campaign window to the campaign itself.

Relevant visual reference:

* [https://www.tableau.com/sites/default/files/2021-06/LO_MarketingAnalytics_hero.png](https://www.tableau.com/sites/default/files/2021-06/LO_MarketingAnalytics_hero.png)

## 4. Stakeholders and Users

The Market Lift platform is designed to serve multiple stakeholder groups with a single source of analytical truth.

Primary stakeholders include:

* Commercial leadership evaluating ROI
* Marketing teams optimizing channel mix
* Finance teams validating revenue attribution
* Business intelligence teams building dashboards
* Data engineers maintaining analytical models

Each group consumes the same metrics but through different analytical lenses. The model must therefore be stable, transparent, and extensible.

Relevant visual reference:

* [https://cdn.prod.website-files.com/63f5d1d3b1f5e04f6a4c6c6a/63f5d1d3b1f5e04f6a4c6c8d_data-stakeholders.png](https://cdn.prod.website-files.com/63f5d1d3b1f5e04f6a4c6c6a/63f5d1d3b1f5e04f6a4c6c8d_data-stakeholders.png)

## 5. Scope Definition

### In Scope

* Analytical modeling of market lift
* Star schema optimized for BI consumption
* Campaign attribution at daily granularity
* Cross-country, cross-product analysis
* Historical trend analysis
* Comparative campaign performance

### Out of Scope

* Real-time bidding optimization
* Marketing automation execution
* Predictive modeling beyond baseline estimation
* Customer-level attribution
* External ad platform integrations

This scope ensures the project remains analytically rigorous without drifting into operational tooling.

Relevant visual reference:

* [https://www.datasciencecentral.com/wp-content/uploads/2021/10/data-warehouse-architecture.png](https://www.datasciencecentral.com/wp-content/uploads/2021/10/data-warehouse-architecture.png)

## 6. Data Warehouse Design Overview

The Market Lift platform is built on a dimensional modeling approach optimized for analytical workloads. A star schema is used to balance query performance, clarity, and extensibility.

The design emphasizes:

* Clear grain definition
* Conformed dimensions
* Additive facts
* BI tool friendliness

The central fact table records daily sales performance at the intersection of date, location, product, and campaign.

Relevant visual reference:

* [https://www.kimballgroup.com/wp-content/uploads/2013/08/StarSchema.png](https://www.kimballgroup.com/wp-content/uploads/2013/08/StarSchema.png)

## 7. Fact Table Design: Market Sales

The fact table represents the atomic unit of analysis. Each row corresponds to a single product sold in a specific location on a specific day, with or without campaign influence.

Key characteristics:

* Daily grain
* One row per product-location-date
* Campaign foreign key nullable
* Baseline and actual stored separately

Core metrics include:

* Baseline Units
* Actual Units
* Lift Units
* Revenue

This separation allows analysts to recompute lift under alternative assumptions without reprocessing raw data.

Relevant visual reference:

* [https://learn.microsoft.com/en-us/power-bi/guidance/media/star-schema/star-schema-example.png](https://learn.microsoft.com/en-us/power-bi/guidance/media/star-schema/star-schema-example.png)

## 8. Dimension Design: Date

The date dimension is foundational to all time-based analysis. It enables seasonality analysis, campaign window alignment, and period-over-period comparisons.

Attributes include:

* Calendar date
* Day of week
* Week number
* Month
* Quarter
* Year
* Fiscal periods

A fully populated date dimension avoids expensive runtime date calculations in BI tools.

Relevant visual reference:

* [https://www.sqlshack.com/wp-content/uploads/2020/02/date-dimension-table.png](https://www.sqlshack.com/wp-content/uploads/2020/02/date-dimension-table.png)

## 9. Dimension Design: Location

Location modeling supports geographic performance analysis and regional strategy evaluation.

The hierarchy supports rollups from city to country while preserving regional segmentation.

Attributes include:

* Country
* State or Province
* City
* Regional tier or market classification

This structure enables cross-border comparisons and regional performance clustering.

Relevant visual reference:

* [https://www.guru99.com/images/1/020819_1032_DataWareh4.png](https://www.guru99.com/images/1/020819_1032_DataWareh4.png)

## 10. Dimension Design: Product

Products are modeled to support therapeutic, brand, and pricing analysis.

Key attributes include:

* Brand name
* Generic name
* Therapeutic area
* List price

This enables lift analysis by category, portfolio contribution analysis, and price sensitivity exploration.

Relevant visual reference:

* [https://www.researchgate.net/profile/Dimensional-Modeling/publication/331588233/figure/fig2/AS:733289366093824@1551864935753/Star-schema-for-product-sales.png](https://www.researchgate.net/profile/Dimensional-Modeling/publication/331588233/figure/fig2/AS:733289366093824@1551864935753/Star-schema-for-product-sales.png)

## 11. Dimension Design: Campaign

The campaign dimension captures the intent and scope of marketing interventions.

Attributes include:

* Campaign name
* Channel
* Start and end dates
* Target geography
* Target product

Campaigns are treated as descriptive entities rather than performance containers. Performance always lives in the fact table.

Relevant visual reference:

* [https://cdn.analyticsvidhya.com/wp-content/uploads/2020/07/star-schema-marketing.png](https://cdn.analyticsvidhya.com/wp-content/uploads/2020/07/star-schema-marketing.png)

## 12. Metric Definitions and Governance

Clear metric definitions are essential to prevent analytical drift.

### Baseline Units

Baseline units represent expected sales absent marketing intervention. They are not historical averages but modeled expectations.

### Actual Units

Actual units represent recorded sales volume.

### Lift Units

Lift units equal actual units minus baseline units. Negative lift is allowed and meaningful.

### Revenue

Revenue is calculated from actual units multiplied by unit price. Baseline revenue can be derived analytically.

Relevant visual reference:

* [https://www.datapine.com/blog/wp-content/uploads/2018/10/marketing-analytics-dashboard-example.png](https://www.datapine.com/blog/wp-content/uploads/2018/10/marketing-analytics-dashboard-example.png)

## 13. Campaign Attribution Logic

Campaign attribution follows deterministic rules:

* Campaigns apply only within defined date windows
* Campaigns apply only to defined geographies and products
* Only one campaign may influence a product-location-day

This avoids double counting and ensures interpretability.

Relevant visual reference:

* [https://www.segment.com/wp-content/uploads/2021/01/marketing-attribution-models.png](https://www.segment.com/wp-content/uploads/2021/01/marketing-attribution-models.png)

## 14. Analytical Use Cases

### Executive Performance Review

Executives can assess which campaigns generated true incremental revenue.

### Channel Effectiveness

Marketing teams can compare channel efficiency across regions.

### Portfolio Strategy

Product leaders can identify categories most responsive to promotion.

Relevant visual reference:

* [https://www.sisense.com/wp-content/uploads/2021/03/marketing-dashboard-example.png](https://www.sisense.com/wp-content/uploads/2021/03/marketing-dashboard-example.png)

## 15. Visualization Strategy

Dashboards are designed to tell stories, not just display numbers.

Recommended visuals include:

* Baseline vs Actual trend lines
* Lift contribution waterfalls
* Geographic heatmaps
* Campaign ROI ranking tables

Visual design emphasizes contrast between baseline and actual to make lift immediately visible.

Relevant visual reference:

* [https://public.tableau.com/static/images/Ma/MarketingAnalyticsDashboard/MarketingDashboard/4_3.png](https://public.tableau.com/static/images/Ma/MarketingAnalyticsDashboard/MarketingDashboard/4_3.png)

## 16. Data Quality and Validation

Quality controls include:

* Non-negative baseline enforcement
* Referential integrity across dimensions
* Campaign window validation
* Outlier detection on lift values

These controls ensure analytical trust.

Relevant visual reference:

* [https://www.gartner.com/imagesrv/insights/data-quality.png](https://www.gartner.com/imagesrv/insights/data-quality.png)

## 17. Performance Considerations

The star schema enables:

* Efficient aggregation
* Predicate pushdown
* Minimal join complexity

This ensures responsiveness even with multi-year data.

Relevant visual reference:

* [https://learn.microsoft.com/en-us/azure/architecture/data-guide/images/star-schema.png](https://learn.microsoft.com/en-us/azure/architecture/data-guide/images/star-schema.png)

## 18. Security and Access Control

Access is controlled at the warehouse and BI layer.

* Row-level security by geography if required
* Metric-level governance via semantic models

Relevant visual reference:

* [https://www.snowflake.com/wp-content/uploads/2022/08/security-architecture.png](https://www.snowflake.com/wp-content/uploads/2022/08/security-architecture.png)

## 19. Extensibility and Future Enhancements

The model supports future extensions such as:

* Additional countries
* New product lines
* New campaign channels
* Scenario modeling

No structural redesign is required for moderate growth.

Relevant visual reference:

* [https://www.databricks.com/wp-content/uploads/2021/10/lakehouse-architecture.png](https://www.databricks.com/wp-content/uploads/2021/10/lakehouse-architecture.png)

## 20. Risks and Mitigations

Key risks include:

* Poor baseline estimation
* Misaligned campaign metadata
* Overinterpretation of lift

Mitigations include governance, documentation, and stakeholder education.

Relevant visual reference:

* [https://www.projectmanager.com/wp-content/uploads/2022/05/project-risk-management.png](https://www.projectmanager.com/wp-content/uploads/2022/05/project-risk-management.png)

## 21. Implementation Roadmap

Phases include:

* Model deployment
* Historical data loading
* Dashboard development
* Stakeholder training

Relevant visual reference:

* [https://www.productplan.com/uploads/roadmap-example.png](https://www.productplan.com/uploads/roadmap-example.png)

## 22. Maintenance Strategy

Ongoing activities include:

* Periodic metric audits
* Campaign metadata reviews
* Performance monitoring

Relevant visual reference:

* [https://www.redhat.com/cms/managed-files/data-maintenance-automation.png](https://www.redhat.com/cms/managed-files/data-maintenance-automation.png)

## 23. Success Criteria

The project is successful when:

* Campaign ROI is quantifiable
* Baseline assumptions are trusted
* Decision-making shifts from intuition to evidence

Relevant visual reference:

* [https://www.strategyzer.com/assets/resources/business-model-canvas-example.png](https://www.strategyzer.com/assets/resources/business-model-canvas-example.png)

## 24. Conclusion

The Market Lift Analytics Platform transforms marketing analysis from descriptive reporting into causal insight. By formalizing baseline, actual, and lift as first-class analytical entities, it enables organizations to invest with confidence, cut waste, and scale what truly works.

This project is not just a data model. It is an analytical contract between data, marketing, and finance. It defines how success is measured and how truth is established.
