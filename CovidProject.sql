USE Covid_Project;
SELECT * FROM CovidDeaths;

--Preview of the data
USE Covid_Project;
SELECT * FROM CovidDeaths;
SELECT * FROM CovidVaccination;

--Total deaths v Total Population
with cte as
(
SELECT date,location,new_cases,new_deaths,
CASE
	WHEN new_cases IS  NULL THEN 0
	ELSE new_cases
	END AS cases,
CASE
	WHEN new_deaths IS NULL THEN 0
	ELSE new_deaths
	END AS deaths
FROM CovidDeaths
)
SELECT location,ROUND((SUM(deaths)/SUM(cases))*100,2) as death_percentage
FROM cte
WHERE cases>0
GROUP BY location
ORDER BY location;

--Top 10 Countries having highest infection rate
SELECT top 10 location,ROUND((MAX(total_cases)/MAX(Population))*100,2) AS infection_rate
FROM CovidDeaths
GROUP BY location
ORDER BY infection_rate DESC

--Preview of the data
USE Covid_Project;
SELECT * FROM CovidDeaths;
SELECT * FROM CovidVaccination;

--Total deaths v Total Population
with cte as
(
SELECT date,location,new_cases,new_deaths,
CASE
	WHEN new_cases IS  NULL THEN 0
	ELSE new_cases
	END AS cases,
CASE
	WHEN new_deaths IS NULL THEN 0
	ELSE new_deaths
	END AS deaths
FROM CovidDeaths
)
SELECT location,ROUND((SUM(deaths)/SUM(cases))*100,2) as death_percentage
FROM cte
WHERE cases>0
GROUP BY location
ORDER BY location;

--Top 10 Countries having highest infection rate
SELECT top 10 location,ROUND((MAX(total_cases)/MAX(Population))*100,2) AS infection_rate
FROM CovidDeaths
GROUP BY location
ORDER BY infection_rate DESC


--Countries with highest death rate
SELECT location,ROUND((MAX(CONVERT(int,total_deaths))/MAX(population))*100,2) as death_rate
FROM Coviddeaths
WHERE continent IS NOT NULL
GROUP BY location
ORDER BY location;

--Total deathcount per continent
SELECT continent,MAX(cast(total_deaths as int)) as deaths
FROM CovidDeaths
WHERE continent IS NOT NULL
GROUP By continent
ORDER BY deaths DESC;

--Daily global data
SELECT  date,SUM(new_cases) as cases,SUM(CONVERT(int,new_deaths)) as deaths
FROM CovidDeaths
WHERE continent IS NOT NULL
GROUP BY date
ORDER BY date;


--Calculating total population vs total vaccinated people
SELECT cd.location,MAX(cd.population) as population,MAX(CONVERT(float,people_vaccinated)) as vaccinations,
ROUND((MAX(CONVERT(float,people_vaccinated))/MAX(cd.population))*100,2) as vaccine_rate
FROM CovidDeaths cd
JOIN CovidVaccination cv
ON cd.location=cv.location AND cd.date=cv.date
WHERE cd.continent IS NOT NULL 
GROUP BY cd.location



--Countries with highest death rate
SELECT location,ROUND((MAX(CONVERT(int,total_deaths))/MAX(population))*100,2) as death_rate
FROM Coviddeaths
WHERE continent IS NOT NULL
GROUP BY location
ORDER BY location;

--Total deathcount per continent
SELECT continent,MAX(cast(total_deaths as int)) as deaths
FROM CovidDeaths
WHERE continent IS NOT NULL
GROUP By continent
ORDER BY deaths DESC;

--Daily global data
SELECT  date,SUM(new_cases) as cases,SUM(CONVERT(int,new_deaths)) as deaths
FROM CovidDeaths
WHERE continent IS NOT NULL
GROUP BY date
ORDER BY date;


--Calculating total population vs total vaccinated people
SELECT cd.location,MAX(cd.population) as population,MAX(CONVERT(float,people_vaccinated)) as vaccinations,
ROUND((MAX(CONVERT(float,people_vaccinated))/MAX(cd.population))*100,2) as vaccine_rate
FROM CovidDeaths cd
JOIN CovidVaccination cv
ON cd.location=cv.location AND cd.date=cv.date
WHERE cd.continent IS NOT NULL 
GROUP BY cd.location

--Finding the total number of confirmed cases in a specific country
SELECT location,MAX(total_cases) as cases
FROM CovidDeaths
WHERE continent IS NOT NULL         --location also contains all the continent.So,removing the continet from the data
GROUP BY location
ORDER BY location

--Finding the total number of confirmed deaths in a specific country
with cte as
(
SELECT location,new_deaths,
CASE
	WHEN new_deaths IS NULL THEN 0
	ELSE new_deaths
	END AS death
from CovidDeaths
)
SELECT location,SUM(death) as total_death
FROM cte
GROUP BY location
ORDER BY location;



--Trend of confirmed cases over time
with cte as
(
SELECT DATEPART(year,date) as year,DATEPART(month,date) as month,SUM(new_cases) as total_cases
FROM CovidDeaths
GROUP BY DATEPART(year,date),DATEPART(month,date)
),
cte2 as
(
SELECT *,LAG(total_cases) OVER(ORDER BY year,month) as pre_month_case
FROM cte
)
SELECT CONCAT(year,'-',month),total_cases,((total_cases-pre_month_case)/pre_month_case)*100 as increment_rate
FROM cte2


--Comparison of confirmed deaths between regions 
SELECT continent,SUM(CONVERT(int,new_deaths)) as total_deaths
FROM CovidDeaths
WHERE continent IS NOT NULL
GROUP BY continent
ORDER BY total_deaths DESC;


--Is there any affect of smoking rate on total cases
with cte as
(
SELECT cd.continent,cd.location,cd.date,cd.population,cd.new_cases,cd.new_deaths,cd.icu_patients,cd.hosp_patients,
cv.population_density,cv.median_age,cv.aged_65_older,cv.aged_70_older,cv.gdp_per_capita,cv.extreme_poverty,
cv.cardiovasc_death_rate,cv.diabetes_prevalence,cv.female_smokers,cv.male_smokers,cv.life_expectancy,cv.human_development_index
FROM CovidDeaths cd
JOIN CovidVaccination cv
ON (cd.location=cv.location) AND cd.date=cv.date
)
SELECT location,ROUND((SUM(new_cases)/MAX(population))*100,2) as case_rate,
(ROUND(AVG(CONVERT(float,male_smokers)),2) + ROUND(AVG(CONVERT(float,female_smokers)),2))/2 as smoking_rate
FROM cte
WHERE continent IS NOT NULL
GROUP BY location
HAVING ROUND(AVG(CONVERT(float,male_smokers)),2) IS NOT NULL
ORDER BY case_rate DESC



--Effect of stringency index on covid cases in UK
with cte as
(
SELECT cd.continent,cd.location,cd.date,cd.population,cd.new_cases,cd.new_deaths,cv.stringency_index,cd.icu_patients,cd.hosp_patients,
cv.population_density,cv.median_age,cv.aged_65_older,cv.aged_70_older,cv.gdp_per_capita,cv.extreme_poverty,
cv.cardiovasc_death_rate,cv.diabetes_prevalence,cv.female_smokers,cv.male_smokers,cv.life_expectancy,cv.human_development_index
FROM CovidDeaths cd
JOIN CovidVaccination cv
ON (cd.location=cv.location) AND cd.date=cv.date
),
cte2 as
(
SELECT DATEPART(year,date) as yr,DATEPART(month,date) as mnth,
CASE
	WHEN stringency_index <20 OR stringency_index IS NULL THEN '0-20'
	WHEN stringency_index<40 THEN '20-40'
	WHEN stringency_index<60 THEN '40-60'
	WHEN stringency_index<80 THEN '60-80'
	ELSE '80+'
	END AS si_index,
new_cases
FROM cte
WHERE location='United Kingdom'
)
SELECT CONCAT(yr,'-',mnth) as date,si_index,SUM(new_cases) as total_cases
FROM cte2
GROUP BY yr,mnth,si_index;


--Covid Positive Rate (Since the total tests data is missing in the later part of the data,this positive rate might be incorrect)

SELECT cv.location,MAX(cd.total_cases) as cases,MAX(CONVERT(bigint,cv.total_tests)) as tests,
ROUND((MAX(cd.total_cases)/MAX(CONVERT(bigint,cv.total_tests)))*100,2) as positive_rate 
FROM CovidDeaths cd
JOIN CovidVaccination cv
ON cd.location=cv.location AND cd.date=cv.date
WHERE cd.continent IS NOT NULL
GROUP BY cv.location
HAVING MAX(cd.total_cases) IS NOT NULL AND MAX(cv.total_tests) IS NOT NULL
ORDER BY ROUND((MAX(cd.total_cases)/MAX(CONVERT(bigint,cv.total_tests)))*100,2) DESC


--Increment on Covid Tests based on population
--Since the data is inconsistent on countries we are carrying out this operation only for United Kingdom
with cte as
(
SELECT cd.date as date,CONCAT(DATEPART(year,cd.date),'-',DATEPART(month,cd.date)) as dt,
cd.population as population,
cd.total_cases - LAG(cd.total_cases) OVER (ORDER BY cd.date) as today_case,
CONVERT(int,cv.total_tests)-LAG(CONVERT(int,cv.total_tests)) OVER(ORDER BY cd.date) as today_tests
FROM CovidDeaths cd
JOIN CovidVaccination cv
ON cd.location=cv.location AND cd.date=cv.date
WHERE cd.location='United Kingdom' and cv.total_tests IS NOT NULL
)
SELECT CONCAT(DATEPART(year,date),'-',DATEPART(month,date)) as yrmnth,MAX(population) as popn,SUM(today_tests) as monthly_test
FROM cte
GROUP BY DATEPART(year,date),DATEPART(month,date)
HAVING SUM(today_case) IS NOT NULL AND SUM(today_tests) IS NOT NULL
ORDER BY DATEPART(year,date),DATEPART(month,date)


--vaccination rate of each country
SELECT cd.location,MAX(cd.population) as population,
MAX(cv.people_vaccinated) as vaccinated_people,
ROUND((MAX(cv.people_vaccinated)/MAX(cd.population))*100,2) as vaccine_rate
FROM CovidDeaths cd
JOIN CovidVaccination cv
ON cd.location=cv.location AND cd.date=cv.date
WHERE cd.continent IS NOT NULL
GROUP BY cd.location
ORDER BY ROUND((MAX(cv.people_vaccinated)/MAX(cd.population))*100,2) DESC; --HERE UAE has vaccine rate greater than 100 which implies they vaccinated their entire country along with other nationality


--Top 3 countries in every continent with higest vaccine rate
with cte as
(
SELECT cd.continent,cd.location,MAX(cd.population) as population,MAX(cv.people_vaccinated) as total_vaccinated,
ROUND((MAX(cv.people_vaccinated)/MAX(cd.population))*100,2) as vaccine_rate
FROM CovidVaccination cv
JOIN CovidDeaths cd
ON cd.location=cv.location AND cd.date=cv.date
WHERE cd.continent IS NOT NULL
GROUP BY cd.continent,cd.location
HAVING MAX(cv.people_vaccinated) IS NOT NULL
),
cte2 as
(
SELECT *,
DENSE_RANK() OVER(PARTITION BY continent ORDER BY vaccine_rate DESC) as rnk
FROM cte
)
SELECT *
FROM cte2
WHERE rnk IN (1,2,3);