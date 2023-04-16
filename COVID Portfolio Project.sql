SELECT *
FROM CovidDeaths
WHERE continent IS NOT NULL
ORDER BY 3,4

--SELECT *
--FROM CovidVaccinations
--ORDER BY 3,4

-- Select Data that we are going to be using 

SELECT location, date, total_cases, new_cases, total_deaths, population
FROM CovidDeaths
WHERE continent IS NOT NULL
ORDER BY 1,2

-- Looking at total cases vs total deaths
-- This will show the likelihood of you dying if you contract covid in your country

SELECT location, date, total_cases, total_deaths, ((total_deaths * 100.0)/total_cases) AS DeathPercentage
FROM CovidDeaths
WHERE location like '%states%'
WHERE continent IS NOT NULL
ORDER BY 1,2

-- Looking at the total cases vs the population
-- Shows what percentage of the population contracted Covid

SELECT location, date, population, total_cases, ((total_cases * 100.0)/population) AS CovidPercentage
FROM CovidDeaths
--WHERE location like '%states%'
WHERE continent IS NOT NULL
ORDER BY 1,2


-- Looking at countries with highest infection rate compared to population

SELECT location, population, MAX(total_cases) AS HighestInfectionCount, MAX(((total_cases * 100.0)/population)) AS PercentPopulationInfected
FROM CovidDeaths
--WHERE location like '%states%'
WHERE continent IS NOT NULL
GROUP BY location, population
ORDER BY PercentPopulationInfected DESC

-- BREAKING THINGS DOWN BY CONTINENT

SELECT continent, MAX(total_deaths) as TotalDeathCount
FROM CovidDeaths
--WHERE location like '%states%'
WHERE continent IS NOT NULL
GROUP BY continent
ORDER BY TotalDeathCount DESC

-- Showing the countries with the highest death count per population

SELECT location, MAX(total_deaths) as TotalDeathCount
FROM CovidDeaths
--WHERE location like '%states%'
WHERE continent IS NULL
GROUP BY location
ORDER BY TotalDeathCount DESC

-- GLOBAL NUMBERS

SELECT date, SUM(COALESCE(new_cases, 0)), SUM(COALESCE(new_deaths, 0)), SUM(COALESCE(new_deaths, 0))*100/SUM(COALESCE(new_cases, 0)) AS DeathPercentage
FROM CovidDeaths
-- WHERE location like '%states%'
WHERE continent IS NOT NULL
AND new_deaths <> 0
AND new_cases <> 0
GROUP BY date
ORDER BY 1,2

SELECT 
FROM CovidDeaths
WHERE continent IS NOT NULL
GROUP BY DATE

SELECT SUM(new_cases) AS total_cases, SUM(new_deaths) AS total_deaths, SUM(new_deaths)*100/SUM(new_cases) AS DeathPercentage
FROM CovidDeaths
-- WHERE location like '%states%'
WHERE continent IS NOT NULL
AND new_deaths <> 0
AND new_cases <> 0
-- GROUP BY date
ORDER BY 1,2

-- Looking at total population vs vaccinations

SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CAST(vac.new_vaccinations AS BIGINT)) OVER (PARTITION BY dea.location ORDER BY CAST(dea.location AS VARCHAR(50)), dea.date) AS RollingPeopleVaccinated
--, (RollingPeopleVaccinated*100/population)
FROM CovidDeaths dea
JOIN CovidVaccinations vac
	ON dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.continent IS NOT NULL
ORDER BY 2,3

-- USE CTE

WITH PopvsVac (Continent, Location, Date, Population, New_Vaccinations, RollingPeopleVaccinated)
AS 
(
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CAST(vac.new_vaccinations AS BIGINT)) OVER (PARTITION BY dea.location ORDER BY CAST(dea.location AS VARCHAR(50)), dea.date) AS RollingPeopleVaccinated
--, (RollingPeopleVaccinated*100/population)
FROM CovidDeaths dea
JOIN CovidVaccinations vac
	ON dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.continent IS NOT NULL
-- ORDER BY 2,3
)
SELECT *, (RollingPeopleVaccinated/Population)*100
FROM PopvsVac

-- TEMP TABLE

DROP TABLE IF EXISTS #PercentPopulationVaccinated
CREATE TABLE #PercentPopulationVaccinated
(
Continent NVARCHAR(255),
Location NVARCHAR(255),
Date DATETIME,
Population NUMERIC,
New_Vaccinations NUMERIC,
RollingPeopleVaccinated NUMERIC
)


INSERT INTO #PercentPopulationVaccinated
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CAST(vac.new_vaccinations AS BIGINT)) OVER (PARTITION BY dea.location ORDER BY CAST(dea.location AS VARCHAR(50)), dea.date) AS RollingPeopleVaccinated
--, (RollingPeopleVaccinated*100/population)
FROM CovidDeaths dea
JOIN CovidVaccinations vac
	ON dea.location = vac.location
	AND dea.date = vac.date
 WHERE dea.continent IS NOT NULL
 ORDER BY 2,3

SELECT *, (RollingPeopleVaccinated/Population)*100
FROM #PercentPopulationVaccinated


-- Creating view to store data for later visualizations

CREATE VIEW PercentPopulationVaccinated AS
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CAST(vac.new_vaccinations AS BIGINT)) OVER (PARTITION BY dea.location ORDER BY CAST(dea.location AS VARCHAR(50)), dea.date) AS RollingPeopleVaccinated
--, (RollingPeopleVaccinated*100/population)
FROM CovidDeaths dea
JOIN CovidVaccinations vac
	ON dea.location = vac.location
	AND dea.date = vac.date
 WHERE dea.continent IS NOT NULL
 --ORDER BY 2,3

 SELECT *
 FROM PercentPopulationVaccinated