SELECT * 
FROM PortofolioProject..CovidDeaths
ORDER BY 3,4;

--SELECT * 
--FROM PortofolioProject..CovidVaccinations
--ORDER BY 3,4;

--Select data that we are going to be using

SELECT location, date, total_cases, new_cases, total_deaths, population
FROM PortofolioProject..CovidDeaths
ORDER BY 1, 2

--Look at total cases of total deaths

SELECT location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 AS DeathPercentage
FROM PortofolioProject..CovidDeaths
WHERE location like '%states%'
ORDER BY 1, 2

-- Looking at total cases VS population
-- shows the percentage of population got Covid-19

SELECT location, date, total_cases, population, (total_cases/population)*100 AS Infectedrate
FROM PortofolioProject..CovidDeaths
ORDER BY 1, 2

-- looking at China's total cases vs populution, percentage of population got covid-19 

SELECT location, date, population, total_cases, total_deaths, (total_deaths/total_cases)*100 AS DeathPercentage, (total_cases/population)*100 AS Infectedrate
FROM PortofolioProject..CovidDeaths
WHERE location like '%China%'
ORDER BY 1, 2

-- Which country has the highest infection rate? - Done by Yifei

SELECT location, date, population, total_cases, (total_cases/population)*100 AS Infectionrate
FROM PortofolioProject..CovidDeaths
WHERE (total_cases/population)*100 IS NOT NULL
ORDER BY 5 DESC

-- Which country has the highest infection rate? - Done by Alex

SELECT location, population, MAX(total_cases) AS HighestinfectionCount, MAX(total_cases/population)*100 AS Infectionrate
FROM PortofolioProject..CovidDeaths
GROUP BY location, population
ORDER BY Infectionrate DESC

-- showing countries with highest death count per country

SELECT location, population, MAX(CAST(total_deaths as int)) AS HighestdeathCount
FROM PortofolioProject..CovidDeaths
WHERE continent IS NOT NULL
GROUP BY location, population
ORDER BY HighestdeathCount DESC

--Let's break down to the continent (WITHOUT including world, international, European Union)

SELECT continent, MAX(CAST(total_deaths as int)) AS HighestdeathCount
FROM PortofolioProject..CovidDeaths
WHERE continent IS NOT NULL
GROUP BY continent
ORDER BY HighestdeathCount DESC

--Lets' break things down by continent (INCLUDING world, international, European Union)

SELECT location, MAX(CAST(total_deaths as int)) AS HighestDeathCount
FROM PortofolioProject..CovidDeaths
WHERE continent IS NULL
GROUP BY location
ORDER BY HighestdeathCount DESC

-- showing contitents with highest death count per population

SELECT continent, MAX(CAST(total_deaths as int)/population) AS HighestdeathCountPerPopulation
FROM PortofolioProject..CovidDeaths
WHERE continent IS NOT NULL AND population IS NOT NULL
GROUP BY continent
ORDER BY HighestdeathCountPerPopulation DESC

-- Global numbers

SELECT SUM(new_cases) as Global_total_cases, SUM(CAST(new_deaths as int)) as Global_total_deaths, SUM(CAST(new_deaths as int))/SUM(new_cases)* 100 as Global_deaths_percentage
FROM PortofolioProject..CovidDeaths
ORDER BY 1

--Look at the tabel dbo.CovidVaccinaions 

SELECT *
FROM PortofolioProject..CovidDeaths

SELECT * 
FROM PortofolioProject..CovidVaccinations


SELECT *
FROM PortofolioProject..CovidDeaths as dea
JOIN PortofolioProject..CovidVaccinations as vac 
    ON dea.location = vac.location 
	   AND dea.date = vac.date 

-- Looking at Total Populations vs Vaccinations 


-- USE CTE

With PopvsVac (Continent, Location, Date, Population, New_vaccinations, RollingPeopleVaccinated)
as
(
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations 
       ,SUM(CONVERT(int, vac.new_vaccinations)) OVER (Partition by dea.location Order by dea.location, dea.date) as RollingPeopleVaccinated 
	   ---,(RollingPeopleVaccinated/dea.population) * 100 as VaccinatedPerPopulation 
FROM PortofolioProject..CovidDeaths as dea  
JOIN PortofolioProject..CovidVaccinations as vac 
    ON dea.location = vac.location 
	   AND dea.date = vac.date
WHERE dea.continent IS NOT NULL
--ORDER BY 2, 3
)

SELECT *, (RollingPeopleVaccinated/population) * 100 as VaccinatedPerPopulation 
FROM PopvsVac

--TEMP TABLE

DROP Table if exists #Percent_Population_Vaccinated
Create Table #Percent_Population_Vaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccinations numeric,
RollingPeopleVaccinated numeric
)

insert into #Percent_Population_Vaccinated
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations 
       ,SUM(CONVERT(int, vac.new_vaccinations)) OVER (Partition by dea.location Order by dea.location, dea.date) as RollingPeopleVaccinated 
	   ---(RollingPeopleVaccinated/dea.population) * 100 
FROM PortofolioProject..CovidDeaths as dea  
JOIN PortofolioProject..CovidVaccinations as vac 
    ON dea.location = vac.location 
	   AND dea.date = vac.date
WHERE dea.continent IS NOT NULL
--ORDER BY 2, 3

SELECT *, (RollingPeopleVaccinated/Population)*100
FROM #Percent_Population_Vaccinated

--Create view to store data for later visualization

Create View PercentPopulationVaccinated as 
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations 
       ,SUM(CONVERT(int, vac.new_vaccinations)) OVER (Partition by dea.location Order by dea.location, dea.date) as RollingPeopleVaccinated 
	   ---(RollingPeopleVaccinated/dea.population) * 100 
FROM PortofolioProject..CovidDeaths as dea  
JOIN PortofolioProject..CovidVaccinations as vac 
    ON dea.location = vac.location 
	   AND dea.date = vac.date
WHERE dea.continent IS NOT NULL
--ORDER BY 2, 3

