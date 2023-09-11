Select *
From PortfolioProject..CovidDeath
Where continent is not null
order by 3,4

--Select *
--From PortfolioProject..CovidVacination
--order by 3,4
-- select Data that useful for the analysis

Select Location, date, total_cases, new_cases, total_deaths, population
From PortfolioProject..CovidDeath
Where continent is not null
order by 1,2

-- Looking at Total Cases vs Total Deaths
-- Need to convert the data type to avoid error

Select Location, date, total_cases, total_deaths, (CONVERT(float,total_deaths)/NULLIF(CONVERT(float,total_cases),0))*100 as DeathPercentage
From PortfolioProject..CovidDeath
Where continent is not null
-- Where location like '%germany%'
order by 1,2

-- Looking at the total Case vs Population 
-- Shows what population got infected 

Select Location, date, population, total_cases, (CONVERT(float,total_cases)/NULLIF(CONVERT(float,population),0))*100 as PercentagePopulationInfected
From PortfolioProject..CovidDeath
Where location like '%germany%'
order by 1,2

-- Looking at countries with Highest Infection Rate compared to Population 

Select Location, population, MAX(total_cases) as HighestInfectionCount, Max (CONVERT(float,total_cases)/NULLIF(CONVERT(float,population),0))*100 as PercentagePopulationInfected
From PortfolioProject..CovidDeath
-- Where location like '%germany%'
Group by location, population
order by PercentagePopulationInfected desc

Select Location, MAX(CONVERT(float,total_deaths,0)) as TotalDeathCount
From PortfolioProject..CovidDeath
-- Where location like '%germany%'
Where continent is not null
Group by location
order by TotalDeathCount desc

-- We have been segregating by location where continent is null 

Select Location, MAX(CONVERT(float,total_deaths,0)) as TotalDeathCount
From PortfolioProject..CovidDeath
-- Where location like '%germany%'
Where continent is not null
Group by location
order by TotalDeathCount desc

-- LET'S BREAK THINGS DOWN BY CONTINENT


Select continent, MAX(CONVERT(float,total_deaths,0)) as TotalDeathCount
From PortfolioProject..CovidDeath
-- Where location like '%germany%'
Where continent is not null
Group by continent
order by TotalDeathCount desc

-- GLOBAL NUMBER
-- Introduction of aggregrate funtion
-- Error invalid column name new (input cast)

Select date, SUM(new_cases) as total_cases, SUM(cast(new_deaths as bigint)) as total_deaths
From PortfolioProject..CovidDeath
-- Where location like '%germany%'
where continent is not null
Group By date
order by 1,2

Select date, SUM(new_cases) as total_cases, 
SUM(cast(new_deaths as bigint)) as total_deaths, 
CASE WHEN SUM(new_cases) = 0 THEN 0 -- Handle division by zero 
ELSE SUM(CAST(new_deaths AS BIGINT))/ (SUM(new_cases) * 100)
END as DeathPercentage
From PortfolioProject..CovidDeath
-- Where location like '%germany%'
where continent is not null
Group By date
order by 1,2

Select SUM(new_cases) as total_cases, 
SUM(cast(new_deaths as bigint)) as total_deaths, 
CASE WHEN SUM(new_cases) = 0 THEN 0 -- Handle division by zero 
ELSE SUM(CAST(new_deaths AS BIGINT))/ (SUM(new_cases) * 100)
END as DeathPercentage
From PortfolioProject..CovidDeath
-- Where location like '%germany%'
where continent is not null
--Group By date
order by 1,2

-- Looking at total Population vs Vaccination

Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(bigint,vac.new_vaccinations)) OVER (Partition by dea.location Order by dea.location, dea.date) as GrossVaccinatedPeople
From PortfolioProject..CovidDeath dea
Join PortfolioProject..CovidVacination vac
	On dea.location = vac.location
	and dea.date = vac.date
	where dea.continent is not null
	order by 2,3

-- TEMP TABLE
DROP Table if exists #PercentPopulationVaccinated
Create Table #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccinations numeric,
GrossVaccinatedPeople numeric
)
Insert into #PercentPopulationVaccinated
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(bigint,vac.new_vaccinations)) OVER (Partition by dea.location Order by dea.location, dea.date) as GrossVaccinatedPeople
--, (RollingPeopleVaccinated/population)*100
From PortfolioProject..CovidDeath dea
Join PortfolioProject..CovidVacination vac
	On dea.location = vac.location
	and dea.date = vac.date
	where dea.continent is not null
--order by 2,3

Select *, (GrossVaccinatedPeople/Population)*100
From #PercentPopulationVaccinated

Create View PercentPopulationVaccinated as
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(bigint,vac.new_vaccinations)) OVER (Partition by dea.location Order by dea.location, dea.date) as GrossVaccinatedPeople
--, (RollingPeopleVaccinated/population)*100
From PortfolioProject..CovidDeath dea
Join PortfolioProject..CovidVacination vac
	On dea.location = vac.location
	and dea.date = vac.date
	where dea.continent is not null
--order by 2,3

Select *
From PercentPopulationVaccinated
