#' Convert the data structure of WCPFC catch-and-effort (task 2) datasets Drifnet original format
#'
#' Convert the structure of WCPFC catch-and-effort datasets (task 2) Drifnet original format to the harmonized data structure that is used as input of the toolbox.
#'
#' @param path_to_raw_dataset String: path to the input DBF dataset.
#' 
#' @return The efforts dataset formatted in the harmonized data structure that is used as input of the toolbox.
#'
#' @details Input csv file must be structured like this: \url{https://goo.gl/R5EbrB}
#' This script works with any dataset that has the first 5 columns named and ordered as follow: {YY|MM|LAT5|LON5|DAYS} followed by a list of columns specifing the species codes with "_N" for catches expressed in number and "_T" for catches expressed in tons
#' 
#' @author Paul Taconet, IRD \email{paul.taconet@ird.fr}
#' 
#' @keywords Western and Central Pacific Fisheries Commission WCPFC tuna RFMO Sardara Global database on tuna fishieries
#'
#' @seealso \code{\link{convertDSD_wcpfc_ce_Driftnet}} to convert WCPFC task 2 Drifnet data structure, \code{\link{convertDSD_wcpfc_ce_Longline}} to convert WCPFC task 2 Longline data structure, \code{\link{convertDSD_wcpfc_ce_Pole_and_line}} to convert WCPFC task 2 Pole-and-line data structure, \code{\link{convertDSD_wcpfc_ce_PurseSeine}} to convert WCPFC task 2 Purse seine data structure, \code{\link{convertDSD_wcpfc_nc}} to convert WCPFC task 1 data structure  
#'



#path_to_raw_dataset="https://goo.gl/R5EbrB"

if(!require(rtunaatlas)){
  if(!require(devtools)){
    install.packages("devtools")
  }
  require(devtools)
  install_github("ptaconet/rtunaatlas")
}
if(!require(foreign)){
  install.packages("foreign")
}

require(rtunaatlas)
require(foreign)




wd<-getwd()
download.file(path_to_raw_dataset,destfile=paste(wd,"/dbf_file.DBF",sep=""), method='auto', quiet = FALSE, mode = "w",cacheOK = TRUE,extra = getOption("download.file.extra"))
path_to_raw_dataset=paste(wd,"/dbf_file.DBF",sep="")



# Input data sample:
# YY MM LAT5 LON5 DAYS ALB_N  ALB_C
# 1983 11  30S 170W    0     0  0.000
# 1983 11  35S 170W  133   886  4.960
# 1983 12  35S 165W    0     0  0.000
# 1983 12  35S 170W  133   870  4.872
# 1983 12  40S 165W    0     0  0.000
# 1983 12  40S 170W  248  3822 21.402

# Effort: final data sample:
# Flag Gear time_start   time_end AreaName School EffortUnits Effort
#  ALL    D 1983-11-01 1983-12-01  6330165    ALL        DAYS    133
#  ALL    D 1983-12-01 1984-01-01  6330165    ALL        DAYS    133
#  ALL    D 1983-12-01 1984-01-01  6335165    ALL        DAYS    248
#  ALL    D 1984-01-01 1984-02-01  6230165    ALL        DAYS     85
#  ALL    D 1984-01-01 1984-02-01  6240160    ALL        DAYS     59
#  ALL    D 1984-01-01 1984-02-01  6335165    ALL        DAYS    704


colToKeep_efforts <- c("Flag","Gear","time_start","time_end","AreaName","School","EffortUnits","Effort")


##Efforts

# Reach the efforts pivot DSD using a function in WCPFC_functions.R
efforts_pivot_WCPFC<-FUN_efforts_WCPFC_CE (path_to_raw_dataset)
efforts_pivot_WCPFC$Gear<-"D"

# Reach the efforts harmonized DSD using a function in ICCAT_functions.R
efforts<-WCPFC_CE_efforts_pivotDSD_to_harmonizedDSD(efforts_pivot_WCPFC,colToKeep_efforts)

colnames(efforts)<-c("flag","gear","time_start","time_end","area","schooltype","unit","value")

dataset<-efforts
