--looking at india's data
select *from "owid-covid-data"
where location = 'India'
order by date desc;

-- Deleting the data based on income category which is included in this file.
DELETE FROM "owid-covid-data" WHERE location like '%income%';

-- checking the data if the results are coming out correctly
select Max(new_deaths) from "owid-covid-data"
where location = 'India';

--starting
 SELECT location, date, total_cases, new_cases, total_deaths, population
FROM "owid-covid-data"
order by 1,2;


--1
-- looking at total cases vs total deaths of the world and in India

SELECT location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as deathPercentage
FROM "owid-covid-data"
order by 1,2;
SELECT location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as deathPercentage
FROM "owid-covid-data"
where location = 'India'
order by 1,2 desc;


--2
-- now for total cases vs population
SELECT location, date, total_cases, population, (total_cases/population)*100 as covidPercentage
FROM "owid-covid-data"
   --where location = 'India'
order by 1,2 desc ;

--3
-- --looking at highest infected rate  compared to population
SELECT location, population, max(total_cases) as HighestCovidCount, max((total_cases/population)*100) as PopulationinfectedPercentage
FROM "owid-covid-data"
where continent is not null
group by location, population
order by PopulationinfectedPercentage desc ;

--4
-- --looking for locations with highest Death count
SELECT location, max(cast(total_deaths as int) )as TotalDeathCount
FROM "owid-covid-data"
where continent is not null
group by location
order by TotalDeathCount desc;


--5
-- breaking things by continent
-- showing continents with highest death count per population
SELECT location,  max(total_deaths) as TotalDeathCount
FROM "owid-covid-data"
where continent is null
group by location
order by TotalDeathCount desc;

SELECT continent,  max(total_deaths) as TotalDeathCount
FROM "owid-covid-data"
where continent is not null
group by continent
order by TotalDeathCount desc;


--6
-- looking into data on a global scale
SELECT date, sum(new_cases) as total_Cases_in_day, sum(new_deaths) as total_Deaths_in_day, (sum(new_deaths)/sum(new_cases))*100 as DeathPercentage
FROM "owid-covid-data"
    ---where location = 'India' and new_deaths != 0
group by date
order by 1 desc;

SELECT  sum(new_cases) as total_Cases_in_day, sum(new_deaths) as total_Deaths_in_day, (sum(new_deaths)/sum(new_cases))*100 as DeathPercentage
FROM "owid-covid-data"
order by 1 desc;



--7
--NOW FOR VACCINATIONS
-- looking at total population vs vaccinations
with popVSvac ( continent, location, date, popualation, new_vaccinations, PeopleVaccinatedRollingCount) as
               (select continent,
                    location,
                    date,
                    population,
                    new_vaccinations,
                    sum(cast(new_vaccinations as double precision)) over (partition by location order by location,date)
                        as PeopleVaccinatedRollingCount
              from "owid-covid-data"
              where continent is not null
               --order by 2,3
                 )
select *, (PeopleVaccinatedRollingCount/popualation)*100 as VaccinationpercentageRolling
from popVSvac;


--- Sorted Queries for tableau visualizatiton
 --1) Here we are looking at total numbers of the world
 Select SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, SUM(cast(new_deaths as int))/SUM(New_Cases)*100 as DeathPercentage
From "owid-covid-data"
--Where location like 'India'
where continent is not null
--Group By date
order by 1,2 ;

--2) Here we are looking at Numbers on continental basis.. Filtering out the data for the utilization of map plots
Select location, SUM(cast(new_deaths as int)) as TotalDeathCount
From "owid-covid-data"
Where continent is null
and location not in ('World', 'European Union', 'International')
Group by location
order by TotalDeathCount desc;

--3)
Select Location, Population, Max(total_cases) as HighestInfectionCount,  Max((total_cases/population))*100 as PercentPopulationInfected
From "owid-covid-data"
--where location = 'India'
Group by Location, Population
order by PercentPopulationInfected desc;

--4)
Select Location, Population,date, MAX(total_cases) as HighestInfectionCount,  Max((total_cases/population))*100 as PercentPopulationInfected
From "owid-covid-data"
--where location = 'India'
Group by Location, Population, date
order by PercentPopulationInfected desc ;


-- Creating View to store data for later visualizations

Create View PercentPopulationVaccinated as
Select continent, location, date, population, new_vaccinations
, sum(cast(new_vaccinations as double precision)) OVER (Partition by Location Order by location,Date) as PeopleVaccinatedRollingCount
From "owid-covid-data"
where continent is not null
