/*
Covid 19 Data Exploration 

Skills used: Joins, CTE's, Temp Tables, Windows Functions, Aggregate Functions, Creating Views, Converting Data Types

*/


select * from Portfolio_project..covidDeaths$
where continent is not null
order by 3,4;

select * from Portfolio_project..covidvaccin$
order by 3,4;

--covid death percentage in India

select location,date,total_cases,total_deaths,total_cases,CAST( total_deaths AS float) / CAST(total_cases AS float) *100 as DEathPercentage
from Portfolio_project..covidDeaths$
where location like '%india%'
order by 1,2;


--highest infected ppl per population 

select location,population,max(total_cases) as highestinfectioncount
,MAX(CAST( total_cases AS float)) / max(CAST(population AS float)) *100 as infectedpopulation
from Portfolio_project..covidDeaths$
--where location like '%india%'
group by location,population
order by infectedpopulation desc;


--continent with highest death count per population

select location,max(total_deaths) as totaldeath
--,MAX(CAST( total_cases AS float)) / max(CAST(population AS float)) *100 as infectedpopulation
from Portfolio_project..covidDeaths$
--where location like '%india%'
where continent is not  null
group by location
order by totaldeath  desc;

--Global percentage

select  date,sum(new_cases) as total_cases,SUM(cast(new_deaths as int)) as total_deaths
,sum(cast(new_deaths as int))/NULLIF(sum(new_cases),0) *100 as percentage
--,CAST( total_deaths AS float) / CAST(total_cases AS float) *100 as DEathPercentage
from Portfolio_project..covidDeaths$
--where location like '%india%'
where continent is not  null
group by date
order by 1,2;


select  sum(new_cases) as total_cases,SUM(cast(new_deaths as int)) as total_deaths
,sum(cast(new_deaths as int))/NULLIF(sum(new_cases),0) *100 as percentage
--,CAST( total_deaths AS float) / CAST(total_cases AS float) *100 as DEathPercentage
from Portfolio_project..covidDeaths$
--where location like '%india%'
where continent is not  null
--group by date
order by 1,2;



--total ppl vacinated


select cd.continent,cd.location,cd.date,cd.population,cv.new_vaccinations,
sum( cast(cv.new_vaccinations as BIGINT)) OVER (Partition by cd.location order by cd.location,cv.date) as pplgettingvacinated
from Portfolio_project..covidvaccin$ cv,
 Portfolio_project..covidDeaths$ cd
where cv.location=cd.location
and cd.continent is not  null
and cv.date=cd.date
order by 2,3

-- CTE

WITH popvsvac(continent,location,date,population,new_vaccinations,pplgettingvacinated)
AS
(
select cd.continent,cd.location,cd.date,cd.population,cv.new_vaccinations,
sum(cast(cv.new_vaccinations as BIGINT)) OVER (Partition by cd.location order by cd.location,cv.date) as pplgettingvacinated
from Portfolio_project..covidvaccin$ cv,
 Portfolio_project..covidDeaths$ cd
where cv.location=cd.location
and cd.continent is not  null
and cv.date=cd.date
)
select * , (pplgettingvacinated/population*100)
from popvsvac;



--TEMP Table
DROP TABLE IF exists #PERCENTPOPULATIONVACCINATED
CREATE TABLE #PERCENTPOPULATIONVACCINATED
(
continent nvarchar(255),
location nvarchar(255),
date datetime,
population numeric,
new_vaccinations numeric,
pplgettingvacinated numeric
)
INSERT into  #PERCENTPOPULATIONVACCINATED
select cd.continent,cd.location,cd.date,cd.population,cv.new_vaccinations,
sum(cast(cv.new_vaccinations as BIGINT)) OVER (Partition by cd.location order by cd.location,cv.date) as pplgettingvacinated
from Portfolio_project..covidvaccin$ cv,
 Portfolio_project..covidDeaths$ cd
where cv.location=cd.location
and cd.continent is not  null
and cv.date=cd.date

select * , (pplgettingvacinated/population*100)
from #PERCENTPOPULATIONVACCINATED;


---CREATE VIEW for vizualization

create view PERCENTPOPULATIONVACCINATED as
select cd.continent,cd.location,cd.date,cd.population,cv.new_vaccinations,
sum(cast(cv.new_vaccinations as BIGINT)) OVER (Partition by cd.location order by cd.location,cv.date) as pplgettingvacinated
from Portfolio_project..covidvaccin$ cv,
 Portfolio_project..covidDeaths$ cd
where cv.location=cd.location
and cd.continent is not  null
and cv.date=cd.date

select * from PERCENTPOPULATIONVACCINATED;
