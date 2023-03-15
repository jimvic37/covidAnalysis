--  drop table if exists for puprpose of altering table 
DROP Table IF exists covid_deaths;
-- create table for covid vaccination
Create table covid_deaths(
	iso_code CHAR(3) NOT NULL, 
    continent varchar(20) default null,
    location varchar(20) NOT NULL,
    c_date date NOT NULL,
    population INT NOT NULL,
    population_density float,
    total_cases int,
    new_cases int,
    new_cases_smoothed float, 
    total_deaths int,
    new_deaths int,
    new_deaths_smoothed float, 
    total_cases_per_million float, 
    new_cases_per_million float, 
    new_cases_smoothed_per_million float, 
    total_deaths_per_million float,
    new_deaths_per_million float,
    new_deaths_smoothed_per_million float, 
    reproduction_rate float,
    icu_patients int,
    icu_patients_per_million float, 
    hosp_patients int, 
    hosp_patients_per_million float, 
    weekly_icu_admissions int,
    weekly_icu_admissions_per_million float,
    weekly_hosp_admissions int, 
    weekly_hosp_admissions_per_million float,
    total_tests int, 
    new_tests int, 
    total_tests_per_thousand float,
    new_tests_per_thousand float, 
    new_tests_smoothed int, 
    new_tests_smoothed_per_thousand float, 
    positive_rate float, 
    tests_per_case float,
    tests_units varchar(20),
    aged_65_older float,
    gdp_per_capita float, 
    cardiovasc_death_rate float, 
    diabetes_prevalence float, 
    female_smokers float, 
    male_smokers float, 
    hospital_beds_per_thousand float,
    life_expectancy float, 
    human_development_index float
);

-- LOAD DATA INFILE statement to load data from a CSV file into a table
LOAD DATA INFILE 'C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/covidDeaths.csv' IGNORE 
INTO TABLE covid_deaths
FIELDS TERMINATED BY ',' -- Fields in the CSV file are separated by commas
LINES TERMINATED BY '\n' -- Lines in the CSV file are separated by newlines
IGNORE 1 LINES -- Ignore the first line of the CSV file, which contains column names
(iso_code, continent, location, @c_date, population, population_density, total_cases, new_cases,
new_cases_smoothed, total_deaths, new_deaths, new_deaths_smoothed, total_cases_per_million, 
new_cases_per_million,new_cases_smoothed_per_million, total_deaths_per_million, new_deaths_per_million,
new_deaths_smoothed_per_million, reproduction_rate, icu_patients, icu_patients_per_million, 
hosp_patients, hosp_patients_per_million,weekly_icu_admissions, weekly_icu_admissions_per_million, 
weekly_hosp_admissions, weekly_hosp_admissions_per_million, total_tests,new_tests, 
total_tests_per_thousand, new_tests_per_thousand,new_tests_smoothed, 
new_tests_smoothed_per_thousand,positive_rate, tests_per_case,tests_units, aged_65_older, 
gdp_per_capita, cardiovasc_death_rate, diabetes_prevalence, female_smokers, 
male_smokers,hospital_beds_per_thousand,life_expectancy,human_development_index)
-- Convert the 'c_date' column to a DATE format using STR_TO_DATE
SET c_date = STR_TO_DATE(@c_date, '%m/%d/%Y');

-- drop table if exists for puprpose of altering table 
DROP Table IF exists covid_vaccination;
-- create table for covid vaccination
Create table covid_vaccination(
	iso_code CHAR(3) NOT NULL,
    continent varchar(20) default null,
    location varchar(20) NOT NULL,
    c_date date NOT NULL,
    population INT NOT NULL,
    population_density float,
    total_vaccinations int default NULL,
    people_vaccinated int default NULL,
    people_fully_vaccinated int default NULL,
    total_boosters int default NULL,
    new_vaccinations int default NULL,
    new_vaccinations_smoothed int default NULL,
    total_vaccinations_per_hundred float default NULL,
    people_vaccinated_per_hundred float default NULL,
    people_fully_vaccinated_per_hundred float default NULL,
    total_boosters_per_hundred float default NULL,
    new_vaccinations_smoothed_per_million int default NULL,
    new_people_vaccinated_smoothed int default NULL,
    new_people_vaccinated_smoothed_per_hundred float default NULL,
    CHECK (LENGTH(iso_code) = 3)
);

-- use load data statement to load data into covid vaccination table 
LOAD DATA INFILE 'C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/covidVaccination.csv' IGNORE 
INTO TABLE covid_vaccination
FIELDS TERMINATED BY ','
LINES TERMINATED BY '\n'
IGNORE 1 LINES
(iso_code, continent, location, @c_date, population, population_density, total_vaccinations, people_vaccinated, people_fully_vaccinated, total_boosters, new_vaccinations, new_vaccinations_smoothed, total_vaccinations_per_hundred, people_vaccinated_per_hundred, people_fully_vaccinated_per_hundred, 
total_boosters_per_hundred, new_vaccinations_smoothed_per_million, new_people_vaccinated_smoothed, new_people_vaccinated_smoothed_per_hundred)
SET c_date = STR_TO_DATE(@c_date, '%m/%d/%Y');


-- exploring created table data
select * from covid_deaths;
select * from covid_vaccination;


-- total cases by continent
select location as continent, max(total_cases) as total_covid_cases
from covid_deaths
where continent  = "" and location in ("Africa", "Asia", "Europe", "North America", "Oceania", "South America")
group by location
order by 2;


-- average death percentage by continent
select location as continent, round(AVG(total_deaths/total_cases) * 100, 2) as average_death_percentage, round(max(total_deaths/total_cases) * 100, 2) as maximum_death_percentage
from covid_deaths
where continent  = "" and location in ("Africa", "Asia", "Europe", "North America", "Oceania", "South America", "World")
group by location
order by 3;


-- create a new table called deaths which only include country data for covidDeaths table exlcuding aggreagted data 
drop table if exists deaths;
create table deaths
as 
select *
from covid_deaths
where continent != "";


-- create a new table called vaccination which only include country data for covidVaccination table exlcuding aggreagted data
drop table if exists vaccination;
create table vaccination
as 
select *
from covid_vaccination
where continent != "";


-- retrieving death percentage by location
select location, round(Max(total_deaths/total_cases) * 100, 2) as death_percentage
from deaths
where total_cases > total_deaths -- filtering out data that gives false information
group by location
order by 2 desc;


-- death percentage of United States
select location, round(Max(total_deaths/total_cases) * 100, 2) as death_percentage
from deaths
where location like "%states" -- filtering out data that gives false information
group by location
order by 2 desc;


-- covid percentage by population over location
select location, round(Max(total_cases/population) * 100, 2) as covid_percentage_by_population
from deaths
where total_cases > total_deaths
group by location
order by 2 desc;


-- correlation between population_density and covid percentage by population over location
select location, Max(population_density) as population_density, 
round(Max(total_cases/population) * 100, 2) as covid_percentage_by_population
from deaths
where total_cases > total_deaths and population_density > 0
group by location
order by 2, 3 desc;


-- average new_cases per location
select location, round(avg(new_cases))
from deaths
where continent != "" and new_cases>0
group by location
order by 2 desc;


-- hospital admission by covid cases
with hosp_admission(location, admission_percentage) as
	(select location, max(hosp_patients/total_cases) * 100
	from deaths
	group by location)
    select location, admission_percentage
    from hosp_admission
    where admission_percentage >0 and admission_percentage < 100 and admission_percentage is not null
    order by 2;


-- average new cases per day since the covid outburst
select c_date, round(avg(new_cases), 2) as "Average new_cases per day"
from deaths
where new_cases !=0
group by c_date
order by c_date;


-- which date had the most covid outburst
select c_date, sum(new_cases) "New cases per day"
from deaths
where new_cases !=0
group by c_date
order by 2 desc;


-- querying to see whether smoking percentage corrleates with death percentage and infection rate
select location, round(max(female_smokers),2) "Female smoker percentage",round(max(male_smokers),2) "Male smoker percentage", round(avg(new_deaths/new_cases) * 100, 2) "Death percentage ", round(sum(new_cases)/max(population) * 100, 3) "infection rate"
from deaths
where female_smokers !=0 and male_smokers !=0
group by location
order by 4;


-- querying to see whether life_expectancy correlates with death percenatge and infection rate
select location, life_expectancy, round(avg(new_deaths/new_cases), 3) * 100 as "death percentage", round(sum(new_cases)/max(population) * 100, 3) "infection rate"
from deaths
where life_expectancy != 0 and new_cases !=0
group by location, life_expectancy
order by 2;


-- querying to see whether human_development_index correlates with death percentage and infection rate
select location, human_development_index, round(avg(new_deaths/new_cases), 3) * 100 as "death percentage", round(sum(new_cases)/max(population) * 100, 3) "infection rate"
from deaths
where human_development_index != 0 and new_cases !=0
group by location, human_development_index
order by 2;


-- querying to see whether gdp_per_capita correlates with death percentage and infection rate
select location, gdp_per_capita, round(avg(new_deaths/new_cases), 3) * 100 as "death percentage", round(sum(new_cases)/max(population) * 100, 3) "infection rate"
from deaths
where gdp_per_capita != 0 and new_cases !=0
group by location, gdp_per_capita
order by 2;


-- querying to see whether aged_65_older correlates with death percentage and infection rate
select location, aged_65_older, round(avg(new_deaths/new_cases), 3) * 100 as "death percentage", round(sum(new_cases)/max(population) * 100, 3) "infection rate"
from deaths
where aged_65_older != 0 and new_cases !=0
group by location, aged_65_older
order by 2;


-- querying to see whether cardiovasc_death_rate correlates with death percentage and infection rate
select location, cardiovasc_death_rate, round(avg(new_deaths/new_cases), 3) * 100 as "death percentage", round(sum(new_cases)/max(population) * 100, 3) "infection rate"
from deaths
where cardiovasc_death_rate != 0 and new_cases !=0
group by location, cardiovasc_death_rate
order by 2;


-- querying to see whether diabetes_prevalence correlates with death percentage and infection rate
select location, diabetes_prevalence, round(avg(new_deaths/new_cases), 3) * 100 as "death percentage", round(sum(new_cases)/max(population) * 100, 3) "infection rate"
from deaths
where diabetes_prevalence != 0 and new_cases !=0
group by location, diabetes_prevalence
order by 2;


-- first date of vaccination for each country
select location,min(c_date) as first_vaccination
from vaccination
where people_vaccinated > 0
group by location;


-- first location and first date of vaccination administered
select location,min(c_date) as first_vaccination
from vaccination
where people_vaccinated > 0 and c_date = (select min(c_date) from vaccination where people_vaccinated > 0) 
group by location;


-- creating view that contains information about the date each country administered first covid vaccination
create or replace view first_vaccination
as
select * from vaccination
where (location, c_date) in (select location, min(c_date)
from vaccination
where people_vaccinated > 0 group by location);


-- creating view of before vaccination for each country
drop table IF exists before_vaccination;
create table before_vaccination
as
select d.*, f.total_vaccinations, f.people_vaccinated, f.people_fully_vaccinated, f.total_boosters
from deaths d join first_vaccination f 
on d.location = f.location and d.c_date < f.c_date;
 
 
 -- creating view of after vaccination started for each country
drop table IF exists after_vaccination;
create table after_vaccination
as
select d.*, f.total_vaccinations, f.people_vaccinated, f.people_fully_vaccinated, f.total_boosters
from deaths d join first_vaccination f 
on d.location = f.location and d.c_date >= f.c_date;


-- use of with statement to compare death percentage and infection rate before vaccination and after vaccination
with bf_vaccination(location, death_percentage, avg_infection_rate)
as
(select location, round(avg(new_deaths/new_cases), 3) * 100, round(sum(new_cases)/max(population) * 100, 3)
from before_vaccination
where new_deaths !=0 and new_cases !=0
group by location),
af_vaccination(location, death_percentage, avg_infection_rate)
as
(select location, round(avg(new_deaths/new_cases) * 100, 3), round(sum(new_cases)/max(population) * 100, 3)
from after_vaccination
where new_deaths !=0 and new_cases !=0
group by location)
select b.location, b.death_percentage "before vaccination death percentage", a.death_percentage "after vaccination death percentage", 
b.avg_infection_rate "before vaccination average infection rate", a.avg_infection_rate "after vaccination average infection rate"
from bf_vaccination b join af_vaccination a
on b.location = a.location;


















