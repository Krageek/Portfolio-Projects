Select *
From PortfolioProject..CovidDeaths
Where continent is not null
Order By 3,4;

--Select *
--From PortfolioProject..CovidVaccinations
--Order By 3,4;

Select Location, date, total_cases, new_cases, total_deaths, population
From PortfolioProject..CovidDeaths
Where continent is not null
Order By 1,2;

-- Total Cases vs Total Deaths as Percentage

Select Location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPerc
From PortfolioProject..CovidDeaths
Where Location like 'Canada'
Order By 1,2;

-- Total Cases vs Population as Percentage

Select Location, date, total_cases, population, (total_cases/population)*100 as CovidPerc
From PortfolioProject..CovidDeaths
Where Location like 'Canada'
Order By 1,2;

-- Countries with highest infection rates based on population

Select Location, Max(total_cases) as HighestInfectionCount, population, Max(total_cases/population)*100 as CovidPerc
From PortfolioProject..CovidDeaths
Where continent is not null
Group By population, Location
Order By CovidPerc DESC;

-- Broken By Continent

-- Countries with highest death count per Population

Select continent, Max(cast(Total_deaths as int)) as TotalDeathCount
From PortfolioProject..CovidDeaths
Where continent is not null
Group By continent
Order By TotalDeathCount DESC;


-- Global Numbers

Select SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, SUM(cast(new_deaths as int))/SUM(New_Cases)*100 as DeathPerc
From PortfolioProject..CovidDeaths
Where continent is not null
--Group By date
Order By 1,2;


-- Total Population vs Vaccinations

Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(cast (vac.new_vaccinations as int)) OVER (Partition by dea.location Order by dea.location,dea.date) as RollingPeopleVaccinated
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
	On dea.location = vac.location 
	and dea.date = vac.date
Where dea.continent is not null
Order By 2,3;

-- Use CTE

With PopvsVac (Continent, Location, Date, Population, New_Vaccinations, RollingPeopleVaccinated)
as 
(
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(cast (vac.new_vaccinations as int)) OVER (Partition by dea.location Order by dea.location,dea.date) as RollingPeopleVaccinated
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
	On dea.location = vac.location 
	and dea.date = vac.date
Where dea.continent is not null
--Order By 2,3;
)
Select *, (RollingPeopleVaccinated/Population)*100
From PopvsVac


-- Temp Table

Drop Table if exists #PercentPopulationVaccinated
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
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(cast (vac.new_vaccinations as int)) OVER (Partition by dea.location Order by dea.location,dea.date) as RollingPeopleVaccinated
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
	On dea.location = vac.location 
	and dea.date = vac.date
--Where dea.continent is not null
--Order By 2,3;

Select *, (RollingPeopleVaccinated/Population)*100
From #PercentPopulationVaccinated



-- Creating View to store data for later visualizations

Create View PercentPopulationVaccinated as
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(cast (vac.new_vaccinations as int)) OVER (Partition by dea.location Order by dea.location,dea.date) as RollingPeopleVaccinated
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
	On dea.location = vac.location 
	and dea.date = vac.date
Where dea.continent is not null
--Order By 2,3;

Select *
From PercentPopulationVaccinated;