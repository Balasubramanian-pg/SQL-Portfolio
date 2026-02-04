# A Data-Driven Analysis of Computer Science Universities

## Introduction

Choosing a university for Computer Science is one of the most consequential academic decisions a student can make. Rankings, reputation, research output, and employability all compete for attention, yet it is often unclear how these factors interact or which ones truly matter most. This project takes a step back from surface-level rankings and conducts a detailed, data-driven exploration of Computer Science universities across the globe.

Using a comprehensive dataset sourced from Kaggle, the analysis examines how universities perform across multiple dimensions, including academic reputation, employer perception, research impact, and international collaboration. Rather than treating excellence as a single score, the project aims to unpack what excellence actually looks like in practice and how it varies by institution, country, and time.

## Data Source and Preparation

The analysis is built on a structured dataset obtained from Kaggle, a widely used platform for high-quality open datasets. While the raw data provided a strong foundation, it required careful preparation before meaningful analysis could begin.

The dataset went through a structured Extract, Transform, Load (ETL) process using Excel Power Query. This stage focused on ensuring consistency, accuracy, and analytical readiness. Key preparation steps included:

* Standardizing column names and data types for analytical consistency
* Handling missing or incomplete values to avoid skewed results
* Validating numeric fields such as scores, rankings, and citation metrics
* Structuring the data for efficient querying and analysis in SQL

Once cleaned and validated, the dataset was loaded into a SQL database. This enabled scalable querying, reproducible analysis, and the ability to explore complex relationships across thousands of records.

## About the Data

The dataset captures information on more than 2,400 universities offering Computer Science programs, spanning multiple countries and years. It provides a multi-dimensional view of institutional performance rather than relying on a single ranking metric.

Key variables included in the dataset are:

* Overall Computer Science score
* Academic reputation within the global academic community
* Employer reputation, reflecting graduate employability
* Research impact measured through citations per paper
* Index citations, representing research visibility and influence
* International research collaboration indicators
* Country and regional identifiers

The longitudinal nature of the data allows for trend analysis, making it possible to observe how institutions evolve over time rather than evaluating them based on a single snapshot.

## Exploration Process and Analytical Approach

The analytical workflow followed a structured progression, moving from foundational understanding to advanced insights.

### Data Familiarization

The first step involved a deep review of the dataset structure, variable definitions, and scoring methodologies. Understanding how each metric was calculated was essential for forming meaningful research questions and avoiding misinterpretation of results.

### Descriptive Statistics

Basic statistical techniques were applied to understand distributions, central tendencies, and variability across key metrics. This helped identify common performance ranges, extreme outliers, and differences between institutions at various ranking levels.

### Identification of Top Performers

Universities were ranked based on their overall Computer Science scores to identify leading institutions globally. This analysis highlighted not only consistently top-ranked universities but also institutions that performed exceptionally well in specific dimensions such as research or employability.

### Country-Level Analysis

The data was segmented by country to explore national patterns in Computer Science education. This revealed differences in how countries balance academic research, industry alignment, and global collaboration, as well as disparities in overall performance.

### Correlation Analysis

Relationships between major variables were examined, with particular focus on the link between academic reputation and employer reputation. This analysis explored whether strong academic standing translates into better job market outcomes for graduates.

### Cluster Analysis

Clustering techniques were used to group universities based on employer reputation and research impact metrics. This uncovered distinct institutional profiles, such as research-intensive universities, industry-aligned institutions, and balanced performers.

### Temporal Trends

A time-based analysis of the top 10 universities’ overall scores was conducted to understand stability and change over time. This provided insights into whether leading institutions maintain dominance or experience fluctuations due to policy, funding, or strategic shifts.

### Comparative Metric Analysis

Academic reputation scores were compared against research citation metrics to examine whether prestige aligns with measurable research output. This helped highlight institutions that outperform expectations or rely more heavily on reputation than impact.

### Hypothesis Testing

Statistical hypothesis testing was applied to compare overall Computer Science scores between universities in the United States and those in other countries. This allowed for evidence-based conclusions about geographic advantages and global competitiveness.

### Educational and Career Insights

The final stage translated analytical findings into practical insights for prospective students. The analysis emphasized:

* Countries with strong employability outcomes for CS graduates
* Institutions that balance research excellence with industry relevance
* Strategic considerations for students considering international education or relocation

## Key Findings and Insights

The analysis revealed that Computer Science excellence is multifaceted. High academic reputation does not always guarantee strong employer outcomes, and research impact varies significantly even among similarly ranked institutions. Country-level patterns suggest that national education systems and industry ecosystems play a substantial role in shaping outcomes.

Longitudinal trends showed that while some universities maintain consistent leadership, others experience notable shifts, highlighting the dynamic nature of global CS education.

## Conclusion

This project demonstrates how data analysis and SQL can be used to move beyond surface-level rankings and uncover deeper insights into Computer Science universities worldwide. By examining performance across reputation, research, employability, and time, the analysis provides a more nuanced understanding of what drives academic excellence.

The findings offer value to multiple stakeholders. Students gain clarity on how to evaluate universities based on their personal goals. Institutions can benchmark themselves against global peers. Policymakers and educators can better understand the factors that contribute to sustained excellence in Computer Science education.

Ultimately, the project reinforces that informed decisions in education are best made not through isolated metrics, but through careful, data-driven exploration of the broader academic landscape.