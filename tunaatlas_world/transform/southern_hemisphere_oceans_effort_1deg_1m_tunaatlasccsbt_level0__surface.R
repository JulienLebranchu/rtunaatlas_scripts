######################################################################
##### 52North WPS annotations ##########
######################################################################
# wps.des: id = southern_hemisphere_oceans_effort_1deg_1m_tunaatlasccsbt_level0__surface, title = Harmonize data structure of CCSBT Surface effort datasets, abstract = Harmonize the structure of CCSBT catch-and-effort datasets: 'Surface' (pid of output file = southern_hemisphere_oceans_effort_1deg_1m_tunaatlasccsbt_level0__surface). The only mandatory field is the first one. The metadata must be filled-in only if the dataset will be loaded in the Tuna atlas database. ;
# wps.in: id = path_to_raw_dataset, type = String, title = Path to the input dataset to harmonize. Input file must be structured as follow: https://goo.gl/TokY4i, value = "https://goo.gl/TokY4i";
# wps.in: id = path_to_metadata_file, type = String, title = NULL or path to the csv of metadata. The template file can be found here: https://raw.githubusercontent.com/ptaconet/rtunaatlas_scripts/master/sardara_world/transform_trfmos_data_structure/metadata_source_datasets_to_database/metadata_source_datasets_to_database_template.csv . If NULL, no metadata will be outputted., value = "NULL";
# wps.out: id = zip_namefile, type = text/zip, title = Dataset with structure harmonized + File of metadata (for integration within the Tuna Atlas database) + File of code lists (for integration within the Tuna Atlas database) ; 



if(!require(rtunaatlas)){
  if(!require(devtools)){
    install.packages("devtools")
  }
  require(devtools)
  install_github("ptaconet/rtunaatlas")
}
require(rtunaatlas)

# Input data sample (after importing as data.frame in R):
# YEAR MONTH COUNTRY_CODE GEAR_CODE CCSBT_STATISTICAL_AREA LATITUDE LONGITUDE NUMBER_OF_HOURS_SEARCHED WEIGHT_(Kg)_OF_SBT_RETAINED
# 1975    12           AU        PS                      4      -37       150                       17                       59800
# 1976     8           AU        BB                      4      -36       150                        8                           0
# 1976     9           AU        BB                      4      -37       150                       14                       36200
# 1976     9           AU        BB                      4      -35       150                        4                           0
# 1976     9           AU        BB                      4      -34       151                       21                           0
# 1976    10           AU        BB                      4      -37       150                       51                       41000

# Effort: final data sample:
# Flag Gear time_start   time_end AreaName School EffortUnits Effort
#   AU   BB 1976-08-01 1976-09-01  6336150    ALL       HRSRH      8
#   AU   BB 1976-09-01 1976-10-01  6334151    ALL       HRSRH     21
#   AU   BB 1976-09-01 1976-10-01  6335150    ALL       HRSRH      4
#   AU   BB 1976-09-01 1976-10-01  6337150    ALL       HRSRH     14
#   AU   BB 1976-10-01 1976-11-01  6334151    ALL       HRSRH     21
#   AU   BB 1976-10-01 1976-11-01  6336150    ALL       HRSRH     29


#library(readxl) # devtools::install_github("hadley/readxl") 
#RFMO_CE<-read_excel(path_to_raw_dataset, sheet = "CEData_Surface", col_names = TRUE, col_types = NULL,na = "")

### Reach the catches pivot DSD using a function stored in ICCAT_functions.R

RFMO_CE<-read.csv(path_to_raw_dataset,stringsAsFactors = F)
#colnames(RFMO_CE)<-gsub("\r\n", "_", colnames(RFMO_CE))
#colnames(RFMO_CE)<-gsub(" ", "_", colnames(RFMO_CE))

#RFMO_CE<-as.data.frame(RFMO_CE)
#Remove lines that are read in the Excel but that are not real
RFMO_CE<- RFMO_CE[!is.na(RFMO_CE$YEAR),] 
RFMO_CE$WEIGHT_Kg_OF_SBT_RETAINED<-as.numeric(RFMO_CE$WEIGHT_Kg_OF_SBT_RETAINED)
RFMO_CE$NUMBER_OF_HOURS_SEARCHED<-as.numeric(RFMO_CE$NUMBER_OF_HOURS_SEARCHED)


#Flag
RFMO_CE$Flag<-RFMO_CE$COUNTRY_CODE

#Gear
RFMO_CE$Gear<-RFMO_CE$GEAR_CODE

#Year and period
RFMO_CE<-harmo_time_2(RFMO_CE, "YEAR", "MONTH")
#Format inputDataset time to have the time format of the DB, which is one column time_start and one time_end
RFMO_CE<-format_time_db_format(RFMO_CE)

# Area 
RFMO_CE<-harmo_spatial_5(RFMO_CE,"LATITUDE","LONGITUDE",1,5)

#School
RFMO_CE$School<-"ALL"


efforts<-RFMO_CE

efforts$EffortUnits<-"HRSRH"
efforts$Effort<-efforts$NUMBER_OF_HOURS_SEARCHED
colToKeep_efforts <- c("Flag","Gear","time_start","time_end","AreaName","School","EffortUnits","Effort")
efforts <-efforts[colToKeep_efforts]


#remove whitespaces on columns that should not have withespace
efforts[,c("AreaName","Flag")]<-as.data.frame(apply(efforts[,c("AreaName","Flag")],2,function(x){gsub(" *$","",x)}),stringsAsFactors=FALSE)

# remove 0 and NA values 
efforts <- efforts  %>% 
  filter( ! Effort %in% 0 ) %>%
  filter( ! is.na(Effort)) 

efforts <- efforts %>% 
  group_by(Flag,Gear,time_start,time_end,AreaName,School,EffortUnits) %>% 
  summarise(Effort = sum(Effort))  
efforts<-as.data.frame(efforts)

colnames(efforts)<-c("flag","gear","time_start","time_end","geographic_identifier","schooltype","unit","value")
efforts$source_authority<-"CCSBT"
dataset<-efforts


### Compute metadata
if (path_to_metadata_file!="NULL"){
  source("https://raw.githubusercontent.com/ptaconet/rtunaatlas_scripts/master/tunaatlas_world/transform/compute_metadata.R")
} else {
  df_metadata<-NULL
  df_codelists<-NULL
}


## To check the outputs:
# str(dataset)
# str(df_metadata)
# str(df_codelists)
