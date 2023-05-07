--select *
--from PortofolioProject..CovidVaccination
--order by 3,4 

--select *
--from PortofolioProject..CovidDeaths
--order by 3,4

-- select data are going to using
--select continent, location, date, new_cases, total_cases, total_deaths, population
--from CovidDeaths
--order by 2,3

-- looking at total case vs total deaths
--select continent, location, date, new_cases, total_cases, total_deaths, (total_deaths*100)/total_cases as death_percentage
--from CovidDeaths
--where location = 'zimbabwe'
--order by 2,3 desc

-- looking at total case vs population
-- show percentage of population got covid
--select location, date, population, total_cases, CAST((total_cases/population)*100 as bigint) as population_covid
--from CovidDeaths
--where location = 'united states'
--order by 2,3

-- looking at countries with highest infection rete compared to population
--select continent, location, population, MAX(total_cases) as highestInfection, MAX((total_cases/population)*100) as population_covid
--from CovidDeaths
----where location = 'united states'
--group by continent, location, population
--order by population_covid desc

-- showing countries with highest death count per population
--select location, population, MAX(cast(total_deaths as bigint)) as highestDeaths
--from CovidDeaths
--where continent is not null
--group by location, population
--order by highestDeaths desc

-- showing continents with the highhest death count per population
--select continent,sum(cast(population as bigint)) as totalPopulation, max(cast(total_deaths as bigint)) as theHighestdeath
--from CovidDeaths
--where continent is not null
--group by continent
--order by 3 desc

-- global deaths percentage
--select sum(cast(new_deaths as int)) as sumdeaths, sum(new_cases) as total_cases,
--(sum(cast(new_deaths as int))/sum(new_cases))*100 as deathPercentage
--from CovidDeaths
--group by new_deaths

 --select population vs vactination
select dea.location, dea.date, population, new_vaccinations,
sum(cast(new_vaccinations as bigint)) over (partition by dea.location order by dea.location,
dea.date) as rollingPeopleVaccination
from CovidDeaths dea
join CovidVaccination vac
on dea.location = vac.location 
and dea.date = vac.date

-- if use ctes
with popvsvac (location, date, population, new_vaccinations, rollingPeopleVaccination)
as(
select dea.location, dea.date, population, new_vaccinations,
sum(cast(new_vaccinations as bigint)) over (partition by dea.location order by dea.location,
dea.date) as rollingPeopleVaccination
from CovidDeaths dea
join CovidVaccination vac
on dea.location = vac.location 
and dea.date = vac.date
)
select *, (rollingPeopleVaccination/population)*100
from popvsvac

-- if use temp table
drop table if exists #percentPopulationVaccinated
create table #percentPopulationVaccinated(
location nvarchar(255),
date datetime,
population numeric,
new_vaccinations numeric,
rollingPeopleVaccination numeric
)
insert into #percentPopulationVaccinated
select dea.location, dea.date, population, new_vaccinations,
sum(cast(new_vaccinations as bigint)) over (partition by dea.location order by dea.location,
dea.date) as rollingPeopleVaccination
from CovidDeaths dea
join CovidVaccination vac
on dea.location = vac.location 
and dea.date = vac.date
select *
from #percentPopulationVaccinated

-- create view
create view percentPopulationVaccination as
select dea.location, dea.date, population, new_vaccinations,
sum(cast(new_vaccinations as bigint)) over (partition by dea.location order by dea.location,
dea.date) as rollingPeopleVaccination
from CovidDeaths dea
join CovidVaccination vac
on dea.location = vac.location 
and dea.date = vac.date

select *
from percentPopulationVaccination

