-- Modified Query from YT:Alex The Analyst
-- Covid Data for Tableau Dashboard (2020 - 2022)

SELECT SUM(new_cases) AS total_cases,
	SUM(cast(new_deaths AS int)) AS total_deaths,
	SUM(cast(new_deaths AS int))/SUM(New_Cases)*100 AS DeathPercentage
FROM PortfolioProject..CovidDeaths
WHERE continent is not null
	AND date < '2023-01-01'
order by 1,2

-- 2. 

SELECT location,
	SUM(cast(new_deaths AS int)) AS TotalDeathCount
FROM PortfolioProject.dbo.CovidDeaths
--Where location like '%states%'
WHERE continent IS NULL 
	AND location NOT IN ('World', 'European Union', 'International')
	AND location NOT LIKE '%income%'
	AND date < '2023-01-01'
GROUP BY location
ORDER BY TotalDeathCount desc


-- 3.

SELECT Location,
	Population,
	MAX(CAST(total_cases AS float)) as HighestInfectionCount,
	MAX((CAST(total_cases AS float)/population))*100 as PercentPopulationInfected
FROM PortfolioProject.dbo.CovidDeaths
WHERE location NOT LIKE '%income%'
	AND date < '2023-01-01'
GROUP BY Location, Population
ORDER BY PercentPopulationInfected DESC


-- 4.


SELECT location,
	population,
	date,
	MAX(CAST(total_cases AS float)) as HighestInfectionCount,
	MAX((CAST(total_cases AS float)/population))*100 AS PercentPopulationInfected
FROM PortfolioProject.dbo.CovidDeaths
WHERE location NOT LIKE '%income%'
	AND date < '2023-01-01'
GROUP BY location, population, date
ORDER BY PercentPopulationInfected DESC