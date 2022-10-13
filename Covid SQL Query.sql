SELECT * 
FROM ProjectCovid..CovidDeath$
ORDER BY 3,4

SELECT * 
FROM ProjectCovid..CovidVaccine$
ORDER BY 3,4

--mengetahui persentase penderita yang meninggal karena covid di Indonesia
SELECT location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as PersentasiKematian
FROM ProjectCovid..CovidDeath$
WHERE location = 'Indonesia'
AND continent is not null
ORDER BY 1,2

--Mengetahui perbandingan penderita covid dengan jumlah populasi di Indonesia
SELECT location, date, population, total_cases, (total_cases/population)*100 as PersentasiPenderitaCovid
FROM ProjectCovid..CovidDeath$
WHERE location = 'Indonesia'
ORDER BY 1,2

--mengetahui persentase penderita covid terbanyak berdasarkan populasinya
SELECT continent, location, population, MAX(total_cases) as TotalCase, MAX((total_cases/population))*100 as PersentasiPenderitaCovid
FROM ProjectCovid..CovidDeath$
WHERE continent is not null
GROUP BY continent, location, population
ORDER BY PersentasiPenderitaCovid desc

--mengetahui korban covid yang meninggal terbanyak berdasarkan negara
SELECT continent, location, MAX(CAST(total_deaths as int)) as TotalKematian
FROM ProjectCovid..CovidDeath$
WHERE continent is not null 
GROUP BY continent, location
ORDER BY TotalKematian desc

--mengetahui korban covid yang meninggal terbanyak berdasarkan benua
SELECT continent, MAX(CAST(total_deaths as int)) as TotalKematian
FROM ProjectCovid..CovidDeath$
WHERE continent is not null 
GROUP BY continent
ORDER BY TotalKematian desc

--mengetahui jumlah korban yang terkena covid dan persentase yang meninggal setiap hari
SELECT date, SUM(new_cases) as total_cases, SUM(CAST(new_deaths as int)) as total_death, SUM(CAST(new_deaths as int))/SUM(new_cases)*100 as PersentaseMeninggal
FROM ProjectCovid..CovidDeath$
WHERE continent is not null
GROUP BY date
ORDER BY date

--total jumlah korban yang terkena covid dan meninggal
SELECT SUM(new_cases) as total_cases, SUM(CAST(new_deaths as int)) as total_death, SUM(CAST(new_deaths as int))/SUM(new_cases)*100 as PersentaseMeninggal
FROM ProjectCovid..CovidDeath$
WHERE continent is not null


--mengetahui jumlah orang yang sudah divaksin setiap hari
SELECT ded.continent, ded.location, ded.date, ded.population, vac.new_vaccinations
, SUM(CAST(vac.new_vaccinations as bigint)) OVER (PARTITION BY ded.location ORDER BY ded.location, ded.date) as SudahDivaksin
FROM ProjectCovid..CovidDeath$ ded
JOIN ProjectCovid..CovidVaccine$ vac
	ON ded.location = vac.location
	and ded.date = vac.date
WHERE ded.continent is not null
ORDER BY 2,3

--mengetahui persentase orang yang sudah divaksin di setiap negara
with udahVaksin (continent, location, population, SudahDivaksin)
as
(
SELECT ded.continent, ded.location, ded.population
, MAX(CAST(vac.new_vaccinations as bigint)) OVER (PARTITION BY ded.location ORDER BY ded.location) as SudahDivaksin
FROM ProjectCovid..CovidDeath$ ded
JOIN ProjectCovid..CovidVaccine$ vac
	ON ded.location = vac.location
	and ded.date = vac.date
WHERE ded.continent is not null
)
SELECT *, (SudahDivaksin/population)*100 as PersentaseSudahVaksin
FROM udahVaksin
GROUP BY continent, location, population, SudahDivaksin
ORDER BY continent, location




--MEMBUAT VIEW
CREATE VIEW PersentaseKematianIndo as 
SELECT location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as PersentasiKematian
FROM ProjectCovid..CovidDeath$
WHERE location = 'Indonesia'
AND continent is not null

CREATE VIEW PersentasePenderitaCovid as
SELECT continent, location, population, MAX(total_cases) as TotalCase, MAX((total_cases/population))*100 as PersentasiPenderitaCovid
FROM ProjectCovid..CovidDeath$
WHERE continent is not null
GROUP BY continent, location, population

CREATE VIEW TotalKorbanCovid as
SELECT continent, location, MAX(CAST(total_deaths as int)) as TotalKematian
FROM ProjectCovid..CovidDeath$
WHERE continent is not null 
GROUP BY continent, location

CREATE VIEW TotalKorbanCovidBenua as
SELECT continent, MAX(CAST(total_deaths as int)) as TotalKematian
FROM ProjectCovid..CovidDeath$
WHERE continent is not null 
GROUP BY continent

CREATE VIEW DailyUpdate as
SELECT date, SUM(new_cases) as total_cases, SUM(CAST(new_deaths as int)) as total_death, SUM(CAST(new_deaths as int))/SUM(new_cases)*100 as PersentaseMeninggal
FROM ProjectCovid..CovidDeath$
WHERE continent is not null
GROUP BY date

CREATE VIEW TotalCovid as
SELECT SUM(new_cases) as total_cases, SUM(CAST(new_deaths as int)) as total_death, SUM(CAST(new_deaths as int))/SUM(new_cases)*100 as PersentaseMeninggal
FROM ProjectCovid..CovidDeath$
WHERE continent is not null

CREATE VIEW DailyVaksin as
SELECT ded.continent, ded.location, ded.date, ded.population, vac.new_vaccinations
, SUM(CAST(vac.new_vaccinations as bigint)) OVER (PARTITION BY ded.location ORDER BY ded.location, ded.date) as SudahDivaksin
FROM ProjectCovid..CovidDeath$ ded
JOIN ProjectCovid..CovidVaccine$ vac
	ON ded.location = vac.location
	and ded.date = vac.date
WHERE ded.continent is not null

CREATE VIEW StatusVaksin as
with udahVaksin (continent, location, population, SudahDivaksin)
as
(
SELECT ded.continent, ded.location, ded.population
, MAX(CAST(vac.new_vaccinations as bigint)) OVER (PARTITION BY ded.location ORDER BY ded.location) as SudahDivaksin
FROM ProjectCovid..CovidDeath$ ded
JOIN ProjectCovid..CovidVaccine$ vac
	ON ded.location = vac.location
	and ded.date = vac.date
WHERE ded.continent is not null
)
SELECT *, (SudahDivaksin/population)*100 as PersentaseSudahVaksin
FROM udahVaksin
GROUP BY continent, location, population, SudahDivaksin
