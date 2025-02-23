
--AGGREGATE FUNCTIONS

select * FROM dbo.[Travel details dataset cleaned]

/*1) Question: Find destinations where the average accommodation cost is greater than $1000.*/

SELECT Destination , AVG(Accommodation_cost )  AS avg_acc_cost
FROM dbo.[Travel details dataset cleaned]
GROUP BY Destination
HAVING avg(Accommodation_cost) > 1000

--2) Question: Calculate the total transportation cost for each traveler.

SELECT Traveler_name ,sum(Transportation_cost) AS total_transportation_cost
FROM dbo.[Travel details dataset cleaned]
GROUP BY Traveler_name

--3) Question: Find the top 5 most expensive trips (based on total cost: accommodation + transportation) and order them in descending order.

SELECT TOP 5 Trip_ID,Destination, (Accommodation_cost + Transportation_cost) AS total_cost 
FROM dbo.[Travel details dataset cleaned]
GROUP BY Destination
ORDER BY total_cost DESC






--SUB-QUERY

--4) Find the average accommodation cost across all trips and list trips where the accommodation cost is higher than the average

SELECT Trip_ID, Destination , Accommodation_cost
FROM dbo.[Travel details dataset cleaned]
WHERE Accommodation_cost > (SELECT avg(Accommodation_cost) FROM dbo.[Travel details dataset cleaned])

--5)Identify travelers who visited the destination with the highest number of trips.

SELECT Traveler_name,Destination
FROM dbo.[Travel details dataset cleaned]
WHERE Destination in (SELECT TOP 1 Destination FROM dbo.[Travel details dataset cleaned] 
						GROUP BY Destination
						ORDER BY COUNT(Destination) DESC)

--6)Find the names of the travelers who visited destinations that have more than 2 travelers in total.

SELECT Traveler_name,Destination
FROM dbo.[Travel details dataset cleaned]
WHERE Destination in (SELECT Destination FROM dbo.[Travel details dataset cleaned]
						GROUP BY Destination
						HAVING COUNT(Destination) > 2 ) 




--TYPES OF JOINS

--INNER - JOIN


--7) Which travelers nationality from specific countries have taken trips to 'London, UK' destinations, 
--   along with their accommodation type and transportation cost?

SELECT 
    t.Traveler_name, 
    t.Traveler_nationality,
	t.Traveler_gender,
    r.Destination, 
    r.Accommodation_type, 
    r.Transportation_cost
FROM 
    Travelers t
INNER JOIN 
    Trips r
ON 
    t.Travelers_ID = r.Trip_ID
WHERE 
    t.Traveler_gender = 'Male' AND 
    r.Destination = 'London, UK';


--LEFT - JOIN

--8)Identify all the travelers name,nationality  and gender from Travelers table

SELECT 
    t.Traveler_name, 
    t.Traveler_nationality,
	t.Traveler_gender,
    r.Destination, 
    r.Accommodation_type, 
    r.Transportation_cost
FROM 
    Travelers t
left JOIN 
    Trips r
ON 
    t.Travelers_ID = r.Trip_ID

--RIGHT - JOIN

--9)Identify all the trip destinations , Accommodation_type and Transportation_cost  from trips table

SELECT 
    t.Traveler_name, 
    t.Traveler_nationality,
	t.Traveler_gender,
    r.Destination, 
    r.Accommodation_type, 
    r.Transportation_cost
FROM 
    Travelers t
right JOIN 
    Trips r
ON 
    t.Travelers_ID = r.Trip_ID


--FULL - OUTER JOIN

--10)Combine  all the records from traveler table and trips table.

SELECT 
    t.Traveler_name, 
    t.Traveler_nationality,
    r.Destination, 
    r.Start_date, 
    r.End_date
FROM 
    Travelers t
FULL OUTER JOIN 
    Trips r
ON 
    t.Travelers_ID = r.Trip_ID;

--SELF-JOIN

--11) find trips that have the same destination but different travelers.

SELECT t1.trip_id AS Trip1_ID, 
       t1.destination AS Destination, 
       t2.trip_id AS Trip2_ID      
FROM dbo.trips AS t1
JOIN dbo.trips AS t2 
    ON t1.destination = t2.destination 
    AND t1.trip_id <> t2.trip_id;




--WINDOW-FUNCTIONS

--RANK AND DENSE RANK FUNCTIONS


--12) select the top 3 destination which has the most transportation cost

SELECT * FROM(
SELECT *,RANK() OVER(PARTITION BY Destination ORDER BY Transportation_cost DESC) AS ranking,
		 DENSE_RANK() OVER(PARTITION BY Destination ORDER BY Transportation_cost DESC) AS dense_ranking
FROM dbo.trips
) x
WHERE x.ranking < 4


--ROW-NUMBER

--13) Find the first 2 travelers from each Nationality

SELECT * FROM 
(
SELECT *,ROW_NUMBER() OVER(PARTITION BY Traveler_nationality ORDER BY Travelers_ID) rn FROM dbo.travelers
) x
WHERE x.rn < 3


--LAG


--14) find the duration days higher or equal or greater than previous duration days

SELECT *,
		CASE 
			WHEN Duration_days > LAG(Duration_days) OVER(PARTITION BY Destination ORDER BY Trip_ID) THEN 'Higher Than Previous Duration_days'
			WHEN Duration_days < LAG(Duration_days) OVER(PARTITION BY Destination ORDER BY Trip_ID) THEN 'Lesser Than Previous Duration_days'
			WHEN Duration_days = LAG(Duration_days) OVER(PARTITION BY Destination ORDER BY Trip_ID) THEN 'Equal to Previous Duration_days'
		END Duration_days
FROM dbo.trips


--LEAD


--15) find the duration days higher or equal or greater than next duration days

SELECT *,
		CASE 
			WHEN Duration_days > LEAD(Duration_days) OVER(PARTITION BY Destination ORDER BY Trip_ID) THEN 'Higher Than nect Duration_days'
			WHEN Duration_days < LEAD(Duration_days) OVER(PARTITION BY Destination ORDER BY Trip_ID) THEN 'Lesser Than next Duration_days'
			WHEN Duration_days = LEAD(Duration_days) OVER(PARTITION BY Destination ORDER BY Trip_ID) THEN 'Equal to next Duration_days'
		END Duration_days
FROM dbo.trips





--CTE - TABLES

--16) Find trips that lasted more than 7 days and were taken in 2027.

WITH cte AS (
	SELECT 
	Trip_ID ,
	Destination,
	Start_date,
	End_date,
	Duration_days
	FROM dbo.trips
	WHERE YEAR(Start_date) = 2027 and Duration_days > 7
)

SELECT 
	Trip_ID ,
	Destination,
	Start_date,
	End_date,
	Duration_days 
FROM cte

--17) Find trips where the total cost (accommodation + transportation) exceeded $2000.

WITH act AS (
    SELECT 
        Trip_ID, 
        Destination, 
        (Accommodation_cost + Transportation_cost) as total_cost
    FROM dbo.trips
)

SELECT 
    MAX(Trip_ID) as Max_Trip_ID,
    Destination,
    MAX(total_cost) as max_total_cost
FROM act
WHERE total_cost > 2000
GROUP BY Destination
ORDER BY MAX(total_cost) DESC 





























