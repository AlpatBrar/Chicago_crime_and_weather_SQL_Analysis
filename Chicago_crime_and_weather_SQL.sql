select * from [crime_and_weather_project]..c_crimes
select * from [crime_and_weather_project]..c_area
select * from [crime_and_weather_project]..c_temp


--Create view of all the 3 tables

create view crime_data as 
select c.crime_date,c.city_block,c.crime_type,c.crime_description,c.crime_location,c.arrest,c.domestic,c.community_id,c.latitude,c.longitude,
a.name,a.population,a.area_sq_mi,a.density,
t.temp_high,t.temp_low,t.precipitation from [crime_and_weather_project]..c_crimes as c
join [crime_and_weather_project]..c_area a on c.community_id=a.community_id
join [crime_and_weather_project]..c_temp  t on cast(c.crime_date as date)=t.date

select * from crime_data
-----------------------------------------------------------------------------------------------------------------

-- How many total crimes were reported in 2021?

select count(crime_date) as Total_crimes from [crime_and_weather_project]..c_crimes

-------------------------------------------------------------------------------------------------------------------

-- What is the count of Homicide, Battery and Assault reported?

select crime_type,count(crime_type) as Total_count from [crime_and_weather_project]..c_crimes where crime_type in ('homicide','battery','assault')
group by crime_type

-------------------------------------------------------------------------------------------------------------------


-- What are the top ten communities that had the most crimes reported?
-- We will also add the current population to see if area density is also a factor.

select top 10 name,population,density,count(community_id) Total_crimes from crime_data
group by community_id,name,population,density
order by Total_crimes desc

-------------------------------------------------------------------------------------------------------------------

-- What are the top ten communities that had the least amount of crimes reported?
-- We will also add the current population to see if area density is also a factor.

select top 10 a.name,a.population,a.density,count(c.community_id) total_crimes from [crime_and_weather_project]..c_crimes c join [crime_and_weather_project]..c_area a 
on c.community_id=a.community_id
group by c.community_id,a.name,a.population,a.density
order by total_crimes 

-------------------------------------------------------------------------------------------------------------------

-- Which month had the most crimes reported?

select datename(month,crime_date) as Month_name,count(*) as Total_crime from [crime_and_weather_project]..c_crimes 
group by datename(month,crime_date)
order by Total_crime desc

-------------------------------------------------------------------------------------------------------------------

-- What month had the most homicides and what was the average temp?

select datename(month,crime_date) as month_name,count(*) as Total_count,round(avg((temp_high+temp_low)/2),2) Average_temp from crime_data
where crime_type in ('homicide')
group by datename(month,crime_date)
order by Total_count desc

-------------------------------------------------------------------------------------------------------------------

-- What weekday were most crimes committed?

select datename(WEEKDAY,crime_date) as Day_name,count(*) as Total_crime from [crime_and_weather_project]..c_crimes 
group by datename(WEEKDAY,crime_date)
order by Total_crime desc

-------------------------------------------------------------------------------------------------------------------

-- What are the top ten city block that have had the most reported crimes?

select top 10 city_block,count(*) as Total_crime from crime_data 
group by city_block 
order by Total_crime desc

-------------------------------------------------------------------------------------------------------------------

-- What are the top ten city streets that have had the most homicides?

select top 10 city_block,count(*) as Total_crime from crime_data where crime_type='homicide' 
group by city_block 
order by Total_crime desc

-------------------------------------------------------------------------------------------------------------------

 -- What was the number of reported crimes on the hottest day of the year vs the coldest?

 with Hottest as(
	select temp_high,count(*) as crime from crime_data where temp_high=(select max(temp_high) from crime_data) group by temp_high),
coldest as (
    select temp_low,count(*) as crime from crime_data where temp_low=(select min(temp_low) from crime_data) group by temp_low)
select h.temp_high as Temp,h.crime from Hottest h 
union 
select c.temp_low as Temp,c.crime from coldest c

-------------------------------------------------------------------------------------------------------------------

-- What is the number and types of reported crimes on Michigan Ave?

SELECT Crime_type,count(*) Crimes_Michigan_ave from crime_data where city_block like '%michigan ave%'
group by crime_type
order by Crimes_Michigan_ave desc

-------------------------------------------------------------------------------------------------------------------

-- What are the top 5 least reported crime, how many arrests were made and the percentage of arrests made?

Select top 5 crime_type,count(*) Total_crime,sum(case when arrest='true' then 1 else 0 end) Total_arrest,
(sum(case when arrest='true' then 1 else 0 end))/count(*)*100 as Percentage from crime_data 
group by crime_type
order by total_crime

-------------------------------------------------------------------------------------------------------------------

-- What is the percentage of domestic violence crimes?

select  100*((select count(*) from crime_data where domestic like '%true%')/ count(*))  domestic_crime from crime_data