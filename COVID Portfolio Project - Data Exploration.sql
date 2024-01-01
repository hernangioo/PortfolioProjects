-----COVID 19 Data Exploration
-----Data Source: https://ourworldindata.org/covid-deaths
-----Date Range: January 2020 - December 2023

-- Check if table is correctly imported
SELECT *
FROM PortfolioProject.dbo.CovidDeaths
ORDER BY 3, 4

SELECT *
FROM PortfolioProject.dbo.CovidVaccinations
ORDER BY 3, 4

-- COVID 19 Total Cases and Total Deaths

SELECT location, date, total_cases, new_cases, total_deaths, population
FROM PortfolioProject.dbo.CovidDeaths
ORDER BY 1, 2

-- Looking at the Total Cases vs Total Deaths
-- Show the likelihood of dying if you contract Covid in United Kingdom
SELECT location, date, total_cases, total_deaths,
	(CAST(total_deaths AS float)) /(CAST(total_cases AS float))*100 AS DeathPercentage
FROM PortfolioProject.dbo.CovidDeaths
WHERE location = 'United Kingdom'
ORDER BY 1, 2

-- Looking at the Total Cases vs Population
-- Shows what percentage of population got Covid
SELECT location, date, population, total_cases,
	(CAST(total_cases AS float)) /(CAST(population AS float))*100 AS PercentPopulationInfected
FROM PortfolioProject.dbo.CovidDeaths
WHERE location = 'United Kingdom'
ORDER BY 1, 2

-- Looking at countries with highest infection rate compared to population
SELECT sub.*, (sub.HighestInfectionCount/sub.population)*100 AS PercentPopulationInfected
FROM
(
SELECT location, population, MAX(total_cases) AS HighestInfectionCount
	--MAX((CAST(total_cases AS float)) /(CAST(population AS float))*100) AS PercentPopulationInfected
FROM PortfolioProject.dbo.CovidDeaths
WHERE continent IS NOT NULL
GROUP BY location, population
) sub
ORDER BY PercentPopulationInfected DESC

--Show continents/countries with highest death count

SELECT continent, location, MAX(CAST(total_deaths AS int)) AS TotalDeathCount
FROM PortfolioProject.dbo.CovidDeaths
WHERE continent IS NOT NULL
GROUP BY continent, location
ORDER BY TotalDeathCount DESC

-- Summary of death count by continent
--SELECT location, MAX(CAST(total_deaths AS int)) AS TotalDeathCount
--FROM PortfolioProject.dbo.CovidDeaths
--WHERE continent IS NULL
--AND location NOT IN (
--	SELECT location FROM PortfolioProject.dbo.CovidDeaths WHERE location LIKE '%income%'
--	) --Exclude Income categories
--GROUP BY location
--ORDER BY TotalDeathCount DESC

SELECT location, MAX(CAST(total_deaths AS int)) AS TotalDeathCount
FROM PortfolioProject.dbo.CovidDeaths
WHERE continent IS NULL

AND location NOT LIKE '%income%' --Exclude Income categories
AND location NOT LIKE '%world%'  --Exclude
GROUP BY location
ORDER BY TotalDeathCount DESC

--Global Numbers
SELECT a.*,
	CASE WHEN a.total_cases = 0 THEN 0
	ELSE (a.total_deaths/a.total_cases)*100
	END AS DeathPercentage
FROM
(
SELECT date, SUM(new_cases) AS total_cases,
	SUM(CAST(new_deaths AS int)) AS total_deaths
FROM PortfolioProject.dbo.CovidDeaths
WHERE continent IS NOT NULL
GROUP BY date
) a
ORDER BY 1,2

-- Across the world
SELECT SUM(new_cases) AS total_cases, SUM(CAST(new_deaths AS int)) AS total_deaths,
	(SUM(CAST(new_deaths AS int))/SUM(new_cases))*100 AS DeathPercentage
FROM PortfolioProject.dbo.CovidDeaths
WHERE continent IS NOT NULL
ORDER BY 1,2

--
SELECT SUM(new_cases) AS total_cases, SUM(CAST(new_deaths AS int)) AS total_deaths,
	(SUM(CAST(new_deaths AS int))/SUM(new_cases))*100 AS DeathPercentage
FROM PortfolioProject.dbo.CovidDeaths
WHERE location LIKE '%world%'
ORDER BY 1,2

--COVID 19 Vaccination

--Looking at Total Popuplation vs Vaccination
SELECT dea.continent,
	dea.location,
	dea.date,
	dea.population,
	vac.new_vaccinations,
	SUM(CAST(vac.new_vaccinations AS float)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) AS RollingPeopleVaccinated
FROM PortfolioProject.dbo.CovidDeaths dea
JOIN PortfolioProject.dbo.CovidVaccinations vac
ON dea.location = vac.location AND dea.date = vac.date
WHERE dea.continent IS NOT NULL
ORDER BY 2,3


--Show  Vaccination rate in United Kingdom
--Vaccination rate exceeded 100% probably due to booster shots
SELECT dea.continent,
	dea.location,
	dea.date,
	dea.population,
	vac.people_fully_vaccinated,
	(CAST(vac.people_fully_vaccinated AS float)/CAST(dea.population AS float))*100 AS vaccination_rate
FROM PortfolioProject.dbo.CovidDeaths dea
JOIN PortfolioProject.dbo.CovidVaccinations vac
ON dea.location = vac.location AND dea.date = vac.date
WHERE dea.continent IS NOT NULL
AND dea.location = 'United Kingdom'
ORDER BY 3


--Show  New Vaccinations vs Population
--USE CTE
WITH PopvsVac (continent, location, date, population, new_vaccinations, RollingPeopleVaccinated)
AS
(
SELECT dea.continent,
	dea.location,
	dea.date,
	dea.population,
	vac.new_vaccinations,
	SUM(CAST(vac.new_vaccinations AS float)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) AS RollingPeopleVaccinated
FROM PortfolioProject.dbo.CovidDeaths dea
JOIN PortfolioProject.dbo.CovidVaccinations vac
ON dea.location = vac.location AND dea.date = vac.date
WHERE dea.continent IS NOT NULL
--ORDER BY 2,3
)
SELECT *, (RollingPeopleVaccinated/population)*100 AS vaccination_rate
FROM PopvsVac

--Creating View to store data for later viz
CREATE VIEW PercentPopulationVaccinated AS
SELECT dea.continent,
	dea.location,
	dea.date,
	dea.population,
	vac.new_vaccinations,
	SUM(CAST(vac.new_vaccinations AS float)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) AS RollingPeopleVaccinated
FROM PortfolioProject.dbo.CovidDeaths dea
JOIN PortfolioProject.dbo.CovidVaccinations vac
ON dea.location = vac.location AND dea.date = vac.date
WHERE dea.continent IS NOT NULL
--ORDER BY 2,3

SELECT *
FROM PercentPopulationVaccinated
