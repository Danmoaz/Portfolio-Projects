-- Select all columns from Covid Deaths table where column "continent" has data (diregards NULLS) & orders "location" & "date" in asc. order

Select * From dbo.CovidDeaths
Where continent is not null
order by 3,4

-- Total % deaths by day in the US

Select location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as 'Death %'
From dbo.CovidDeaths
Where location like '%states'
order by 2

-- Total % cases by day in the US

Select location, date,population, total_cases, (total_cases/population)*100 as 'Cases %'
From dbo.CovidDeaths
Where location like '%states'
order by 2

-- Breakdown by % Total Population Infected

Select location, population, MAX(total_cases) as 'Highest Infection Count', MAX((total_cases/population))*100 as '%PopulationInfected'
From dbo.CovidDeaths
Group by location, population
order by '%PopulationInfected' DESC

-- Countries with highest death count. We need to use cast as total_deaths are not stored as integers

Select location, MAX(cast(total_deaths as int)) as 'Total Deaths Count'
From dbo.CovidDeaths
Where continent is not null
Group by location
order by 'Total Deaths Count' DESC

-- Same as above but with convert

Select location, MAX(CONVERT(int, total_deaths)) as 'Total Deaths Count'
From dbo.CovidDeaths
Where continent is not null
Group by location
order by 'Total Deaths Count' DESC

-- Breakdown by Continent

Select continent, MAX(cast(total_deaths as int)) as 'Total Deaths Count'
From dbo.CovidDeaths
Where continent is not null
Group by continent
order by 'Total Deaths Count' DESC

-- Global Numbers (removed date column)

Select SUM(new_cases) as 'Total Cases', SUM(cast(new_deaths as int)) as 'Total Deaths', SUM(cast(new_deaths as int))/SUM(new_cases)*100 as ' % Deaths'
From dbo.CovidDeaths
-- Where location like '%states%'
Where continent is not null
-- Group by date
order by 1,2

-- Join both tables, giving them short names & looking at total population vs. vaccionations

Select *
From dbo.CovidDeaths as dea
join dbo.CovidVaccinations as vac
	on dea.location = vac.location
	and dea.date = vac.date

-- Looking at total population vs. vaccionations

Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
From dbo.CovidDeaths as dea
join dbo.CovidVaccinations as vac
	on dea.location = vac.location
	and dea.date = vac.date
Where dea.continent is not null
and vac.new_vaccinations is not null
-- and dea.location like '%Canada%'
order by 2,3

-- Rolling vaccinations given

Select dea.continent, dea.location, dea.population, vac.new_vaccinations, 
SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.location ORDER by dea.location, dea.date) as 'Total Amount Vaccinations'
From CovidDeaths dea
Join CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
Where dea.continent is not null
--  and dea.location like 'Spain'
Order by 2,3

--

Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
From dbo.CovidDeaths as dea
join dbo.CovidVaccinations as vac
	on dea.location = vac.location
	and dea.date = vac.date
Where dea.continent is not null
and vac.new_vaccinations is not null
-- and dea.location like '%Canada%'
order by 2,3

-- Use CTE as you can't use a created table

With PopsvsVac (continent, location, date, population, new_vaccinations, TotalAmountVaccinations)
as
(
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.location ORDER by dea.location, dea.date) as 'Total Amount Vaccinations'
--, (Total Amount Vaccinations/population)*100
From CovidDeaths dea
Join CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
Where dea.continent is not null
--Order by 2,3
)
Select *, (TotalAmountVaccinations/population)*100 as 'Total Population Vaccinated'
From PopsvsVac

-- Temp Table

DROP Table if exists #PercentPopulationVaccinated -- 
Create Table #PercentPopulationVaccinated
(
Continent nvarchar (255),
Location nvarchar (255),
Date datetime,
Population numeric,
New_vaccinations numeric,
Total_Amount_Vaccinations numeric,
)

Insert into #PercentPopulationVaccinated
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.location ORDER by dea.location, dea.date) as 'Total Amount Vaccinations'
--, (Total Amount Vaccinations/population)*100
From CovidDeaths dea
Join CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
-- Where dea.continent is not null
-- order by 2,3

Select *, (Total_Amount_Vaccinations/population)*100 as 'Total Population Vaccinated'
From #PercentPopulationVaccinated

-- Creating view to store data for later visualizations

Create View PercentPopulationVaccinated as
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.location ORDER by dea.location, dea.date) as 'Total Amount Vaccinations'
--, (Total Amount Vaccinations/population)*100
From CovidDeaths dea
Join CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
Where dea.continent is not null

-- Now we can use the view created

Select *
From PercentPopulationVaccinated