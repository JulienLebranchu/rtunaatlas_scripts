######################################################################
##### 52North WPS annotations ##########
######################################################################
# wps.des: id = east_pacific_ocean_catch_1deg_1m_ps_tunaatlasiattc_level0__byFlag, title = Harmonize data structure of IATTC ByFlag effort datasets, abstract = Harmonize the structure of IATTC catch-and-effort datasets: 'PublicPSBillfishFlag' and 'PublicPSTunaFlag' and 'PublicPSSharkFlag' (pid of output file = east_pacific_ocean_catch_1deg_1m_ps_tunaatlasIATTC_level0__billfish_byFlag or east_pacific_ocean_catch_1deg_1m_ps_tunaatlasIATTC_level0__shark_byFlag or east_pacific_ocean_catch_1deg_1m_ps_tunaatlasIATTC_level0__tuna_byFlag). The only mandatory field is the first one. The metadata must be filled-in only if the dataset will be loaded in the Tuna atlas database. ;
# wps.in: id = path_to_raw_dataset, type = String, title = Path to the input dataset to harmonize. Input file must be structured as follow: https://goo.gl/Q1w7Ur, value = "https://goo.gl/Q1w7Ur";
# wps.in: id = path_to_metadata_file, type = String, title = NULL or path to the csv of metadata. The template file can be found here: https://raw.githubusercontent.com/ptaconet/rtunaatlas_scripts/master/sardara_world/transform_trfmos_data_structure/metadata_source_datasets_to_database/metadata_source_datasets_to_database_template.csv . If NULL, no metadata will be outputted., value = "NULL";
# wps.out: id = zip_namefile, type = text/zip, title = Dataset with structure harmonized + File of metadata (for integration within the Tuna Atlas database) + File of code lists (for integration within the Tuna Atlas database) ; 



# '# This script works with any data that has the first 5 columns named and ordered as follow: {Year|Month|Flag|LatC1|LonC1|NumSets}


if(!require(rtunaatlas)){
  if(!require(devtools)){
    install.packages("devtools")
  }
  require(devtools)
  install_github("ptaconet/rtunaatlas")
}
require(rtunaatlas)

  ##Catches
  
  catches_pivot_IATTC <-FUN_catches_IATTC_CE_Flag_or_SetType(path_to_raw_dataset,"Flag","PS")
  catches_pivot_IATTC$NumSets<-NULL
  
  colToKeep_captures <- c("Flag","Gear","time_start","time_end","AreaName","School","Species","CatchType","CatchUnits","Catch")
  catches<-IATTC_CE_catches_pivotDSD_to_harmonizedDSD(catches_pivot_IATTC,colToKeep_captures)
  
  colnames(catches)<-c("flag","gear","time_start","time_end","area","schooltype","species","catchtype","unit","value")
  
  dataset<-catches
  
  
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
  
  