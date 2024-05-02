SELECT *
FROM portfolioproject..CovidDeaths
ORDER BY 3,4

--SELECT * 
--FROM portfolioproject..CovidVaccination
--ORDER BY 3,4

-- SELECT data we are going to use

SELECT location,date,total_cases,new_cases,total_deaths,population
FROM portfolioproject..CovidDeaths
order by 1,2

--looking total_cases vs total_deaths
-- shows likelihood of dying 
SELECT location,date,total_cases,total_deaths,(total_deaths/total_cases)*100 as death_percentage
FROM portfolioproject..CovidDeaths
where location like '%state%'
order by 1,2

-- looking total_cases vs population
-- shows what percentage of population got covid

SELECT location,date,total_cases,population,(total_cases/population)*100 as populationpercentageinfected
FROM portfolioproject..CovidDeaths
--where location like '%state%'
WHERE continent is NOT NULL
order by 1,2

-- looking at country with highest infection rate compare to the population

SELECT location,population,MAX(total_cases) as Highest_infection_count ,MAX ((total_cases/population))*100 as
percentage_populationinfected

FROM portfolioproject..CovidDeaths
--where location like '%state%' 
WHERE continent is NOT NULL
group by  location,population
order by percentage_populationinfected desc


--looking if group by date

SELECT location,population,date,MAX(total_cases) as Highest_infection_count ,MAX ((total_cases/population))*100 as
percentage_populationinfected

FROM portfolioproject..CovidDeaths
--where location like '%state%' 
WHERE continent is NOT NULL
group by  location,population,date
order by percentage_populationinfected desc

-- showing country with highest death count per population

SELECT location,MAX(cast(total_deaths as int) ) as total_death_count
FROM portfolioproject..CovidDeaths
WHERE continent is NOT NULL
GROUP BY location
ORDER BY total_death_count desc

-- Let's breakdown by continent
-- showing continent with the highest death rate per population

SELECT continent,MAX(cast(total_deaths as int) ) as total_death_count
FROM portfolioproject..CovidDeaths
WHERE continent is NOT NULL
GROUP BY continent
ORDER BY total_death_count desc

-- GLOBAL NUMBERS
SELECT date,
SUM(new_cases)as totalcases,
SUM(cast(new_deaths as int))as totaldeaths,
SUM(cast(new_deaths as int))/SUM(new_cases) *100 as death_percentage
FROM portfolioproject..CovidDeaths
--where location like '%state%'
WHERE continent is NOT NULL
GROUP BY date
order by 1,2

-- showing total death out of total cases
SELECT
SUM(new_cases)as totalcases,
SUM(cast(new_deaths as int))as totaldeaths,
SUM(cast(new_deaths as int))/SUM(new_cases) *100 as death_percentage
FROM portfolioproject..CovidDeaths
--where location like '%state%'
WHERE continent is NOT NULL
order by 1,2

-- Now let's work on Covid Vaccination Table

SELECT *
FROM portfolioproject..CovidVaccination

SELECT *
FROM portfolioproject..CovidDeaths

-- Join two table
SELECT *
FROM portfolioproject..CovidVaccination vac
JOIN portfolioproject..CovidDeaths dea
ON vac.location=dea.location
 AND vac.date=dea.date

 -- Looking at total vaccination vs population
 SELECT dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations,
 SUM(CAST(vac.new_vaccinations AS int)) OVER (PARTITION BY dea.location order by dea.location,dea.date) as RollingPeopleVaccinated
FROM portfolioproject..CovidDeaths dea
JOIN portfolioproject..CovidVaccination vac
 ON dea.location=vac.location
 and dea.date=vac.date
WHERE dea.continent IS NOT NULL
order by 2,3

--USE CTE

WITH popvsvac(continent,location,date,population,new_vaccination,RollingPeopleVaccinated)
as
(
SELECT dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations,
 SUM(CAST(vac.new_vaccinations AS int)) OVER (PARTITION BY dea.location order by dea.location,dea.date) as RollingPeopleVaccinated
FROM portfolioproject..CovidDeaths dea
JOIN portfolioproject..CovidVaccination vac
 ON dea.location=vac.location
 and dea.date=vac.date
WHERE dea.continent IS NOT NULL
)
SELECT *,RollingPeopleVaccinated/population *100 as RollingPeopleVaccinated_Percentage
FROM popvsvac


-- Create TEMP Table
DROP Table if exists #PercentagePeopleVaccinated -- checking table name already exists or not before creation
CREATE Table #PercentagePeopleVaccinated
(
continent nvarchar(255),
location nvarchar(255),
date datetime,
population numeric,
new_vaccination numeric,
RollingPeopleVaccinated numeric
)

-- check table
select * from #PercentagePeopleVaccinated

-- Insert into Table
Insert into #PercentagePeopleVaccinated
SELECT dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations,
 SUM(CAST(vac.new_vaccinations AS int)) OVER (PARTITION BY dea.location order by dea.location,dea.date) as RollingPeopleVaccinated
FROM portfolioproject..CovidDeaths dea
JOIN portfolioproject..CovidVaccination vac
 ON dea.location=vac.location
 and dea.date=vac.date
--WHERE dea.continent IS NOT NULL

-- check inserted data
SELECT *,RollingPeopleVaccinated/population *100 as RollingPeopleVaccinated_Percentage
FROM #PercentagePeopleVaccinated


-- Creating view to store data in later visualization

USE portfolioproject
GO


Create View PercentagePeopleVaccinated as
SELECT dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations,
 SUM(CAST(vac.new_vaccinations AS int)) OVER (PARTITION BY dea.location order by dea.location,dea.date) as RollingPeopleVaccinated
FROM portfolioproject..CovidDeaths dea
JOIN portfolioproject..CovidVaccination vac
 ON dea.location=vac.location
 and dea.date=vac.date
WHERE dea.continent IS NOT NULL

-- Selecting all data from the view
SELECT * FROM PercentagePeopleVaccinated;

-- Or we can add more conditions or calculations
SELECT *, RollingPeopleVaccinated / population * 100 AS RollingPeopleVaccinated_Percentage
FROM PercentagePeopleVaccinated;

SELECT location,SUM(cast(new_deaths as int)) as TotalDeathCount
From portfolioproject..CovidDeaths
where continent is null
and location not in ('World','European Union','International')
Group by location
order by TotalDeathCount Desc




