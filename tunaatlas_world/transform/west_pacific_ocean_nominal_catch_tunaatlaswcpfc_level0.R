######################################################################
##### 52North WPS annotations ##########
######################################################################
# wps.des: id = west_pacific_ocean_nominal_catch_tunaatlaswcpfc_level0, title = Harmonize data structure of WCPFC nominal catch, abstract = Harmonize the structure of WCPFC nominal catch dataset (pid of output file = west_pacific_ocean_nominal_catch_tunaatlaswcpfc_level0). The only mandatory field is the first one. The metadata must be filled-in only if the dataset will be loaded in the Tuna atlas database. ;
# wps.in: id = path_to_raw_dataset, type = String, title = Path to the input dataset to harmonize. Input file must be structured as follow: https://goo.gl/KfUXpF, value = "https://goo.gl/KfUXpF";
# wps.in: id = path_to_metadata_file, type = String, title = NULL or path to the csv of metadata. The template file can be found here: https://raw.githubusercontent.com/ptaconet/rtunaatlas_scripts/master/sardara_world/transform_trfmos_data_structure/metadata_source_datasets_to_database/metadata_source_datasets_to_database_template.csv. , value = "NULL";
# wps.out: id = zip_namefile, type = text/zip, title = Dataset with structure harmonized + File of metadata (for integration within the Tuna Atlas database) + File of code lists (for integration within the Tuna Atlas database) ; 

  # Input data sample:
  # yy gear flag fleet alb_mt bet_mt pbf_mt skj_mt yft_mt blm_mt bum_mt mls_mt swo_mt ham_mt mak_mt ocs_mt por_mt fal_mt thr_mt
  # 1950    H   PH            0      0      0      0   1196     32    508      0     19      0      0      0      0      0      0
  # 1950    K   PH            0      0      0   1056   4784      0      0      0      0      0      0      0      0      0      0
  # 1950    L   JP    DW  16713  17463      0      0  12575      0      0      0      0      0      0      0      0      0      0
  # 1950    L   US    HW     27    781      0     34    269      0      0      0      0      0      0      0      0      0      0
  # 1950    O   ID            0      0      0   2645    625      0      0      0      0      0      0      0      0      0      0
  # 1950    O   PH            0      0      0   2782   2314      0      0      0      0      0      0      0      0      0      0
  
  # Catch: final data sample:
  # Flag Gear time_start   time_end AreaName School Species CatchType CatchUnits Catch
  #   AU    L 1985-01-01 1986-01-01    WCPFC    ALL     YFT       ALL         MT     9
  #   AU    L 1986-01-01 1987-01-01    WCPFC    ALL     BET       ALL         MT     1
  #   AU    L 1986-01-01 1987-01-01    WCPFC    ALL     YFT       ALL         MT    13
  #   AU    L 1987-01-01 1988-01-01    WCPFC    ALL     ALB       ALL         MT   129
  #   AU    L 1987-01-01 1988-01-01    WCPFC    ALL     BET       ALL         MT    64
  #   AU    L 1987-01-01 1988-01-01    WCPFC    ALL     BLM       ALL         MT    17

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
if(!require(reshape)){
  install.packages("reshape")
}

require(rtunaatlas)
require(reshape)
require(dplyr)


### Nominal catches

  #NC<-read_excel(path_to_raw_dataset,col_names = TRUE)
 NC<-read.csv(path_to_raw_dataset,stringsAsFactors = F)

# normalize 
NC<-melt(NC, id=c("yy","gear","flag","fleet"))

NC$value<-as.numeric(NC$value)

NC <- NC  %>% 
  filter( ! value %in% 0 ) %>%
  filter( ! is.na(value)) 

NC$variable<-as.character(NC$variable)
NC$variable <- gsub("_mt", "", NC$variable)
NC$variable <- toupper(NC$variable)



colToKeep_NC<-c("yy","flag","gear","variable","value")
NC_harm_WCPFC<-NC[colToKeep_NC]
colnames(NC_harm_WCPFC)<-c("Year", "Flag","Gear","Species","Catch")

NC_harm_WCPFC$AreaName<-"WCPFC"
NC_harm_WCPFC$AreaCWPgrid<-NA
NC_harm_WCPFC$School<-"ALL"
NC_harm_WCPFC$CatchType<-"ALL"
NC_harm_WCPFC$CatchUnits<-"MT"
NC_harm_WCPFC$RFMO<-"WCPFC"
NC_harm_WCPFC$Ocean<-"PAC_W"

NC_harm_WCPFC$MonthStart<-1
NC_harm_WCPFC$Period<-12
#Format inputDataset time to have the time format of the DB, which is one column time_start and one time_end
NC_harm_WCPFC<-format_time_db_format(NC_harm_WCPFC)

NC <- NC_harm_WCPFC  %>% 
  filter( ! Catch %in% 0 )

rm(NC_harm_WCPFC)

NC <-NC[c("Flag","Gear","time_start","time_end","AreaName","School","Species","CatchType","CatchUnits","Catch")]

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
