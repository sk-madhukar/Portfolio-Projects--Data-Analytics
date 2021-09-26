/*
 COVID-19 Data Exploration

 Skills used: Joins, CTE's, Temp Tables, Windows Functions, Aggregate Functions, Creating Views, and Converting Data Types
*/


SELECT *
FROM portfolio_project..covid_deaths
WHERE continent is not NULL
ORDER BY 3,4


-- Select starting data, which are going to be using
SELECT location, date, total_cases, new_cases, total_deaths, population
FROM portfolio_project..covid_deaths
WHERE continent is not NULL
ORDER BY 1,2


--Total Cases vs Total Deaths
--Calculating Death Percentage according to location
SELECT location, date, population, total_cases, total_deaths, (total_deaths/total_cases)*100 AS death_percentage
FROM portfolio_project..covid_deaths
WHERE location = 'India'
	AND continent is not NULL
ORDER BY 1,2


--Total Cases vs Population
--Calculating what percentage of population infected with Covid
SELECT location, date, population, total_cases, (total_cases/population)*100 AS case_percentage
FROM portfolio_project..covid_deaths
--where location = 'India'
order by 1,2


--Calculating Countries with Highest Infection Rate compared to there Population
SELECT location, population, MAX(total_cases) AS highest_infection_count, 
		MAX((total_cases/population)*100) AS percentage_population_infected
FROM portfolio_project..covid_deaths
--where location = 'India'
GROUP BY location, population
ORDER BY percentage_population_infected DESC


--Countries with highest death count per population
SELECT location, MAX(CAST(total_deaths AS int)) AS total_death_count
FROM portfolio_project..covid_deaths
WHERE continent is not NULL
GROUP BY location
ORDER BY total_death_count DESC



--Calculating Continents with the highest death count per population
SELECT continent, MAX(cast(total_deaths AS int))AS total_death_count
FROM portfolio_project..covid_deaths
WHERE continent is not NULL
GROUP BY continent
ORDER BY total_death_count DESC


--GLOBAL NUMBERS
SELECT SUM(new_cases) AS total_cases, SUM(CAST(new_deaths AS int))AS total_deaths, 
		SUM(CAST(new_deaths AS int))/SUM(new_cases)*100 AS death_percentage
FROM portfolio_project..covid_deaths
WHERE continent is not NULL
ORDER BY 1,2


--Total Population vs Vaccinations
--Percentage of populatoion that has received at least one Covid Vaccine dose
SELECT d.continent,
		d.location,
		d.date,
		d.population,
		v.new_vaccinations,
		SUM(CONVERT(int, v.new_vaccinations)) OVER (PARTITION BY d.location ORDER BY d.location, d.date) AS consecutive_count_of_vaccinations
		--(consecutive_count_of_vaccinations/population)*100
FROM portfolio_project..covid_deaths d
JOIN portfolio_project..covid_vaccinations v
	ON d.location = v.location
	AND d.date = v.date
WHERE d.continent is not null
ORDER BY 2,3


--Using CTE to perform calculation on Partition By, refer to previous query
WITH population_vs_Vaccinations (continent, location, date, population, new_vaccinations, consecutive_count_of_vaccinations) as
(
SELECT d.continent, d.location, d.date, d.population, v.new_vaccinations,
		SUM(CONVERT(int, v.new_vaccinations)) OVER (PARTITION BY d.location ORDER BY d.location, d.date)as consecutive_count_of_vaccinations
FROM portfolio_project..covid_deaths d
JOIN portfolio_project..covid_vaccinations v
	ON d.location = v.location
	AND d.date = v.date
WHERE d.continent is not NULL
)
SELECT *, (consecutive_count_of_vaccinations/population)*100
from population_vs_Vaccinations



--Usign TEMP TABLE to perform Calculation on Partition BY - refer to previous query
DROP TABLE IF EXISTS #percent_population_vaccinated
CREATE TABLE #percent_population_vaccinated
(
	continent nvarchar(255),
	location nvarchar(255),
	date datetime,
	population numeric,
	new_vaccination numeric,
	consecutive_count_of_vaccinations numeric
)
INSERT INTO #percent_population_vaccinated
SELECT d.continent, d.location, d.date, d.population, v.new_vaccinations,
		SUM(CONVERT(int, v.new_vaccinations)) OVER (PARTITION BY d.location ORDER BY d.location, d.date)as consecutive_count_of_vaccinations
FROM portfolio_project..covid_deaths d
JOIN portfolio_project..covid_vaccinations v
	ON d.location = v.location
	AND d.date = v.date
--where d.continent is not null

SELECT *, (consecutive_count_of_vaccinations/population)*100
FROM #percent_population_vaccinated


--Creating View to store data for later visulization
CREATE VIEW percent_population_vaccinated AS
SELECT d.continent, d.location, d.population, v.new_vaccinations,
	SUM(CAST(v.new_vaccinations as int)) OVER (PARTITION BY d.location order by d.location, d.date) AS consecutive_count_of_vaccinations
FROM portfolio_project..covid_deaths d
JOIN portfolio_project..covid_vaccinations v
	ON d.location = v.location
	AND d.date = v.date
where d.continent is not null

--Checking Create View operation
SELECT *
from percent_population_vaccinated