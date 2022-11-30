SELECT *
FROM [Portfolio Project].dbo.CovidVaccinations$
WHERE continent is not null
ORDER BY 1,2

--Select Data that we are going to be using, for simplicity of understanding we are going to check out the location, date, population and cases.

SELECT location, date, total_cases, new_cases, total_deaths, population
FROM [Portfolio Project].dbo.CovidDeaths$
WHERE continent is not null
ORDER BY 1,2

-- We will be looking at the total cases vs total deaths

SELECT location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 AS Mortality_Rate
FROM [Portfolio Project].dbo.CovidDeaths$
WHERE location like 'India'
AND continent is not null
ORDER BY 1,2

--We can analyse the Total cases vs Population
-- This helps us to understand what percentage of population got Covid

SELECT location, date, population, total_cases, (total_cases/population)*100 AS Percent_of_Population_Infected
FROM [Portfolio Project].dbo.CovidDeaths$
WHERE location like 'India'
AND continent is not null
ORDER BY 1,2

--Looking at countries with Highest Infection Rate compared to Population

SELECT location, population, MAX(total_cases) AS Highest_Cases, MAX((total_cases/population))*100 AS Percent_of_Population_Infected
FROM [Portfolio Project].dbo.CovidDeaths$
--WHERE location like 'India'
WHERE continent is not null
Group by location, population
ORDER BY Percent_of_Population_Infected desc

--Showing countries with higest Death count per Population

SELECT location, MAX(CAST(Total_deaths AS int)) AS TotalDeathCount
FROM [Portfolio Project].dbo.CovidDeaths$
--WHERE location like 'India'
WHERE continent is not null
Group by location
ORDER BY TotalDeathCount desc

--Let's Break Things down by Continent
-- Showing continents with the highest death count per population

SELECT continent, MAX(CAST(Total_deaths AS int)) AS TotalDeathCount
FROM [Portfolio Project].dbo.CovidDeaths$
--WHERE location like 'India'
WHERE continent is not null
Group by continent
ORDER BY TotalDeathCount desc

--GLOBAL NUMBERS

SELECT date, SUM(new_cases) AS total_cases, SUM(CAST(new_deaths AS int)) AS total_deaths, SUM(CAST(new_deaths AS int))/SUM(new_cases)*100 AS Mortaility_Rate
FROM [Portfolio Project].dbo.CovidDeaths$
WHERE continent is not null
GROUP BY date
ORDER BY 1,2

-- Analysing Population vs Vaccinations

WITH PopvsVac (Continent, location, date, population, new_vaccinations, Rolling_People_Vaccinated)
as
(
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location ORDER BY dea.location,
dea.date) AS Rolling_People_Vaccinated
FROM [Portfolio Project].dbo.CovidVaccinations$ vac
JOIN [Portfolio Project].dbo.CovidDeaths$ dea
	ON dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.continent is not null
--ORDER BY 2,3
)
SELECT *, (Rolling_People_Vaccinated/Population)*100
FROM PopvsVac
-- Creating CTE

-- TEMP TABLE

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
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location ORDER BY dea.location,
dea.date) AS Rolling_People_Vaccinated
FROM [Portfolio Project].dbo.CovidVaccinations$ vac
JOIN [Portfolio Project].dbo.CovidDeaths$ dea
	ON dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.continent is not null
--ORDER BY 2,3

SELECT *, (Rolling_People_Vaccinated/Population)*100
FROM #Percent_Population_Vaccinated

-- Creating a view for later visualziation

CREATE VIEW PercentPopulationVaccinated as
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location ORDER BY dea.location,
dea.date) AS Rolling_People_Vaccinated
FROM [Portfolio Project].dbo.CovidVaccinations$ vac
JOIN [Portfolio Project].dbo.CovidDeaths$ dea
	ON dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.continent is not null
--ORDER BY 2,3

SELECT *
FROM PercentPopulationVaccinated

