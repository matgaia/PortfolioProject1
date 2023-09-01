--Verifying first that the database has been imported correctly
--SELECT * 
--FROM PortfolioProject..CovidDeaths
--WHERE continent is not null

--SELECT *
--FROM PortfolioProject..CovidVaccination
--WHERE continent is not null

--Looking at COVID 19 mortality in Brazil 
--Shows the mortality rate among people who contracted the disease
SELECT location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as mortality
FROM PortfolioProject..CovidDeaths
Where location = 'Brazil'
AND total_deaths is not NULL
Order by 2,1

--Looking at COVID 19 infection rate in Brazil 
--Shows the population's infection rate in Brazil

SELECT location, date, total_cases, population, (total_cases/population)*100 as infection_rate
FROM PortfolioProject..CovidDeaths
Where location = 'Brazil'
Order by 2,1

-- Looking at countries with highest death count per population

SELECT location, population, MAX(total_cases) as HighestInfectionCountry, MAX((total_cases/population))*100 as PercentPopulationInfected
FROM PortfolioProject..CovidDeaths
Group by Location, population
Order by PercentPopulationInfected desc

--Showing Countries ranked by highest mortality number

SELECT location, MAX(cast(total_deaths as int)) as TotalDeathCount
From PortfolioProject..CovidDeaths
WHERE continent is not null 
Group by Location, population
Order By TotalDeathCount desc

--Showing Continents ranked by Death Count 
 
 SELECT location, MAX(cast(total_deaths as int)) as TotalDeathCount
From PortfolioProject..CovidDeaths
WHERE
(
	(continent is null)
)
AND
(
	(location <> 'European Union')
AND
	(location <> 'International')
AND
	(location <> 'World')
)
Group by location
Order By TotalDeathCount desc

--Global Numbers (total cases, total deaths, mortality rate)

SELECT SUM(new_cases) as total_cases, SUM(cast(new_deaths as Int)) as total_deaths, SUM(cast(new_deaths as Int))/SUM(New_Cases)*100 as mortality
FROM PortfolioProject..CovidDeaths
--Where location = 'Brazil'
WHERE continent is not NULL
--Group By date
Order by 2,1


-- Looking at Global Vaccination rate

SELECT dea.continent, dea.location, dea.date, dea. population, vac.new_vaccinations
, SUM(Convert(int,vac.new_vaccinations)) OVER (Partition by dea.location Order by dea.location, dea.Date) as RollingPopulationVaccinated
FROM PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccination vac
	ON dea.location = vac. location
	and dea.date = vac.date
WHERE dea.continent is not null
order by 2,3

-- USE CTE

With PopvsVac (continent, location, date, population, new_vaccinations, RollingPopulationVaccinated)
as
(
SELECT dea.continent, dea.location, dea.date, dea. population, vac.new_vaccinations
, SUM(Convert(int,vac.new_vaccinations)) OVER (Partition by dea.location Order by dea.location, dea.Date) as RollingPopulationVaccinated
FROM PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccination vac
	ON dea.location = vac. location
	and dea.date = vac.date
WHERE 
(
	(dea.continent is not null)
AND
	(vac.new_vaccinations is not null)
)
)
SELECT*, (RollingPopulationVaccinated/population)*100
FROM PopvsVac
ORDER BY 7



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
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccination vac
	On dea.location = vac.location
	and dea.date = vac.date
WHERE 
(
	(dea.continent is not null)
AND
	(vac.new_vaccinations is not null)
)
--where dea.continent is not null 
--order by 2,3

Select *, (RollingPeopleVaccinated/Population)*100
From #PercentPopulationVaccinated
Order by 7

-- Create view to store data for later visualizations

CREATE VIEW PercentPopulationVaccinated as
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccination vac
	On dea.location = vac.location
	and dea.date = vac.date
WHERE 
(
	(dea.continent is not null)
AND
	(vac.new_vaccinations is not null)
)
