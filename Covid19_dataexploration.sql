Select * from Covid_Death
select * from Covid_Vaccination

----Checking the Total Cases vs Total Death
--Shows likelihood of dying if you contracted Covid in Nigeria
Select location, date, total_cases,total_deaths,(total_deaths/total_cases)*100  as DeathPercentage
From Covid_Death
--Where location = 'Nigeria'
Order by 1,2 desc

--Checking the Total case VS the Country's population
--Shows the percentage of of the population that got infected
Select location, date, population,total_cases,(total_cases/population)*100  as InfectedPercentage
From Covid_Death
Where continent is not null
--Where location = 'Nigeria'
Order by 1,2

--Country with highest infection rate compare to population
Select location,  population,max(total_cases) as HighestInfection,max((total_cases/population))*100  as highestInfectedPercentage
From Covid_Death
Where continent is not null
group by location, population
Order by 4 desc

--SHowing the continent with highest death count per population
Select continent,max(total_deaths) as TotalDeathCount
From Covid_Death
Where continent is not null
group by continent
Order by 2 desc

--This code is more accurate
Select location,max(total_deaths) as TotalDeathCount
From Covid_Death
Where continent is null
group by location
Order by 2 desc

--Global View Data
--Showing the new cases daily around the world
Select date, sum(new_cases) as Daily_New_Cases
From Covid_Death
Where continent is not null
group by date
Order by 1 

--showing the total cases each day around the world
Select date, sum(total_cases) as Daily_Total_Cases
From Covid_Death
Where continent is not null
group by date
Order by 1 

--Joining both tables
Select *
From Covid_death death
join Covid_Vaccination vaccine
on death.date = vaccine.date and death.location = vaccine.location 

--Looking at total population vs vaccination
Select death.continent, death.location, death.date, death.population,vaccine.new_vaccinations,
SUM(convert (bigint, vaccine.new_vaccinations)) Over (Partition by death.location order by death.location,death.date) as Vaccination_Progress
From Covid_death death
join Covid_Vaccination vaccine
on death.date = vaccine.date and death.location = vaccine.location
Where death.continent is not null
order by 1,2,3
--rate of vaccination in the country using CTE
with popvsvac (continent, location, date,population, new_vaccination,vaccination_progress)
as
(Select death.continent, death.location, death.date, death.population,vaccine.new_vaccinations,
SUM(convert (bigint, vaccine.new_vaccinations)) Over (Partition by death.location order by death.location,death.date) as Vaccination_Progress
From Covid_death death
join Covid_Vaccination vaccine
on death.date = vaccine.date and death.location = vaccine.location
Where death.continent is not null

)
select  *, (convert (decimal, vaccination_progress)/population)*100 as rate
From popvsvac

--rate of vaccination in the country using Temp Table
Drop Table if exists #vaccinatedpercentage
Create Table #vaccinatedpercentage
(continent nvarchar (100),
location nvarchar (150),
Date datetime,
population numeric,
New_vaccination numeric,
Vaccination_progress numeric)
insert into #vaccinatedpercentage
Select death.continent, death.location, death.date, death.population,vaccine.new_vaccinations,
SUM(convert (bigint, vaccine.new_vaccinations)) Over (Partition by death.location order by death.location,death.date) as Vaccination_Progress
From Covid_death death
join Covid_Vaccination vaccine
on death.date = vaccine.date and death.location = vaccine.location
Where death.continent is not null

select  *, ( vaccination_progress/population)*100 as rate
From #vaccinatedpercentage

--creating view to store data later for visualization
Create view percentagepopulationvaccinated as 
Select death.continent, death.location, death.date, death.population,vaccine.new_vaccinations,
SUM(convert (bigint, vaccine.new_vaccinations)) Over (Partition by death.location order by death.location,death.date) as Vaccination_Progress
From Covid_death death
join Covid_Vaccination vaccine
on death.date = vaccine.date and death.location = vaccine.location
Where death.continent is not null
