/*
	queries used for tableu project
*/

--1.
SELECT SUM(new_cases) AS total_cases, SUM(CAST(new_deaths as int)) AS total_deaths, 
		SUM(CAST(new_deaths as int))/SUM(new_cases) *100 AS death_percentage
FROM portfolio_project..covid_deaths
--WHERE location = 'India'
WHERE continent is not NULL
--ORDER BY 1


--We take these out they are not inluded in the above queries and want to stay consistent
--European Union is part of Europe
--2.
SELECT location, SUM(CAST(new_deaths AS int)) AS total_deaths
FROM portfolio_project..covid_deaths
WHERE continent is NULL
	AND location not in ('world', 'european union','international')
GROUP BY location
ORDER BY total_deaths DESC


--3.
SELECT location, population, MAX(total_cases) AS highest_infection_count, MAX(total_cases)/population*100 AS percent_population_infected
FROM portfolio_project..covid_deaths
--WHERE location IN ('India', 'United states')
GROUP BY location, population
ORDER BY percent_population_infected desc


--4.
SELECT location,date, population, MAX(total_cases) AS highest_infection_count, MAX(total_cases/population)*100 AS percent_pupulation_infected
FROM portfolio_project..covid_deaths
GROUP BY location, population, date
ORDER BY percent_pupulation_infected desc
