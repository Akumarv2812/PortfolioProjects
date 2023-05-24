select *
from CovidDeaths
where continent is not null
order by 3,4

--Select *
--from CovidVaccine
--order by 3,4

--select data that we are going to be using

select Location,date,total_cases,new_cases,total_deaths,population
from CovidDeaths
where continent is not null
order by 1,2

--Looking at Total Cases vs Total Deaths
--shows likelihood of dying if you contract covid in your country

select Location,date,total_cases,total_deaths,
(cast(total_deaths as float)/cast(total_cases as float))*100 as DeathPercentage
from CovidDeaths
where location like 'india'
order by 1,2 


--looking at total cases vs population
--shows what percentage of population got covid

select Location,date,total_cases,population,
(cast(total_cases as float)/population)*100 as PercentPopulationInfected
from CovidDeaths
--where location like 'india'
where continent is not null
order by 1,2 


-- looking at countries with highest infection rate compared to population

select Location,population,
Max(total_cases) as HighestInfectionCount, MAX((cast(total_cases as float)/population))*100 as PercentPopulationInfected
from CovidDeaths
--where location like 'india'
where continent is not null
group by location,population
order by PercentPopulationInfected desc


--showing countries with highest death count per population

select Location, Max(cast(total_deaths as int)) as TotalDeathCount
from CovidDeaths
--where location like 'india'
where continent is not null
group by location
order by TotalDeathCount desc


--LET'S BREAK DOWN BY CONTINENT


--showing the continents with the highest death count per population

select continent, Max(cast(total_deaths as int)) as TotalDeathCount
from CovidDeaths
--where location like 'india'
where continent is not null
group by continent
order by TotalDeathCount desc



-- Global Numbers

select date,SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths,
SUM(cast(new_deaths as int))/SUM(new_cases)*100 as DeathPercentage
from CovidDeaths
--where location like 'india'
where Continent is not null and new_cases is not null and new_deaths is not null and new_deaths != 0
group by date
order by 1,2 


select SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths,
SUM(cast(new_deaths as int))/SUM(new_cases)*100 as DeathPercentage
from CovidDeaths
--where location like 'india'
where Continent is not null and new_cases is not null and new_deaths is not null and new_deaths != 0
--group by date
order by 1,2 


--Looking at total population vs vaccinations


select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(cast(vac.new_vaccinations as float)) OVER 
(Partition by dea.location order by dea.location, dea.date)
as RollingPeopleVaccinated
--,(RollingPeopleVaccinated/population)*100
from CovidDeaths dea
join CovidVaccine vac
     on dea.location = vac.location
	 and dea.date = vac.date
where dea.continent is not null
order by 2,3



--use CTE

with PopvsVac (continent, location, date, population, new_vaccinations, RollingPeopleVaccinated)
as
(
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(cast(vac.new_vaccinations as float)) OVER 
(Partition by dea.location order by dea.location, dea.date)
as RollingPeopleVaccinated
--,(RollingPeopleVaccinated/population)*100
from CovidDeaths dea
join CovidVaccine vac
     on dea.location = vac.location
	 and dea.date = vac.date
where dea.continent is not null
--order by 2,3
)
select *,(RollingPeopleVaccinated/population)*100
from PopvsVac


--Temp Table

create table #PercentPopulationVaccinated
(
continent nvarchar(255),
location nvarchar(255),
date datetime,
population numeric,
new_vaccinations numeric,
RollingPeopleVaccinated numeric
)

insert into #PercentPopulationVaccinated
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(cast(vac.new_vaccinations as float)) OVER 
(Partition by dea.location order by dea.location, dea.date)
as RollingPeopleVaccinated
--,(RollingPeopleVaccinated/population)*100
from CovidDeaths dea
join CovidVaccine vac
     on dea.location = vac.location
	 and dea.date = vac.date
where dea.continent is not null
--order by 2,3

select *,(RollingPeopleVaccinated/population)*100
from #PercentPopulationVaccinated


--creating view to store data for later visualizations

create view PercentPopulationVaccinated as 
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(cast(vac.new_vaccinations as float)) OVER 
(Partition by dea.location order by dea.location, dea.date)
as RollingPeopleVaccinated
--,(RollingPeopleVaccinated/population)*100
from CovidDeaths dea
join CovidVaccine vac
     on dea.location = vac.location
	 and dea.date = vac.date
where dea.continent is not null
--order by 2,3


select *
from PercentPopulationVaccinated