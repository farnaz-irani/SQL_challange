/* 
* Try to get as far as you can in this challenge, but don't worry if you can't achieve all objectives.
*/
/*  
 * 1 As a Data Analyst, it is crucial to be able to make sure that you can rely on the quality of your data.
 *   In the actual_elapsed_time column you have data with the calculated time from departure to arrival. 
 *   But are you really sure that you can rely on its quality in order to do business recommendations?  
 *   Since we have the data on departure and arrival time, we can do our own calculations and compare the results.
 */

/*  
 * 1.1 But first, let's take a closer look at the data and get an overall view.
 * 	   Since computational power comes at some costs and is shared by many people inside a company,
 *     retrieve only that much data you really need. So, let's take a look at the first 100 rows of the flights table.
 * 	   Please provide the query below.
 */

SELECT dep_time , arr_time, actual_elapsed_time 
FROM flights
LIMIT 100;


/*  
 * 1.2 And now, let's take a closer look at some particular relevant columns and make sure we fully understand these values.
 * 	   What do the values in arr_time, dep_time and actual_elapsed_time really mean?
 * 	   Retrieve all unique values from these columns(in three queries) and order them in descending order.
 *     Remember, retrieve as much data as you need - not more and not less.
 * 	   Please provide the query below.
 */
SELECT DISTINCT dep_time
FROM flights
ORDER BY dep_time DESC;

-- 2.400 as max and 1 as min

SELECT DISTINCT arr_time  
FROM flights
ORDER BY arr_time DESC
LIMIT 200;
--2.400 as max and 1 as min

SELECT DISTINCT actual_elapsed_time  
FROM flights
ORDER BY actual_elapsed_time DESC
LIMIT 200;

--try things
SELECT dep_time,
       dep_delay,
       arr_time,
       arr_delay,
       actual_elapsed_time,
       origin,
       dest
FROM flights
WHERE actual_elapsed_time  IS NOT NULL
ORDER BY actual_elapsed_time  DESC ;

--convert float to datetime
SELECT DISTINCT dep_time,
                arr_time,
                actual_elapsed_time,
                make_time((dep_time ::INT)/100,  (dep_time ::INT)%100, 0) AS converted_dep_time,
                make_time((arr_time ::INT)/100,  (arr_time ::INT)%100, 0) AS converted_arr_time,
                make_time((actual_elapsed_time ::INT)/100,  (actual_elapsed_time ::INT)%100, 0) AS converted_actual_elapsed_time    
FROM flights
WHERE dep_time IS NOT NULL 
ORDER BY dep_time DESC;
/*  
 * 1.3 What do the values in these three columns mean?
 *     Please provide the answer below.    
 */
-- we have floats as data types. we don't have time formatting with e.g. colons

/*  
 * 2   Finally. Let's start with the actual task. In the next steps, you are going to calculate the flight time 
 *     and match it with the actual_elapsed_time column values.
 * 	   ==> The main objective is to get as close as possible to a match rate of 100%.
 */


 /*
 * 2.1 Query the following columns from the flights table: flight_date, origin, dest, dep_time, arr_time and air_time.
 *     Convert dep_time, arr_time into TIME variables: dep_time_f and arr_time_f 
 *     Convert air_time (actual_elapsed_time) into an INTERVAL variable: air_time_f
 *     Calculate the difference of dep_time_f and arr_time_f in a new column called travel_time_f.
 *     Please provide the query below.
 */
SELECT flight_date,
       origin,
       dest,
       actual_elapsed_time,
       make_interval(mins => actual_elapsed_time ::INT) AS actual_elapsed_time_f,
       make_time((dep_time ::INT)/100,  (dep_time ::INT)%100, 0) AS dep_time_f,
       make_time((arr_time ::INT)/100,  (arr_time ::INT)%100, 0) AS arr_time_f,
       make_time((arr_time ::INT)/100,  (arr_time ::INT)%100, 0) - make_time((dep_time ::INT)/100,  (dep_time ::INT)%100, 0)  AS travel_time_f
FROM flights f 

SELECT dep_time, arr_time, actual_elapsed_time 
FROM flights
WHERE actual_elapsed_time IS NOT NULL 
ORDER BY  actual_elapsed_time DESC;


/* 2.2 Compare the travel time with the air_time (acutal_elapsed_time) column.
 * 	   How many values are matching? Provide the number in percentage.
 *     Please provide the query and answer below.
 */
SELECT flight_date,
       origin,
       dest,
       actual_elapsed_time,
       make_interval(mins => actual_elapsed_time ::INT) AS actual_elapsed_time_f,
       make_time((dep_time ::INT)/100,  (dep_time ::INT)%100, 0) AS dep_time_f,
       make_time((arr_time ::INT)/100,  (arr_time ::INT)%100, 0) AS arr_time_f,
       make_time((arr_time ::INT)/100,  (arr_time ::INT)%100, 0) - make_time((dep_time ::INT)/100,  (dep_time ::INT)%100, 0)  AS travel_time_f     
FROM flights f 
--

SELECT * FROM flights LIMIT 5;

SELECT (Sum(CASE WHEN (df.travel_time_f = df.actual_elapsed_time_f)THEN 1 ELSE 0 END)) * 100.0 / count(*) AS percentage
--count(df.travel_time_f - df.actual_elapsed_time_f) * 1.0/ (SELECT COUNT(*) * 1.0 
                                                                  --FROM df2) 
FROM (SELECT flight_date,
       origin,
       dest,
       actual_elapsed_time,
       make_interval(mins => actual_elapsed_time ::INT) AS actual_elapsed_time_f,
       make_time((dep_time ::INT)/100,  (dep_time ::INT)%100, 0) AS dep_time_f,
       make_time((arr_time ::INT)/100,  (arr_time ::INT)%100, 0) AS arr_time_f,
       make_time((arr_time ::INT)/100,  (arr_time ::INT)%100, 0) - make_time((dep_time ::INT)/100,  (dep_time ::INT)%100, 0)  AS travel_time_f 
FROM flights f) AS df;



-- 361.428 total, 178.707 have no difference which are  ca. 49 %


SELECT difference , COUNT(*) * 1.0 /
          (SELECT COUNT(*) FROM df WHERE difference = TRUE)
FROM df WHERE difference = TRUE;

/* 2.3 Try to explain the results of 2.2.
 *     Please provide the answer below.
 */

-- timezone is one reason that we have different times between travel time and actual elapsed time

/* 2.4 Join the airports table and add the time zone columns to your existing table.
 * 	   Before you add them, transform them to INTERVAL and change their names to origin_tz and dest_tz.
 *     Please provide the query below.
 */

SELECT df.flight_date,
       df.actual_elapsed_time_f,
       df.travel_time_f,
       MAKE_INTERVAL(hours => a1.tz ::INT) AS origin_tz,
       MAKE_INTERVAL(hours => a2.tz ::INT) AS dest_tz
FROM (SELECT flight_date,
       origin,
       dest,
       actual_elapsed_time,
       make_interval(mins => actual_elapsed_time ::INT) AS actual_elapsed_time_f,
       make_time((dep_time ::INT)/100,  (dep_time ::INT)%100, 0) AS dep_time_f,
       make_time((arr_time ::INT)/100,  (arr_time ::INT)%100, 0) AS arr_time_f,
       make_time((arr_time ::INT)/100,  (arr_time ::INT)%100, 0) - make_time((dep_time ::INT)/100,  (dep_time ::INT)%100, 0)  AS travel_time_f 
FROM flights f) AS df
INNER JOIN airports a1 
ON df.origin = a1.faa
INNER JOIN airports a2
ON df.dest = a2.faa
--ORDER BY a2.tz DESC, a1.tz DESC;



	  
/* 2.5 Next, convert the departure and arrival time to UTC and store them in dep_time_f_utc and arr_time_f_utc.
 * 	   Calculate the difference of the new columns and store it in a new column travel_time_f_utc.
 *     Please provide the query below.
 */

SELECT df.flight_date,
       df.dep_time_f,
       df.arr_time_f,
       df.actual_elapsed_time_f,
       df.travel_time_f,
       MAKE_INTERVAL(hours => a1.tz ::INT) AS origin_tz,
       MAKE_INTERVAL(hours => a2.tz ::INT) AS dest_tz,
       df.dep_time_f - MAKE_INTERVAL(hours => a1.tz ::INT) AS dep_time_f_utc,
       df.arr_time_f - MAKE_INTERVAL(hours => a2.tz ::INT) AS arr_time_f_utc,
       (df.arr_time_f - MAKE_INTERVAL(hours => a2.tz ::INT))- (df.dep_time_f - MAKE_INTERVAL(hours => a1.tz ::INT)) AS travel_time_f_utc
FROM (SELECT flight_date,
       origin,
       dest,
       actual_elapsed_time,
       make_interval(mins => actual_elapsed_time ::INT) AS actual_elapsed_time_f,
       make_time((dep_time ::INT)/100,  (dep_time ::INT)%100, 0) AS dep_time_f,
       make_time((arr_time ::INT)/100,  (arr_time ::INT)%100, 0) AS arr_time_f,
       make_time((arr_time ::INT)/100,  (arr_time ::INT)%100, 0) - make_time((dep_time ::INT)/100,  (dep_time ::INT)%100, 0)  AS travel_time_f 
FROM flights f) AS df
INNER JOIN airports a1 
ON df.origin = a1.faa
INNER JOIN airports a2
ON df.dest = a2.faa;

SELECT current_timestamp


SELECT MAKE_TIMESTAMPTZ(2021, 1, 1, 10, 30, 0) AS new_timestamp;  

/* 2.6 What's the percentage of matching records now?
 *     Explain the result.
 *     Please provide the query and answer below.
 */
 SELECT (Sum(CASE WHEN (df2.travel_time_f_utc = df2.actual_elapsed_time_f)THEN 1 ELSE 0 END)) * 100.0 / count(*) AS UTC_percentage
 FROM (SELECT df.flight_date,
       df.dep_time_f,
       df.arr_time_f,
       df.actual_elapsed_time_f,
       df.travel_time_f,
       MAKE_INTERVAL(hours => a1.tz ::INT) AS origin_tz,
       MAKE_INTERVAL(hours => a2.tz ::INT) AS dest_tz,
       df.dep_time_f - MAKE_INTERVAL(hours => a1.tz ::INT) AS dep_time_f_utc,
       df.arr_time_f - MAKE_INTERVAL(hours => a2.tz ::INT) AS arr_time_f_utc,
       (df.arr_time_f - MAKE_INTERVAL(hours => a2.tz ::INT))- (df.dep_time_f - MAKE_INTERVAL(hours => a1.tz ::INT)) AS travel_time_f_utc
FROM (SELECT flight_date,
       origin,
       dest,
       actual_elapsed_time,
       make_interval(mins => actual_elapsed_time ::INT) AS actual_elapsed_time_f,
       make_time((dep_time ::INT)/100,  (dep_time ::INT)%100, 0) AS dep_time_f,
       make_time((arr_time ::INT)/100,  (arr_time ::INT)%100, 0) AS arr_time_f,
       make_time((arr_time ::INT)/100,  (arr_time ::INT)%100, 0) - make_time((dep_time ::INT)/100,  (dep_time ::INT)%100, 0)  AS travel_time_f 
FROM flights f) AS df
INNER JOIN airports a1 
ON df.origin = a1.faa
INNER JOIN airports a2
ON df.dest = a2.faa) AS df2;


 
/* Extra Credit: 2.7 Add two columns to your table
 * 				     dep_timestamp_utc: a timestamp that shows the date and time of the departure in UTC time zone
 *     			     arr_timestamp_utc: a timestamp that shows the date and time of the arrival in UTC time zone
 *     			     How many flights arrived after midnight UTC?
 *     			     Please provide the query and answer below.
 */
--fixing negative time differences
SELECT df.flight_date,
       df.dep_time_f,
       df.arr_time_f,
       df.actual_elapsed_time_f,
       df.travel_time_f,
       MAKE_INTERVAL(hours => a1.tz ::INT) AS origin_tz,
       MAKE_INTERVAL(hours => a2.tz ::INT) AS dest_tz,
       df.dep_time_f - MAKE_INTERVAL(hours => a1.tz ::INT) AS dep_time_f_utc,
       df.arr_time_f - MAKE_INTERVAL(hours => a2.tz ::INT) AS arr_time_f_utc,
       CASE WHEN df.arr_time_f - MAKE_INTERVAL(hours => a2.tz ::INT) < df.dep_time_f - MAKE_INTERVAL(hours => a1.tz ::INT)
            THEN (INTERVAL '24' HOUR) + ((df.arr_time_f - MAKE_INTERVAL(hours => a2.tz ::INT)) - (df.dep_time_f - MAKE_INTERVAL(hours => a1.tz ::INT)))
            ELSE (df.arr_time_f - MAKE_INTERVAL(hours => a2.tz ::INT)) - (df.dep_time_f - MAKE_INTERVAL(hours => a1.tz ::INT))
       END AS correct_travel_time
FROM (SELECT flight_date,
       origin,
       dest,
       actual_elapsed_time,
       make_interval(mins => actual_elapsed_time ::INT) AS actual_elapsed_time_f,
       make_time((dep_time ::INT)/100,  (dep_time ::INT)%100, 0) AS dep_time_f,
       make_time((arr_time ::INT)/100,  (arr_time ::INT)%100, 0) AS arr_time_f,
       make_time((arr_time ::INT)/100,  (arr_time ::INT)%100, 0) - make_time((dep_time ::INT)/100,  (dep_time ::INT)%100, 0)  AS travel_time_f 
FROM flights f) AS df
INNER JOIN airports a1 
ON df.origin = a1.faa
INNER JOIN airports a2
ON df.dest = a2.faa;


/* Extra Credit: 2.8 Until now, we achieved a match rate of nearly 84%
 * 					 1. Do you have any ideas how to increase the match rate any further?
 *  				 2. Create a query and confirm your ideas.  
 */

-- to calculate the new percentage after fixing the negative travel_time
SELECT (Sum(CASE WHEN (df2.correct_travel_time = df2.actual_elapsed_time_f)THEN 1 ELSE 0 END)) * 100.0 / count(*) AS UTC_percentage
FROM (SELECT df.flight_date,
       df.dep_time_f,
       df.arr_time_f,
       df.actual_elapsed_time_f,
       df.travel_time_f,
       MAKE_INTERVAL(hours => a1.tz ::INT) AS origin_tz,
       MAKE_INTERVAL(hours => a2.tz ::INT) AS dest_tz,
       df.dep_time_f - MAKE_INTERVAL(hours => a1.tz ::INT) AS dep_time_f_utc,
       df.arr_time_f - MAKE_INTERVAL(hours => a2.tz ::INT) AS arr_time_f_utc,
       CASE WHEN df.arr_time_f - MAKE_INTERVAL(hours => a2.tz ::INT) < df.dep_time_f - MAKE_INTERVAL(hours => a1.tz ::INT)
            THEN (INTERVAL '24' HOUR) + ((df.arr_time_f - MAKE_INTERVAL(hours => a2.tz ::INT)) - (df.dep_time_f - MAKE_INTERVAL(hours => a1.tz ::INT)))
            ELSE (df.arr_time_f - MAKE_INTERVAL(hours => a2.tz ::INT)) - (df.dep_time_f - MAKE_INTERVAL(hours => a1.tz ::INT))
       END AS correct_travel_time
FROM (SELECT flight_date,
       origin,
       dest,
       actual_elapsed_time,
       make_interval(mins => actual_elapsed_time ::INT) AS actual_elapsed_time_f,
       make_time((dep_time ::INT)/100,  (dep_time ::INT)%100, 0) AS dep_time_f,
       make_time((arr_time ::INT)/100,  (arr_time ::INT)%100, 0) AS arr_time_f,
       make_time((arr_time ::INT)/100,  (arr_time ::INT)%100, 0) - make_time((dep_time ::INT)/100,  (dep_time ::INT)%100, 0)  AS travel_time_f 
FROM flights f) AS df
INNER JOIN airports a1 
ON df.origin = a1.faa
INNER JOIN airports a2
ON df.dest = a2.faa
) AS df2;

-- to see that 2% diffrence
SELECT *
FROM (
SELECT df.flight_date,
       df.dep_time_f,
       df.arr_time_f,
       df.actual_elapsed_time_f,
       df.travel_time_f,
       MAKE_INTERVAL(hours => a1.tz ::INT) AS origin_tz,
       MAKE_INTERVAL(hours => a2.tz ::INT) AS dest_tz,
       df.dep_time_f - MAKE_INTERVAL(hours => a1.tz ::INT) AS dep_time_f_utc,
       df.arr_time_f - MAKE_INTERVAL(hours => a2.tz ::INT) AS arr_time_f_utc,
       CASE WHEN df.arr_time_f - MAKE_INTERVAL(hours => a2.tz ::INT) < df.dep_time_f - MAKE_INTERVAL(hours => a1.tz ::INT)
            THEN (INTERVAL '24' HOUR) + ((df.arr_time_f - MAKE_INTERVAL(hours => a2.tz ::INT)) - (df.dep_time_f - MAKE_INTERVAL(hours => a1.tz ::INT)))
            ELSE (df.arr_time_f - MAKE_INTERVAL(hours => a2.tz ::INT)) - (df.dep_time_f - MAKE_INTERVAL(hours => a1.tz ::INT))
       END AS correct_travel_time
FROM (SELECT flight_date,
       origin,
       dest,
       actual_elapsed_time,
       make_interval(mins => actual_elapsed_time ::INT) AS actual_elapsed_time_f,
       make_time((dep_time ::INT)/100,  (dep_time ::INT)%100, 0) AS dep_time_f,
       make_time((arr_time ::INT)/100,  (arr_time ::INT)%100, 0) AS arr_time_f,
       make_time((arr_time ::INT)/100,  (arr_time ::INT)%100, 0) - make_time((dep_time ::INT)/100,  (dep_time ::INT)%100, 0)  AS travel_time_f 
FROM flights f) AS df
INNER JOIN airports a1 
ON df.origin = a1.faa
INNER JOIN airports a2
ON df.dest = a2.faa
) AS df2
WHERE df2.correct_travel_time != df2.actual_elapsed_time_f;

	  
