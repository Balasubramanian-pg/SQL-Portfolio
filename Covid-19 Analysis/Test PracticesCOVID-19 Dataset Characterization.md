# Thought Process Behind the COVID-19 Data Analysis SQL Queries

This analysis follows a systematic approach to understand the pandemic's impact through data. Here's my detailed thought process:

## 1. Initial Data Exploration

**Objective**: Understand the data structure and available fields.

**Approach**:
- First query selects all vaccination data where continent is specified (to avoid double-counting continent aggregates)
- Second query focuses on deaths data with key metrics (location, date, cases, deaths, population)
- Ordered by location and date to see chronological progression

**Rationale**: Starting with broad exploration helps identify data quality issues and potential analysis directions.

## 2. Mortality Rate Analysis (India-specific)

**Objective**: Understand disease severity in a specific country.

**Approach**:
- Calculated mortality rate as (total_deaths/total_cases)*100
- Filtered for India to see how deadly COVID was there
- Ordered chronologically to track changes over time

**Rationale**: Mortality rate shows the proportion of cases that resulted in death, indicating healthcare system effectiveness.

## 3. Infection Rate Analysis

**Objective**: Understand disease spread within population.

**Approach**:
- Calculated infection rate as (total_cases/population)*100
- Initially focused on India, then expanded globally
- Used MAX() to find peak infection rates by country

**Rationale**: Shows what percentage of population was infected - important for understanding herd immunity thresholds.

## 4. Death Count Analysis

**Objective**: Identify hardest-hit areas.

**Approach**:
- First by country, then by continent
- Used CAST to convert string deaths to integers for aggregation
- MAX() to find total death counts

**Rationale**: Absolute death counts help prioritize resource allocation and compare impact across regions.

## 5. Global Daily Statistics

**Objective**: Track worldwide pandemic progression.

**Approach**:
- SUM() of new cases and deaths per day
- Calculated global mortality rate
- Grouped by date for time series analysis

**Rationale**: Provides big-picture view of pandemic waves and overall severity.

## 6. Vaccination Analysis

**Objective**: Track vaccination rollout effectiveness.

**Approach**:
- Used two methods (CTE and temp table) to calculate rolling vaccinations
- Joined deaths and vaccinations tables on location and date
- Calculated vaccination percentage of population

**Key Techniques**:
1. **Window Functions**: `SUM() OVER (PARTITION BY...ORDER BY...)` for running totals
2. **Data Persistence**: Temp table vs CTE for different use cases
3. **View Creation**: For visualization reuse

**Rationale**: Vaccination progress is crucial for understanding pandemic recovery and protection levels.

## Architectural Decisions

1. **Filtering by Continent**:
   - Added `WHERE continent is not null` to avoid double-counting
   - Continent-level data appears as location with null continent

2. **Data Type Handling**:
   - Used `CAST`/`CONVERT` for string-to-number conversions
   - Ensured proper numeric calculations

3. **Progressive Analysis**:
   - Started simple (single country metrics)
   - Progressed to complex (global vaccination trends)
   - Built up from basic aggregations to advanced window functions

4. **Performance Considerations**:
   - Used appropriate GROUP BY clauses
   - Partitioned window functions by location for efficiency
   - Created temp structures for complex calculations

This analysis provides a comprehensive view of the pandemic from multiple perspectives - infection spread, mortality impact, and vaccination progress - using progressively more sophisticated SQL techniques.

# COVID-19 Data Analysis SQL Queries

This SQL script performs a comprehensive analysis of COVID-19 data, focusing on cases, deaths, vaccinations, and their relationships with population demographics. Here's a breakdown of the analysis:

## Initial Data Exploration

```sql
SELECT *
FROM [Portfolio Project].dbo.CovidVaccinations$
WHERE continent is not null
ORDER BY 1,2

SELECT location, date, total_cases, new_cases, total_deaths, population
FROM [Portfolio Project].dbo.CovidDeaths$
WHERE continent is not null
ORDER BY 1,2
```

## Key Metrics Analysis

### 1. Mortality Rate Analysis (India-specific)
```sql
SELECT location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 AS Mortality_Rate
FROM [Portfolio Project].dbo.CovidDeaths$
WHERE location like 'India'
AND continent is not null
ORDER BY 1,2
```

### 2. Infection Rate Analysis (India-specific)
```sql
SELECT location, date, population, total_cases, (total_cases/population)*100 AS Percent_of_Population_Infected
FROM [Portfolio Project].dbo.CovidDeaths$
WHERE location like 'India'
AND continent is not null
ORDER BY 1,2
```

### 3. Global Infection Rate Comparison
```sql
SELECT location, population, MAX(total_cases) AS Highest_Cases, 
       MAX((total_cases/population))*100 AS Percent_of_Population_Infected
FROM [Portfolio Project].dbo.CovidDeaths$
WHERE continent is not null
GROUP BY location, population
ORDER BY Percent_of_Population_Infected desc
```

### 4. Death Count Analysis by Country
```sql
SELECT location, MAX(CAST(Total_deaths AS int)) AS TotalDeathCount
FROM [Portfolio Project].dbo.CovidDeaths$
WHERE continent is not null
GROUP BY location
ORDER BY TotalDeathCount desc
```

### 5. Death Count Analysis by Continent
```sql
SELECT continent, MAX(CAST(Total_deaths AS int)) AS TotalDeathCount
FROM [Portfolio Project].dbo.CovidDeaths$
WHERE continent is not null
GROUP BY continent
ORDER BY TotalDeathCount desc
```

### 6. Global Daily Statistics
```sql
SELECT date, SUM(new_cases) AS total_cases, 
       SUM(CAST(new_deaths AS int)) AS total_deaths, 
       SUM(CAST(new_deaths AS int))/SUM(new_cases)*100 AS Mortality_Rate
FROM [Portfolio Project].dbo.CovidDeaths$
WHERE continent is not null
GROUP BY date
ORDER BY 1,2
```

## Vaccination Analysis

### 1. Using Common Table Expression (CTE) for Vaccination Progress
```sql
WITH PopvsVac (Continent, location, date, population, new_vaccinations, Rolling_People_Vaccinated) AS
(
    SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
           SUM(CONVERT(int,vac.new_vaccinations)) OVER (PARTITION BY dea.Location ORDER BY dea.location, dea.date) AS Rolling_People_Vaccinated
    FROM [Portfolio Project].dbo.CovidVaccinations$ vac
    JOIN [Portfolio Project].dbo.CovidDeaths$ dea
        ON dea.location = vac.location
        AND dea.date = vac.date
    WHERE dea.continent is not null
)
SELECT *, (Rolling_People_Vaccinated/Population)*100 AS Vaccination_Percentage
FROM PopvsVac
```

### 2. Using Temporary Table for Vaccination Progress
```sql
DROP TABLE IF EXISTS #Percent_Population_Vaccinated
CREATE TABLE #Percent_Population_Vaccinated
(
    Continent nvarchar(255),
    Location nvarchar(255),
    Date datetime,
    Population numeric,
    New_vaccination numeric,
    Rolling_People_Vaccinated numeric
)

INSERT INTO #Percent_Population_Vaccinated
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
       SUM(CONVERT(int,vac.new_vaccinations)) OVER (PARTITION BY dea.Location ORDER BY dea.location, dea.date) AS Rolling_People_Vaccinated
FROM [Portfolio Project].dbo.CovidVaccinations$ vac
JOIN [Portfolio Project].dbo.CovidDeaths$ dea
    ON dea.location = vac.location
    AND dea.date = vac.date
WHERE dea.continent is not null

SELECT *, (Rolling_People_Vaccinated/Population)*100 AS Vaccination_Percentage
FROM #Percent_Population_Vaccinated
```

### 3. Creating a View for Visualization
```sql
CREATE VIEW PercentPopulationVaccinated AS
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
       SUM(CONVERT(int,vac.new_vaccinations)) OVER (PARTITION BY dea.Location ORDER BY dea.location, dea.date) AS Rolling_People_Vaccinated
FROM [Portfolio Project].dbo.CovidVaccinations$ vac
JOIN [Portfolio Project].dbo.CovidDeaths$ dea
    ON dea.location = vac.location
    AND dea.date = vac.date
WHERE dea.continent is not null

SELECT * FROM PercentPopulationVaccinated
```

Note: There appears to be a typo in the view creation script ("population" is misspelled as "population" in the SELECT clause). Also, there's an unmatched parenthesis in the SUM function in the view definition.
