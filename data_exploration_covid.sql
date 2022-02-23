/*
Covid-19 Data Exploration

Skills used: Joins, CTE's, Temp Tables, Windows Functions, Aggregate Functions, Creating Views, Converting Data Types

Dataset Citation:
Hannah Ritchie, Edouard Mathieu, Lucas Rodés-Guirao, Cameron Appel, Charlie Giattino, Esteban Ortiz-Ospina, Joe Hasell, Bobbie Macdonald, Diana Beltekian and Max Roser (2020) - "Coronavirus Pandemic (COVID-19)". Published online at OurWorldInData.org. Retrieved from: 'https://ourworldindata.org/coronavirus' [Online Resource]
*/

SELECT * 
FROM portfolio_project..covid_deaths
WHERE continent IS NOT NULL
ORDER BY 3, 4;


--Select Data that we are going to be analyzing

SELECT location,
		date,
		total_cases, 
		new_cases, 
		total_deaths, 
		population
FROM portfolio_project..covid_deaths
WHERE continent IS NOT NULL
ORDER BY 1, 2;


--Total Cases vs Total Deaths
--Shows likelihood of dying if you get covid in your country

SELECT location,
		date,
		total_cases,
		total_deaths, 
		(total_deaths/total_cases)*100 AS death_percentage
FROM portfolio_project..covid_deaths
WHERE location = 'Bolivia'
ORDER BY 1,2 DESC;


--Total Cases vs Population
--Shows what percentage of Population got Covid in your country

SELECT location,
		date,
		total_cases,
		population,
		(total_cases/population)*100 AS percent_population_inf
FROM portfolio_project..covid_deaths
WHERE location LIKE '%olivia%'
ORDER BY 1,2 DESC;


--Countries with Highest Infection Rate compared to Population

SELECT location,
	population, 
	MAX(total_cases) AS highest_infection_count,
	MAX((total_cases/population)*100) AS percent_population_inf
FROM portfolio_project..covid_deaths
GROUP BY location, population
ORDER BY percent_population_inf DESC;


--Countries with Highest Total Death Count per country

SELECT location,
		MAX(CAST(total_deaths AS int)) AS total_death_count
FROM portfolio_project..covid_deaths
WHERE continent IS NOT NULL
GROUP BY location
ORDER BY total_death_count DESC;



--BREAKING THINGS DOWN BY CONTINENT

--Showing continents with the Highest Death Count per Population

SELECT continent,
		MAX(CAST(total_deaths AS int)) AS total_death_count
FROM portfolio_project..covid_deaths
WHERE continent IS NOT NULL
GROUP BY continent
ORDER BY total_death_count DESC;


--Global numbers

SELECT date,
		SUM(new_cases) AS total_cases,
		SUM(CAST(new_deaths AS int)) AS total_deaths,
		SUM(CAST(new_deaths AS int))/SUM(new_cases)*100 AS death_percentage
FROM portfolio_project..covid_deaths
WHERE new_cases IS NOT NULL
AND covid_deaths.new_cases != 0
AND new_deaths IS NOT NULL
AND covid_deaths.new_deaths != 0
GROUP BY date
ORDER BY 1,2 DESC;


--Total Population vs Vaccination
--Shows when Vaccinations started per country

SELECT TOP 1 cd.location,
		cd.date, 
		cd.population,
		cv.new_vaccinations
FROM portfolio_project..covid_deaths AS cd
	JOIN portfolio_project..covid_vaccinations AS cv
	ON cd.location = cv.location
	AND cd.date = cv.date
WHERE cd.continent IS NOT NULL
AND cv.new_vaccinations IS NOT NULL
AND cd.location = 'Bolivia'
ORDER BY cd.date ASC;


--Shows Percentage of Population that has recieved at least one covid vaccine

SELECT cd.continent,
		cd.location,
		cd.date, 
		cd.population,
		cv.new_vaccinations,
		SUM(CAST(cv.new_vaccinations AS bigint)) OVER (PARTITION BY cd.location ORDER BY cd.location, cd.date) as rolling_people_vac
		--,(rolling_people_vac/population)*100
FROM portfolio_project..covid_deaths AS cd
	JOIN portfolio_project..covid_vaccinations AS cv
	ON cd.location = cv.location
	AND cd.date = cv.date
WHERE cd.continent IS NOT NULL
ORDER BY 2, 3;


--Using CTE to perform Calculation on Partition By in previous query

WITH pop_vac (
		continent,
		location,
		date,
		population,
		new_vaccination,
		rolling_people_vac
) AS
(
SELECT cd.continent,
		cd.location,
		cd.date, 
		cd.population,
		cv.new_vaccinations,
		SUM(CONVERT(bigint, cv.new_vaccinations)) OVER (PARTITION BY cd.location ORDER BY cd.location, cd.date) as rolling_people_vac
FROM portfolio_project..covid_deaths AS cd
	JOIN portfolio_project..covid_vaccinations AS cv
	ON cd.location = cv.location
	AND cd.date = cv.date
WHERE cd.continent IS NOT NULL
)
SELECT *, (rolling_people_vac/population)*100 AS percentage_vac
FROM pop_vac;


--Using Temp Table to perform Calculation on Partition By in previous query

DROP Table if exists #percent_pop_vac
Create Table #percent_pop_vac
(
	continent nvarchar(255),
	location nvarchar(255),
	date datetime,
	population numeric,
	new_vaccinations numeric,
	rolling_people_vac numeric
)

INSERT INTO #percent_pop_vac
SELECT cd.continent,
		cd.location,
		cd.date, 
		cd.population,
		cv.new_vaccinations,
		SUM(CONVERT(bigint, cv.new_vaccinations)) OVER (PARTITION BY cd.location ORDER BY cd.location, cd.date) as rolling_people_vac
FROM portfolio_project..covid_deaths AS cd
	JOIN portfolio_project..covid_vaccinations AS cv
	ON cd.location = cv.location
	AND cd.date = cv.date
WHERE cd.continent IS NOT NULL

Select *, (rolling_people_vac/population)*100 AS percentage_vac
From #percent_pop_vac


-- Creating View to store data for later visualizations

CREATE VIEW PercentPopulationVaccinate AS
SELECT cd.continent,
		cd.location,
		cd.date, 
		cd.population,
		cv.new_vaccinations,
		SUM(CAST(cv.new_vaccinations AS bigint)) OVER (PARTITION BY cd.location ORDER BY cd.location, cd.date) as rolling_people_vac
		--,(rolling_people_vac/population)*100
FROM portfolio_project..covid_deaths AS cd
	JOIN portfolio_project..covid_vaccinations AS cv
	ON cd.location = cv.location
	AND cd.date = cv.date
WHERE cd.continent IS NOT NULL;

CREATE VIEW RollingPeopleVac AS
SELECT cd.continent,
		cd.location,
		cd.date, 
		cd.population,
		cv.new_vaccinations,
		SUM(CAST(cv.new_vaccinations AS bigint)) OVER (PARTITION BY cd.location ORDER BY cd.location, cd.date) as rolling_people_vac
		--,(rolling_people_vac/population)*100
FROM portfolio_project..covid_deaths AS cd
	JOIN portfolio_project..covid_vaccinations AS cv
	ON cd.location = cv.location
	AND cd.date = cv.date
WHERE cd.continent IS NOT NULL
--ORDER BY 2, 3;









