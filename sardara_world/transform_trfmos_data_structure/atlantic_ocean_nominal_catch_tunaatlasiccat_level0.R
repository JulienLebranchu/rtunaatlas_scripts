######################################################################
##### 52North WPS annotations ##########
######################################################################
# wps.des: id = atlantic_ocean_nominal_catch_tunaatlasiccat_level0, title = Harmonize data structure of ICCAT nominal catch, abstract = Harmonize the structure of ICCAT nominal catch dataset (pid of output file = atlantic_ocean_nominal_catch_tunaatlasICCAT_level0__bySamplingArea or atlantic_ocean_nominal_catch_tunaatlasICCAT_level0__byStockArea). The only mandatory field is the first one. The metadata must be filled-in only if the dataset will be loaded in the Tuna atlas database. ;
# wps.in: id = path_to_raw_dataset, type = String, title = Path to the input dataset to harmonize. Input file must be structured as follow: https://goo.gl/lEw8oK, value = "https://goo.gl/lEw8oK";
# wps.in: id = spatial_stratification, type = String, title = Spatial stratification to keep. SampAreaCode is for Sampling areas and Stock is for stock areas, value = "SampAreaCode|Stock";
# wps.in: id = path_to_metadata_file, type = String, title = NULL or path to the csv of metadata. The template file can be found here: https://raw.githubusercontent.com/ptaconet/rtunaatlas_scripts/master/sardara_world/transform_trfmos_data_structure/metadata_source_datasets_to_database/metadata_source_datasets_to_database_template.csv. , value = "NULL";
# wps.out: id = zip_namefile, type = text/zip, title = Dataset with structure harmonized + File of metadata (for integration within the Tuna Atlas database) + File of code lists (for integration within the Tuna Atlas database) ; 

if(!require(rtunaatlas)){
  if(!require(devtools)){
    install.packages("devtools")
  }
  require(devtools)
  install_github("ptaconet/rtunaatlas")
}
if(!require(dplyr)){
  install.packages("dplyr")
}
require(rtunaatlas)
require(dplyr)

#' @author Paul Taconet, IRD \email{paul.taconet@ird.fr}
#' 
#' @keywords Internal Commission for the Conservation of Atlantic Tuna ICCAT tuna RFMO Sardara Global database on tuna fishieries
#'
#' @seealso \code{\link{convertDSD_iccat_ce_task2}} to convert ICCAT task 2 , \code{\link{convertDSD_iccat_nc}} to convert ICCAT nominal catch data structure


#library(readxl) # devtools::install_github("hadley/readxl") 

#ICCAT_NC<-read_excel(path_to_raw_dataset, sheet = "dsT1NC", col_names = TRUE, col_types = NULL,na = "", skip = 3)
ICCAT_NC<-read.csv(path_to_raw_dataset)

colToKeep_NC<-c("Species","YearC","Flag",spatial_stratification,"GearCode","Qty_t","CatchTypeCode")  ### Previously CatchTypeCode was named DataType
NC_harm_ICCAT<-ICCAT_NC[colToKeep_NC]
colnames(NC_harm_ICCAT)<-c("Species", "Year","Flag","AreaName","Gear","Catch","CatchType")

NC_harm_ICCAT$AreaCWPgrid<-NA
NC_harm_ICCAT$School<-"ALL"
NC_harm_ICCAT$CatchUnits<-"MT"
NC_harm_ICCAT$RFMO<-"ICCAT"
NC_harm_ICCAT$Ocean<-"ATL"

NC_harm_ICCAT$MonthStart<-1
NC_harm_ICCAT$Period<-12

#Format inputDataset time to have the time format of the DB, which is one column time_start and one time_end
NC_harm_ICCAT<-as.data.frame(NC_harm_ICCAT)
NC_harm_ICCAT<-format_time_db_format(NC_harm_ICCAT)

NC<-NC_harm_ICCAT

rm(NC_harm_ICCAT)

NC <-NC[colToKeep_captures]
# remove 0 and NA values 
NC <- NC  %>% 
  filter( ! Catch %in% 0 ) %>%
  filter( ! is.na(Catch)) 

NC <- NC %>% 
  group_by(Flag,Gear,time_start,time_end,AreaName,School,Species,CatchType,CatchUnits) %>% 
  summarise(Catch = sum(Catch))
NC<-as.data.frame(NC)

colnames(NC)<-c("flag","gear","time_start","time_end","area","schooltype","species","catchtype","unit","value")

dataset<-NC

### Compute metadata
if (path_to_metadata_file!="NULL"){
  source("https://raw.githubusercontent.com/ptaconet/rtunaatlas_scripts/master/sardara_world/transform_trfmos_data_structure/metadata_source_datasets_to_database/compute_metadata.R")
} else {
  df_metadata<-NULL
  df_codelists<-NULL
}


## To check the outputs:
# str(dataset)
# str(df_metadata)
# str(df_codelists)
