select * from CovidDeaths
where continent is not null
order by 3,4
 --select Data that we will be using

select location,date, total_cases, new_cases, total_deaths,population
from CovidDeaths
order by 1,2

--Looking at total cases vs total death
--Shows the likelihood of dying if you contract covid in your country

select location,date, total_cases, total_deaths,(total_deaths/total_cases)*100 as DeathPercentage 
from CovidDeaths
where location like '%states%' and  continent is not null

order by 1,2

--Looking at total cases vs population
--Shows what percentage of the population got covid

select location,date, population, total_cases,(total_cases/population)*100 as PercentePopulationInfected
from CovidDeaths
--where location like '%states%' and continent is not null


order by 1,2


--Lookig at countries that have the highest infection rate compared to population 

select location, population, Max(total_cases) as HighestInfectionCount, Max(total_cases/population)*100 as 
PercentePopulationInfected
from CovidDeaths
--where location like '%states%'and continent is not null
Group By location, population
order by PercentePopulationInfected desc

--Showing the countries with highest death count per population
select location, Max(cast(total_deaths as int)) as TotalDeathCount from CovidDeaths
where continent is not null
Group by location
order by TotalDeathCount desc

--Let's Break things down by continent
--Showing the continents with highest death count per population

select continent, Max(cast(total_deaths as int)) as TotalDeathCount from CovidDeaths
where continent is not null
Group by continent
order by TotalDeathCount desc

--Global Number
--showing sum new cases and sum new deaths per date
select date, sum(new_cases) as total_cases,sum(cast(new_deaths as int )) as total_deaths,
sum(cast(new_deaths as int ))/sum(new_cases)*100 as DeathPercentage 
from CovidDeaths 
where continent is not null
Group by date
order by 1,2

--Showing sum total new cases and deaths and DeathPercentage
select  sum(new_cases) as total_cases,sum(cast(new_deaths as int )) as total_deaths,
sum(cast(new_deaths as int ))/sum(new_cases)*100 as DeathPercentage 
from CovidDeaths 
where continent is not null
--Group by date
order by 1,2


select * from CovidDeaths
select * from CovidVaccinations


--Looking at total population vs vaccinations

select  dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations,
sum(cast(vac.new_vaccinations as int)) over(Partition by dea.location order by dea.location ,dea.date)
as RollingPeopleVaccinated(RollingPeopleVaccinated/population)*100
from CovidDeaths dea join CovidVaccinations vac
on dea.location=vac.location
and dea.date=vac.date
where dea.continent is not null
order by 2,3


--Use CTE

with PopvsVac(contitent, location, Date,population,new_vaccinations,RollingPeopleVaccinated)
as
(
select  dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations,
sum(cast(vac.new_vaccinations as int)) over(Partition by dea.location order by dea.location ,dea.date)
as RollingPeopleVaccinated 
--(RollingPeopleVaccinated / population) * 100
from 
	CovidDeaths dea 
join 
	CovidVaccinations vac
on 
	dea.location=vac.location and dea.date=vac.date
where 
	dea.continent is not null
--order by 2,3 desc
)

select *, (RollingPeopleVaccinated / population) * 100
from PopvsVac


--Temp Table
Drop table if exists #PercentPopulationVaccinated
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

select 
dea.continent, 
dea.location,
dea.date,
dea.population, 
vac.new_vaccinations
,sum(cast(vac.new_vaccinations as int)) over(Partition by dea.location order by dea.location ,dea.date)
as RollingPeopleVaccinated 
--(RollingPeopleVaccinated / population) * 100
from 
	CovidDeaths dea 
join 
	CovidVaccinations vac
on 
	dea.location=vac.location and dea.date=vac.date
where 
	dea.continent is not null
--order by 2,3 desc

select *, (RollingPeopleVaccinated / population) * 100
from  #PercentPopulationVaccinated

--Creating view to store data for visulizations 

create view PercentPopulationVaccinated as
select 
dea.continent, 
dea.location,
dea.date,
dea.population, 
vac.new_vaccinations
,sum(cast(vac.new_vaccinations as int)) over(Partition by dea.location order by dea.location ,dea.date)
as RollingPeopleVaccinated 
--(RollingPeopleVaccinated / population) * 100
from 
	CovidDeaths dea 
join 
	CovidVaccinations vac
on 
	dea.location=vac.location and dea.date=vac.date
where 
	dea.continent is not null
--order by 2,3 desc

select * from PercentPopulationVaccinated
