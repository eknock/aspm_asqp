# DATA 670 Capstone project
# Problem statement: Using machine learning (supervised or unsupervised), 
# identify the airport based on metrics.  This way the machine can identify
# a specific airport or airports based on the desired metrics.  This 
# approach will enable FAA planners to focus on the specific airports 
# and see why certain airports have the desired metrics. It could be:
# --Procedures,
# No. of ATCs
# No. of runways 
# Types of traffic,
# Etc.,  
#######################################################################
# =================================================================================
# installing various packages
# =================================================================================
# code by vikram b baliga 
# http://www.vikram-baliga.com/blog/2015/7/19/a-hassle-free-way-to-verify-that-r-packages-are-installed-and-loaded
# START CODE OF VIKRAM'S CODE
# =================================================================================
# specify the packages of interest
packages = c( "RPostgreSQL","zoo")


# RPostgreSQL = to interface with an PostgreSQL RDBMS


# use this function to check if each package is on the local machine
# if a package is installed, it will be loaded
# if any are not, the missing package(s) will be installed and loaded
package.check <- lapply(packages, FUN = function(x) {
  if (!require(x, character.only = TRUE)) {
    install.packages(x, dependencies = TRUE)
    library(x, character.only = TRUE)
  }else{
    library(x, character.only = TRUE) # the else statement added by Enoch Moses
  }
})

#verify they are loaded
search()
# =================================================================================
# END OF VIKRAM'S CODE
# =================================================================================
# function to load CSV file
loadCsvFile <- function(file_name,skip_number,newheader, remove_bottom_number){
  data_frame <- read.csv(file_name,skip=skip_number,header=FALSE, sep=",", na.strings = c("","NA"))
  # puts the header name
  names(data_frame) <- newheader
  
  # removes all columns with NA values
  data_frame = data_frame[newheader]
  
  # remove tail - routine
  # #####################
  # get total number of rows in the data frame
  total_rows = nrow(data_frame)
  # reduce the total number by removing the undesired tail
  total_rows = total_rows - remove_bottom_number
  # remove the tail
  data_frame = head(data_frame,total_rows)
  
  # returrn the data frame
  return(data_frame)
}
# function to standardize date
getFormattedDate <- function(old_date){
  inner_date <- old_date
  new_date <- as.yearmon(inner_date,"%b-%y")
  return(new_date)
}
getFormattedDateOther <- function(old_date){
  inner_date <- old_date
  dash_index <- regexpr("-",inner_date)
  year <- substr(inner_date,0,dash_index-1)
  month <- substr(inner_date,dash_index, dash_index+3)
  month <- substr(month,2,4)
  inner_date <- paste(month,year,sep="-")
  new_date <- getFormattedDate(inner_date)
  return(new_date)
 
}

# function moveDataToDB
moveDataToDB <- function(conn, data_frame_name, data_frame){
  if(!dbExistsTable(conn, data_frame_name)){
      dbWriteTable(conn,data_frame_name, data_frame)
  }
}



# Airport: Standard Report ? ASQP Flights
####################################################
asqp_stnd_report_data_file= "raw_csv_files/ASQP_0100_122018_ops_airport_standard_report_all_airports.csv"
header_asqp_stnd_report <- c(
  "Date",
  "Facility",
  "Actual Departures",
  "Actual Arrivals",
  "Departure Cancellations",
  "Arrival Cancellations",
  "Departure Diversions",
  "Arrival Diversions",
  "On-Time Arrivals",
  "Percentage On-Time Gate Departures",
  "Percentage On-Time Gate Arrivals", # changed from Percent to Percentage
  "Average Gate Departure Delay",
  "Average Gate Arrival Delay",
  "Average Block Delay",
  "Average Taxi Out Time",
  "Average Taxi In Time",
  "Delayed Arrivals",
  "Average Delay Per Delayed Arrivals"
  )
# get the desired data frame from the csv file
asqp_stnd_report <- loadCsvFile(asqp_stnd_report_data_file, 7, header_asqp_stnd_report,4)

#remove unwanted variables
rm(asqp_stnd_report_data_file)
rm(header_asqp_stnd_report)

# add ASQP variable 
asqp_stnd_report$ASQP <- 1
asqp_stnd_report$Date <- getFormattedDate(asqp_stnd_report$Date)


# Airport: Standard Report – ASPM Flights
####################################################

aspm_stnd_report_data_file = "raw_csv_files/ASPM_0100_122018_ops_airport_standard_report_all_airports.csv"
header_asqp_stnd_report <- c(
  "Facility",
  "Date",
  "Actual Departures",
  "Actual Arrivals",
  "Departure Cancellations",
  "Arrival Cancellations", #renamed from Arrival Cancellation to Arrival Cancellations
  "On-Time Arrivals",
  "Percentage On-Time Gate Departures",
  "Percentage On-Time Gate Arrivals",
  "Average Gate Departure Delay",
  "Average Gate Arrival Delay",
  "Average Block Delay",
  "Average Taxi Out Time",
  "Average Taxi In Time",
  "Delayed Arrivals",
  "Average Delay Per Delayed Arrivals"
)
aspm_stnd_report <- loadCsvFile(aspm_stnd_report_data_file, 7,header_asqp_stnd_report,4)

#remove unwanted variables
rm(aspm_stnd_report_data_file)
rm(header_asqp_stnd_report)

# add ASQP variable 
aspm_stnd_report$ASQP <- 0
aspm_stnd_report$Date <- getFormattedDate(aspm_stnd_report$Date)

# Airport: Casual Report – ASQP Flights
#######################################
asqp_casual_report_data_file = "raw_csv_files/ASQP_0100_122018_ops_airport_casual_report_all_airports.csv"
header_asqp_casual_report <- c(
  "Facility",
  "Date",
  "Actual Departures",
  "Actual Arrivals",
  "Cancellations",
  "Cancellations Causes: Carrier",
  "Cancellations Causes: Weather",
  "Cancellations Causes: NAS",
  "Cancellations Causes: Security",
  "Gate Arrival Delay Minutes",
  "Delay Causes: Carrier Min",
  "Delay Causes: Carrier Flt",
  "Delay Causes: Weather Min",
  "Delay Causes: Weather Flt",
  "Delay Causes: NAS Min",
  "Delay Causes: NAS Flt",
  "Delay Causes: Security Min",
  "Delay Causes: Security Flt",
  "Delay Causes: Late Arrival Min",
  "Delay Causes: Late Arrival Flt",
  "Delay Causes: Total Min",
  "Delay Causes: Total Flt"
)
asqp_casual_report <- loadCsvFile(asqp_casual_report_data_file, 10,header_asqp_casual_report,5)
# 10, 5
#remove unwanted variables
rm(asqp_casual_report_data_file)
rm(header_asqp_casual_report)

# add ASQP variable 
asqp_casual_report$ASQP <- 1
asqp_casual_report$Date <- getFormattedDateOther(asqp_casual_report$Date)
asqp_casual_report$Date <- getFormattedDate(asqp_casual_report$Date)


# Airport: Casual Report – ASPM Flights
#######################################
aspm_casual_report_data_file = "raw_csv_files/ASPM_0100_122018_ops_airport_casual_report_all_airports.csv"
header_aspm_casual_report <- c(
  "Facility",
  "Date",
  "Actual Departures",
  "Actual Arrivals",
  "Cancellations",
  "Cancellations Causes: Carrier",
  "Cancellations Causes: Weather",
  "Cancellations Causes: NAS",
  "Cancellations Causes: Security",
  "Gate Arrival Delay Minutes",
  "Delay Causes: Carrier Min",
  "Delay Causes: Carrier Flt",
  "Delay Causes: Weather Min",
  "Delay Causes: Weather Flt",
  "Delay Causes: NAS Min",
  "Delay Causes: NAS Flt",
  "Delay Causes: Security Min",
  "Delay Causes: Security Flt",
  "Delay Causes: Late Arrival Min",
  "Delay Causes: Late Arrival Flt",
  "Delay Causes: Total Min",
  "Delay Causes: Total Flt"
)
aspm_casual_report <- loadCsvFile(aspm_casual_report_data_file, 10,header_aspm_casual_report,4)
#10,4

#remove unwanted variables
rm(aspm_casual_report_data_file)
rm(header_aspm_casual_report)

# add ASQP variable 
aspm_casual_report$ASQP <- 0
aspm_casual_report$Date <- getFormattedDate(aspm_casual_report$Date)

# Airport: NAS Report – ASQP Flights
#######################################
asqp_nas_report_data_file = "raw_csv_files/ASQP_0100_122018_ops_airport_nas_report_all_airports.csv"
header_asqp_nas_report <- c(
  "Facility",
  "Date",
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
# should be "Delay NAS Causes - No Match: Delay After Gate Departure (>15) Min"
  "Delay NAS Causes - No Match: Delay After Gate Dep >15 Min", 
# should be "Delay NAS Causes - No Match: Delay After Gate Departure (>15) Flt"
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
  "NAS Causes: Total Flt"
)
asqp_nas_report <- loadCsvFile(asqp_nas_report_data_file,16,header_asqp_nas_report,5)
#16,5               

#remove unwanted variables
rm(asqp_nas_report_data_file)
rm(header_asqp_nas_report)

# add ASQP variable 
asqp_nas_report$ASQP <- 1
asqp_nas_report$Date <- getFormattedDate(asqp_nas_report$Date)

# Airport: NAS Report – ASPM Flights
#######################################
aspm_nas_report_data_file = "raw_csv_files/ASPM_0100_122018_ops_airport_nas_report_all_airports.csv"

header_aspm_nas_report <- c(
  "Facility",
  "Date",
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
  "NAS Causes: Total Flt"
)

aspm_nas_report <- loadCsvFile(aspm_nas_report_data_file,16,header_aspm_nas_report,4)
#16,4

#remove unwanted variables
rm(aspm_nas_report_data_file)
rm(header_aspm_nas_report)

# add ASQP variable 
aspm_nas_report$ASQP <- 0
aspm_nas_report$Date <- getFormattedDate(aspm_nas_report$Date)

# Airport: On-Time NAS Report: Use Schedule – ASQP Flights
##########################################################
asqp_nas_on_time_sch_report_data_file = "raw_csv_files/ASQP_0100_122018_ops_airport_on_time_nas_report_user_schedule_all_airports.csv"
header_asqp_nas_on_time_sch_report <- c(
  "Facility",
  "Date",
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
  "Carrier Cause and Prorated Late Arrival Percent"
  
)
asqp_nas_on_time_sch_report <- loadCsvFile(asqp_nas_on_time_sch_report_data_file,8,header_asqp_nas_on_time_sch_report,5)
# 8,5

#remove unwanted variables
rm(asqp_nas_on_time_sch_report_data_file)
rm(header_asqp_nas_on_time_sch_report)

# add ASQP variable 
asqp_nas_on_time_sch_report$ASQP <- 1
asqp_nas_on_time_sch_report$Date <- getFormattedDate(asqp_nas_on_time_sch_report$Date)

# Airport: On-Time NAS Report: Use Schedule – ASPM Flights
##########################################################
aspm_nas_on_time_sch_report_data_file = "raw_csv_files/ASPM_0100_122018_ops_airport_on_time_nas_report_user_schedule_all_airports.csv"
header_aspm_nas_on_time_sch_report <- c(
  "Facility",
  "Date",
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
  "Carrier Cause and Prorated Late Arrival Percent"
)
aspm_nas_on_time_sch_report <-loadCsvFile(aspm_nas_on_time_sch_report_data_file,8,header_aspm_nas_on_time_sch_report,5)
# 8,5

#remove unwanted variables
rm(aspm_nas_on_time_sch_report_data_file)
rm(header_aspm_nas_on_time_sch_report)

# add ASQP variable 
aspm_nas_on_time_sch_report$ASQP <- 0
aspm_nas_on_time_sch_report$Date <- getFormattedDate(aspm_nas_on_time_sch_report$Date)

# Airport: On-Time NAS Report: Use Flight Plan – ASQP Flights
#############################################################
asqp_nas_on_time_flight_plan_report_data_file = "raw_csv_files/ASQP_0100_122018_ops_airport_on_time_nas_report_use_flight_plan_all_airports.csv"
header_asqp_nas_on_time_flight_plan_report <- c(
  "Facility",
  "Date",
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
  "Carrier Cause and Prorated Late Arrival Percent"
)
asqp_nas_on_time_flight_plan_report <- loadCsvFile(asqp_nas_on_time_flight_plan_report_data_file,8,header_asqp_nas_on_time_flight_plan_report,5)
# 8,5

#remove unwanted variables
rm(asqp_nas_on_time_flight_plan_report_data_file)
rm(header_asqp_nas_on_time_flight_plan_report)

# add ASQP variable 
asqp_nas_on_time_flight_plan_report$ASQP <- 1
asqp_nas_on_time_flight_plan_report$Date <- getFormattedDateOther(asqp_nas_on_time_flight_plan_report$Date)

# Airport: On-Time NAS Report: Use Flight Plan – ASPM Flights
#############################################################
aspm_nas_on_time_flight_plan_report_data_file = "raw_csv_files/ASPM_0100_122018_ops_airport_on_time_nas_report_use_flight_plan_all_airports.csv"
header_aspm_nas_on_time_flight_plan_report <- c(
  "Facility",
  "Date",
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
  "Carrier Cause and Prorated Late Arrival Percent"
)
aspm_nas_on_time_flight_plan_report <- loadCsvFile(aspm_nas_on_time_flight_plan_report_data_file,8,header_aspm_nas_on_time_flight_plan_report,5)
# 8, 5

#remove unwanted variables
rm(aspm_nas_on_time_flight_plan_report_data_file)
rm(header_aspm_nas_on_time_flight_plan_report)

# add ASQP variable 
aspm_nas_on_time_flight_plan_report$ASQP <- 0
aspm_nas_on_time_flight_plan_report$Date <- getFormattedDate(aspm_nas_on_time_flight_plan_report$Date)

# Airport: BTS Report – ASQP Flights
####################################
asqp_bts_report_data_file = "raw_csv_files/ASQP_0100_122018_ops_airport_bts_report_all_airports.csv"
header_asqp_bts_report <- c(
  "Facility",
  "Date",
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
  "Total"
)
asqp_bts_report <- loadCsvFile(asqp_bts_report_data_file,10,header_asqp_bts_report,7)
#10, 7

#remove unwanted variables
rm(asqp_bts_report_data_file)
rm(header_asqp_bts_report)

# remove rows with nulls
asqp_bts_report <- na.omit(asqp_bts_report)

# add ASQP variable 
asqp_bts_report$ASQP <- 1
asqp_bts_report$Date <- getFormattedDate(asqp_bts_report$Date)

# Airport: BTS Report – ASPM Flights
####################################
aspm_bts_report_data_file = "raw_csv_files/ASPM_0100_122018_ops_airport_bts_report_all_airports.csv"
header_aspm_bts_report <- c(
  "Facility",
  "Date",
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
  "Total"
)
aspm_bts_report <- loadCsvFile(aspm_bts_report_data_file,10,header_aspm_bts_report,7)
# 10, 7

#remove unwanted variables
rm(aspm_bts_report_data_file)
rm(header_aspm_bts_report)

# remove rows with nulls
aspm_bts_report <- na.omit(aspm_bts_report)

# add ASQP variable 
aspm_bts_report$ASQP <- 0
aspm_bts_report$Date <- getFormattedDate(aspm_bts_report$Date)
# Airport: BTS TransStats Report – ASQP Flights
###############################################
asqp_bts_trans_stats_report_data_file = "raw_csv_files/ASQP_0100_122018_ops_airport_bts_transtats_report_all_airports.csv"
header_asqp_bts_trans_stats_report <- c(
  "Facility",
  "Date",
  "Wx",
  "Vol",
  "Eqpt",
  "Rwy",
  "Oth",
  "Total"
  
)
asqp_bts_trans_stats_report <- loadCsvFile(asqp_bts_trans_stats_report_data_file,4,header_asqp_bts_trans_stats_report,4)
# 4 4

#remove unwanted variables
rm(asqp_bts_trans_stats_report_data_file)
rm(header_asqp_bts_trans_stats_report)

# add ASQP variable 
asqp_bts_trans_stats_report$ASQP <- 1
asqp_bts_trans_stats_report$Date <- getFormattedDate(asqp_bts_trans_stats_report$Date)

# Airport: BTS TransStats Report – ASPM Flights
###############################################
aspm_bts_trans_stats_report_data_file = "raw_csv_files/ASPM_0100_122018_ops_airport_bts_transtats_report_all_airports.csv"
header_aspm_bts_trans_stats_report <- c(
  "Facility",
  "Date",
  "Wx",
  "Vol",
  "Eqpt",
  "Rwy",
  "Oth",
  "Total"
)
aspm_bts_trans_stats_report <- loadCsvFile(aspm_bts_trans_stats_report_data_file,4,header_aspm_bts_trans_stats_report,4)
# 4 4

#remove unwanted variables
rm(aspm_bts_trans_stats_report_data_file)
rm(header_aspm_bts_trans_stats_report)

# add ASQP variable 
aspm_bts_trans_stats_report$ASQP <- 0
aspm_bts_trans_stats_report$Date <- getFormattedDate(aspm_bts_trans_stats_report$Date)

# Airport: Schedule Reliability Report – ASQP Flights
#####################################################
asqp_sch_rely_report_data_file = "raw_csv_files/ASQP_0100_122018_ops_airport_schedule_reliability_report_all_airports.csv"
header_asqp_sch_rely_report <- c(
  "Facility",
  "Date",
  "Actual Departures",
  "Actual Arrivalls",
  "Departure Cancellations",
  "Arrival Cancellations",
  "Departure Diversions",
  "Arrival Diversions",
  "On-Time Arrivals",
  "% On-Time Gate Departures",
  "% On-Time Gate Arrivals",
  "Average Gate Departure Delay",
  "Average Gate Arrival Delay",
  "Average Block Delay",
  "Average Taxi Out Time",
  "Average Taxi In Time",
  "Delayed Arrivals",
  "Average Delay Per Delayed Arrivals",
  "Percent Schedule Arrival Reliability",
  "Percent Schedule Departure Reliablility"
  
)
asqp_sch_rely_report <- loadCsvFile(asqp_sch_rely_report_data_file,7,header_asqp_sch_rely_report,5)
# 7 5

#remove unwanted variables
rm(asqp_sch_rely_report_data_file)
rm(header_asqp_sch_rely_report)

# add ASQP variable 
asqp_sch_rely_report$ASQP <- 1
asqp_sch_rely_report$Date <- getFormattedDate(asqp_sch_rely_report$Date)

#Airport: Dispatch & Schedule Reliability Report – ASQP Flights
###############################################################
asqp_disp_sch_rely_report_data_file = "raw_csv_files/ASQP_0100_122018_ops_airport_dispatch_and_schedule_reliability_report_all_airports.csv"
header_asqp_disp_sch_rely_report <- c(
  "Facility",
  "Date",
  "Actual Departures",
  "Actual Arrivals",
  "Departure Cancellations",
  "Arrival Cancellations",
  "Departure Diversions",
  "Arrival Diversions",
  "On-Time Arrivals",
  "% On-Time Gate Departures",
  "% On-Time Gate Arrivals",
  "Average Gate Departure Delay",
  "Average Gate Arrival Delay",
  "Average Block Delay",
  "Average Taxi Out Time",
  "Average Taxi In Time",
  "Delayed Arrivals",
  "Average Delay Per Delayed Arrivals",
  "Percent Schedule Arrival Reliability",
  "Percent Schedule Departure Reliablility",
  "Percent Dispatch Reliability"
)
asqp_disp_sch_rely_report <- loadCsvFile(asqp_disp_sch_rely_report_data_file,7,header_asqp_disp_sch_rely_report,5)

#remove unwanted variables
rm(asqp_disp_sch_rely_report_data_file)
rm(header_asqp_disp_sch_rely_report)

# add ASQP variable 
asqp_disp_sch_rely_report$ASQP <- 1
asqp_disp_sch_rely_report$Date <- getFormattedDate(asqp_disp_sch_rely_report$Date)

########
# insert the csv in PostgreSQL database
########

# create the connection
conn <- dbConnect(PostgreSQL(), user=rstudioapi::askForPassword("Database user"), password=rstudioapi::askForPassword("Database password"),dbname="aspm_db")

r# create the table and load the data if the table with data does not exist
moveDataToDB(conn, "ASQP_STND_REPORT", asqp_stnd_report)
moveDataToDB(conn, "ASPM_STND_REPORT", aspm_stnd_report)

moveDataToDB(conn, "ASQP_CASUAL_REPORT", asqp_casual_report)
moveDataToDB(conn, "ASPM_CASUAL_REPORT", aspm_casual_report)

moveDataToDB(conn, "ASQP_NAS_REPORT", asqp_nas_report)
moveDataToDB(conn, "ASPM_NAS_REPORT", aspm_nas_report)

moveDataToDB(conn, "ASQP_NAS_TIME_SCH_REPORT", asqp_nas_on_time_sch_report)
moveDataToDB(conn, "ASPM_NAS_TIME_SCH_REPORT", aspm_nas_on_time_sch_report)

moveDataToDB(conn, "ASQP_NAS_ON_TIME_FLIGHT_PLAN_REPORT", asqp_nas_on_time_flight_plan_report)
moveDataToDB(conn, "ASPM_NAS_ON_TIME_FLIGHT_PLAN_REPORT", aspm_nas_on_time_flight_plan_report)

moveDataToDB(conn, "ASQP_BTS_REPORT", asqp_bts_report)
moveDataToDB(conn, "ASPM_BTS_REPORT", aspm_bts_report)

moveDataToDB(conn, "ASQP_BTS_TRANS_STATS_REPORT", asqp_bts_trans_stats_report)
moveDataToDB(conn, "ASPM_BTS_TRANS_STATS_REPORT", aspm_bts_trans_stats_report)

# put them in the database eventhough they were out of scope of 
moveDataToDB(conn, "ASQP_SCH_RELY_REPORT",asqp_sch_rely_report)
moveDataToDB(conn, "ASQP_DISP_SCH_RELY_REPORT",asqp_disp_sch_rely_report)

# remove the variables
rm(aspm_bts_report)
rm(asqp_bts_report)
rm(aspm_casual_report)
rm(asqp_casual_report)
rm(aspm_bts_trans_stats_report)
rm(asqp_bts_trans_stats_report)
rm(aspm_nas_on_time_flight_plan_report)
rm(asqp_nas_on_time_flight_plan_report)
rm(aspm_nas_on_time_sch_report)
rm(asqp_nas_on_time_sch_report)
rm(aspm_nas_report)
rm(asqp_nas_report)
rm(aspm_stnd_report)
rm(asqp_stnd_report)
rm(asqp_disp_sch_rely_report)
rm(asqp_sch_rely_report)

# get the initial reports from the database
# get stnd_report from database
stnd_report <- dbGetQuery(conn, "SELECT * FROM stnd_report")
stnd_report$Facility <- NULL
stnd_report$Date <- NULL
stnd_report$ASQP <- factor(stnd_report$ASQP)

# get casual_report from database
casual_report <- dbGetQuery(conn, "SELECT * FROM casual_report")
casual_report$Facility <- NULL
casual_report$Date <- NULL
casual_report$ASQP <- factor(casual_report$ASQP)

# get nas_report from database
nas_report <-  dbGetQuery(conn, "SELECT * FROM nas_report")
nas_report$Facility <-NULL
nas_report$Date <- NULL
nas_report$ASQP <- factor(nas_report$ASQP)

rm(conn)

