--SELECT * FROM PortfolioProject..CovidDeaths
--ORDER BY 3,4

--SELECT * FROM PortfolioProject..CovidVaccinations
--ORDER BY 3,4

--Select data we are going to be using

--SELECT Location, date, total_cases, new_cases, total_deaths, population 
--from PortfolioProject..CovidDeaths
--order by 1,2

--Loking at total cases vs total deaths

SELECT Location, date, total_cases, total_deaths, (cast(total_deaths as float)/total_cases)*100 as DeathPercentage
from PortfolioProject..CovidDeaths
where location like '%states%'
order by 1,2



-- looking at total cases vs Population
--shows what percentage of population had got the covid
SELECT Location, date, population, total_cases, (total_cases/population)*100 as PercentPopulaionInfected
from PortfolioProject..CovidDeaths
where location like '%Lithuania%'
order by 1,2

--Loking at Countries with highest infection vs Population
SELECT Location, population, MAX(total_cases) as HighestInfectionCount,  MAX((total_cases/population))*100 as PercentPopulaionInfected
from PortfolioProject..CovidDeaths
--where location like '%Lithuania%'
group by location, population
order by PercentPopulaionInfected desc


--Showing Countries with highest death count per population

SELECT Location, MAX(cast(total_deaths as int)) as TotalDeath
from PortfolioProject..CovidDeaths
where continent is not NULL
group by location
order by TotalDeath desc

--Lets break things down by continent
SELECT location, MAX(cast(total_deaths as int)) as TotalDeath
from PortfolioProject..CovidDeaths
where continent is NULL
group by location
order by TotalDeath desc


--Global numbers
SELECT date, SUM(new_cases) as total_cases, SUM(new_deaths) as total_deaths--, SUM(new_deaths)/SUM(new_cases)*100 as deathPecentage
from PortfolioProject..CovidDeaths
where continent is not NULL
group by date
order by 1,2

--JOIN tables together
--Looking at total population vs vaccinations
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, SUM(CONVERT(int, vac.new_vaccinations)) OVER (Partition by dea.location order by dea.location, dea.date)
FROM PortfolioProject..CovidVaccinations vac
JOIN PortfolioProject..CovidDeaths dea
	ON dea.location = vac.location
	AND dea.date = vac.date
where dea.continent is not NULL
order by 2,3


--Create table
drop table if exists #PercentPopulationVaccinated
Create table #PercentPopulationVaccinated
(
continent nvarchar(255),
location nvarchar(255),
date datetime,
population numeric,
new_vaccinations numeric,
RollingPeopleVaccinated	numeric
)
insert into #PercentPopulationVaccinated
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, SUM(cast(vac.new_vaccinations as float)) OVER (Partition by dea.location order by dea.location, dea.date) as RollingPeaopleVaccinated
FROM PortfolioProject..CovidVaccinations vac
JOIN PortfolioProject..CovidDeaths dea
	ON dea.location = vac.location
	AND dea.date = vac.date
where dea.continent is not NULL
--order by 2,3

SELECT *, (RollingPeopleVaccinated/population)*100
from #PercentPopulationVaccinated



-- Creating view to store data for later vizualizations

Create View PercentPopulationVaccinated as
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, SUM(cast(vac.new_vaccinations as float)) OVER (Partition by dea.location order by dea.location, dea.date) as RollingPeaopleVaccinated
FROM PortfolioProject..CovidVaccinations vac
JOIN PortfolioProject..CovidDeaths dea
	ON dea.location = vac.location
	AND dea.date = vac.date
where dea.continent is not NULL
--order by 2,3

select * from PercentPopulationVaccinated