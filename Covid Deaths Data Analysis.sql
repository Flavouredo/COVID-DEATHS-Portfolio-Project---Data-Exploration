

Select *
From PortfolioProjectOne..CovidDeaths
where continent is not null
order by 3,4


---Looking at Total Cases vs Total Deaths
---This shows the likelihood of dying if you contract covid in your country
Select Location, date, total_cases, total_deaths, (total_deaths/total_cases)* 100 as DeathPercentage
From PortfolioProjectOne..CovidDeaths
Where location like '%states%'
and continent is not null
order by 1,2


---Loking at the Total Cases vs Population
---Shows what percentage of Population got covid

Select Location, date, Population, total_cases, (total_cases/population)* 100 as PopulationPercentage
From PortfolioProjectOne..CovidDeaths
---Where location like '%states%'
order by 1,2


---Looking at countries with infection rate compared to population
Select Location, Population, MAX(total_cases) as HighestInfectionCount, MAX(total_cases/population)* 100 as PopulationInfected
From PortfolioProjectOne..CovidDeaths
---Where location like '%states%'
group by location, population
order by 4 desc



---Showing the countries with the highest Death count perpopulation
Select Location, MAX(cast(total_deaths as int)) as TotalDeathCount
From PortfolioProjectOne..CovidDeaths
---Where location like '%states%'
where continent is not null
group by location
order by 2 desc



--Let's break things down by continent
---Showing the continets with the highest death count

Select continent, MAX(cast(total_deaths as int)) as TotalDeathCount
From PortfolioProjectOne..CovidDeaths
---Where location like '%states%'
where continent is not null
group by continent
order by 2 desc


--Global Numbers

Select SUM(new_cases), SUM(cast(new_deaths as int)), SUM(cast(new_deaths as int))/SUM(New_Cases)*100 as DeathPercentage
From PortfolioProjectOne..CovidDeaths 
--Where location like '%states%'
where continent is not null
--Group by date
order by 1,2



--Looking at Total Population vs Vaccinations

Select sww.continent, sww.location, sww.date, sww.population, cdd.new_vaccinations
, SUM(CONVERT(int,cdd.new_vaccinations)) OVER (Partition by sww.Location Order by sww.Location, sww.date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From PortfolioProjectOne..CovidDeaths sww 
Join PortfolioProjectOne..CovidVaccinations cdd
   On sww.location = cdd.location
	and sww.date = cdd.date
Where sww.continent is not null
and cdd.new_vaccinations is not null 
order by 2,3




-- USE CTE

With PopvsVac (Continent, Location, Date, Population, New_Vaccinations, RollingPeopleVaccinated)
as
(
Select sww.continent, sww.location, sww.date, sww.population, cdd.new_vaccinations
, SUM(CONVERT(int,cdd.new_vaccinations)) OVER (Partition by sww.Location Order by sww.Location, sww.date) as RollingPeopleVaccinated

From PortfolioProjectOne..CovidDeaths sww 
Join PortfolioProjectOne..CovidVaccinations cdd
   On sww.location = cdd.location
	and sww.date = cdd.date
Where sww.continent is not null
and cdd.new_vaccinations is not null 
--order by 2,3
)

Select *, (RollingPeopleVaccinated/Population)*100
From PopvsVac


--Temp table


Create Table #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccinations numeric,
RollingPeopleVaccinated numeric
)


Insert into #PercentPopulationVaccinated
Select sww.continent, sww.location, sww.date, sww.population, cdd.new_vaccinations
, SUM(CONVERT(int,cdd.new_vaccinations)) OVER (Partition by sww.Location Order by sww.Location, sww.date) as RollingPeopleVaccinated
From PortfolioProjectOne..CovidDeaths sww 
Join PortfolioProjectOne..CovidVaccinations cdd
   On sww.location = cdd.location
	and sww.date = cdd.date

Select *, (RollingPeopleVaccinated/Population)*100
From #PercentPopulationVaccinated


--- Craeting Views
Create View #PercentPopulationVaccinated as
Select sww.continent, sww.location, sww.date, sww.population, cdd.new_vaccinations
, SUM(CONVERT(int,cdd.new_vaccinations)) OVER (Partition by sww.Location Order by sww.Location, sww.date) as RollingPeopleVaccinated
From PortfolioProjectOne..CovidDeaths sww 
Join PortfolioProjectOne..CovidVaccinations cdd
   On sww.location = cdd.location
	and sww.date = cdd.date
Where sww.continent is not null