select*
from PortfolioProject..CovidVaccinations



---Memilih data yang akan digunakan
Select location, date, population, total_cases, new_cases, total_deaths, new_deaths
From PortfolioProject..CovidDeaths
where continent is NOT NULL



---Fatalitas (jumlah kematian vs jumlas kasus perhari)
select location, date, population, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
from PortfolioProject..CovidDeaths
where continent is NOT NULL



---Fatalitas covid di Indonesia
select location, population, max(total_cases) as TotalCases, sum(cast(total_deaths as int)) as TotalDeaths,
(max(cast(total_deaths as int))/max(total_cases))*100 as DeathPerctage
from PortfolioProject..CovidDeaths
where location like 'Indonesia'
Group by location, population



---Urutan negara dengan fatalistas tertinggi
select location, population, max(total_cases) as TotalCases, 
max(cast(total_deaths as int)) as TotalDeaths,
(max(cast(total_deaths as int))/max(total_cases))*100 as DeathsPercentage
from PortfolioProject..CovidDeaths
where continent is NOT NULL
Group by location, population
Order by DeathsPercentage desc



---Persentase populasi yang terkena covid di indonesia
select location,date, population, total_cases, (total_cases/population)*100 as PercentPopulationInfected
from PortfolioProject..CovidDeaths
where location like 'Indonesia'

---Persentase populasi total yang terinfeksi covid di indonesia
select location, population, (max(total_cases)/population)*100 as PercentPopulationInfected
from PortfolioProject..CovidDeaths
where location like 'Indonesia'
group by location, population



---Urutan negara dengan persentase populasi terinfeksi covid
select location, population, max(total_cases) as TotalCases, 
(max(total_cases)/population)*100 as InfectionPercentage
from PortfolioProject..CovidDeaths
where continent is NOT NULL
Group by location, population
Order by InfectionPercentage desc


---Persentase kematian akibat covid per populasi
select location, population, max(total_cases) as TotalCases, 
max(cast(total_deaths as int)) as TotalDeaths,
(max(cast(total_deaths as int))/population)*100 as PopulationDeathsPercentage
from PortfolioProject..CovidDeaths
where continent is NOT NULL
Group by location, population
Order by PopulationDeathsPercentage desc



---persentase terinfeksi per populasi, fatalitas global dan kematian perpopulasi
select sum(new_cases) as TotalCases, sum(cast(new_deaths as int)) as TotalDeaths, sum(population) as TotalPopulation, 
(sum(new_cases)/sum(population))*100 as InfectionPercentage, 
(sum(cast(new_deaths as int))/sum(new_cases))*100 as DeathsPercentage,
(sum(cast(new_deaths as int))/sum(population))*100 as PopulationDeathsPercentage
from PortfolioProject..CovidDeaths
where continent is not null



---persentase populasi yang paling tidak menerima satu kali vaksin
select Vac.location, Vac.date, population, people_vaccinated,
((max(cast(people_vaccinated as int)) OVER (partition by vac.location order by vac.location, vac.date)/population)*100) as
PeopleVaccinated
from PortfolioProject..CovidDeaths as Dea
join PortfolioProject..CovidVaccinations as Vac
	on Dea.location = Vac.location
	and Dea.date = Vac.date
where vac.continent is not null



---urutan negara dengan persentase vaksinasi tertinggi
select CovidVaccinations.location, max(cast(people_fully_vaccinated as int)) as TotalPeopleFullyVaccinated, population, 
(max(cast(people_fully_vaccinated as int))/population)*100 as PeopleVaccinatedPercentage
from PortfolioProject..CovidDeaths
join PortfolioProject..CovidVaccinations
	on CovidDeaths.location = CovidVaccinations.location
where CovidVaccinations.continent is NOT NULL
group by CovidVaccinations.location, population
order by 4 desc



---persentase vaksinasi global
WITH CTE_Vaccinations as (SELECT location, max(cast(people_vaccinated as bigint)) as PeopleVaccinatedperCountry,
max(cast(people_fully_vaccinated as bigint)) as PeopleFullyVaccinatedperCountry
from PortfolioProject..CovidVaccinations
where continent is NOT NULL
group by location)

select sum(population) as GlobalPopulation, sum(PeopleVaccinatedperCountry) as TotalPeopleVaccinated,
sum(PeopleFullyVaccinatedperCountry) as TotalPeopleFullyVaccinated,
(sum(PeopleVaccinatedperCountry)/sum(population))*100 as PeopleVaccinatedPercentage,
(sum(PeopleFullyVaccinatedperCountry)/sum(population))*100 as PeopleFullyVaccinatedPercentage
from PortfolioProject..CovidDeaths
join CTE_Vaccinations
 on CovidDeaths.location = CTE_Vaccinations.location

