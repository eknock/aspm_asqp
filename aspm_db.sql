-- CREATE THE STND_REPORT
CREATE VIEW STND_REPORT AS
(SELECT 
    "Date","Facility","Actual Departures","Actual Arrivals","Departure Cancellations",
    "Arrival Cancellations", "On-Time Arrivals", "Percentage On-Time Gate Departures",
    "Percentage On-Time Gate Arrivals", "Average Gate Arrival Delay","Average Taxi Out Time",
    "Average Taxi In Time", "Delayed Arrivals", "Average Delay Per Delayed Arrivals", "ASQP"
FROM public."ASQP_STND_REPORT" AS asqp_stnd_report

UNION 
SELECT 
    "Date","Facility","Actual Departures","Actual Arrivals","Departure Cancellations",
    "Arrival Cancellations", "On-Time Arrivals", "Percentage On-Time Gate Departures",
    "Percentage On-Time Gate Arrivals", "Average Gate Arrival Delay","Average Taxi Out Time",
    "Average Taxi In Time", "Delayed Arrivals", "Average Delay Per Delayed Arrivals", "ASQP"
FROM public."ASPM_STND_REPORT" AS aspm_stnd_report)
EXCEPT 
(SELECT 
    asqp_report."Date",
    asqp_report."Facility",
    asqp_report."Actual Departures",
    asqp_report."Actual Arrivals",
    asqp_report."Departure Cancellations",
    asqp_report."Arrival Cancellations", 
    asqp_report."On-Time Arrivals", 
    asqp_report."Percentage On-Time Gate Departures",
    asqp_report."Percentage On-Time Gate Arrivals", 
    asqp_report."Average Gate Arrival Delay",
    asqp_report."Average Taxi Out Time",
    asqp_report."Average Taxi In Time", 
    asqp_report."Delayed Arrivals", 
    asqp_report."Average Delay Per Delayed Arrivals",
    asqp_report."ASQP"
FROM public."ASQP_STND_REPORT" AS asqp_report INNER JOIN public."ASPM_STND_REPORT" AS aspm_report
ON
    aspm_report."Date" = asqp_report."Date" AND
    aspm_report."Facility" = asqp_report."Facility" AND
    aspm_report."Actual Departures" = asqp_report."Actual Departures" AND
    aspm_report."Actual Arrivals" = asqp_report."Actual Arrivals" AND
    aspm_report."Departure Cancellations" = asqp_report."Departure Cancellations" AND
    aspm_report."Arrival Cancellations" = asqp_report."Arrival Cancellations" AND
    aspm_report."On-Time Arrivals" = asqp_report."On-Time Arrivals" AND
    aspm_report."Percentage On-Time Gate Departures" = asqp_report."Percentage On-Time Gate Departures" AND
    aspm_report."Percentage On-Time Gate Arrivals" = asqp_report."Percentage On-Time Gate Arrivals" AND 
    aspm_report."Average Gate Arrival Delay" = asqp_report."Average Gate Arrival Delay" AND
    aspm_report."Average Taxi Out Time" = asqp_report."Average Taxi Out Time" AND
    aspm_report."Average Taxi In Time" = asqp_report."Average Taxi In Time" AND
    aspm_report."Delayed Arrivals" = asqp_report."Delayed Arrivals" AND
    aspm_report."Average Delay Per Delayed Arrivals" = asqp_report."Average Delay Per Delayed Arrivals");

-- CREATE THE CASUAL_REPORT
CREATE VIEW CASUAL_REPORT AS
(SELECT 
    "Date","Facility","Actual Departures","Actual Arrivals","Cancellations",
    "Cancellations Causes: Carrier", "Cancellations Causes: Weather", "Cancellations Causes: NAS","Cancellations Causes: Security",
    "Gate Arrival Delay Minutes", "Delay Causes: Carrier Min","Delay Causes: Carrier Flt","Delay Causes: Weather Min",
    "Delay Causes: Weather Flt","Delay Causes: NAS Min","Delay Causes: NAS Flt","Delay Causes: Security Min","Delay Causes: Security Flt",
    "Delay Causes: Late Arrival Min","Delay Causes: Late Arrival Flt","Delay Causes: Total Min","Delay Causes: Total Flt","ASQP"
FROM public."ASQP_CASUAL_REPORT" AS asqp_casual_report

UNION 
SELECT 
    "Date","Facility","Actual Departures","Actual Arrivals","Cancellations",
    "Cancellations Causes: Carrier", "Cancellations Causes: Weather", "Cancellations Causes: NAS","Cancellations Causes: Security",
    "Gate Arrival Delay Minutes", "Delay Causes: Carrier Min","Delay Causes: Carrier Flt","Delay Causes: Weather Min",
    "Delay Causes: Weather Flt","Delay Causes: NAS Min","Delay Causes: NAS Flt","Delay Causes: Security Min","Delay Causes: Security Flt",
    "Delay Causes: Late Arrival Min","Delay Causes: Late Arrival Flt","Delay Causes: Total Min","Delay Causes: Total Flt","ASQP"  
FROM public."ASPM_CASUAL_REPORT" AS aspm_casual_report)
EXCEPT
(SELECT 
    asqp_report."Date",
    asqp_report."Facility",
    asqp_report."Actual Departures",
    asqp_report."Actual Arrivals",
    asqp_report."Cancellations",
    asqp_report."Cancellations Causes: Carrier", 
    asqp_report."Cancellations Causes: Weather", 
    asqp_report."Cancellations Causes: NAS",
    asqp_report."Cancellations Causes: Security",
    asqp_report."Gate Arrival Delay Minutes", 
    asqp_report."Delay Causes: Carrier Min",
    asqp_report."Delay Causes: Carrier Flt",
    asqp_report."Delay Causes: Weather Min",
    asqp_report."Delay Causes: Weather Flt",
    asqp_report."Delay Causes: NAS Min",
    asqp_report."Delay Causes: NAS Flt",
    asqp_report."Delay Causes: Security Min",
    asqp_report."Delay Causes: Security Flt",
    asqp_report."Delay Causes: Late Arrival Min",
    asqp_report."Delay Causes: Late Arrival Flt",
    asqp_report."Delay Causes: Total Min",
    asqp_report."Delay Causes: Total Flt",
    asqp_report."ASQP"
FROM public."ASQP_CASUAL_REPORT" AS asqp_report INNER JOIN public."ASPM_CASUAL_REPORT" AS aspm_report
ON
    aspm_report."Date" =  asqp_report."Date" AND
    aspm_report."Facility" =  asqp_report."Facility" AND
    aspm_report."Actual Departures" =  asqp_report."Actual Departures" AND
    aspm_report."Actual Arrivals" =  asqp_report."Actual Arrivals" AND
    aspm_report."Cancellations" =  asqp_report."Cancellations" AND
    aspm_report."Cancellations Causes: Carrier" =  asqp_report."Cancellations Causes: Carrier" AND
    aspm_report."Cancellations Causes: Weather" =  asqp_report."Cancellations Causes: Weather" AND
    aspm_report."Cancellations Causes: NAS" =  asqp_report."Cancellations Causes: NAS" AND
    aspm_report."Cancellations Causes: Security" =  asqp_report."Cancellations Causes: Security" AND
    aspm_report."Gate Arrival Delay Minutes" =  asqp_report."Gate Arrival Delay Minutes" AND
    aspm_report."Delay Causes: Carrier Min" =  asqp_report."Delay Causes: Carrier Min" AND
    aspm_report."Delay Causes: Carrier Flt" =  asqp_report."Delay Causes: Carrier Flt" AND
    aspm_report."Delay Causes: Weather Min" =  asqp_report."Delay Causes: Weather Min" AND
    aspm_report."Delay Causes: Weather Flt" =  asqp_report."Delay Causes: Weather Flt" AND
    aspm_report."Delay Causes: NAS Min" =  asqp_report."Delay Causes: NAS Min" AND
    aspm_report."Delay Causes: NAS Flt" =  asqp_report."Delay Causes: NAS Flt" AND
    aspm_report."Delay Causes: Security Min" =  asqp_report."Delay Causes: Security Min" AND
    aspm_report."Delay Causes: Security Flt" =  asqp_report."Delay Causes: Security Flt" AND
    aspm_report."Delay Causes: Late Arrival Min" =  asqp_report."Delay Causes: Late Arrival Min" AND
    aspm_report."Delay Causes: Late Arrival Flt" =  asqp_report."Delay Causes: Late Arrival Flt" AND
    aspm_report."Delay Causes: Total Min" =  asqp_report."Delay Causes: Total Min" AND
    aspm_report."Delay Causes: Total Flt" =  asqp_report."Delay Causes: Total Flt");

-- CREATE THE NAS_REPORT

CREATE VIEW NAS_REPORT AS
(SELECT
    "Date",
    "Facility",
    "Cancellation NAS Causes: Wx",
    "Cancellation NAS Causes: Vol",
    "Cancellation NAS Causes: Eqpt",
    "Cancellation NAS Causes: Rwy",
    "Cancellation NAS Causes: Oth",
    "Cancellation NAS Causes: No Match Other Carrier Reported NAS",
    "Cancellation NAS Causes: No Match Required Validation",
    "Cancellation NAS Causes: Total",
    "Delay NAS Causes - Causes: Wx Min",
    "Delay NAS Causes - Causes: Wx Flt",
    "Delay NAS Causes - Causes: Vol Min",
    "Delay NAS Causes - Causes: Vol Flt",
    "Delay NAS Causes - Causes: Eqpt Min",
    "Delay NAS Causes - Causes: Eqpt Flt",
    "Delay NAS Causes - Causes: Rwy Min",
    "Delay NAS Causes - Causes: Rwy Flt",
    "Delay NAS Causes - Causes: Oth Min",
    "Delay NAS Causes - Causes: Oth Flt",
    "Delay NAS Causes - No Match: NAS <15 Min",
    "Delay NAS Causes - No Match: NAS <15 Flt",
    "Delay NAS Causes - No Match: Delay After Gate Dep >15 Min",
    "Delay NAS Causes - No Match: Delay After Gate Dep >15 Flt",
    "Delay NAS Causes - No Match: Gate Dep Delay<6 Min",
    "Delay NAS Causes - No Match: Gate Dep Delay<6 Flt",
    "Delay NAS Causes - No Match: Other Carr Reported NAS Min",
    "Delay NAS Causes - No Match: Other Carr Reported NAS Flt",
    "Delay NAS Causes - No Match: Other Carr Reported Non-NAS Min",
    "Delay NAS Causes - No Match: Other Carr Reported Non-NAS Flt",
    "Delay NAS Causes - No Match: No Other Carr Reported Delays Min",
    "Delay NAS Causes - No Match: No Other Carr Reported Delays Flt",
    "Delay NAS Causes - No Match: NAS Delays Requiring Val Min",
    "Delay NAS Causes - No Match: NAS Delays Requiring Val Flt",
    "NAS Causes: Total Min",
    "NAS Causes: Total Flt",
    "ASQP"
FROM public."ASQP_NAS_REPORT" AS asqp_nas_report

UNION

SELECT
    "Date",
    "Facility",
    "Cancellation NAS Causes: Wx",
    "Cancellation NAS Causes: Vol",
    "Cancellation NAS Causes: Eqpt",
    "Cancellation NAS Causes: Rwy",
    "Cancellation NAS Causes: Oth",
    "Cancellation NAS Causes: No Match Other Carrier Reported NAS",
    "Cancellation NAS Causes: No Match Required Validation",
    "Cancellation NAS Causes: Total",
    "Delay NAS Causes - Causes: Wx Min",
    "Delay NAS Causes - Causes: Wx Flt",
    "Delay NAS Causes - Causes: Vol Min",
    "Delay NAS Causes - Causes: Vol Flt",
    "Delay NAS Causes - Causes: Eqpt Min",
    "Delay NAS Causes - Causes: Eqpt Flt",
    "Delay NAS Causes - Causes: Rwy Min",
    "Delay NAS Causes - Causes: Rwy Flt",
    "Delay NAS Causes - Causes: Oth Min",
    "Delay NAS Causes - Causes: Oth Flt",
    "Delay NAS Causes - No Match: NAS <15 Min",
    "Delay NAS Causes - No Match: NAS <15 Flt",
    "Delay NAS Causes - No Match: Delay After Gate Dep >15 Min",
    "Delay NAS Causes - No Match: Delay After Gate Dep >15 Flt",
    "Delay NAS Causes - No Match: Gate Dep Delay<6 Min",
    "Delay NAS Causes - No Match: Gate Dep Delay<6 Flt",
    "Delay NAS Causes - No Match: Other Carr Reported NAS Min",
    "Delay NAS Causes - No Match: Other Carr Reported NAS Flt",
    "Delay NAS Causes - No Match: Other Carr Reported Non-NAS Min",
    "Delay NAS Causes - No Match: Other Carr Reported Non-NAS Flt",
    "Delay NAS Causes - No Match: No Other Carr Reported Delays Min",
    "Delay NAS Causes - No Match: No Other Carr Reported Delays Flt",
    "Delay NAS Causes - No Match: NAS Delays Requiring Val Min",
    "Delay NAS Causes - No Match: NAS Delays Requiring Val Flt",
    "NAS Causes: Total Min",
    "NAS Causes: Total Flt",
    "ASQP"
FROM public."ASPM_NAS_REPORT" AS aspm_nas_report)
EXCEPT
(SELECT
    asqp_report."Date", 
    asqp_report."Facility", 
    asqp_report."Cancellation NAS Causes: Wx",
    asqp_report."Cancellation NAS Causes: Vol",
    asqp_report."Cancellation NAS Causes: Eqpt",
    asqp_report."Cancellation NAS Causes: Rwy",
    asqp_report."Cancellation NAS Causes: Oth",
    asqp_report."Cancellation NAS Causes: No Match Other Carrier Reported NAS",
    asqp_report."Cancellation NAS Causes: No Match Required Validation",
    asqp_report."Cancellation NAS Causes: Total",
    asqp_report."Delay NAS Causes - Causes: Wx Min",
    asqp_report."Delay NAS Causes - Causes: Wx Flt",
    asqp_report."Delay NAS Causes - Causes: Vol Min",
    asqp_report."Delay NAS Causes - Causes: Vol Flt",
    asqp_report."Delay NAS Causes - Causes: Eqpt Min",
    asqp_report."Delay NAS Causes - Causes: Eqpt Flt",
    asqp_report."Delay NAS Causes - Causes: Rwy Min",
    asqp_report."Delay NAS Causes - Causes: Rwy Flt",
    asqp_report."Delay NAS Causes - Causes: Oth Min",
    asqp_report."Delay NAS Causes - Causes: Oth Flt",
    asqp_report."Delay NAS Causes - No Match: NAS <15 Min",
    asqp_report."Delay NAS Causes - No Match: NAS <15 Flt",
    asqp_report."Delay NAS Causes - No Match: Delay After Gate Dep >15 Min",
    asqp_report."Delay NAS Causes - No Match: Delay After Gate Dep >15 Flt",
    asqp_report."Delay NAS Causes - No Match: Gate Dep Delay<6 Min",
    asqp_report."Delay NAS Causes - No Match: Gate Dep Delay<6 Flt",
    asqp_report."Delay NAS Causes - No Match: Other Carr Reported NAS Min",
    asqp_report."Delay NAS Causes - No Match: Other Carr Reported NAS Flt",
    asqp_report."Delay NAS Causes - No Match: Other Carr Reported Non-NAS Min",
    asqp_report."Delay NAS Causes - No Match: Other Carr Reported Non-NAS Flt",
    asqp_report."Delay NAS Causes - No Match: No Other Carr Reported Delays Min",
    asqp_report."Delay NAS Causes - No Match: No Other Carr Reported Delays Flt",
    asqp_report."Delay NAS Causes - No Match: NAS Delays Requiring Val Min",
    asqp_report."Delay NAS Causes - No Match: NAS Delays Requiring Val Flt",
    asqp_report."NAS Causes: Total Min",
    asqp_report."NAS Causes: Total Flt",
    asqp_report."ASQP"
FROM public."ASQP_NAS_REPORT" AS asqp_report INNER JOIN public."ASPM_NAS_REPORT" AS aspm_report
ON 
    aspm_report."Date" = asqp_report."Date" AND
    aspm_report."Facility" = asqp_report."Facility" AND
    aspm_report."Cancellation NAS Causes: Wx" = asqp_report."Cancellation NAS Causes: Wx" AND
    aspm_report."Cancellation NAS Causes: Vol" = asqp_report."Cancellation NAS Causes: Vol" AND
    aspm_report."Cancellation NAS Causes: Eqpt" = asqp_report."Cancellation NAS Causes: Eqpt" AND
    aspm_report."Cancellation NAS Causes: Rwy" = asqp_report."Cancellation NAS Causes: Rwy" AND
    aspm_report."Cancellation NAS Causes: Oth" = asqp_report."Cancellation NAS Causes: Oth" AND
    aspm_report."Cancellation NAS Causes: No Match Other Carrier Reported NAS" = asqp_report."Cancellation NAS Causes: No Match Other Carrier Reported NAS" AND
    aspm_report."Cancellation NAS Causes: No Match Required Validation" = asqp_report."Cancellation NAS Causes: No Match Required Validation" AND
    aspm_report."Cancellation NAS Causes: Total" = asqp_report."Cancellation NAS Causes: Total" AND
    aspm_report."Delay NAS Causes - Causes: Wx Min" = asqp_report."Delay NAS Causes - Causes: Wx Min" AND
    aspm_report."Delay NAS Causes - Causes: Wx Flt" = asqp_report."Delay NAS Causes - Causes: Wx Flt" AND
    aspm_report."Delay NAS Causes - Causes: Vol Min" = asqp_report."Delay NAS Causes - Causes: Vol Min" AND
    aspm_report."Delay NAS Causes - Causes: Vol Flt" = asqp_report."Delay NAS Causes - Causes: Vol Flt" AND
    aspm_report."Delay NAS Causes - Causes: Eqpt Min" = asqp_report."Delay NAS Causes - Causes: Eqpt Min" AND
    aspm_report."Delay NAS Causes - Causes: Eqpt Flt" = asqp_report."Delay NAS Causes - Causes: Eqpt Flt" AND
    aspm_report."Delay NAS Causes - Causes: Rwy Min" = asqp_report."Delay NAS Causes - Causes: Rwy Min" AND
    aspm_report."Delay NAS Causes - Causes: Rwy Flt" = asqp_report."Delay NAS Causes - Causes: Rwy Flt" AND
    aspm_report."Delay NAS Causes - Causes: Oth Min" = asqp_report."Delay NAS Causes - Causes: Oth Min" AND
    aspm_report."Delay NAS Causes - Causes: Oth Flt" = asqp_report."Delay NAS Causes - Causes: Oth Flt" AND
    aspm_report."Delay NAS Causes - No Match: NAS <15 Min" = asqp_report."Delay NAS Causes - No Match: NAS <15 Min" AND 
    aspm_report."Delay NAS Causes - No Match: NAS <15 Flt" = asqp_report."Delay NAS Causes - No Match: NAS <15 Flt" AND
    aspm_report."Delay NAS Causes - No Match: Delay After Gate Dep >15 Min" = asqp_report."Delay NAS Causes - No Match: Delay After Gate Dep >15 Min" AND
    aspm_report."Delay NAS Causes - No Match: Delay After Gate Dep >15 Flt" = asqp_report."Delay NAS Causes - No Match: Delay After Gate Dep >15 Flt" AND
    aspm_report."Delay NAS Causes - No Match: Gate Dep Delay<6 Min"= asqp_report."Delay NAS Causes - No Match: Gate Dep Delay<6 Min" AND
    aspm_report."Delay NAS Causes - No Match: Gate Dep Delay<6 Flt" = asqp_report."Delay NAS Causes - No Match: Gate Dep Delay<6 Flt" AND
    aspm_report."Delay NAS Causes - No Match: Other Carr Reported NAS Min" = asqp_report."Delay NAS Causes - No Match: Other Carr Reported NAS Min" AND
    aspm_report."Delay NAS Causes - No Match: Other Carr Reported NAS Flt" = asqp_report."Delay NAS Causes - No Match: Other Carr Reported NAS Flt" AND
    aspm_report."Delay NAS Causes - No Match: Other Carr Reported Non-NAS Min" = asqp_report."Delay NAS Causes - No Match: Other Carr Reported Non-NAS Min" AND
    aspm_report."Delay NAS Causes - No Match: Other Carr Reported Non-NAS Flt"= asqp_report."Delay NAS Causes - No Match: Other Carr Reported Non-NAS Flt" AND
    aspm_report."Delay NAS Causes - No Match: No Other Carr Reported Delays Min" = asqp_report."Delay NAS Causes - No Match: No Other Carr Reported Delays Min" AND
    aspm_report."Delay NAS Causes - No Match: No Other Carr Reported Delays Flt" = asqp_report."Delay NAS Causes - No Match: No Other Carr Reported Delays Flt" AND
    aspm_report."Delay NAS Causes - No Match: NAS Delays Requiring Val Min" = asqp_report."Delay NAS Causes - No Match: NAS Delays Requiring Val Min" AND
    aspm_report."Delay NAS Causes - No Match: NAS Delays Requiring Val Flt" = asqp_report."Delay NAS Causes - No Match: NAS Delays Requiring Val Flt" AND
    aspm_report."NAS Causes: Total Min"  = asqp_report."NAS Causes: Total Min" AND
    aspm_report."NAS Causes: Total Flt"= asqp_report."NAS Causes: Total Flt");

-- CREATE THE NAS_TIME_SCH_REPORT VIEW
CREATE VIEW NAS_TIME_SCH_REPORT AS
(SELECT
    "Date",
    "Facility",
    "Total Flights",
    "All Causes Flights",
    "All Causes Percent",
    "Extreme Weather As The Only Factor Flights",
    "Extreme Weather As The Only Factor Percent",
    "Carrier Cause As The Only Factor Flights",
    "Carrier Cause As The Only Factor Percent",
    "NAS Cause As The Only Factor Flights",
    "NAS Cause As The Only Factor Percent",
    "Security Cause As The Only Factor Flights",
    "Security Cause As The Only Factor Percent",
    "NAS Cause and Prorated Late Arrival Flights",
    "NAS Cause and Prorated Late Arrival Percent",
    "Carrier Cause and Prorated Late Arrival Flights",
    "Carrier Cause and Prorated Late Arrival Percent",
    "ASQP"
 FROM public."ASQP_NAS_TIME_SCH_REPORT" AS asqp_nas_time_sch_report   

 UNION

SELECT
    "Date",
    "Facility",
    "Total Flights",
    "All Causes Flights",
    "All Causes Percent",
    "Extreme Weather As The Only Factor Flights",
    "Extreme Weather As The Only Factor Percent",
    "Carrier Cause As The Only Factor Flights",
    "Carrier Cause As The Only Factor Percent",
    "NAS Cause As The Only Factor Flights",
    "NAS Cause As The Only Factor Percent",
    "Security Cause As The Only Factor Flights",
    "Security Cause As The Only Factor Percent",
    "NAS Cause and Prorated Late Arrival Flights",
    "NAS Cause and Prorated Late Arrival Percent",
    "Carrier Cause and Prorated Late Arrival Flights",
    "Carrier Cause and Prorated Late Arrival Percent",
    "ASQP"
 FROM public."ASPM_NAS_TIME_SCH_REPORT" AS aspm_nas_time_sch_report)

EXCEPT
(SELECT
    asqp_report."Date",
    asqp_report."Facility",
    asqp_report."Total Flights",
    asqp_report."All Causes Flights",
    asqp_report."All Causes Percent",
    asqp_report."Extreme Weather As The Only Factor Flights",
    asqp_report."Extreme Weather As The Only Factor Percent",
    asqp_report."Carrier Cause As The Only Factor Flights",
    asqp_report."Carrier Cause As The Only Factor Percent",
    asqp_report."NAS Cause As The Only Factor Flights",
    asqp_report."NAS Cause As The Only Factor Percent",
    asqp_report."Security Cause As The Only Factor Flights",
    asqp_report."Security Cause As The Only Factor Percent",
    asqp_report."NAS Cause and Prorated Late Arrival Flights",
    asqp_report."NAS Cause and Prorated Late Arrival Percent",
    asqp_report."Carrier Cause and Prorated Late Arrival Flights",
    asqp_report."Carrier Cause and Prorated Late Arrival Percent",
    asqp_report."ASQP"
FROM public."ASQP_NAS_TIME_SCH_REPORT" AS asqp_report INNER JOIN public."ASPM_NAS_TIME_SCH_REPORT" AS aspm_report
ON 
    aspm_report."Date" = asqp_report."Date"  AND
    aspm_report."Facility" = asqp_report."Facility"  AND
    aspm_report."Total Flights" = asqp_report."Total Flights"  AND
    aspm_report."All Causes Flights" = asqp_report."All Causes Flights"  AND
    aspm_report."All Causes Percent" = asqp_report."All Causes Percent"  AND
    aspm_report."Extreme Weather As The Only Factor Flights" = asqp_report."Extreme Weather As The Only Factor Flights"  AND
    aspm_report."Extreme Weather As The Only Factor Percent" = asqp_report."Extreme Weather As The Only Factor Percent"  AND
    aspm_report."Carrier Cause As The Only Factor Flights" = asqp_report."Carrier Cause As The Only Factor Flights"  AND
    aspm_report."Carrier Cause As The Only Factor Percent" = asqp_report."Carrier Cause As The Only Factor Percent"  AND
    aspm_report."NAS Cause As The Only Factor Flights" = asqp_report."NAS Cause As The Only Factor Flights"  AND
    aspm_report."NAS Cause As The Only Factor Percent" = asqp_report."NAS Cause As The Only Factor Percent"  AND
    aspm_report."Security Cause As The Only Factor Flights" = asqp_report."Security Cause As The Only Factor Flights"  AND
    aspm_report."Security Cause As The Only Factor Percent" = asqp_report."Security Cause As The Only Factor Percent"  AND
    aspm_report."NAS Cause and Prorated Late Arrival Flights" = asqp_report."NAS Cause and Prorated Late Arrival Flights"  AND
    aspm_report."NAS Cause and Prorated Late Arrival Percent" = asqp_report."NAS Cause and Prorated Late Arrival Percent"  AND
    aspm_report."Carrier Cause and Prorated Late Arrival Flights" = asqp_report."Carrier Cause and Prorated Late Arrival Flights"  AND
    aspm_report."Carrier Cause and Prorated Late Arrival Percent" = asqp_report."Carrier Cause and Prorated Late Arrival Percent");

-- CREATE NAS_ON_TIME_FLIGHT_PLAN_REPORT VIEW
CREATE VIEW NAS_ON_TIME_FLIGHT_PLAN_REPORT AS
(SELECT
    "Date",
    "Facility",
    "Total Flights",
    "All Causes Flights",
    "All Causes Percent",
    "Extreme Weather As The Only Factor Flights",
    "Extreme Weather As The Only Factor Percent",
    "Carrier Cause As The Only Factor Flights",
    "Carrier Cause As The Only Factor Percent",
    "NAS Cause As The Only Factor Flights",
    "NAS Cause As The Only Factor Percent",
    "Security Cause As The Only Factor Flights",
    "Security Cause As The Only Factor Percent",
    "NAS Cause and Prorated Late Arrival Flights",
    "NAS Cause and Prorated Late Arrival Percent",
    "Carrier Cause and Prorated Late Arrival Flights",
    "Carrier Cause and Prorated Late Arrival Percent",
    "ASQP"
 FROM public."ASQP_NAS_ON_TIME_FLIGHT_PLAN_REPORT" AS asqp_nas_on_time_flight_plan_report   

 UNION

SELECT
    "Date",
    "Facility",
    "Total Flights",
    "All Causes Flights",
    "All Causes Percent",
    "Extreme Weather As The Only Factor Flights",
    "Extreme Weather As The Only Factor Percent",
    "Carrier Cause As The Only Factor Flights",
    "Carrier Cause As The Only Factor Percent",
    "NAS Cause As The Only Factor Flights",
    "NAS Cause As The Only Factor Percent",
    "Security Cause As The Only Factor Flights",
    "Security Cause As The Only Factor Percent",
    "NAS Cause and Prorated Late Arrival Flights",
    "NAS Cause and Prorated Late Arrival Percent",
    "Carrier Cause and Prorated Late Arrival Flights",
    "Carrier Cause and Prorated Late Arrival Percent",
    "ASQP"
 FROM public."ASPM_NAS_ON_TIME_FLIGHT_PLAN_REPORT" AS aspm_nas_on_time_flight_plan_report)
EXCEPT
(SELECT
    asqp_report."Date",
    asqp_report."Facility",
    asqp_report."Total Flights",
    asqp_report."All Causes Flights",
    asqp_report."All Causes Percent",
    asqp_report."Extreme Weather As The Only Factor Flights",
    asqp_report."Extreme Weather As The Only Factor Percent",
    asqp_report."Carrier Cause As The Only Factor Flights",
    asqp_report."Carrier Cause As The Only Factor Percent",
    asqp_report."NAS Cause As The Only Factor Flights",
    asqp_report."NAS Cause As The Only Factor Percent",
    asqp_report."Security Cause As The Only Factor Flights",
    asqp_report."Security Cause As The Only Factor Percent",
    asqp_report."NAS Cause and Prorated Late Arrival Flights",
    asqp_report."NAS Cause and Prorated Late Arrival Percent",
    asqp_report."Carrier Cause and Prorated Late Arrival Flights",
    asqp_report."Carrier Cause and Prorated Late Arrival Percent",
    asqp_report."ASQP"
FROM public."ASQP_NAS_ON_TIME_FLIGHT_PLAN_REPORT" AS asqp_report INNER JOIN public."ASPM_NAS_ON_TIME_FLIGHT_PLAN_REPORT" AS aspm_report
ON 
    aspm_report."Date" = asqp_report."Date" AND
    aspm_report."Facility" = asqp_report."Facility" AND
    aspm_report."Total Flights"= asqp_report."Total Flights" AND
    aspm_report."All Causes Flights" = asqp_report."All Causes Flights" AND
    aspm_report."All Causes Percent" = asqp_report."All Causes Percent" AND
    aspm_report."Extreme Weather As The Only Factor Flights" = asqp_report."Extreme Weather As The Only Factor Flights" AND
    aspm_report."Extreme Weather As The Only Factor Percent" = asqp_report."Extreme Weather As The Only Factor Percent" AND
    aspm_report."Carrier Cause As The Only Factor Flights" = asqp_report."Carrier Cause As The Only Factor Flights" AND
    aspm_report."Carrier Cause As The Only Factor Percent" = asqp_report."Carrier Cause As The Only Factor Percent" AND
    aspm_report."NAS Cause As The Only Factor Flights" = asqp_report."NAS Cause As The Only Factor Flights" AND
    aspm_report."NAS Cause As The Only Factor Percent" = asqp_report."NAS Cause As The Only Factor Percent" AND
    aspm_report."Security Cause As The Only Factor Flights" = asqp_report."Security Cause As The Only Factor Flights" AND
    aspm_report."Security Cause As The Only Factor Percent" = asqp_report."Security Cause As The Only Factor Percent" AND
    aspm_report."NAS Cause and Prorated Late Arrival Flights" = asqp_report."NAS Cause and Prorated Late Arrival Flights" AND
    aspm_report."NAS Cause and Prorated Late Arrival Percent" = asqp_report."NAS Cause and Prorated Late Arrival Percent" AND
    aspm_report."Carrier Cause and Prorated Late Arrival Flights" = asqp_report."Carrier Cause and Prorated Late Arrival Flights" AND
    aspm_report."Carrier Cause and Prorated Late Arrival Percent" = asqp_report."Carrier Cause and Prorated Late Arrival Percent");

-- CREATE BTS_REPORT VIEW
CREATE VIEW BTS_REPORT AS
(SELECT
    "Date",
    "Facility",
    "Total Ops Scheduled",
    "Cancellations: Car",
    "Cancellations: Wx",
    "Cancellations: NAS",
    "Cancellations: Sec",
    "Flights: Cancelled",
    "Flights: Diverted",
    "Flights: On-Time",
    "Flights: Delayed",
    "Delay Minutes: Car",
    "Delay Minutes: Wx",
    "Delay Minutes: NAS",
    "Delay Minutes: Sec",
    "Delay Minutes: Late Arr Flights",
    "Total",
    "ASQP"
FROM public."ASQP_BTS_REPORT" AS asqp_bts_report
UNION
SELECT
    "Date",
    "Facility",
    "Total Ops Scheduled",
    "Cancellations: Car",
    "Cancellations: Wx",
    "Cancellations: NAS",
    "Cancellations: Sec",
    "Flights: Cancelled",
    "Flights: Diverted",
    "Flights: On-Time",
    "Flights: Delayed",
    "Delay Minutes: Car",
    "Delay Minutes: Wx",
    "Delay Minutes: NAS",
    "Delay Minutes: Sec",
    "Delay Minutes: Late Arr Flights",
    "Total",
    "ASQP"
FROM public."ASPM_BTS_REPORT" AS aspm_bts_report)
EXCEPT
(SELECT
    asqp_report."Date",
    asqp_report."Facility",
    asqp_report."Total Ops Scheduled",
    asqp_report."Cancellations: Car",
    asqp_report."Cancellations: Wx",
    asqp_report."Cancellations: NAS",
    asqp_report."Cancellations: Sec",
    asqp_report."Flights: Cancelled",
    asqp_report."Flights: Diverted",
    asqp_report."Flights: On-Time",
    asqp_report."Flights: Delayed",
    asqp_report."Delay Minutes: Car",
    asqp_report."Delay Minutes: Wx",
    asqp_report."Delay Minutes: NAS",
    asqp_report."Delay Minutes: Sec",
    asqp_report."Delay Minutes: Late Arr Flights",
    asqp_report."Total",
    asqp_report."ASQP"
FROM public."ASQP_BTS_REPORT" AS asqp_report INNER JOIN public."ASPM_BTS_REPORT" AS aspm_report
ON 
    aspm_report."Date" = asqp_report."Date" AND
    aspm_report."Facility" = asqp_report."Facility" AND
    aspm_report."Total Ops Scheduled" = asqp_report."Total Ops Scheduled" AND
    aspm_report."Cancellations: Car" = asqp_report."Cancellations: Car" AND
    aspm_report."Cancellations: Wx" = asqp_report."Cancellations: Wx" AND
    aspm_report."Cancellations: NAS" = asqp_report."Cancellations: NAS" AND
    aspm_report."Cancellations: Sec" = asqp_report."Cancellations: Sec" AND
    aspm_report."Flights: Cancelled" = asqp_report."Flights: Cancelled" AND
    aspm_report."Flights: Diverted" = asqp_report."Flights: Diverted" AND
    aspm_report."Flights: On-Time" = asqp_report."Flights: On-Time" AND
    aspm_report."Flights: Delayed" = asqp_report."Flights: Delayed" AND
    aspm_report."Delay Minutes: Car" = asqp_report."Delay Minutes: Car" AND
    aspm_report."Delay Minutes: Wx" = asqp_report."Delay Minutes: Wx" AND
    aspm_report."Delay Minutes: NAS" = asqp_report."Delay Minutes: NAS" AND
    aspm_report."Delay Minutes: Sec" = asqp_report."Delay Minutes: Sec" AND
    aspm_report."Delay Minutes: Late Arr Flights" = asqp_report."Delay Minutes: Late Arr Flights" AND
    aspm_report."Total" = asqp_report."Total" );

-- CREATE BTS_REPORT VIEW
CREATE VIEW BTS_TRANS_STATS_REPORT AS
(SELECT
    "Date",
    "Facility",
    "Wx",
    "Vol",
    "Eqpt",
    "Rwy",
    "Oth",
    "Total",
    "ASQP"
FROM public."ASQP_BTS_TRANS_STATS_REPORT" AS asqp_bts_trans_stats_report
UNION
SELECT
    "Date",
    "Facility",
    "Wx",
    "Vol",
    "Eqpt",
    "Rwy",
    "Oth",
    "Total",
    "ASQP"
FROM public."ASPM_BTS_TRANS_STATS_REPORT" AS aspm_bts_trans_stats_report)
EXCEPT
(SELECT
    asqp_report."Date",
    asqp_report."Facility",
    asqp_report."Wx",
    asqp_report."Vol",
    asqp_report."Eqpt",
    asqp_report."Rwy",
    asqp_report."Oth",
    asqp_report."Total",
    asqp_report."ASQP"
FROM public."ASQP_BTS_TRANS_STATS_REPORT" AS asqp_report INNER JOIN public."ASPM_BTS_TRANS_STATS_REPORT" AS aspm_report
ON 
    aspm_report."Date" = asqp_report."Date" AND
    aspm_report."Facility" = asqp_report."Facility"  AND
    aspm_report."Wx" = asqp_report."Wx" AND
    aspm_report."Vol" = asqp_report."Vol" AND
    aspm_report."Eqpt" = asqp_report."Eqpt" AND
    aspm_report."Rwy" = asqp_report."Rwy" AND
    aspm_report."Oth" = asqp_report."Oth" AND
    aspm_report."Total" = asqp_report."Total");


