######################################################################
##### 52North WPS annotations ##########
######################################################################
# wps.des: id = southern_hemisphere_oceans_nominal_catch_tunaatlasccsbt_level0__bygear, title = Harmonize data structure of CCSBT nominal catch, abstract = Harmonize the structure of CCSBT nominal catch dataset (pid of output file = southern_hemisphere_oceans_nominal_catch_tunaatlasccsbt_level0__bygear). The only mandatory field is the first one. The metadata must be filled-in only if the dataset will be loaded in the Tuna atlas database. ;
# wps.in: id = path_to_raw_dataset, type = String, title = Path to the input dataset to harmonize. Input file must be structured as follow: https://goo.gl/033iit, value = "https://goo.gl/033iit";
# wps.in: id = path_to_metadata_file, type = String, title = NULL or path to the csv of metadata. The template file can be found here: https://raw.githubusercontent.com/ptaconet/rtunaatlas_scripts/master/sardara_world/transform_trfmos_data_structure/metadata_source_datasets_to_database/metadata_source_datasets_to_database_template.csv. , value = "NULL";
# wps.out: id = zip_namefile, type = text/zip, title = Dataset with structure harmonized + File of metadata (for integration within the Tuna Atlas database) + File of code lists (for integration within the Tuna Atlas database) ; 


#' @author Paul Taconet, IRD \email{paul.taconet@ird.fr}
#' 
#' @keywords Commission for the Conservation of Southern Bluefin Tuna CCSBT tuna RFMO Sardara Global database on tuna fishieries
#'
#' @seealso \code{\link{convertDSD_ccsbt_ce_Longline}} to convert CCSBT task 2 Longline data structure, \code{\link{convertDSD_ccsbt_ce_Surface}} to convert CCSBT task 2 Surface data structure


if(!require(rtunaatlas)){
  if(!require(devtools)){
    install.packages("devtools")
  }
  require(devtools)
  install_github("ptaconet/rtunaatlas")
}
if(!require(reshape)){
  install.packages("reshape")
}

require(rtunaatlas)
require(reshape)


##Catches
  
  
  # Input data sample (after importing as data.frame in R):
  #`Calendar\r\nYear` Longline `Purse\r\nSeine` `Pole\r\nand\r\nLine`  Trol Handline `Gill\r\nNet` Other
  #               1952      565              264                    NA    NA        0             0     0
  #               1953     3890              509                    NA    NA        0             0     0
  #               1954     2447              424                    NA    NA        0             0     0
  #               1955     1964              322                    NA    NA        0             0     0
  #               1956     9603              964                    NA    NA        0             0     0
  #               1957    22908             1264                    NA    NA        0             0     0
  
  
  # final data sample:
  #Flag     Gear time_start   time_end AreaName School Species CatchType CatchUnits Catch
  #  ALL Gill Net 1982-01-01 1983-01-01    CCSBT    ALL     SBF       ALL         MT    11
  #  ALL Gill Net 1983-01-01 1984-01-01    CCSBT    ALL     SBF       ALL         MT    12
  #  ALL Gill Net 1985-01-01 1986-01-01    CCSBT    ALL     SBF       ALL         MT    67
  #  ALL Gill Net 1986-01-01 1987-01-01    CCSBT    ALL     SBF       ALL         MT    81
  #  ALL Gill Net 1987-01-01 1988-01-01    CCSBT    ALL     SBF       ALL         MT    87
  #  ALL Gill Net 1988-01-01 1989-01-01    CCSBT    ALL     SBF       ALL         MT   234
  
  require(reshape)

  
#library(readxl) # devtools::install_github("hadley/readxl") 
  #CCSBT_NC<-read_excel(path_to_raw_dataset, sheet = "Catch by Gear", col_names = TRUE, col_types = NULL,na = "",skip=7)
  
  CCSBT_NC<-read.csv(path_to_raw_dataset,stringsAsFactors = F)
  #colnames(CCSBT_NC)<-gsub("\r\n", " ", colnames(CCSBT_NC))
  #colnames(CCSBT_NC)<-gsub(" ", "_", colnames(CCSBT_NC))

  #CCSBT_NC<-as.data.frame(CCSBT_NC)

CCSBT_NC<-melt(CCSBT_NC, id.vars="Calendar_Year") 
CCSBT_NC$variable<-as.character(CCSBT_NC$variable)

CCSBT_NC$variable<-gsub("_", " ", CCSBT_NC$variable)

#Flag
CCSBT_NC$Flag<-"ALL"

#Gear
CCSBT_NC$Gear<-CCSBT_NC$variable



#Year and period
CCSBT_NC$Year<-CCSBT_NC$Calendar_Year
CCSBT_NC$MonthStart<-1
CCSBT_NC$Period<-12
#Format inputDataset time to have the time format of the DB, which is one column time_start and one time_end
CCSBT_NC<-format_time_db_format(CCSBT_NC)

# Area 
CCSBT_NC$AreaName<-"CCSBT"

#School
CCSBT_NC$School<-"ALL"

#Species
CCSBT_NC$Species<-"SBF"

#CatchType
CCSBT_NC$CatchType<-"ALL"



#Catch
CCSBT_NC$Catch<-CCSBT_NC$value

CCSBT_NC$CatchUnits<-"MT"

colToKeep_captures <- c("Flag","Gear","time_start","time_end","AreaName","School","Species","CatchType","CatchUnits","Catch")
NC <-CCSBT_NC[colToKeep_captures]


#remove whitespaces on columns that should not have withespace
NC[,c("AreaName","Flag")]<-as.data.frame(apply(NC[,c("AreaName","Flag")],2,function(x){gsub(" *$","",x)}),stringsAsFactors=FALSE)

# remove 0 and NA values 
NC <- NC  %>% 
  filter( ! Catch %in% 0 ) %>%
  filter( ! is.na(Catch)) 

NC <- NC %>% 
  group_by(Flag,Gear,time_start,time_end,AreaName,School,Species,CatchType,CatchUnits) %>% 
  summarise(Catch = sum(Catch))
NC<-as.data.frame(NC)

colnames(NC)<-c("flag","gear","time_start","time_end","geographic_identifier","schooltype","species","catchtype","unit","value")
NC$source_authority<-"CCSBT"
dataset<-NC



### Compute metadata
#if (path_to_metadata_file!="NULL"){
#  source("https://raw.githubusercontent.com/ptaconet/rtunaatlas_scripts/master/tunaatlas_world/transform/compute_metadata.R")
#} else {
#  df_metadata<-NULL
#  df_codelists<-NULL
#}


## To check the outputs:
# str(dataset)
# str(df_metadata)
# str(df_codelists)

