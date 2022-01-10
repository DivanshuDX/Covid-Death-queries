SELECT *
FROM PortfolioProject..CovidDeaths
order by 3, 4

Select *
from PortfolioProject..CovidVaccinations
order by 3, 4

-- 1.Comparing total deaths per total cases

SELECT location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as Deathpercentage 
FROM PortfolioProject..CovidDeaths 
Where location = 'India'
and date = '2022-01-04 00:00:00:000'
order by 1, 2

-- 2.Showing Total cases per population

SELECT location, date, population, total_cases, (total_cases/population)*100 as Covidpercentage 
FROM PortfolioProject..CovidDeaths
Where location like 'India'
and continent is not null
order by 1, 2

-- 3.Looking for countries with Highest Infection rate compared to Population

SELECT Location, Population, MAX(total_cases) as HighInfectCount, MAX((total_cases/population))*100 as InfectPercentage 
FROM PortfolioProject..CovidDeaths
Where location like 'India'
GROUP BY Location, Population
ORDER BY InfectPercentage desc

-- 4.Showing Highest death rate per population

SELECT location, MAX(cast(total_deaths as int)) as TotalDeathCount 
FROM PortfolioProject..CovidDeaths
--Where location like 'India'
WHERE continent is not null
GROUP BY location
order by TotalDeathCount desc

-- 5.Showing continents with highest death rate per population

SELECT continent, MAX(cast(total_deaths as int)) as TotalDeathCount 
FROM PortfolioProject..CovidDeaths
--Where location like 'India'
WHERE continent is not null
GROUP BY continent
order by TotalDeathCount desc

-- GLOBAL NUMBERS

SELECT sum(new_cases) as Totalcases, sum(cast(new_deaths as int)) as TotalDeaths, 
	(sum(cast(new_deaths as int))/sum(new_cases))*100 as Totaldeathpercentage
FROM PortfolioProject..CovidDeaths
WHERE continent is not null
--GROUP BY date
ORDER BY 1, 2 


-- Looking at total population VS Vaccinations


WITH PopvsVac (Continent, Location , Date, Population, New_Vaccinations, Rollingpeoplevaccinated)
as
(
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(cast(vac.new_vaccinations as int)) OVER 
(PARTITION BY dea.location ORDER BY dea.location, dea.date) as Rollingpeoplevaccinated
FROM PortfolioProject..CovidDeaths dea
JOIN PortfolioProject..CovidVaccinations vac
	on dea.location = vac.location
	and dea.date = vac.date
WHERE dea.continent is not null
and dea.location is not null
--ORDER BY 2,3 
)
SELECT *, (Rollingpeoplevaccinated/Population)*100 as PopulationVAC
FROM PopvsVac


-- Temp Table

CREATE TABLE #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_Vaccinations numeric,
RollingPeopleVaccinated numeric,
)
INSERT INTO #PercentPopulationVaccinated
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER 
(PARTITION BY dea.location ORDER BY dea.location, dea.date) as Rollingpeoplevaccinated
FROM PortfolioProject..CovidDeaths dea
JOIN PortfolioProject..CovidVaccinations vac
	on dea.location = vac.location
	and dea.date = vac.date
WHERE dea.continent is not null
--ORDER BY 2,3 

SELECT *, (Rollingpeoplevaccinated/Population)*100 as PopulationVAC
FROM #PercentPopulationVaccinated

