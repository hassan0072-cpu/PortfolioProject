select*
from PortfolioProject.dbo.COVIDDEATHS$
where continent is not null
order by 3,4
--select*
--from PortfolioProject.dbo.CovidVaccinations$
--order by 3,4

select location, date, total_cases,new_cases,total_deaths,population
from PortfolioProject.dbo.COVIDDEATHS$
order by 1,2


-- Looking at Total Cases Vs Total Deaths
--Shows Likelihood of dying if you contract Covid In Your Country
Select location, date, total_cases,total_deaths, 
(CONVERT(float, total_deaths) / NULLIF(CONVERT(float, total_cases), 0)) * 100 AS Deathpercentage
from PortfolioProject.dbo.COVIDDEATHS$
Where location like '%India%'
order by 1,2

--Looking At Total Cases Vs Population
--shows what percentage population got Covid
Select location, date, population,total_cases,
(CONVERT(float, total_cases) / NULLIF(CONVERT(float,population ), 0)) * 100 AS  PercentagePopulaionInfected
from PortfolioProject.dbo.COVIDDEATHS$
Where location like '%India%'
order by 1,2


--looking at Countries Having Highest infection rate compared to population
Select location,population, max(total_cases) as HighestInfectionCount, Max(total_cases/population)*100 as PercentagePopulaionInfected
from PortfolioProject.dbo.COVIDDEATHS$
--Where location like '%states%'
group by location,population
order by PercentagePopulaionInfected desc

--Showing countries with highest death count per population
 select location,max (cast(total_deaths as int)) as TotalDeathCounts
 from PortfolioProject..COVIDDEATHS$
 --where location like '%states%'
 where continent is not null
 group by location
 order by TotalDeathCounts Desc
 
 
 --LETS BREAK THINGS DOWN BY CONTINENT
 

 -- showing Continents with the highest death count PER Population
 select continent,max (cast(total_deaths as int)) as TotalDeathCounts
 from PortfolioProject..COVIDDEATHS$
 --where location like '%states%'
 where continent is not  null
 group by continent
 order by TotalDeathCounts Desc


 -- ACROSS GLOBAL NUMBER
 Select SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths,SUM(cast(new_deaths as int))/SUM(New_Cases)*100 as DeathPercentage
From PortfolioProject.dbo.COVIDDEATHS$
--Where location like '%states%'
where continent is not null 
--Group By date
order by 1,2


-- Looking at Total Population vs Vaccinations
-- Shows Percentage of Population that has recieved at least one Covid Vaccine

Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(bigint,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
--,(RollingPeopleVaccinated/population)*100
From PortfolioProject..COVIDDEATHS$ dea
Join PortfolioProject..CovidVaccinations$ vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null 
order by 2,3


--USE CTE
With PopvsVac (continent, location, date, population,new_vaccinations, RollingPeopleVaccinated)
as
(
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(bigint,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
--,(RollingPeopleVaccinated/population)*100
From PortfolioProject..COVIDDEATHS$ dea
Join PortfolioProject..CovidVaccinations$ vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null 
--order by 2,3
)
select*,(RollingPeopleVaccinated/population)*100 as RollingPeopleVacciatedPercentage
from PopvsVac



--Temp Table
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
, SUM(CONVERT(bigint,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From PortfolioProject..COVIDDEATHS$ dea
Join PortfolioProject..CovidVaccinations$ vac
	On dea.location = vac.location
	and dea.date = vac.date
--where dea.continent is not null 
--order by 2,3

Select *, (RollingPeopleVaccinated/Population)*100
From #PercentPopulationVaccinated


-- Creating View to store data for later visualizations

CREATE VIEW PercentPopulationVaccinated AS
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(bigint,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From PortfolioProject..COVIDDEATHS$ dea
Join PortfolioProject..CovidVaccinations$ vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null 
--order by 2,3

SELECT*
FROM PercentPopulationVaccinated
