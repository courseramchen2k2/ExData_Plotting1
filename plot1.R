## load package and clear environment for data processing
library(data.table)
library(lubridate)
library(dplyr)
rm(list=ls())

FileURL1 <- "https://d396qusza40orc.cloudfront.net/exdata%2Fdata%2Fhousehold_power_consumption.zip"
FileName1 <- "./exdata_data_household_power_consumption.zip"
FileName2 <- "./household_power_consumption.txt"
CC <- c("character","character","numeric","numeric","numeric","numeric","numeric","numeric","numeric")

## download necessary files to current working directory if file not present.
if (!file.exists(FileName1)){
        download.file(FileURL1, destfile=FileName1, mode="wb")
}

## Extract Dataset zip file if not present.
if (!file.exists(FileName2)) {
        message("Extracting file.....")
        unzip(FileName1, overwrite=TRUE)
}

## Loading the Data
## 1. Old method which takes around 18 seconds to complete, just for reference
##
## Data <- tbl_df(read.table(FileName2, header=TRUE, sep=";", numerals="no.loss",
##                          na.strings=c("NA","-","?"), colClasses=CC, 
##                          strip.white=TRUE)) %>%
##        filter(Date == "1/2/2007" | Date== "2/2/2007") %>%
##        mutate(DateTime = dmy_hms(paste(Date, Time))) %>%
##        select(DateTime, 3:9)
##
## 2. Another method which takes around 6 seconds to complete, just for reference
##
## Data <- read.table(pipe("findstr /B /R ^[12]/2/2007 household_power_consumption.txt"),
##                    sep=";",header=FALSE,na.strings = "?",stringsAsFactors = FALSE)
## names(Data)<-names(read.table(pipe("findstr /B /R ^Date household_power_consumption.txt"),
##                               sep=";",header = TRUE))
## Data <- mutate(Data, DateTime = dmy_hms(paste(Date, Time))) %>%
##         select(DateTime, 3:9)
##
## 3. Fastest read method so far 2.85 sec when loading library and 0.39 second when
## library already loaded.
##
## Using data.table package fread to read in only the 2 day period section from file
## then add the column names manually, then use dplyr package and lubridate package
## to add a new column of proper date time then delete the old Date and Time column
## since there is 1 row of data every minute, nrow for fread is 2 days x 24 hours x 
## 60 minutes of entry, skip actually skip all entry above 1/2/2007 
Data <- fread(FileName2, sep=";", na.strings="?", colClasses=CC, skip="1/2/2007",
              nrow=2*24*60)
setnames(Data,c("Date","Time","Global_active_power","Global_reactive_power",
                 "Voltage","Global_intensity","Sub_metering_1", "Sub_metering_2",
                 "Sub_metering_3"))
Data <- mutate(Data, DateTime = dmy_hms(paste(Date, Time))) %>%
        select(DateTime, 3:9)

## open png file device then Plot the graph
png("./plot1.png", width=480, height=480)
hist(Data$Global_active_power, col="red", main="Global Active Power", 
     xlab="Global Active Power (kilowatts)")
dev.off()
