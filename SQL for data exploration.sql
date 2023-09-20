--Death_table

-- There're some contient is NULL so location is all contient --> This is incorrect when we compare countries so we sort out all continents which are NULL
Select * 
From Covid_Death
WHERE continent is not null
Order by 3,4

-- Looking total_cases vs total_deaths
-- Show likelihood of dying if you contract covid in your country
Select location, date, population, total_cases, total_deaths, (convert(decimal, total_deaths)/(convert(decimal,total_cases)))*100 AS Death_Percentage 
FROM Covid_Death
--Where location = 'vietnam'
WHERE continent is not null
Order by 1,2

-- Looking total_cases vs population
-- Show what percentage of population got Covid
Select location, date, population, total_cases, (convert(decimal, total_cases)/(convert(decimal,population)))*100 AS Case_Percentage 
FROM Covid_Death
--Where location = 'vietnam'
WHERE continent is not null
Order by 5 desc

-- Looking at countries with highest infection rate compared to population

Select location, population, Max(cast(total_cases as decimal)) AS Max_total_cases, Max(convert(decimal, total_cases)/(convert(decimal, population)))*100 AS Percent_Population_Infected
FROM Covid_Death
--Where location like '%vietnam%'
WHERE continent is not null
Group by location, population
Order by Percent_Population_Infected desc

-- Showing country with highest death count per population
Select location, Max(cast(total_deaths as int)) AS Max_total_death_count
--Where location like '%vietnam%'
From Covid_Death
WHERE continent is not null
Group by location
Order by Max_total_death_count desc

-- Let's break things down by continent
Select continent, Max(cast(total_deaths as int)) AS Max_total_death_count
--Where location like '%vietnam%'
From Covid_Death
WHERE continent is not null
Group by continent
Order by Max_total_death_count desc

-- SHhowing the continent with hiaghest death count
Select continent, Max(cast(total_deaths as int)) AS Max_total_death_count
--Where location like '%vietnam%'
From Covid_Death
WHERE continent is not null
Group by continent
Order by Max_total_death_count desc

-- GLobal Number
Select date, sum(new_cases) AS total_cases, sum(new_deaths) as total_deaths, case when sum(new_cases) = 0 then null else sum(new_deaths)/sum(new_cases)*100 end as death_percentage
FROM Covid_Death
--Where location = 'vietnam'
--WHERE new_cases is not null and new_deaths is not null
Group by date
Order by 1

Select sum(new_cases) AS total_cases, sum(new_deaths) as total_deaths, sum(new_deaths)/nullif (sum(new_cases),0)*100 as death_percentage
FROM Covid_Death
--Where location = 'vietnam'
--WHERE new_cases is not null and new_deaths is not null
--Group by date
Order by 1

--Vaccinations_table

Select * 
From Covid_Vaccinations

--Looking at total population & Vaccinations

--Use Subquery

Select * , rolling_people_vaccinated/population *100
From
(Select  Dea.continent, Dea.location, Dea.date, dea.population, Vac.new_vaccinations, Sum(convert(decimal, Vac.new_vaccinations)) over(partition by dea.location order by dea.location, dea.date) as rolling_people_vaccinated
From Covid_Death Dea
Join Covid_Vaccinations Vac
On Dea.location = Vac.location
And Dea.date = Vac.date
Where Dea.continent is not null ) 
AS popvsvac

--Use Temporary table

Drop table if exists #PercentPopulationVaccinated
Create Table #PercentPopulationVaccinated
(
continent nvarchar(255),
location nvarchar(255),
date datetime,
population numeric,
new_vaccinations numeric,
rolling_people_vaccinated numeric
)
Insert into #PercentPopulationVaccinated
Select  Dea.continent, Dea.location, Dea.date, dea.population, Vac.new_vaccinations, Sum(convert(decimal, Vac.new_vaccinations)) over(partition by dea.location order by dea.location, dea.date) as rolling_people_vaccinated
From Covid_Death Dea
Join Covid_Vaccinations Vac
On Dea.location = Vac.location
And Dea.date = Vac.date
Where Dea.continent is not null

Select *, rolling_people_vaccinated/population *100
From #PercentPopulationVaccinated

--Creating view to store data for data visualizations

Create View PercentPopulationVaccinated As
Select  Dea.continent, Dea.location, Dea.date, dea.population, Vac.new_vaccinations, Sum(convert(decimal, Vac.new_vaccinations)) over(partition by dea.location order by dea.location, dea.date) as rolling_people_vaccinated
From Covid_Death Dea
Join Covid_Vaccinations Vac
On Dea.location = Vac.location
And Dea.date = Vac.date
Where Dea.continent is not null
