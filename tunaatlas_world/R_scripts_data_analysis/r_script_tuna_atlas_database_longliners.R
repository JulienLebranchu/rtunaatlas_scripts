## R script to extract the global effort in number of hooks and the global catch in number of specimens of tuna longliners aggregated by 5° squares

# @author: Paul Taconet, IRD (French National Research Institute for Sustainable Development), paul.taconet@ird.fr
# @date: 2018-03-08
# More info: https://bluebridge.d4science.org/group/fao_tunaatlas/global-tuna-atlas

## 1) Install packages

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


## 2) Connect to the open global Tuna atlas database
con<-rtunaatlas::db_connection_tunaatlas_world()

## 3) Extract from the database the following dataset: Global monthly fishing effort targeting tuna and tuna-like species (1950-2016) aggregated by statistical squares of 5° longitude and latitude (IRD level 0)
# 3.1 Extract the metadata of the dataset. The output is a table containing a set of metadata (including title, description, contacts, information on how the dataset was generated, etc.)
metadata_global_effort<-rtunaatlas::list_metadata_datasets(con,identifier="global_effort_5deg_1m_1950_01_01_2016_01_01_tunaatlasird_level0__2017")
View(metadata_global_effort)

# 3.2 Extract the dataset as R data.frame (takes approx. 4 minutes)
global_effort_df<-rtunaatlas::extract_dataset(con,metadata_global_effort)  # To get also the labels, add argument  labels=TRUE
head(global_effort_df)

# Get the code list for gears used in the dataset
gear_coding_system_metadata<-rtunaatlas::get_codelist_of_dimension(con,metadata_global_effort,dimension_name="gear")
gear_coding_system<-rtunaatlas::extract_dataset(con,gear_coding_system_metadata)
View(gear_coding_system)

# 3.3 Filter the dataset to keep only Longline data expressed in number of HOOKS
global_effort_df_ll<-global_effort_df %>% filter(gear_group=="LL",unit=="HOOKS")

## 4) Extract from the database the following dataset: Global monthly catch of tuna and tuna-like species (1950-2016) aggregated by statistical squares of 5° longitude and latitude (IRD level 0)
# 4.1 Extract the metadata
metadata_global_catch<-rtunaatlas::list_metadata_datasets(con,identifier="global_catch_5deg_1m_1950_01_01_2016_01_01_tunaatlasird_level0__2017")
# 4.2 Extract the dataset as R data.frame (takes approx. 2 minutes)
global_catch_df<-rtunaatlas::extract_dataset(con,metadata_global_catch)  # To get also the labels, add argument  labels=TRUE

# Get the code list for units used in the dataset
unit_coding_system_metadata<-rtunaatlas::get_codelist_of_dimension(con,metadata_global_catch,dimension_name="unit")
unit_coding_system<-rtunaatlas::extract_dataset(con,unit_coding_system_metadata)
View(unit_coding_system)

# 4.3 Filter the dataset to keep only Longline data expressed in number
global_catch_df_ll<-global_catch_df %>% filter(gear_group=="LL",unit %in% c("NO","NOMT"))
global_catch_df_ll$unit<-"NO"
                                               
                                               
## 5) Visualize the data. Ensure the plot window is wide enough before executing the functions.

# 5.1 Pie map of global catch of longliners expressed in number of speciments by 5° square and by species between 2010 and 2015
rtunaatlas::pie_map(con,
                    df_input=global_catch_df_ll %>% filter (time_start>="2010-01-01" & time_end<="2016-01-01"),
                    dimension_group_by="species",
                    df_spatial_code_list_name="areas_tuna_rfmos_task2",
                    number_of_classes=4 
)

# 5.2 Pie map of global effort of longliners expressed in number of hooks by 5° square and by fishing country between 2010 and 2015
rtunaatlas::pie_map(con,
                    df_input=global_effort_df_ll %>% filter (time_start>="2010-01-01" & time_end<="2016-01-01"),
                    dimension_group_by="flag",
                    df_spatial_code_list_name="areas_tuna_rfmos_task2",
                    number_of_classes=4 
)


# 5.3 Yearly evolution of the global effort of longliners expressed in number of hooks by 5° square and by fishing country
rtunaatlas::time_series_plot(
  df_input=global_effort_df_ll,
  time_resolution="year",
  dimension_group_by="flag",
  number_of_classes=5
)                                          
