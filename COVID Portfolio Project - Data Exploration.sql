/*
Covid 19 Data Exploration 
Skills used: Joins, CTE's, Temp Tables, Windows Functions, Aggregate Functions, Creating Views, Converting Data Types
*/

SELECT *
FROM [Portfolio Project]..covid_deaths
WHERE continent is not null
ORDER BY 3,4

-- Select Data that we are going to be starting with

SELECT location, date, total_cases, new_cases, total_deaths, population
FROM [Portfolio Project]..covid_deaths
WHERE continent is not null
ORDER BY 1,2


-- Total cases Vs Total Deaths
-- Shows the probability of dying if you get COVID in Argentina

SELECT location, date, total_cases, total_deaths, CAST (total_deaths AS float) / CAST (total_cases AS float)*100 AS Deaths_Percentage
FROM [Portfolio Project]..covid_deaths
WHERE continent is not null 
AND location = 'Argentina'
ORDER BY 1,2


-- Total Cases Vs Population
-- Shows what percentage of population got COVID 

SELECT location, date, population, total_cases, CAST (total_cases AS float) / CAST (population AS float)*100 AS Percentage_Population_Infected
FROM [Portfolio Project]..covid_deaths
WHERE continent is not null
-- AND location = 'Argentina'
ORDER BY 1,2


-- Countries with Highest Infection Rate compared to Population

SELECT location, population, MAX (CAST (total_cases AS float)) AS Highest_Infection_Count, MAX(CAST (total_cases AS float) / CAST (population AS float)*100) AS Percentage_Population_Infected
FROM [Portfolio Project]..covid_deaths
WHERE continent is not null
GROUP BY location, population
ORDER BY Percentage_Population_Infected desc


-- Countries with Highest Death Count per Population

SELECT location, MAX (CAST (total_deaths AS float)) AS Total_Death_Count
FROM [Portfolio Project]..covid_deaths
WHERE continent is not null
GROUP BY location
ORDER BY Total_Death_Count desc



-- BREAKING THINGS DOWN BY CONTINENT

-- Showing contintents with the highest death count per population

SELECT location, MAX (CAST (total_deaths AS float)) AS Total_Death_Count
FROM [Portfolio Project]..covid_deaths
WHERE continent is null
AND location <> 'World'
AND location <> 'High income'
AND location <> 'Upper middle income'
AND location <> 'Lower middle income'
AND location <> 'Low income'
AND location <> 'International'
GROUP BY location
ORDER BY Total_Death_Count desc


--Global numbers per date

SELECT date, SUM(CAST (new_cases as float)) as total_cases, SUM(CAST (new_deaths as float)) as total_deaths, SUM(CAST (new_deaths as float))/SUM(CAST (new_cases as float))*100 AS Deaths_Percentage
FROM [Portfolio Project]..covid_deaths
WHERE continent is not null 
GROUP BY date
ORDER BY 1,2


-- Global numbers
-- Using CTE to perform Calculation on Partition By 

WITH global (world_population)
AS
(
SELECT distinct (population) as world_population
FROM [Portfolio Project]..covid_deaths
WHERE location = 'World'
),
total (total_cases, total_deaths, Deaths_Percentage)
AS
(
SELECT SUM(CAST (new_cases as float)) as total_cases, 
SUM(CAST (new_deaths as float)) as total_deaths, 
SUM(CAST (new_deaths as float))/SUM(CAST (new_cases as float))*100 AS Deaths_Percentage_contagious
FROM [Portfolio Project]..covid_deaths
WHERE continent is not null 
)
SELECT *, (total_cases/world_population)*100 AS Percentage_contagious
FROM global, total;


-- Total Population vs Vaccinations
-- Shows Percentage of Population that has recieved at least one Covid Vaccine
-- Using Temp Table to perform Calculation on Partition By 

DROP TABLE if exists #Porcent_Population_Vaccinated
CREATE TABLE #Porcent_Population_Vaccinated
(
continent nvarchar(255),
location nvarchar (255),
date datetime,
population numeric, 
new_vaccinations numeric,
total_people_vaccinated numeric
)

INSERT INTO #Porcent_Population_Vaccinated
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
SUM(CONVERT(float, vac.new_vaccinations)) OVER (Partition by dea.location ORDER BY dea.location, dea.date) as total_people_vaccinated
FROM [Portfolio Project]..covid_deaths as dea
JOIN [Portfolio Project]..covid_vaccinations as vac
	ON dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.continent is not null 
ORDER BY date 

SELECT *, (total_people_vaccinated/population)*100 AS Percentage_vaccinated_per_country
FROM #Porcent_Population_Vaccinated


-- Creating View to store data for later visualizations

CREATE VIEW Porcent_Population_Vaccinated AS
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
SUM(CONVERT(float, vac.new_vaccinations)) OVER (Partition by dea.location ORDER BY dea.location, dea.date) as total_people_vaccinated
FROM [Portfolio Project]..covid_deaths as dea
JOIN [Portfolio Project]..covid_vaccinations as vac
	ON dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.continent is not null 
-- ORDER BY date 
