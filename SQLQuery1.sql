Select *
From [Covid_19 ]..covid_deaths
Where continent is not null 
order by 3,4

--Select *
--From [Covid_19 ]..covid_vaccinations
--order by 3,4

-- Select data that we are going to be using
 Select location, date, total_cases, new_cases, total_deaths, population
 From [Covid_19 ]..covid_deaths
 Where continent is not null 
 order by 1,2


-- Looking at Total Cases vs Total Deaths 

 Select location, date, total_cases, total_deaths, 
	CASE
        WHEN TRY_CAST(total_cases AS float)*100 = 0 THEN NULL
        ELSE total_deaths / TRY_CAST(total_cases AS float)*100
    END AS death_Precentage
 From [Covid_19 ]..covid_deaths
 Where location like '%latvia%'
 and continent is not null 
 order by 1,2

 -- total cases vs population 
-- shows what percentage of population got Covid
 
 -- shows what bagg 
 Select location, population, total_cases, date
 From [Covid_19 ]..covid_deaths 
 where location like '%cyprus%'
 and continent is not null 
 --GROUP BY location, population
 ORDER BY date desc;
 
 
  Select location, population, MAX((total_cases)) as HighestInfectionCount
 From [Covid_19 ]..covid_deaths 
 where location like '%cyprus%'
 and continent is not null
 GROUP BY location, population 
 ORDER BY HighestInfectionCount desc;
  

 --Countries with highest infection rate compared to Population

 Select location, population, MAX(cast(total_cases as int)) as HighestInfectionCount, Max((total_cases/population))*100 as PercentPopulationInfected
 From [Covid_19 ]..covid_deaths 
 --where location like '%latvia%'
 Where continent is not null
 Group by location, population
 order by  PercentPopulationInfected desc;

 -- Breaking things down by continent
 Select location, MAX(cast(total_deaths as int)) as TotalDeaths, MAX((total_deaths/population))*100 as PearcentageOfDeaths
 From [Covid_19 ]..covid_deaths 
 --where location like '%latvia%'
 Where continent is null
 Group by location
 order by  PearcentageOfDeaths desc;


-- Showing countries with highest Death Count per Population
 Select location, MAX(cast(total_deaths as int)) as TotalDeaths, MAX((total_deaths/population))*100 as PearcentageOfDeaths
 From [Covid_19 ]..covid_deaths 
 where location like '%states%'
 and continent is not null
 Group by location
 order by  PearcentageOfDeaths desc;

 
 -- Showing continents with the highest death count per population 

 Select location, MAX(cast(total_deaths as int)) as TotalDeaths, MAX((total_deaths/population))*100 as PearcentageOfDeaths
 From [Covid_19 ]..covid_deaths 
 --where location like '%latvia%'
 Where continent is null
 Group by location
 order by  PearcentageOfDeaths desc;

-- Gloabal numbers
 Select SUM(cast(new_cases as int)) as Total_cases, SUM(cast(new_deaths as int)) as Total_deaths, COALESCE(SUM(CAST(new_deaths AS int)) / NULLIF(SUM(new_cases), 0) * 100, 0) AS death_percentage
 From [Covid_19 ]..covid_deaths
 Where continent is not null 
 --Group by date
 order by 1,2

--Looking at Total population vs Vaccinations  
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(convert(bigint, vac.new_vaccinations)) over (Partition by dea.location Order by dea.location, 
dea.date) as RollingPeopleVaccinated
From [Covid_19 ]..covid_deaths dea
Join [Covid_19 ]..covid_vaccinations vac
on dea.location = vac.location
and dea.date = vac.date
Where dea.continent is not null 
order by 2,3 

-- USE CTE 
With PopvsVac (Continent, location, date, population, new_vaccinations, RollingPeopleVaccinated)
as 
(
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(convert(bigint, vac.new_vaccinations)) over (Partition by dea.location)
From [Covid_19 ]..covid_deaths dea
Join [Covid_19 ]..covid_vaccinations vac
on dea.location = vac.location
and dea.date = vac.date
Where dea.continent is not null 
--order by 2,3 
)
Select *, (RollingPeopleVaccinated/population)*100
From PopvsVac

-- TEMP TABLE 
Drop Table if exists #PercentPopulationVaccinated
Create Table #PercentPopulationVaccinated
(
Continent nvarchar(255), 
Location nvarchar(255), 
Date datetime, 
Population numeric, 
New_vaccinations numeric, 
RollingPeopleVaccinated numeric
)

Insert into #PercentPopulationVaccinated
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(convert(bigint, vac.new_vaccinations)) over (Partition by dea.location)
From [Covid_19 ]..covid_deaths dea
Join [Covid_19 ]..covid_vaccinations vac
on dea.location = vac.location
and dea.date = vac.date
Where dea.continent is not null 
--order by 2,3 

Select *, (RollingPeopleVaccinated/population)*100
From #PercentPopulationVaccinated


-- Creating view to store data for later visualizations 
USE [Covid_19 ]
go
Create View PercentVaccinatedPopulation as
Select 
	dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
	, SUM(convert(bigint, vac.new_vaccinations)) over (Partition by dea.location Order by dea.location, 
	dea.date) as RollingPeopleVaccinated
From 
	[Covid_19 ]..covid_deaths dea
Join 
	[Covid_19 ]..covid_vaccinations vac
on 
	dea.location = vac.location
	and dea.date = vac.date
Where 
	dea.continent is not null 
--order by 2,3


 Select location, MAX(cast(total_deaths as int)) as TotalDeaths, MAX((total_deaths/population))*100 as PearcentageOfDeaths
 From [Covid_19 ]..covid_deaths 
 --where location like '%latvia%'
 Where continent is null
 Group by location
 order by  PearcentageOfDeaths desc;

 Select *
 From PercentVaccinatedPopulation