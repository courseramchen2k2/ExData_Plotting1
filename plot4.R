## load package and clear environment for data processing
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

## Read in complete dataset, select rows that match the 2 day period requirement, then
## add a new column by changing to proper POIXct time format with lubridate package and 
## finally rearrange the column so that the properly formatted time file replaces the
## original Date and Time column
Data <- tbl_df(read.table(FileName2, header=TRUE, sep=";", numerals="no.loss",
                          na.strings=c("NA","-","?"), colClasses=CC, 
                          strip.white=TRUE)) %>%
        filter(Date == "1/2/2007" | Date== "2/2/2007") %>%
        mutate(DateTime = dmy_hms(paste(Date, Time))) %>%
        select(DateTime, 3:9)

## open png file device then Plot the graph
png("./plot4.png", width=480, height=480)
par(mfrow = c(2,2), cex=0.75)
with(Data, {
     plot(Data$DateTime, Data$Global_active_power, type="l", xlab="", 
          ylab="Global Active Power")
     plot(Data$DateTime, Data$Voltage, type="l", xlab="datetime",
          ylab="Voltage")
     plot(Data$DateTime, Data$Sub_metering_1, type="l", xlab="",
          ylab="Energy sub metering")
     lines(Data$DateTime, Data$Sub_metering_2, col="red")
     lines(Data$DateTime, Data$Sub_metering_3, col="blue")
     legend("topright", lty=1, col=c("black","red","blue"), 
            legend=c("Sub_metering_1","Sub_metering_2","Sub_metering_3"),
            bty="n")
     plot(Data$DateTime, Data$Global_reactive_power, type="l", xlab="datetime",
          ylab="Global_reactive_power")
     })
dev.off()
