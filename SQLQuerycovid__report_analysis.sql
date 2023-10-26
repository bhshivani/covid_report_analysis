select * from covid_report_analysis.dbo.covid_death_report
where continent is not null
order by 3,4

select * from covid_report_analysis.dbo.covid_vaccination_report
order by 3,4 

select location,date,total_cases,new_cases,total_deaths,population
from covid_report_analysis.dbo.covid_death_report
where continent is not null
order by 1,2

--we looking total_cases vs total_deaths

select location,date,total_cases,population ,(total_cases/ population)*100 as deathpercentage 
from covid_report_analysis.dbo.covid_death_report
where continent is not null
order by 1,2

---looking at the countries with highest infection rate compared to population

select location,population,max(total_cases)as highestinfectioncount,  max((total_cases/population))*100 as percentpopulationinfected 
from covid_report_analysis.dbo.covid_death_report
where continent is not null
group by location,population
order by percentpopulationinfected desc

---showing countries with highest death count per population

select continent,max(cast(total_deaths as int)) totaldeathcount
from covid_report_analysis.dbo.covid_death_report
where continent is not null
group by continent
order by totaldeathcount desc

---global numbers

select sum(new_cases)as total_cases,sum(cast(new_deaths as int)) as total_deaths,
sum(cast(new_deaths as int))/sum(new_cases)*100 as deathpercentage from covid_report_analysis.dbo.covid_death_report
where continent is not null
order by 1,2

select * from covid_report_analysis.dbo.covid_vaccination_report

----looking at total population Vs vaccinations

select dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations ,sum(convert(int,vac.new_vaccinations))
over(partition by dea.location order by dea.location,dea.date)as rollingpeoplevaccinated
from covid_report_analysis.dbo.covid_death_report dea
join covid_report_analysis.dbo. covid_vaccination_report vac
on dea.location = vac.location
and dea.date = vac.date 
where dea.continent is not null
order by 2,3
---(rollingpeoplevaccinated/population)*100

-----use CTE-----

with popVSvac(continent,location,date,population,new_vaccination,rollingpeoplevaccinated)
as
(
select dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations,sum(convert(int,vac.new_vaccinations))
over
(partition by dea.location order by dea.location,dea.date)as rollingpeoplevaccinated
from covid_report_analysis.dbo.covid_death_report dea
join
covid_report_analysis.dbo.covid_vaccination_report vac
on dea.date = vac.date
and dea.location = vac.location
where dea.continent is not null
----order by 2,3-----
)
select*,(rollingpeoplevaccinated/population)*100
from popVSvac

---temp table---
drop table if exists #percentpopulationvaccinated
create table #percentpopulationvaccinated
(
continent nvarchar(255),
location nvarchar(255),
date datetime,
population numeric,
new_vaccinations numeric,
rollingpeoplevaccinated numeric
)

insert into #percentpopulationvaccinated
select dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations,
sum (convert(int,vac.new_vaccinations)) over (partition by dea.location order by dea.location,
dea.date) as rollingpeoplevaccinated

----(rollingpeoplevaccinated/population)*100
from covid_report_analysis.dbo.covid_death_report dea
join covid_report_analysis.dbo.covid_vaccination_report vac
on dea. location = vac.location
and dea.date = vac.date
---where dea.continent is not null

select * , (rollingpeoplevaccinated/ population)*100
from #percentpopulationvaccinated


------creating view to store data for later visulizations-------
 
create view percentpopulationvaccinated as
select dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations,
sum(convert(int ,vac.new_vaccinations))
over(partition by dea.location order by dea.location,dea.date)as
rollingpeoplevaccinated
-----(rollingpeoplevaccinated/population)*100------
from covid_report_analysis.dbo.covid_death_report dea
join
covid_report_analysis.dbo.covid_vaccination_report vac
on dea.location =vac.location
and dea.date = vac.date
where dea.continent is not null
---order by 2,3
select * from #percentpopulationvaccinated

