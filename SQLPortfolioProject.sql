
/*
Covid 19 Data Exploration 
Skills used: Joins, CTE's, Temp Tables, Windows Functions, Aggregate Functions, Creating Views, Converting Data Types
*/

--Select Database Table to see the data

SELECT  *
FROM PortfolioProject..CovidDeaths
WHERE continent is not null 
ORDER BY 3,4


-- Select Data that I'm going to be starting with

SELECT Location, date, total_cases, new_cases, total_deaths, population
FROM PortfolioProject..CovidDeaths
WHERE continent is not null
ORDER BY 1,2


-- Total Cases vs Total Deaths
-- Find Death percentage of Bangladesh

SELECT location,date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercent
FROM PortfolioProject..CovidDeaths
WHERE location = 'Bangladesh'
ORDER BY 1,2


-- Total Cases vs Population
-- Shows what percentage of population infected with Covid

SELECT location,date,population, total_cases, (total_cases/population)*100 as InfectedPercent
FROM PortfolioProject..CovidDeaths
WHERE location = 'Bangladesh'
ORDER BY 1,2


-- Countries with Highest Infection Rate compared to Population

SELECT location,population, MAX(total_cases) AS HighestInfected, MAX((total_cases/population)*100) as InfectedPercent
FROM PortfolioProject..CovidDeaths
--WHERE location = 'Bangladesh'
GROUP BY location, population
ORDER BY InfectedPercent DESC



-- Countries with Highest Death Count per Population

SELECT Location, MAX(Cast (Total_deaths AS int)) as TotalDeathCount
FROM PortfolioProject..CovidDeaths
--WHERE location like '%desh%'
Where continent is not null 
GROUP BY Location
ORDER BY TotalDeathCount DESC



-- BREAKING THINGS DOWN BY CONTINENT

-- Showing contintents with the highest death count per population

Select location, MAX(cast(Total_deaths as int)) as TotalDeathCount
From PortfolioProject..CovidDeaths
Where continent is null 
Group by location
order by TotalDeathCount desc




-- GLOBAL NUMBERS

SELECT date, SUM(new_cases) AS new_total_case,SUM( cast (new_deaths as int)) AS new_total_deaths,SUM(cast(new_deaths as int))/SUM(new_cases)*100 AS DeathPercent
FROM PortfolioProject..CovidDeaths
WHERE continent is not null 
GROUP BY date
ORDER BY 1,2


-- Total Population vs Vaccinations
-- Shows the Population that has recieved at least one Covid Vaccine

SELECT CovidDeaths.continent,CovidDeaths.location, CovidDeaths.date, CovidDeaths.population, CovidVaccinations.new_vaccinations,
 SUM(convert(bigint, CovidVaccinations.new_vaccinations)) OVER (PARTITION BY CovidDeaths.location ORDER BY CovidDeaths.location,
                CovidDeaths.date) AS total_new_vaccination
FROM PortfolioProject..CovidDeaths
   JOIN PortfolioProject..CovidVaccinations
   ON CovidDeaths.location = CovidVaccinations.location
   and CovidDeaths.date = CovidVaccinations.date
WHERE CovidDeaths.continent is not null
ORDER BY 2,3


-- Using CTE(Common Table Expression) to perform Calculation on Partition By in previous query
-- Shows Percentage of Population that has recieved at least one Covid Vaccine

with PopuVsVec(continent, location, date, population, new_vaccinations,total_new_vaccination) AS
(
SELECT CovidDeaths.continent,CovidDeaths.location, CovidDeaths.date, CovidDeaths.population, CovidVaccinations.new_vaccinations,
 SUM(convert(bigint, CovidVaccinations.new_vaccinations)) OVER (PARTITION BY CovidDeaths.location ORDER BY CovidDeaths.location,
                CovidDeaths.date) AS total_new_vaccination
FROM PortfolioProject..CovidDeaths
   JOIN PortfolioProject..CovidVaccinations
   ON CovidDeaths.location = CovidVaccinations.location
   and CovidDeaths.date = CovidVaccinations.date
WHERE CovidDeaths.continent is not null
)

SELECT *, (total_new_vaccination/population)*100 as TNVPercentage
FROM PopuVsVec

-- Using Temp Table to perform Calculation on Partition By in previous query

DROP Table if exists #PopVaccinated
Create Table #PopVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccinations numeric,
total_new_vaccination numeric
)

Insert into #PopVaccinated
SELECT CovidDeaths.continent,CovidDeaths.location, CovidDeaths.date, CovidDeaths.population, CovidVaccinations.new_vaccinations,
 SUM(convert(bigint, CovidVaccinations.new_vaccinations)) OVER (PARTITION BY CovidDeaths.location ORDER BY CovidDeaths.location,
                CovidDeaths.date) AS total_new_vaccination
FROM PortfolioProject..CovidDeaths
   JOIN PortfolioProject..CovidVaccinations
   ON CovidDeaths.location = CovidVaccinations.location
   and CovidDeaths.date = CovidVaccinations.date


Select *, (total_new_vaccination/Population)*100 AS TNVPercentage
From #PopVaccinated




-- Creating View to store data for later visualizations

Create View PopVaccinated as
 SELECT CovidDeaths.continent,CovidDeaths.location, CovidDeaths.date, CovidDeaths.population, CovidVaccinations.new_vaccinations,
 SUM(convert(bigint, CovidVaccinations.new_vaccinations)) OVER (PARTITION BY CovidDeaths.location ORDER BY CovidDeaths.location,
                CovidDeaths.date) AS total_new_vaccination
FROM PortfolioProject..CovidDeaths
   JOIN PortfolioProject..CovidVaccinations
   ON CovidDeaths.location = CovidVaccinations.location
   and CovidDeaths.date = CovidVaccinations.date
WHERE CovidDeaths.continent is not null

SELECT *
FROM PopVaccinated