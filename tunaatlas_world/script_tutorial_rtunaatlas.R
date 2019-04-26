### Tutorial R script to start handling the 'rtunaatlas' package. The 'rtunaatlas' package enables to handle regional and global tuna fisheries datasets.
# Paul Taconet, IRD, 2017-11-25

## Install packages
  if(!require(plotrix)){  # To further deal directly in rtunaatlas package
    install.packages("plotrix")
  } 
  if(!require(devtools)){
    install.packages("devtools")
  }
  require(devtools)
  install_github("ptaconet/rtunaatlas")

  if(!require(dplyr)){
    install.packages("dplyr")
  }
  if(!require(data.table)){
    install.packages("data.table")
  }
  
  require(rtunaatlas)
  require(dplyr)
  require(data.table)
  
## 1) Connect to global tuna fisheries database
  con<-rtunaatlas::db_connection_tunaatlas_world()
  
## 2) List the datasets available in the database (output is a data.frame providing the metadata):
  # 2.1 List all the datasets
  metadata_datasets<-rtunaatlas::list_metadata_datasets(con)
  View(metadata_datasets)
  
  # 2.2 List only the datasets whose source is IOTC
  metadata_datasets_iotc<-rtunaatlas::list_metadata_datasets(con,source_authority=c("IOTC"))
  View(metadata_datasets_iotc)
  

## 3) Extract a dataset from the database (output is a data.frame providing the data):
# To extract a dataset, you may put on the argument "identifier" the name of a dataset (column 'identifier' of the data.frame output of the function list_metadata_datasets)
# Extract the Global catch of tuna, tuna like, etc.. . 
  metadata_global_catch<-rtunaatlas::list_metadata_datasets(con,identifier="global_catch_1950_01_01_2016_01_01_tunaatlasird_level2__2017")
  global_catch_tunaatlasIRD_level2<-rtunaatlas::extract_dataset(con,metadata_global_catch) # (takes time, approx. 2 min in my computer. I suggest to save the file in the computer once extracted, so as to re-use it without having to query Sardara each time this code is ran)
  # To include the labels in the dataset: add argument labels=TRUE in the function extract_dataset
  head(global_catch_tunaatlasIRD_level2)
  # To get more information on this dataset (i.e. metadata): rtunaatlas::list_metadata_datasets(con,identifier="global_catch_1950_01_01_2016_01_01_tunaatlasIRD_level2")
  
## 4) Gear codes used in the dataset might not be explicit. Extract the gear coding system associated to this dataset
  gear_coding_system_metadata<-rtunaatlas::get_codelist_of_dimension(con,
                                                                     metadata_global_catch,
                                                                     dimension_name="gear")
  gear_coding_system<-rtunaatlas::extract_dataset(con,gear_coding_system_metadata)
  
  View(gear_coding_system)
  
## 5) Curate a bit the dataset. The dataset contains a mix of 1° and 5° square resolutions. We re-project all the data on a 5° square grid resolution
 # 5.1 Aggregate data that are defined on quadrants or areas inferior to 5° 
  global_catch_5deg_tunaatlasIRD_level2<-rtunaatlas::spatial_curation_upgrade_resolution(con,global_catch_tunaatlasIRD_level2,5)$df
  
 # 5.2 Disaggregate the data that are defined on quadrant or areas superior to 5° quadrant resolution by dividing the catch equally on the overlappings 5° x 5° quadrants
  global_catch_5deg_tunaatlasIRD_level2<-rtunaatlas::spatial_curation_downgrade_resolution(con,global_catch_5deg_tunaatlasIRD_level2,5)$df
  
## 6) Visualize the data. 

  # 6.1 Pie map of catches of YFT+BET+SKJ by 5° square and by gear between 2010 and 2015
  rtunaatlas::pie_map(con,
                      df_input=global_catch_5deg_tunaatlasIRD_level2 %>% filter (time_start>="2010-01-01" & time_end<="2016-01-01" & unit=="MT" & species %in% c("YFT","BET","SKJ")),
                      dimension_group_by="gear",
                      df_spatial_code_list_name="areas_tuna_rfmos_task2",
                      number_of_classes=4 
                      )
    
  # 6.2 Pie map of catches of YFT+BET+SKJ by 5° square and by species between 2010 and 2015
  rtunaatlas::pie_map(con,
                      df_input=global_catch_5deg_tunaatlasIRD_level2 %>% filter (time_start>="2010-01-01" & time_end<="2016-01-01" & unit=="MT" & species %in% c("YFT","BET","SKJ")),
                      dimension_group_by="species",
                      df_spatial_code_list_name="areas_tuna_rfmos_task2",
                      number_of_classes=4
                      )
  
  
  # 6.3 Yearly evolution of the catches of YFT+BET+SKJ by purse seiners by fishing mode
  rtunaatlas::time_series_plot(
           df_input=global_catch_tunaatlasIRD_level2 %>% filter ( gear=="01.1" & unit=="MT" & species %in% c("YFT","BET","SKJ")),
           time_resolution="year",
           dimension_group_by="schooltype",
           number_of_classes=5
          )
     
  
  
  
## Other functions available in the package: 
  # - convert units of dataset (e.g. number of fishes harvested to weight) using your own conversion factors: help(convert_units),
  # - intersect a spatial dataset with spatial layers e.g. EEZs: help(spatial_curation_intersect_areas), 
  # - raise catch-and-efforts to nominal catch: help(raise_incomplete_dataset_to_total_dataset), 
  # - etc...
