## Chicago Crime & Weather 2021 Analysis

### README

## Project Overview

This project explores the relationship between reported crime incidents and weather conditions in Chicago during the year 2021. By combining crime records with daily temperature data, the analysis aims to uncover spatial, temporal, and environmental patterns that influence criminal activity. The project is designed as an end-to-end analytical exercise, covering data exploration, SQL-based querying, and insight generation that could support public safety planning, policy discussions, and further academic research.

The analysis focuses on understanding where crimes occur most frequently, when they peak throughout the year, how different crime types behave, and whether extreme weather conditions appear to correlate with changes in crime volume.

## Objectives

The primary goals of this project are:

* Quantify overall crime activity in Chicago during 2021
* Identify the most common crime types and their relative frequencies
* Analyze crime distribution across communities, streets, months, and weekdays
* Detect crime hotspots at both neighborhood and street levels
* Examine temporal trends, including seasonal patterns and sustained crime periods
* Explore the relationship between temperature extremes and crime volume
* Highlight actionable insights that could inform crime prevention strategies

## Data Description

The project uses a structured dataset containing crime records for the city of Chicago in 2021, enriched with weather information. Each record represents a reported crime incident and includes attributes such as:

* Unique crime identifier
* Crime type and classification
* Date and time of occurrence
* Community area and street name
* Domestic violence indicator
* Arrest indicator
* Daily high temperature associated with the crime date

Weather data is aligned at the daily level, allowing direct comparison between temperature conditions and crime counts.

## Tools and Technologies

The analysis is primarily conducted using SQL for data querying and aggregation. SQL was chosen to demonstrate strong analytical querying skills and to ensure reproducibility. Results are summarized using tabular outputs and narrative explanations.

Optional downstream tools, such as visualization platforms or notebooks, can be used to extend this analysis with charts, dashboards, or predictive modeling.

## Analysis Structure

The project is structured around a clear question-driven approach. Each analytical section follows a consistent pattern:

* Business or analytical question
* SQL query used to answer the question
* Result and interpretation of findings

This structure ensures clarity, traceability, and ease of review for both technical and non-technical audiences.

### Key Areas of Analysis

#### Overall Crime Volume

The analysis begins by calculating the total number of reported crimes in 2021, establishing a baseline understanding of city-wide crime activity.

#### Crime Type Breakdown

Major violent crime categories such as battery, assault, and homicide are analyzed to understand their relative prevalence. This highlights which offenses contribute most to overall crime counts.

#### Geographic Distribution

Crime counts are aggregated by community areas to identify neighborhoods with disproportionately high or low crime volumes. Population and density data are included to provide additional context.

Street-level analysis further identifies specific corridors with consistently high crime activity, revealing micro-level hotspots.

#### Temporal Trends

Crime patterns are examined across months and weekdays to uncover seasonal and behavioral trends. This includes identifying peak crime months and the days of the week with the highest reported incidents.

A notable temporal finding is the identification of a prolonged stretch of consecutive days with at least one reported homicide, indicating periods of sustained violence.

#### Weather and Temperature Effects

The analysis compares crime volumes on the hottest and coldest days of the year. Monthly homicide counts are also analyzed alongside average high temperatures to explore whether warmer conditions coincide with increased violent crime.

While this analysis does not claim causation, it provides quantitative evidence of associations between temperature extremes and crime levels.

#### Domestic Violence and Arrest Outcomes

Crimes flagged as domestic-related are analyzed to determine their proportion of total incidents. Arrest rates are also reviewed across selected crime categories to highlight offenses with higher or lower enforcement outcomes.

## Key Findings Summary

* Over 200,000 crimes were reported in Chicago during 2021
* Battery was the most common crime, followed by assault and homicide
* Austin recorded the highest number of reported crimes among communities
* October had the highest monthly crime volume, while winter months were the lowest
* Saturdays experienced the highest crime counts among weekdays
* Michigan Avenue emerged as the most crime-prone street
* Approximately one in five crimes involved domestic violence
* Crime volume was higher on the hottest day compared to the coldest day
* July recorded the highest number of homicides, coinciding with high average temperatures

## Assumptions and Limitations

* Weather data is aggregated at the daily level and does not account for intra-day variation
* Crime data reflects reported incidents only and may not capture unreported crimes
* The analysis identifies correlations but does not establish causality
* Population and density figures are treated as static for the year

## Potential Extensions

Future enhancements to this project could include:

* Multi-year analysis to validate whether observed patterns persist over time
* Regression modeling to quantify the influence of temperature and seasonality
* Integration of additional weather variables such as precipitation or humidity
* Visualization dashboards for interactive exploration of crime trends
* Predictive models to anticipate high-risk periods or locations

## Conclusion

This project demonstrates how structured SQL analysis can be used to extract meaningful insights from public crime and weather data. By examining crime through geographic, temporal, and environmental lenses, the analysis provides a nuanced view of public safety dynamics in Chicago during 2021. The findings serve as a strong foundation for deeper analytical work, policy evaluation, and data-driven decision-making in urban crime prevention.
