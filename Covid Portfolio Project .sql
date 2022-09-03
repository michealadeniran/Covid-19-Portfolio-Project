
SELECT * from
[Portfolio Projects].dbo.CovidDeaths$

SELECT * FROM
[Portfolio Projects].dbo.CovidVaccinations$

SELECT Location,date,total_cases,new_cases,total_deaths,population From
[Portfolio Projects].dbo.CovidDeaths$
order by 1,2

----Total CASES VS Total death

SELECT Location,date,total_cases,total_deaths,(total_deaths/total_cases)*100 as DeathPercentage
From
[Portfolio Projects].dbo.CovidDeaths$
Where continent is not null
---where location like '%states%'
Order by 1,2

----------Total death VS Population-----------
----percentage of population that got covid----

SELECT Location,date,total_cases,population,(total_cases/population)*100 as Populationinfected
From
[Portfolio Projects].dbo.CovidDeaths$
Where continent is not null
---where location like '%states%'
Order by 1,2

---------Countries with highest infection rate compared to Population------

SELECT Location, MAX(total_cases) as Highestinfectioncount, population,Max(total_cases/population)*100 as PercentPopulationinfected
From
[Portfolio Projects].dbo.CovidDeaths$
Where continent is not null
---where location like '%states%'
Group by Location,population
Order by PercentPopulationinfected desc

---Countries with highest death count Per Population

SELECT Location, MAX(cast(total_deaths as int)) as Totaldeathcount From
[Portfolio Projects].dbo.CovidDeaths$
Where continent is not null
---where location like '%states%'
Group by Location,population
Order by Totaldeathcount desc

---Lets Break things down by continent
SELECT continent, MAX(cast(total_deaths as int)) as Totaldeathcount From
[Portfolio Projects].dbo.CovidDeaths$
Where continent is not null
---where location like '%states%'
Group by continent
Order by Totaldeathcount desc

----continent with highest death count per population


SELECT continent, MAX(cast(total_deaths as int)) as Totaldeathcount From
[Portfolio Projects].dbo.CovidDeaths$
Where continent is not null
---where location like '%states%'
Group by continent,population
Order by Totaldeathcount desc

------------Global Numbers-------

SELECT sum(new_cases) as total_cases, Sum(cast(new_deaths as int)) as total_death,
Sum(cast(new_deaths as int))/sum(new_cases)*100 as Deathpercentage  From
[Portfolio Projects].dbo.CovidDeaths$
Where continent is not null
---where location like '%states%'
----Group by date
Order by 1,2 desc




SELECT dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations from
[Portfolio Projects].dbo.CovidDeaths$ AS DEA
JOIN
[Portfolio Projects].dbo.CovidVaccinations$ AS VAC
ON 
DEA.Location=VAC.location
AND DEA.date=VAC.date
Where dea.continent is not null
order by 1,2,3

SELECT dea.continent,dea.location,dea.date,dea.population,
vac.new_vaccinations, sum(cast(vac.new_vaccinations as int))
OVER(PARTITION  by dea.location)
From [Portfolio Projects].dbo.CovidDeaths$ AS DEA
JOIN
[Portfolio Projects].dbo.CovidVaccinations$ AS VAC
ON
DEA.Location=VAC.location
AND DEA.date=VAC.date
Where dea.continent is not null
order by 2,3


SELECT dea.continent,dea.location,dea.date,dea.population,
vac.new_vaccinations, sum(cast(vac.new_vaccinations as int))
OVER(PARTITION  by dea.location Order by dea.location,dea.date) AS Rollingpeoplevaccinated
From [Portfolio Projects].dbo.CovidDeaths$ AS DEA
JOIN
[Portfolio Projects].dbo.CovidVaccinations$ AS VAC
ON
DEA.Location=VAC.location
AND DEA.date=VAC.date
Where dea.continent is not null
order by 2,3

------------USE CTE---------------------
-------------------------------with Population vs Vaccination---------------------

with PopvsVac (Continent,Location,Date, Population,New_vaccinations,RollingpeopleVaccinated)
as
(
SELECT dea.continent,dea.location,dea.date,dea.population,
vac.new_vaccinations, sum(cast(vac.new_vaccinations as int))
OVER(PARTITION  by dea.location Order by dea.location,dea.date) AS Rollingpeoplevaccinated
From [Portfolio Projects].dbo.CovidDeaths$ AS DEA
JOIN
[Portfolio Projects].dbo.CovidVaccinations$ AS VAC
ON
DEA.Location=VAC.location
AND DEA.date=VAC.date
Where dea.continent is not null
---order by 2,3
)
Select *,(RollingpeopleVaccinated/Population)*100 From PopvsVac


-------------Using Temp Table---------------------------
Drop Table if exists #PercentpopulationVaccinated
Create Table #PercentpopulationVaccinated
(
Continent nVarchar(255),
Location  nVarchar(255),
date      datetime,
Population numeric,
New_vaccinations numeric,
Rollingpeoplevaccinated numeric
)

insert into #PercentpopulationVaccinated
SELECT dea.continent,dea.location,dea.date,dea.population,
vac.new_vaccinations, sum(cast(vac.new_vaccinations as int))
OVER(PARTITION  by dea.location Order by dea.location,dea.date) AS Rollingpeoplevaccinated
From [Portfolio Projects].dbo.CovidDeaths$ AS DEA
JOIN
[Portfolio Projects].dbo.CovidVaccinations$ AS VAC
ON
DEA.Location=VAC.location
AND DEA.date=VAC.date
Where dea.continent is not null
---order by 2,3

Select *,(RollingpeopleVaccinated/Population)*100 From #PercentpopulationVaccinated

Drop view if exists PercentpopulationVaccinated
Create View PercentpopulationVaccinated as
SELECT dea.continent,dea.location,dea.date,dea.population,
vac.new_vaccinations, sum(cast(vac.new_vaccinations as int))
OVER(PARTITION  by dea.location Order by dea.location,dea.date) AS Rollingpeoplevaccinated
From [Portfolio Projects].dbo.CovidDeaths$ AS DEA
JOIN
[Portfolio Projects].dbo.CovidVaccinations$ AS VAC
ON
DEA.Location=VAC.location
AND DEA.date=VAC.date
Where dea.continent is not null
---order by 2,3

SELECT * FROM  PercentpopulationVaccinated




