SELECT* 
FROM [dbo].[CovidDeaths]
ORDER BY 3,4

SELECT* 
FROM [dbo].[CovidDeaths]
where continent is not null
ORDER BY 3,4

--sELECTING THE DATA WE'll BE MAKING USE OF--
SELECT location, date,new_cases, total_cases,total_deaths,population
FROM Portfolio_PRoject.[dbo].[CovidDeaths]
WHERE continent is not null
ORDER BY 1,2

--CHANGIN THE DATA TYPE--
ALTER TABLE [dbo].[CovidDeaths]
ALTER COLUMN total_deaths FLOAT
GO


--LOOKING AT THE PERCENTAGE OF INFECTED PERSONS BY COUNTRY--
--chances you'll die of covid in a particular country--
SELECT location, date, total_cases,total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
FROM Portfolio_PRoject.[dbo].[CovidDeaths]
WHERE continent is not null
ORDER BY 1,2

SELECT location, date, total_cases,total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
FROM Portfolio_PRoject.[dbo].[CovidDeaths]
WHERE location LIKE 'Nigeria%'
ORDER BY 1,2


--LOOKING AT THE TOTAL CASES VS POPULATION--
SELECT location,  date,population, total_cases, (total_cases/population)*100 as Percentage_Of_Infected_Persons
FROM Portfolio_PRoject.[dbo].[CovidDeaths]
WHERE continent is not null
ORDER BY 1,2


--CONTRIES WITH THE HIGHEST INFECTION RATE--
SELECT location, MAX(total_cases) as HighestInfection
FROM Portfolio_PRoject.[dbo].[CovidDeaths]
WHERE continent is not null
GROUP BY location
ORDER BY HighestInfection DESC




--CONTRIES WITH THE HIGHEST INFECTION RATE COMPARED TO POPULATION--
SELECT location,population, MAX(total_cases) as HighestInfection, MAX(total_cases/population)*100 Percentage_Of_Infected_Persons
FROM Portfolio_PRoject.[dbo].[CovidDeaths]
WHERE continent is not null
GROUP BY location, population
ORDER BY Percentage_Of_Infected_Persons DESC


--SHOWING COUNTRIES WITH THE HIGHEST DEATH RATE--
SELECT location,population, MAX(total_deaths) as TOtalDeathCount
FROM [dbo].[CovidDeaths]
WHERE continent is not null
GROUP BY location,population
ORDER BY TOtalDeathCount DESC

SELECT location, MAX(total_deaths) as TotalDeathCount
FROM [dbo].[CovidDeaths]
WHERE continent is NOT null
GROUP BY location
ORDER BY TOtalDeathCount DESC

--SHOWING CONTINENTS  WITH THE HIGHTEST INFECTION RATE--
SELECT continent, MAX(COV.total_cases) as TotalInfectionCount
FROM [dbo].[CovidDeaths] COV
WHERE continent IS NOT NULL
GROUP BY continent
ORDER BY continent DESC


--SHOWING CONTINENTS  WITH THE HIGHTEST DEATH RATE--
SELECT continent, MAX(COV.total_deaths) as TotalDeathCount
FROM [dbo].[CovidDeaths] COV
WHERE continent IS NOT NULL
GROUP BY continent
ORDER BY continent DESC


--GLOBAL NUMBERS--
SELECT DATE, SUM(COV.new_cases) AS Global_Numbers
FROM [dbo].[CovidDeaths] AS COV
WHere continent IS NOT NULL
GROUP BY date
ORDER BY DATE DESC

SELECT COV.continent, SUM(COV.new_cases) 'New Cases', SUM(COV.new_deaths)AS 'New Death', SUM(COV.new_deaths)/SUM(COV.new_cases)*100 AS Deathpercentage
FROM [dbo].[CovidDeaths] AS COV
WHERE continent IS NOT NULL
GROUP BY continent
ORDER BY 1,2 


--LOOKING AT TOTAL POPULATION VS VACCINATED--
 
 SELECT Cov.continent, Cov.location, cov.date,Cov.population,vac.new_vaccinations
,SUM(cast(vac.new_vaccinations as float)) over (partition by Cov.location order by cov.location,cov.date) as ROllingPeopleVaccinated
FROM CovidDeaths as cov
JOIN CovidVaccination vac
ON cov.location=vac.location
and cov.date=vac.date
WHERE cov.continent IS NOT NULL
ORDER BY 2,3

--USE CTE--
WITH PopVSVAC(continent, location,date, population, new_vaccinations, rollingpeoplevaccinated)
as
(
	 SELECT Cov.continent, Cov.location, cov.date,Cov.population,vac.new_vaccinations
	,SUM(CAST(vac.new_vaccinations as float)) over (partition by Cov.location order by cov.location,cov.date) as ROllingPeopleVaccinated
	FROM CovidDeaths as cov
	JOIN CovidVaccination vac
	ON cov.location=vac.location
	and cov.date=vac.date
	WHERE cov.continent IS NOT NULL	
)

SELECT*, (rollingpeoplevaccinated/population)*100
FROM PopVSVAC




--TEMP TABLE--

--DROP TABLE IF EXISTS #PercentPopulationVacccinated

CREATE TABLE #PercentPopulationVacccinated(
COntinent nvarchar(255),
Location nvarchar(225),
Date datetime,
Population numeric,
New_vaccination numeric,
Rollingpeoplevacccinated numeric
)


 INSERT INTO #PercentPopulationVacccinated 

		 SELECT Cov.continent, Cov.location, cov.date,Cov.population,vac.new_vaccinations
	,SUM(CAST(vac.new_vaccinations as float)) over (partition by Cov.location order by cov.location,cov.date) as ROllingPeopleVaccinated
	FROM CovidDeaths as cov
	JOIN CovidVaccination vac
	ON cov.location=vac.location
	and cov.date=vac.date
	WHERE cov.continent IS NOT NULL	

SELECT*, (Rollingpeoplevacccinated/population)*100
FROM #PercentPopulationVacccinated


--CREATING VIEWS FOR VISUALIZATION --

--LOOKING AT THE PERCENTAGE OF INFECTED PERSONS BY COUNTRY--
CREATE VIEW DeathPercentage AS
SELECT location, date, total_cases,total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
FROM Portfolio_PRoject.[dbo].[CovidDeaths]
WHERE continent is not null


--CONTRIES WITH THE HIGHEST INFECTION RATE--
CREATE VIEW HighestInfectionby_COUNTRY AS
SELECT location, MAX(total_cases) as HighestInfection
FROM Portfolio_PRoject.[dbo].[CovidDeaths]
WHERE continent is not null
GROUP BY location


---COUNTRIES WITH THE HIGHEST DEATH-COUNT--
CREATE VIEW MaxDeathbyCOUNTRY AS
SELECT location,MAX(total_deaths) TOTAL_DEATHS
FROM CovidDeaths
WHERE continent IS NOT NULL
GROUP BY location

--CONTINENTS WITH THE HIGHEST INFECTION RATE--
CREATE VIEW  Total_InfectionBY_CONTINENT AS
SELECT continent, MAX(COV.total_cases) as TotalInfectionCount
FROM [dbo].[CovidDeaths] COV
WHERE continent IS NOT NULL
GROUP BY continent

--CONTINENTS WITH THE HIGHEST DEATH RATE--
CREATE VIEW Total_DeathBY_CONTINENT AS
SELECT continent, MAX(COV.total_deaths) as TotalDeathCount
FROM [dbo].[CovidDeaths] COV
WHERE continent IS NOT NULL
GROUP BY continent


--TOTAL POPULATION VACCINATED--
CREATE VIEW POPULATIONVACCINATED AS
 SELECT Cov.continent, Cov.location, cov.date,Cov.population,vac.new_vaccinations
,SUM(cast(vac.new_vaccinations as float)) over (partition by Cov.location order by cov.location,cov.date) as ROllingPeopleVaccinated
FROM CovidDeaths as cov
JOIN CovidVaccination vac
ON cov.location=vac.location
and cov.date=vac.date
WHERE cov.continent IS NOT NULL





