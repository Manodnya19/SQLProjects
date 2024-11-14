select * from PortfolioProject.coviddeathsnew;

-- select * from PortfolioProject.covidvaccination
-- order by 3, 5 DESC;

-- select the data that we are going to be using

Select location, date, total_cases, new_cases, total_deaths,population
From PortfolioProject.coviddeathsnew
order by 1, 2 DESC;

-- ------------------------------------------------------------------------
-- Looking at Total Cases vs Total Deaths
WITH Death_CTE AS (
    SELECT location, 
           STR_TO_DATE(date, '%d/%m/%Y') AS date, 
           total_cases, 
           total_deaths, 
           (total_deaths / total_cases) * 100 AS DeathPercentage
    FROM PortfolioProject.coviddeathsnew
    WHERE location LIKE '%states%'
)
SELECT location, 
       date, 
       total_cases, 
       total_deaths, 
       DeathPercentage 
FROM Death_CTE
WHERE DeathPercentage > 0
ORDER BY location, date;

-- ------------------------------------------------------------------------
-- Looking at Total Cases vs Population
-- Shows the percerntage of population that got covid

WITH Population_CTE AS (
    SELECT location, 
           STR_TO_DATE(date, '%d/%m/%Y') AS date, 
           total_cases, 
           population, 
           (total_cases / population) * 100 AS PercentOfPopulation
    FROM PortfolioProject.coviddeathsnew
    WHERE location LIKE '%states%'
)
SELECT location, 
       date, 
       total_cases, 
       population, 
       PercentOfPopulation 
FROM Population_CTE
WHERE PercentOfPopulation > 0
ORDER BY location, date;

-- ------------------------------------------------------------------------

-- Country with highest infection rate compared to population
WITH InfectionRate_CTE AS (
    SELECT location,
		   population,
           MAX(total_cases) as InfectionCount, 
           MAX((total_cases / population)) * 100 AS PercentOfPopulationInfected
    FROM PortfolioProject.coviddeathsnew
    Group by Location, Population
)
SELECT location, 
       population, 
       InfectionCount, 
       PercentOfPopulationInfected 
FROM InfectionRate_CTE
WHERE PercentOfPopulationInfected > 0
ORDER BY PercentOfPopulationInfected DESC;

-- ------------------------------------------------------------------------
-- Contry with highest death count per population

SELECT location,
       MAX(CAST(total_deaths AS UNSIGNED)) AS TotalDeathCount
FROM PortfolioProject.coviddeathsnew
where location not in ('Europe', 'North America', 'South America', 'European Union', 'Africa')
GROUP BY location
ORDER BY TotalDeathCount DESC;

-- ------------------------------------------------------------------------

-- Showing continents with the highest death count per population
SELECT continent,
       MAX(CAST(total_deaths AS UNSIGNED)) AS TotalDeathCount
FROM PortfolioProject.coviddeathsnew
where continent is not null
GROUP BY continent
ORDER BY TotalDeathCount DESC;
-- ------------------------------------------------------------------------

-- Global numbers
SELECT STR_TO_DATE(date, '%d/%m/%Y') AS date, 
		SUM(CAST(new_cases AS UNSIGNED)) as TotalCases,
        sum(CAST(new_deaths AS UNSIGNED)) as TotalDeaths,
        sum(new_deaths)/sum(new_cases)*100 as DeathPercentage
FROM PortfolioProject.coviddeathsnew
where continent is not null
Group by date
order by 1, 2;

-- ------------------------------------------------------------------------

-- Total population vs vaccination
WITH PopvsVacCTE(continent, location, Date, population, new_vaccinations, RollingPeopleVaccinated) AS (
    SELECT 
        death.continent, 
        death.location, 
        STR_TO_DATE(death.date, '%d/%m/%Y') AS Date, 
        death.population, 
        vac.new_vaccinations,
        SUM(vac.new_vaccinations) OVER (PARTITION BY death.location ORDER BY STR_TO_DATE(death.date, '%d/%m/%Y')) AS RollingPeopleVaccinated
    FROM 
        PortfolioProject.coviddeathsnew death
    JOIN 
        PortfolioProject.covidvaccination vac
    ON 
        death.location = vac.location 
        AND death.date = vac.date
    WHERE 
        death.continent IS NOT NULL
)
SELECT *, (RollingPeopleVaccinated/population)*100
FROM PopvsVacCTE
ORDER BY location, Date;

-- Creating view to store data for later visualisations

Create View PortfolioProject.PercentPopulationVaccinated as
WITH PopvsVacCTE(continent, location, Date, population, new_vaccinations, RollingPeopleVaccinated) AS (
    SELECT 
        death.continent, 
        death.location, 
        STR_TO_DATE(death.date, '%d/%m/%Y') AS Date, 
        death.population, 
        vac.new_vaccinations,
        SUM(vac.new_vaccinations) OVER (PARTITION BY death.location ORDER BY STR_TO_DATE(death.date, '%d/%m/%Y')) AS RollingPeopleVaccinated
    FROM 
        PortfolioProject.coviddeathsnew death
    JOIN 
        PortfolioProject.covidvaccination vac
    ON 
        death.location = vac.location 
        AND death.date = vac.date
    WHERE 
        death.continent IS NOT NULL
)
SELECT *, (RollingPeopleVaccinated/population)*100
FROM PopvsVacCTE
ORDER BY location, Date;






