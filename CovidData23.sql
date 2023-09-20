SELECT *
FROM PortfolioProject..CovidDeaths
WHERE continent IS NOT NULL
ORDER BY 3, 4

--SELECT *
--FROM PortfolioProject..CovidVaccinations
--WHERE continent IS NOT NULL
--ORDER BY 3, 4

-- Select data that we are going to use

SELECT location, date, total_cases, new_cases, total_deaths, population
FROM PortfolioProject..CovidDeaths
WHERE continent IS NOT NULL
ORDER BY 1, 2

-- Looking at Total Cases vs Total Deaths
-- Shows the likelihood of dying if you contract covid in your country

SELECT location, date, total_cases, total_deaths, CAST(total_deaths AS float)/CAST(total_cases AS float)*100 AS DeathPercentage
FROM PortfolioProject..CovidDeaths
WHERE continent IS NOT NULL AND location = 'Kenya'
ORDER BY 1, 2

-- Looking at the Total Cases vs Population
-- Shows what percentage of population got covid

SELECT location, date, total_cases, population, (CAST(total_cases AS float)/population)*100 AS PercentPopulationInfected
FROM PortfolioProject..CovidDeaths
WHERE continent IS NOT NULL AND location = 'Kenya'
ORDER BY 1, 2

-- Looking at countries with highest infection rates compared to population

SELECT location, population, MAX(total_cases) AS HighestInfectionCount, MAX((CAST(total_cases AS float)/population))*100 AS PercentPopulationInfected
FROM PortfolioProject..CovidDeaths
WHERE continent IS NOT NULL
GROUP BY location, population
ORDER BY PercentPopulationInfected DESC

-- Showing the countries with the highest Death Count per Population

SELECT location, MAX(CAST(total_deaths as int)) AS TotalDeathCount
FROM PortfolioProject..CovidDeaths
WHERE continent IS NOT NULL
GROUP BY location
ORDER BY TotalDeathCount DESC

SELECT location, MAX(CAST(total_deaths as int)) AS TotalDeathCount
FROM PortfolioProject..CovidDeaths
WHERE continent IS NULL AND location NOT LIKE '%income'
GROUP BY location
ORDER BY TotalDeathCount DESC

-- Let's break things down by continent
-- Showing continents with highest death count per population

SELECT continent, MAX(CAST(total_deaths as int)) AS TotalDeathCount
FROM PortfolioProject..CovidDeaths
WHERE continent IS NOT NULL
GROUP BY continent
ORDER BY TotalDeathCount DESC

-- GLOBAL NUMBERS

SELECT date, SUM(new_cases) AS total_cases, SUM(new_deaths) AS total_deaths, SUM(new_deaths)/ NULLIF(SUM(new_cases), 0)*100 AS
DeathPercentage
FROM PortfolioProject..CovidDeaths
WHERE continent IS NOT NULL
GROUP BY date
ORDER BY 1, 2

SELECT SUM(new_cases) AS total_cases, SUM(new_deaths) AS total_deaths, SUM(new_deaths)/ NULLIF(SUM(new_cases), 0)*100 AS
DeathPercentage
FROM PortfolioProject..CovidDeaths
WHERE continent IS NOT NULL
--GROUP BY date
ORDER BY 1, 2

-- Looking at Total Population vs Vaccinations

SELECT dth.continent, dth.location, dth.date, dth.population, vac.new_vaccinations,
SUM(CAST(vac.new_vaccinations AS bigint)) OVER (PARTITION BY dth.location ORDER BY dth.location,
dth.date) AS RollingPeopleVaccinated
--,(RollingPeopleVaccinated/population)*100
FROM PortfolioProject..CovidDeaths AS dth
JOIN PortfolioProject..CovidVaccinations AS vac
	ON dth.location = vac.location
	AND dth.date = vac.date
WHERE dth.continent IS NOT NULL
ORDER BY 2, 3

-- USE CTE
WITH PopvsVac (continent,location, date, population, new_vaccinations, RollingPeopleVaccinated)
AS 
(
SELECT dth.continent, dth.location, dth.date, dth.population, vac.new_vaccinations,
SUM(CAST(vac.new_vaccinations AS bigint)) OVER (PARTITION BY dth.location ORDER BY dth.location,
dth.date) AS RollingPeopleVaccinated
--,(RollingPeopleVaccinated/population)*100
FROM PortfolioProject..CovidDeaths AS dth
JOIN PortfolioProject..CovidVaccinations AS vac
	ON dth.location = vac.location
	AND dth.date = vac.date
WHERE dth.continent IS NOT NULL
--ORDER BY 2, 3
)

SELECT *, (RollingPeopleVaccinated/population)*100
FROM PopvsVac

-- TEMP TABLE

DROP TABLE IF EXISTS #PercentPopulationVaccinated
CREATE TABLE #PercentPopulationVaccinated
(
continent nvarchar(255),
location nvarchar(255),
date datetime,
population numeric,
new_vaccinations numeric,
RollingPeopleVaccinated numeric,
)

INSERT INTO #PercentPopulationVaccinated
SELECT dth.continent, dth.location, dth.date, dth.population, vac.new_vaccinations,
SUM(CAST(vac.new_vaccinations AS bigint)) OVER (PARTITION BY dth.location ORDER BY dth.location,
dth.date) AS RollingPeopleVaccinated
--,(RollingPeopleVaccinated/population)*100
FROM PortfolioProject..CovidDeaths AS dth
JOIN PortfolioProject..CovidVaccinations AS vac
	ON dth.location = vac.location
	AND dth.date = vac.date
WHERE dth.continent IS NOT NULL
--ORDER BY 2, 3

SELECT *, (RollingPeopleVaccinated/population)*100
FROM #PercentPopulationVaccinated

-- Creating View to store data for later visulization

CREATE VIEW PercentPopulationVaccinated AS
SELECT dth.continent, dth.location, dth.date, dth.population, vac.new_vaccinations,
SUM(CAST(vac.new_vaccinations AS bigint)) OVER (PARTITION BY dth.location ORDER BY dth.location,
dth.date) AS RollingPeopleVaccinated
--,(RollingPeopleVaccinated/population)*100
FROM PortfolioProject..CovidDeaths AS dth
JOIN PortfolioProject..CovidVaccinations AS vac
	ON dth.location = vac.location
	AND dth.date = vac.date
WHERE dth.continent IS NOT NULL
--ORDER BY 2, 3

