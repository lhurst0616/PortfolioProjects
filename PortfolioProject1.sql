--Query 1: Making sure our data is appropriate in the CovidDeaths table
SELECT * 
FROM PortfolioProject..CovidDeaths$
WHERE continent is not null
ORDER BY 3,4

--Query 2: Making sure our data is appropriate in the CovidVaccinations table
SELECT * 
FROM PortFolioProject..CovidVaccinations$
WHERE continent is not null
ORDER BY 3,4

--Query 3: Selecting the data that we are going to be using
SELECT Location, date, total_cases, new_cases, total_deaths, population
FROM PortfolioProject..CovidDeaths$
ORDER BY 1,2

--Query 4: INVESTIGATING TOTAL CASES vs. TOTAL DEATHS
--displays risk of dying if you contract Covid (by country)
SELECT Location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 AS death_percentage
FROM PortfolioProject..CovidDeaths$
WHERE location like '%states%'
AND continent is not null
ORDER BY 1,2 desc

--Query 5: INVESTIGATING TOTAL CASES vs. POPULATION
--shows percentage of population that has contracted Covid
SELECT Location, date, population, total_cases, (total_deaths/total_cases)*100 AS death_percentage
FROM PortfolioProject..CovidDeaths$
WHERE location like '%states%'
AND continent is not null
ORDER BY 1,2

--Query 6: FINDING COUNTRIES WITH HIGHEST INFECTION RATE AMONG POPULATION
SELECT location, population, MAX(total_cases) AS HighestInfectionCount, MAX((total_cases/population))*100 AS InfectedPopulation
FROM PortfolioProject..CovidDeaths$
WHERE continent is not null
GROUP BY location, population
ORDER BY InfectedPopulation desc

--Query 7: SHOWING COUNTRIES WITH HIGHEST DEATH COUNT PER POPULATION
Select location, MAX(cast(total_deaths as bigint)) AS TotalDeathCount
FROM PortfolioProject..CovidDeaths$
WHERE continent is not null
GROUP BY location 
ORDER BY TotalDeathCount desc

--Query 8: BREAKING DOWN DATA BY CONTINENT (instead of country!)
Select continent, MAX(cast(total_deaths as bigint)) AS TotalDeathCount
FROM PortfolioProject..CovidDeaths$
WHERE continent is not null
GROUP BY continent
ORDER BY TotalDeathCount desc

--Query 9: GLOBAL NUMBERS
SELECT SUM(new_cases) as total_cases, SUM(cast(new_deaths as bigint)) as total_deaths, 
	SUM(cast(new_deaths as bigint)) / SUM(New_cases) * 100 as DeathPercentage
FROM PortfolioProject..CovidDeaths$
WHERE continent is not null
ORDER BY 1,2

--Query 10: JOINING THE TABLE CovidVaccinations AND THE TABLE CovidDeaths TOGETHER on location and date
SELECT *
FROM PortfolioProject..CovidDeaths$ dea
JOIN PortfolioProject..CovidVaccinations$ vac
	ON dea.location = vac.location
	AND dea.date = vac.date

--Query 11: LOOKING AT WORLDWIDE TOTAL POPULATION VS. VACCINATIONS (USING A CTE)
WITH PopvsVac (Continent, Location, Date, Population, New_Vaccinations, RollingPeopleVaccinated)
AS
(
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
--Add new column displaying total vaccinations
SUM(cast(vac.new_vaccinations as bigint)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) AS RollingPeopleVaccinated
FROM PortfolioProject..CovidDeaths$ dea
JOIN PortfolioProject..CovidVaccinations$ vac
	ON dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.continent is not null
)
SELECT *, (RollingPeopleVaccinated / Population) * 100 as VaccinatedPercentage
FROM PopvsVac

----Query 12: LOOKING AT WORLDWIDE TOTAL POPULATION VS. VACCINATIONS (USING A TEMP TABLE)
DROP TABLE IF exists #PercentPopulationVaccinated
CREATE TABLE #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccinations numeric,
RollingPeopleVaccinated numeric
)

INSERT INTO #PercentPopulationVaccinated

SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
--Add new column displaying total vaccinations
SUM(cast(vac.new_vaccinations as bigint)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) AS RollingPeopleVaccinated
FROM PortfolioProject..CovidDeaths$ dea
JOIN PortfolioProject..CovidVaccinations$ vac
	ON dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.continent is not null

SELECT *, (RollingPeopleVaccinated / Population) * 100 as VaccinatedPercentage
FROM #PercentPopulationVaccinated

--Query 13: CREATING A VIEW TO STORE DATA FOR LATER DATA VISUALIZATIONS
CREATE VIEW PercentPopulationVacc AS 
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
SUM(cast(vac.new_vaccinations as bigint)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) AS RollingPeopleVaccinated
FROM PortfolioProject..CovidDeaths$ dea
JOIN PortfolioProject..CovidVaccinations$ vac
	ON dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.continent is not null

Select * FROM PercentPopulationVacc