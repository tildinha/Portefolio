SELECT *
FROM Portefolio..CovidDeaths
WHERE continent is not null
ORDER BY 3,4

SELECT *
FROM Portefolio..CovidVaccinations
ORDER BY 3,4

 -- Selecting data we'll be using

 SELECT location, date, total_cases, new_cases, total_deaths, population
 FROM Portefolio..CovidDeaths
 WHERE continent is not null
 ORDER BY 1,2

 -- Total Cases vs Total Deaths
 -- Seeing the likehood of someone dying if they contract COVID19 in Portugal

 SELECT location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as deathpercentage
 FROM Portefolio..CovidDeaths
 WHERE location like 'Portugal'
 and continent is not null
 ORDER BY 1,2

 -- Total Cases vs Population
 -- Seeing the percentage of portuguese people that got COVID19
 SELECT location, date, population, total_cases, (total_cases/population)*100 as infectedpercentage
 FROM Portefolio..CovidDeaths
 WHERE location like 'Portugal'
 and continent is not null
 ORDER BY 1,2

 -- Analyzing the infection rate by country

 SELECT location, population, MAX(total_cases) as highestinfectioncount, MAX((total_cases/population))*100 as infectedpercentage
 FROM Portefolio..CovidDeaths
 WHERE continent is not null
 GROUP BY location, population
 ORDER BY infectedpercentage desc

 -- Analyzing the death rate by country

 SELECT location, MAX(cast(total_deaths as int)) as totaldeathcount
 FROM Portefolio..CovidDeaths
 WHERE continent is not null
 GROUP BY location
 ORDER BY totaldeathcount desc

 -- Analyzing the death rate by continent

 SELECT continent, MAX(cast(total_deaths as int)) as totaldeathcount
 FROM Portefolio..CovidDeaths
 WHERE continent is not null
 GROUP BY continent
 ORDER BY totaldeathcount desc

 -- Global numbers

 --By Date
 SELECT date, SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, SUM(cast(new_deaths as int))/SUM(new_cases)*100 as deathpercentage
 FROM Portefolio..CovidDeaths
 WHERE continent is not null
 GROUP BY date
 ORDER BY 1,2

 --Overall
 SELECT SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, SUM(cast(new_deaths as int))/SUM(new_cases)*100 as deathpercentage
 FROM Portefolio..CovidDeaths
 WHERE continent is not null
 ORDER BY 1,2

-- Total Population vs Vaccinations
-- Using CTE

WITH PopvsVac(continent, location, date, population, new_vaccinations, totalvacc)
AS
(
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, SUM(Cast(vac.new_vaccinations as bigint))
 OVER (Partition by dea.location ORDER BY dea.location, dea.date) as totalvacc
 FROM Portefolio..CovidDeaths dea
 Join Portefolio..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
WHERE dea.continent is not null
)
SELECT *, (totalvacc/population)*100
FROM PopvsVac

-- Creating a Temp Table

DROP TABLE IF exists #PercentPopulationVaccinated
CREATE TABLE #PercentPopulationVaccinated
(
continent nvarchar(255),
location nvarchar(255),
date datetime,
population numeric,
new_vaccinations numeric,
totalvacc numeric
)

INSERT INTO #PercentPopulationVaccinated
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, SUM(Cast(vac.new_vaccinations as bigint))
 OVER (Partition by dea.location ORDER BY dea.location, dea.date) as totalvacc
 FROM Portefolio..CovidDeaths dea
 Join Portefolio..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
WHERE dea.continent is not null

SELECT *, (totalvacc/population)*100
FROM #PercentPopulationVaccinated

-- Creating view to store data for later visualizations

CREATE VIEW PercentPopulationVaccinated as
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, SUM(Cast(vac.new_vaccinations as bigint))
 OVER (Partition by dea.location ORDER BY dea.location, dea.date) as totalvacc
 FROM Portefolio..CovidDeaths dea
 Join Portefolio..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
WHERE dea.continent is not null

SELECT *
FROM PercentPopulationVaccinated
