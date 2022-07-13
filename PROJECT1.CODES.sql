
************************************************************************************************************
CHECK THE DATA TYPES OF THE COLUMNS FOR ALL THE DATA SETS
************************************************************************************************************

select * from Information_Schema.columns


***********************************************************************************************************
COMBINING THE DATASETS
***********************************************************************************************************

Select ride_id, rideable_type, started_at, ended_at, start_station_name,start_station_id,end_station_name, end_station_id, start_lat,start_lng, end_lat, end_lng, member_casual into JointA from June_2021 UNION ALL
Select ride_id,
rideable_type,
started_at,
ended_at,
start_station_name,
CAST(start_station_id AS nvarchar) AS start_station_id,
end_station_name,
CAST(end_station_id AS nvarchar) AS end_station_id,
start_lat,
start_lng,
end_lat,
end_lng,
member_casual
FROM July_2021 UNION ALL
Select ride_id, rideable_type, started_at, ended_at, start_station_name,start_station_id,end_station_name, end_station_id, start_lat,start_lng, end_lat, end_lng, member_casualfrom August_2021 UNION ALL
Select ride_id, rideable_type, started_at, ended_at, start_station_name,start_station_id, end_station_name, end_station_id, start_lat,start_lng, end_lat, end_lng, member_casual from September_2021 UNION ALL
Select ride_id, rideable_type, started_at, ended_at, start_station_name,start_station_id, end_station_name, end_station_id, start_lat,start_lng, end_lat, end_lng, member_casual from October_2021 UNION ALL
Select ride_id,
rideable_type,
started_at,
ended_at,
start_station_name,
CAST(start_station_id AS nvarchar) AS start_station_id,
end_station_name,
end_station_id,
start_lat,
start_lng,
end_lat,
end_lng,
member_casual
FROM November_2021 UNION ALL
Select ride_id, rideable_type, started_at, ended_at, start_station_name,start_station_id,end_station_name, end_station_id, start_lat,start_lng, end_lat, end_lng, member_casual from December_2021 UNION ALL
Select ride_id, rideable_type, started_at, ended_at, start_station_name,start_station_id,end_station_name, end_station_id, start_lat,start_lng, end_lat, end_lng, member_casual from January_2022 UNION ALL
Select ride_id, rideable_type, started_at, ended_at, start_station_name,start_station_id,end_station_name, end_station_id, start_lat,start_lng, end_lat, end_lng, member_casual from February_2022 UNION ALL
Select ride_id, rideable_type, started_at, ended_at, start_station_name,start_station_id,end_station_name, end_station_id, start_lat,start_lng, end_lat, end_lng, member_casual from March_2022 UNION ALL
Select ride_id,
rideable_type,
started_at,
ended_at,
start_station_name,
CAST(start_station_id AS nvarchar) AS start_station_id,
end_station_name,
end_station_id,
start_lat,
start_lng,
end_lat,
end_lng,
member_casual
FROM April_2022 UNION ALL
Select ride_id, rideable_type, started_at, ended_at, start_station_name,start_station_id, end_station_name, end_station_id, start_lat,start_lng, end_lat, end_lng, member_casual from May_2022

*************************************************************************************************************
TRANSFORMING THE DATASET
*************************************************************************************************************

Select ride_id,
rideable_type,
started_at,
ended_at,
start_station_name,
start_station_id,
end_station_name,
end_station_id,
start_lat,
start_lng,
end_lat,
end_lng,
member_casual,
datename (weekday,started_at) as DAY,

datename (month,started_at) as MONTH,
datediff(minute,started_at,ended_at) as ride_length,
month(started_at) as monthnum,
case
when month(started_at) in (12, 1, 2) then 'Winter'
when month(started_at) in (3, 4, 5) then 'Spring'
when month(started_at) in (6, 7, 8) then 'Summer'
when month(started_at) in (9, 10, 11) then 'Fall'
end as Season
into JointB from JointA
where started_at<ended_at and start_station_name IS NOT NULL and end_station_name IS NOT
NULL
select * into JointC from JointB where ride_length != 0 and ride_length != 55944 and
start_station_id != end_station_id
alter table JointC
drop column start_station_id, end_station_id


***************************************************************************************
/*ANALYSIS:   Average Ride Length Between Members And Casual Riders (Table 1)*/
***************************************************************************************
create table X (Customer_Type varchar(60), Minimum_Ride int, Maximum_Ride int, Average_Ride int)

select
substring('Member',1,6) Customer_Type,
min(ride_length) Minimum_Ride,
max(ride_length) Maximum_Ride,
avg(ride_length) Average_Ride
into TableB from JointC where member_casual='member'

select
substring('Casual',1,6) Customer_Type,
min(ride_length) Minimum_Ride,
max(ride_length) Maximum_Ride,
avg(ride_length) Average_Ride
into TableC from JointC where member_casual='casual'

select Customer_Type, Minimum_Ride,Maximum_Ride, Average_Ride into Comparison_Summary from X
UNION ALL
select Customer_Type, Minimum_Ride,Maximum_Ride, Average_Ride from TableB
UNION ALL
select Customer_Type, Minimum_Ride,Maximum_Ride, Average_Ride from TableC

select * from Comparison_Summary


*******************************************************************************************
/*ANALYIS: TOTAL RIDE BETWEEN MEMBERS AND CASUAL RIDERS (Table 2)*/
*******************************************************************************************
select member_casual as Customer_Type, sum(datediff(hour,started_at,ended_at)) Total_Ride_Length_Hours from JointC group by member_casual



*******************************************************************************************
/*ANALYSIS: AVERAGE DAILY RIDE (Table 3)*/
*******************************************************************************************
select Day, member_casual as Customer_Type, avg(ride_length) Average_Ride_Minute_Days_of_Week from JointC group by DAY, member_casual order by Average_Ride_Minute_Days_of_Week DESC



*******************************************************************************************
/*ANALYSIS: TOTAL DAILY RIDE (Table 4)*/
*******************************************************************************************
select Month, member_casual as Customer_Type, sum(datediff(hour,started_at,ended_at)) Total_Ride_Length_hours from JointC group by Month, member_casual order by Total_Ride_Length_hours DESC


*******************************************************************************************
/*ANALYSIS: TOTAL SEASONAL RIDE LENGTH (Table 5)*/
*******************************************************************************************
select Month, member_casual as Customer_Type, sum(datediff(hour,started_at,ended_at)) Total_Ride_Length_hours from JointC group by Month, member_casual order by Total_Ride_Length_hours DESC


*******************************************************************************************
/*ANALYSIS: TOTAL SEASONAL RIDE LENGTH (Table 6)*/
*******************************************************************************************
select Season, member_casual as Customer_Type, sum(datediff(hour,started_at,ended_at)) Total_Ride_Length_hours from JointC group by Season, member_casual order by Total_Ride_Length_hours DESC