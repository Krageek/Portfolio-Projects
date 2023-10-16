-- Queries exploring Covid Data till May 2021

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


Select *--, (RollingPeopleVaccinated/Population)*100
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


-- Queries used for Tableau Project 1 on older Covid data till May 2021

Select SUM(cast(new_cases as int)) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, SUM(cast(new_deaths as int))/SUM(New_Cases)*100 as DeathPercentage
From PortfolioProject..CovidDeaths
--Where location like '%states%'
where continent is not null 
--Group By date
order by 1,2




Select location, SUM(cast(new_deaths as int)) as TotalDeathCount
From PortfolioProject..CovidDeaths
--Where location like '%states%'
Where continent is null 
and location not in ('World', 'European Union', 'International')
Group by location
order by TotalDeathCount desc

Select Location, Population, MAX(total_cases) as HighestInfectionCount,  Max((total_cases/population))*100 as PercentPopulationInfected
From PortfolioProject..CovidDeaths
--Where location like '%states%'
Group by Location, Population
order by PercentPopulationInfected desc




Select Location, Population,date, MAX(total_cases) as HighestInfectionCount,  Max((total_cases/population))*100 as PercentPopulationInfected
From PortfolioProject..CovidDeaths
--Where location like '%states%'
Group by Location, Population, date
order by PercentPopulationInfected desc


-- Queries based on updated Covid data till the latest available date (Oct 2023)

Select *
From PortfolioProject..CovidData
Order By location, date;



-- Total cases vs New cases for Canada

Select location, date, new_cases, total_cases
From PortfolioProject..CovidData
Where location like 'Canada'
Order By 2;

-- Total cases vs ICU patients for Canada

Select location, date, new_cases, total_cases, icu_patients
From PortfolioProject..CovidData
Where location like 'Canada'
Order By 2;

--Totat deaths vs Cases as a Percentage

Select location, date, total_cases, total_deaths, (cast(total_deaths as float)/cast(total_cases as float)) * 100 as DeathPerc
From PortfolioProject..CovidData
--Where location like 'Canada'
Order By 1,2;

-- Total number of cases and Total number of tests in Canada

Select location, date, total_cases, total_tests
From PortfolioProject..CovidData
Where location like 'Canada'
Order by 1,2;


--Select location, MAX(cast(total_deaths as int))
--From PortfolioProject..CovidData
--Where location like 'Canada'
--Group By location
----Order By 2;

--Select location, Max(cast(total_deaths_per_million as float))
--From PortfolioProject..CovidData
----Where location like 'India'
--Group By location
--Order by 2 DESC;



-- Tableau Queries for 2nd COVID dashboard

-- Total Cases vs Total Deaths as Percentage
Select location, MAX(cast(total_cases as int)) as TotalCases, MAX(cast(total_deaths as int)) as TotalDeaths, MAX(cast(total_deaths as float))/MAX(cast(total_cases as float)) *100 as TotalDeathsPerc
From PortfolioProject..CovidData
--Where location like 'India'
Group By location
Order By 4;

-- Total Population that was infected as a percentage
Select Location, MAX(population) as Population, MAX(cast(total_cases as int)) as HighestCases, (MAX(cast(total_cases as int))/MAX(population)) * 100 as PopulationInfectedPercentage
From PortfolioProject..CovidData
Group By location
Order By 1;

-- Number of patients in the hospitals across 4 countries
Select location, date, total_cases, icu_patients, hosp_patients, hosp_patients_per_million
From PortfolioProject..CovidData
Where location in ('United States','Canada', 'United Kingdom', 'Australia')
Order by 1,2;

--Select location, MAX(cast(total_cases as int)), MAX(cast(total_deaths as int))
--From PortfolioProject..CovidData
--Where location like 'India'
--Group By location;

-- Total Vaccinations vs Death rate for Canada
Select location, date, total_cases, total_deaths, total_vaccinations, cast(total_deaths as float)/cast(total_cases as float) *100 as FatalityRate
From PortfolioProject..CovidData
Where location like 'Canada'
Order By 1,2;

--Total Cases vs Hospital Patients as a Percentage in Canada (Unused)
Select location, date, total_cases, hosp_patients, cast(hosp_patients as float)/cast(total_cases as float) * 100 as CovidPatientsPercentage
From PortfolioProject..CovidData
Where location like 'Canada'
Order by 2;

-- Total Cases vs Hospital Patients as a Percentage in Canada while showing running maximum COVID patients vs Total Cases percentage value in Canada (Unused)
Select location, date, total_cases, hosp_patients, MAX(cast(hosp_patients as float)/cast(total_cases as float) * 100) Over (Partition By location Order By location, date) as MaxCovidPatientsPercentage
From PortfolioProject..CovidData
Where location like 'Canada'
--Order by 2;




