Update CovidDeaths
SET continent = NULL
WHERE continent = ''; 

ALTER TABLE dbo.CovidDeaths
Alter COLUMN total_cases float;
Update CovidDeaths
SET total_cases = NULL
WHERE total_cases = ''; 

ALTER TABLE dbo.CovidDeaths
Alter COLUMN new_cases float;
Update CovidDeaths
SET new_cases = NULL
WHERE new_cases = ''; 

ALTER TABLE dbo.CovidDeaths
Alter COLUMN new_cases_smoothed float;
Update CovidDeaths
SET new_cases_smoothed = NULL
WHERE new_cases_smoothed = ''; 

ALTER TABLE dbo.CovidDeaths
Alter COLUMN date datetime;

ALTER TABLE dbo.CovidVaccinations
Alter COLUMN new_vaccinations float;

SELECT *
FROM PortfolioProject..CovidDeaths
--Where continent is not null
order by 2,3

--SELECT *
--FROM PortfolioProject..CovidVaccinations
--order by 3,4

SELECT location, date, total_cases, new_cases, total_deaths, population
FROM PortfolioProject..CovidDeaths
order by 1,2

-- Looking at  Total Cases vs Total Deaths
-- Shows the likihood of dying if you contract covid in your country 
SELECT location, date, total_cases, total_deaths, 
(CONVERT(float, total_deaths) / NULLIF(CONVERT(float, total_cases), 0)) * 100 AS Deathpercentage
FROM PortfolioProject..CovidDeaths
WHERE location like '%states%'
order by 1

-- Looking at Total Cases vs Population
-- Shows what percentage of population got Covid 
SELECT location, date, population, total_cases, 
(CONVERT(float, total_cases) / CONVERT(float, population)) * 100 AS PercentPopulationInfected
FROM PortfolioProject..CovidDeaths
WHERE location like '%states%'
order by 1

-- Looking at Countries wih Highest Infection Rate compared to Population
SELECT location, population, MAX(total_cases) as HighestInfectionCount, 
MAX((CONVERT(float, total_cases) / NULLIF(CONVERT(float, population),0))) * 100 AS PercentPopulationInfected
FROM PortfolioProject..CovidDeaths
--WHERE location like '%states%'
Group By location, population
order by PercentPopulationInfected desc

-- Showing Countries with Highes Death Count per Population
SELECT location, MAX(cast(Total_deaths as int)) AS TotalDeathCount
FROM PortfolioProject..CovidDeaths
--WHERE location like '%states%'
Where continent is not null
Group By location
order by TotalDeathCount desc

-- Breakdown by continent
SELECT continent, MAX(cast(Total_deaths as int)) AS TotalDeathCount
FROM PortfolioProject..CovidDeaths
--WHERE location like '%states%'
Where continent is not null
Group By continent
order by TotalDeathCount desc

-- Global Numbers
SELECT date, SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, 
SUM(cast(new_deaths as int))/SUM(New_cases)*100 as DeathPercentage
From PortfolioProject..CovidDeaths
where continent is not null
group by date
order by 1,2


--Looking at Total Population vs Vaccinations

With PopvsVac (Conntinent, Location, Date, Population, new_vaccinations, RollingPeopleVaccinated)
as
(
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(vac.new_vaccinations) OVER (Partition by dea.Location order by dea.location, dea.date) as RollingPeopleVaccinated
FROM PortfolioProject..CovidDeaths dea
JOIN PortfolioProject..CovidVaccinations vac
on dea.location = vac.location
and dea.date = vac.date
where dea.continent is not null
--order by 2,3
)
Select *, (RollingPeopleVaccinated/nullif(Population,0))*100
From PopvsVac


-- Creating View to store data for later visualizations

