######################################################################
##### 52North WPS annotations ##########
######################################################################
# wps.des: id = west_pacific_ocean_catch_5deg_1m_tunaatlasWCPFC_level0__driftnet, title = Harmonize data structure of WCPFC Drifnet catch dataset, abstract = Harmonize the structure of WCPFC catch-and-effort dataset: 'Driftnet' (pid of output file = west_pacific_ocean_catch_5deg_1m_tunaatlasWCPFC_level0__driftnet). The only mandatory field is the first one. The metadata must be filled-in only if the dataset will be loaded in the Tuna atlas database. ;
# wps.in: id = path_to_raw_dataset, type = String, title = Path to the input dataset to harmonize. If it is an Excel file, it must be converted to CSV before using this function. Input file must be structured as follow: https://goo.gl/R5EbrB, value = "https://goo.gl/R5EbrB";
# wps.in: id = path_to_metadata_file, type = String, title = NULL or path to the csv of metadata. The template file can be found here: https://raw.githubusercontent.com/ptaconet/rtunaatlas_scripts/master/sardara_world/transform_trfmos_data_structure/metadata_source_datasets_to_database/metadata_source_datasets_to_database_template.csv . If NULL, no metadata will be outputted., value = "NULL";
# wps.out: id = zip_namefile, type = text/zip, title = Dataset with structure harmonized + File of metadata (for integration within the Tuna Atlas database) + File of code lists (for integration within the Tuna Atlas database) ; 

#' This script works with any dataset that has the first 5 columns named and ordered as follow: {YY|MM|LAT5|LON5|DAYS} followed by a list of columns specifing the species codes with "_N" for catches expressed in number and "_T" for catches expressed in tons


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
  
  # Catch: final data sample:
  # Flag Gear time_start   time_end AreaName School Species CatchType CatchUnits    Catch
  #  ALL    D 1983-11-01 1983-12-01  6330165    ALL     ALB       ALL         MT    4.960
  #  ALL    D 1983-11-01 1983-12-01  6330165    ALL     ALB       ALL         NO  886.000
  #  ALL    D 1983-12-01 1984-01-01  6330165    ALL     ALB       ALL         MT    4.872
  #  ALL    D 1983-12-01 1984-01-01  6330165    ALL     ALB       ALL         NO  870.000
  #  ALL    D 1983-12-01 1984-01-01  6335165    ALL     ALB       ALL         MT   21.402
  #  ALL    D 1983-12-01 1984-01-01  6335165    ALL     ALB       ALL         NO 3822.000
  
##Catches
colToKeep_captures <- c("Flag","Gear","time_start","time_end","AreaName","School","Species","CatchType","CatchUnits","Catch")

### Reach the catches pivot DSD using a function stored in WCPFC_functions.R
catches_pivot_WCPFC<-FUN_catches_WCPFC_CE_allButPurseSeine (path_to_raw_dataset)
catches_pivot_WCPFC$Gear<-"D"

# Catchunits
index.kg <- which( catches_pivot_WCPFC[,"CatchUnits"] == "C" )
catches_pivot_WCPFC[index.kg,"CatchUnits"]<- "MT"

index.nr <- which( catches_pivot_WCPFC[,"CatchUnits"] == "N" )
catches_pivot_WCPFC[index.nr,"CatchUnits"]<- "NO" 

# School
catches_pivot_WCPFC$School<-"ALL"

catches<-WCPFC_CE_catches_pivotDSD_to_harmonizedDSD(catches_pivot_WCPFC,colToKeep_captures)

colnames(catches)<-c("flag","gear","time_start","time_end","geographic_identifier","schooltype","species","catchtype","unit","value")
catches$source_authority<-"WCPFC"
dataset<-catches


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

