use dbms_project1;
create table cancellation_codes (
	CANCELLATION_REASON char(1) NOT NULL,
    CANCELLATION_DESCRIPTION varchar(100),
    primary key(CANCELLATION_REASON));

    
    
use dbms_project1;
Load data infile "C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/tmp/cancellation_codes.csv"
into table cancellation_codes
fields terminated by ','
enclosed by '"'
lines terminated by '\n'
ignore 1 rows
(CANCELLATION_REASON,CANCELLATION_DESCRIPTION);



use dbms_project1;

create table airports (
	IATA_CODE char(3) NOT NULL,
    AIRPORT varchar(100) NOT NULL,
    CITY varchar(100) NOT NULL,
    STATE char(2) NOT NULL,
    COUNTRY char(3) NOT NULL,
    LATITUDE double DEFAULT NULL,
    LONGITUDE double DEFAULT NULL,
    primary key(IATA_CODE));
    
    

use dbms_project1;
Load data infile "C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/tmp/airports.csv"
into table airports
fields terminated by ','
enclosed by '"'
lines terminated by '\n'
ignore 1 rows
(IATA_CODE,AIRPORT,CITY,STATE,COUNTRY,@LATITUDE,@LONGITUDE)
SET LATITUDE = NULLIF(@LATITUDE, ''), LONGITUDE = NULLIF(@LONGITUDE, '');



use dbms_project1;

create table airlines (
	IATA_CODE char(2) NOT NULL,
    AIRLINE varchar(100),
    primary key(IATA_CODE));
    
    

use dbms_project1;
Load data infile "C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/tmp/airlines.csv"
into table airlines
fields terminated by ','
enclosed by '"'
lines terminated by '\n'
ignore 1 rows
(IATA_CODE,AIRLINE);


use dbms_project1;

create table flights (
	YEAR int not null,
    MONTH int not null,
    DAY int not null,
    DAY_OF_WEEK int not null,
    AIRLINE char(2) not null,
    FLIGHT_NUMBER int not null,
    TAIL_NUMBER varchar(20),
    ORIGIN_AIRPORT char(3) not null,
    DESTINATION_AIRPORT char(3) not null,
    SCHEDULED_DEPARTURE int,
    DEPARTURE_TIME int,
    DEPARTURE_DELAY int,
    TAXI_OUT int,
    WHEELS_OFF int,
    SCHEDULED_TIME int,
    ELAPSED_TIME int,
    AIR_TIME int,
    DISTANCE int,
    WHEELS_ON int,
    TAXI_IN int,
    SCHEDULED_ARRIVAL int,
    ARRIVAL_TIME int,
    ARRIVAL_DELAY int,
    DIVERTED int,
    CANCELLED int,
    CANCELLATION_REASON char(1),
    AIR_SYSTEM_DELAY int,
    SECURITY_DELAY int,
    AIRLINE_DELAY int,
    LATE_AIRCRAFT_DELAY int,
    WEATHER_DELAY int,
    primary key(MONTH,DAY,AIRLINE,FLIGHT_NUMBER,TAIL_NUMBER,ORIGIN_AIRPORT,DESTINATION_AIRPORT,SCHEDULED_DEPARTURE),
    foreign key(AIRLINE) references airlines(IATA_CODE),
    foreign key(ORIGIN_AIRPORT) references airports(IATA_CODE),
    foreign key(DESTINATION_AIRPORT) references airports(IATA_CODE),
    foreign key(CANCELLATION_REASON) references cancellation_codes(cancellation_reason));


use dbms_project1;
Load data infile "C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/tmp/flights1.csv"
into table flights
fields terminated by ','
enclosed by '"'
lines terminated by '\n'
ignore 1 rows
(YEAR,MONTH,DAY,DAY_OF_WEEK,AIRLINE,FLIGHT_NUMBER,TAIL_NUMBER,ORIGIN_AIRPORT,DESTINATION_AIRPORT,SCHEDULED_DEPARTURE,@DEPARTURE_TIME,@DEPARTURE_DELAY,@TAXI_OUT,@WHEELS_OFF,@SCHEDULED_TIME,@ELAPSED_TIME,@AIR_TIME,DISTANCE,@WHEELS_ON,@TAXI_IN,SCHEDULED_ARRIVAL,@ARRIVAL_TIME,@ARRIVAL_DELAY,DIVERTED,CANCELLED,@CANCELLATION_REASON,@AIR_SYSTEM_DELAY,@SECURITY_DELAY,@AIRLINE_DELAY,@LATE_AIRCRAFT_DELAY,@WEATHER_DELAY)
SET DEPARTURE_TIME=NULLIF(@DEPARTURE_TIME,''),DEPARTURE_DELAY=NULLIF(@DEPARTURE_DELAY,''),TAXI_OUT=NULLIF(@TAXI_OUT,''),WHEELS_OFF=NULLIF(@WHEELS_OFF,''),SCHEDULED_TIME=NULLIF(@SCHEDULED_TIME,''),ELAPSED_TIME=NULLIF(@ELAPSED_TIME,''),AIR_TIME=NULLIF(@AIR_TIME,''),WHEELS_ON=NULLIF(@WHEELS_ON,''),TAXI_IN=NULLIF(@TAXI_IN,''),ARRIVAL_TIME=NULLIF(@ARRIVAL_TIME,''),ARRIVAL_DELAY=NULLIF(@ARRIVAL_DELAY,''),CANCELLATION_REASON=NULLIF(@CANCELLATION_REASON,''),AIR_SYSTEM_DELAY=NULLIF(@AIR_SYSTEM_DELAY,''),SECURITY_DELAY=NULLIF(@SECURITY_DELAY,''),AIRLINE_DELAY=NULLIF(@AIRLINE_DELAY,''),LATE_AIRCRAFT_DELAY=NULLIF(@LATE_AIRCRAFT_DELAY,''),WEATHER_DELAY=NULLIF(NULLIF(TRIM(@WEATHER_DELAY), ''), '')*1;


SELECT DAY_OF_WEEK, COUNT(*) AS FlightCount
FROM flights
GROUP BY DAY_OF_WEEK
ORDER BY DAY_OF_WEEK;

SELECT 
    AVG(DEPARTURE_DELAY) AS AvgDepartureDelay
FROM flights
WHERE YEAR = 2015 AND DEPARTURE_DELAY > 0;

SELECT ORIGIN_AIRPORT, AVG_DEP_DELAY
FROM (
    SELECT ORIGIN_AIRPORT, AVG(DEPARTURE_DELAY) AS AVG_DEP_DELAY
    FROM flights
    GROUP BY ORIGIN_AIRPORT
    ORDER BY AVG_DEP_DELAY DESC
    LIMIT 10
) AS TopAirports
ORDER BY AVG_DEP_DELAY DESC;

SELECT
    cc.cancellation_description,
    COUNT(*) AS num_flights
FROM
    flights f
JOIN
    cancellation_codes cc ON f.cancellation_reason = cc.cancellation_reason
WHERE
    f.cancelled = 1
GROUP BY
    cc.cancellation_description;

DELIMITER //
CREATE FUNCTION calculate_average_departure_delay_by_airline(airline_code VARCHAR(3), flight_year INT)
RETURNS FLOAT
DETERMINISTIC
BEGIN
    DECLARE avg_departure_delay FLOAT;

    -- Calculate the average departure delay for flights operated by the specified airline in the given year
    SELECT AVG(departure_delay) INTO avg_departure_delay
    FROM flights
    WHERE airline = airline_code AND year = flight_year;

    -- If there are no flights operated by the specified airline in the given year, return NULL
    IF avg_departure_delay IS NULL THEN
        RETURN NULL;
    ELSE
        RETURN avg_departure_delay;
    END IF;
END;

//

DELIMITER ;
SELECT calculate_average_departure_delay_by_airline('UA', 2015);

use dbms_project1;
SELECT state, COUNT(*) AS num_airports
FROM airports
GROUP BY state;

SELECT AIRLINE,
    SUM(AIR_SYSTEM_DELAY) AS TotalAirSystemDelay,
    SUM(SECURITY_DELAY) AS TotalSecurityDelay,
    SUM(AIRLINE_DELAY) AS TotalAirlineDelay,
    SUM(LATE_AIRCRAFT_DELAY) AS TotalLateAircraftDelay,
    SUM(WEATHER_DELAY) AS TotalWeatherDelay
FROM flights
GROUP BY AIRLINE;

SELECT YEAR, MONTH, 
    COUNT(*) AS CancellationCount
FROM flights
WHERE CANCELLED = 1no
GROUP BY YEAR, MONTH;