Select * 
From CovidDeaths
Where continent is not null
order by 3,4

Select * 
From CovidVaccinations
Where continent is not null
order by 3,4

	
--Important Data

Select location,date,total_cases,new_cases,total_deaths,population
From CovidDeaths
Where continent is not null
Order by 1,2

	
--Total Cases Vs Total Deaths
--Shows the likelyhood of dying if you contract covid in Kenya

Select location,date,total_cases,total_deaths,(total_deaths/total_cases)*100 as DeathPercentage
From CovidDeaths
Where location like '%Kenya%'
and continent is not null
Order by 1,2

	
--Total Cases Vs Population
--shows the percentage of population infected with covid

Select location,date,population,total_cases,(total_cases/population)*100 as PercentPopulationInfected
From CovidDeaths
Order by 1,2
	

--Countries with the highest infection rate compared to the population

Select location,population,Max(Total_cases) as HighestInfectCount,Max((total_cases/population))*100 as PercentPopulationInfected
From CovidDeaths
Group by location,population
Order by PercentPopulationInfected desc
	

--Countries with the highest death counts per population

Select location,Max(cast(total_deaths as int)) as TotalDeathCount
From CovidDeaths
Where continent is not null
Group by location
Order by TotalDeathCount desc

	
--BREAKING BY CONTINENTS

--Showing continents with the highest death count per population

Select location,Max(cast(total_deaths as int)) as TotalDeathCount
From CovidDeaths
Where continent is null
Group by location
Order by TotalDeathCount desc

	
--Global Numbers

Select SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, SUM(cast(new_deaths as int))/SUM(New_Cases)*100 as DeathPercentage
From CovidDeaths
where continent is not null 
order by 1,2


--Total population vs vaccinations
--Shows the number of people who have received at least one Covid vaccine
	

Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From CovidDeaths dea
Join CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null 
order by 2,3
	

--Using CTE to perform Calculation on Partition By in previous query
	

With PopvsVac (Continent, Location, Date, Population, New_Vaccinations, RollingPeopleVaccinated)
as
(
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From CovidDeaths dea
Join CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null 
--order by 2,3
)
Select *, (RollingPeopleVaccinated/Population)*100
From PopvsVac
	

-- Using Temp Table to perform Calculation on Partition By in previous query
	

DROP Table if exists #PercentPopulationVaccinated
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
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From CovidDeaths dea
Join CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
--where dea.continent is not null 
--order by 2,3

Select *, (RollingPeopleVaccinated/Population)*100
From #PercentPopulationVaccinated
	

--Create View to store data for later visualizations
	

Create View PercentPopulationVaccinated as
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From CovidDeaths dea
Join CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null 








