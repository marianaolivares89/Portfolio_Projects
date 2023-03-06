/*
Queries used for Tableau Project
*/


-- 1.


--Global numbers per date

SELECT SUM(CAST (new_cases as float)) as total_cases, SUM(CAST (new_deaths as float)) as total_deaths, SUM(CAST (new_deaths as float))/SUM(CAST (new_cases as float))*100 AS Deaths_Percentage
FROM [Portfolio Project]..covid_deaths
WHERE continent is not null 
-- GROUP BY date
ORDER BY 1,2


-- 2. 

-- We take these out as they are not inluded in the above queries and want to stay consistent
-- European Union is part of Europe

SELECT location, MAX (CAST (total_deaths AS float)) AS Total_Death_Count
FROM [Portfolio Project]..covid_deaths
WHERE continent is null
AND location not in ('World', 'European Union', 'International', 'High income', 'Upper middle income', 'Lower middle income', 'Low income')
GROUP BY location
ORDER BY Total_Death_Count desc


-- 3.

SELECT location, population, MAX (CAST (total_cases AS float)) AS Highest_Infection_Count, MAX(CAST (total_cases AS float) / CAST (population AS float)*100) AS Percentage_Population_Infected
FROM [Portfolio Project]..covid_deaths
WHERE continent is not null
GROUP BY location, population
ORDER BY Percentage_Population_Infected desc


-- 4.

SELECT location, population, date, MAX (CAST (total_cases AS float)) AS Highest_Infection_Count, MAX(CAST (total_cases AS float) / CAST (population AS float)*100) AS Percentage_Population_Infected
FROM [Portfolio Project]..covid_deaths
WHERE continent is not null
GROUP BY location, population, date
ORDER BY Percentage_Population_Infected desc





