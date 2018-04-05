######################################################################
##### 52North WPS annotations ##########
######################################################################
# wps.des: id = create_own_tuna_atlas_nominal_catch, title = Create your own georeferenced nominal catch Tuna Atlas dataset, abstract = This algorithm allows to create own regional or global tuna altas. It takes as input the public domain datasets of the five Tuna Regional Fisheries Management Organizations (tRFMOs) (IOTC|ICCAT|WCPFC|IATTC|CCSBT) stored within the Sardara database. It proposes a set of parameters to customize the computation of the tuna atlas. ;
# wps.in: id = include_IOTC, type = string, title = Include IOTC data (Indian Ocean) in the atlas (TRUE or FALSE), value = TRUE;
# wps.in: id = include_ICCAT, type = string, title = Include ICCAT data (Atlantic Ocean) in the tuna atlas?, value = TRUE;
# wps.in: id = include_IATTC, type = string, title = Include IATTC data (Eastern Pacific Ocean) in the tuna atlas?, value = TRUE;
# wps.in: id = include_WCPFC, type = string, title = Include WCPFC data (Western Pacific Ocean) in the tuna atlas?, value = TRUE;
# wps.in: id = include_CCSBT, type = string, title = Include CCSBT data (Southern hemisphere Oceans - only Southern Bluefin Tuna) in the atlas?, value = TRUE;
# wps.in: id = datasets_year_release, type = string, title = Year of release of the datasets by the tRFMOs. First available year is 2017. Usually, datasets released in the year Y contain the time series from the beginning of the fisheries (e.g. 1950) to year Y-2 (included). For instance 2017 will extract the datasets released in 2017 and that cover the time series from 1950 to 2015 (included), value = 2017;
# wps.in: id = iccat_nominal_catch_spatial_stratification, type = string, title = Concerns ICCAT Nominal catch data. Use only if parameter include_ICCAT is set to TRUE. ICCAT nominal catch datasets can be spatially stratified either by sampling areas or by stock areas. Which spatial stratification to select for the output dataset? sampling_area or stock_area. ,value = "sampling_area|stock_area"
# wps.in: id = mapping_map_code_lists, type = string, title = Map code lists (gears, species, flags, schooltypes, catchtype)? When using multiple sources of data (i.e. multiple RFMOS), code lists used by the various tRFMOs might be different. They should therefore be mapped to single code lists in order to be able to compare the data. TRUE : map code lists. The url to the datasets providing the code list mappings to use must be set in the parameter mapping_source_mappings. See parameter mapping_source_mappings for more details. FALSE : do not map code lists. Output data will use input codes., value = "TRUE" ;
# wps.in: id = mapping_csv_mapping_datasets_url, type = string, title = Use only if parameter mapping_map_code_lists is set to TRUE. Path to the CSV file containing the dimensions that must be mapped and the name of the mapping dataset for each dimension mapped. The mapping datasets must be available in Sardara database. An example of this CSV can be found here: https://goo.gl/2hA1sq. , value="http://data.d4science.org/ZWFMa3JJUHBXWk9NTXVPdFZhbU5BUFEyQnhUeWd1d3lHbWJQNStIS0N6Yz0" ;
# wps.in: id = mapping_keep_src_code, type = string, title = Use only if parameter mapping_map_code_lists is set to TRUE. In case of code list mapping (mapping_map_code_lists==TRUE) keep source coding system column? TRUE : conserve in the output dataset both source and target coding systems columns. FALSE : conserve only target coding system. , value= "FALSE" ;
# wps.in: id = SBF_data_rfmo_to_keep, type = string, title = Concerns Southern Bluefin Tuna (SBF) data. Use only if parameter include_CCSBT is set to TRUE. SBF tuna data do exist in both CCSBT data and the other tuna RFMOs data. Wich data should be kept? CCSBT : CCSBT data are kept for SBF. other_trfmos : data from the other TRFMOs are kept for SBF. NULL : Keep data from all the tRFMOs. Caution: with the option NULL, data in the overlapping zones are likely to be redundant., value = "CCSBT|other_trfmos|NULL";
# wps.out: id = zip_namefile, type = text/zip, title = Outputs are 3 csv files: the dataset of georeferenced catches + a dataset of metadata (including informations on the computation, i.e. how the primary datasets were transformed by each correction) [TO DO] + a dataset providing the code lists used for each dimension (column) of the output dataset [TO DO]. All outputs and codes are compressed within a single zip file. ; 


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

if(!require(data.table)){
  install.packages("data.table")
}

require(rtunaatlas)
require(dplyr)
require(data.table)


url_scripts_create_own_tuna_atlas<-"https://raw.githubusercontent.com/ptaconet/rtunaatlas_scripts/master/tunaatlas_world/create_own_tuna_atlas/sourced_scripts/"

# connect to Sardara DB
con<-rtunaatlas::db_connection_tunaatlas_world()

# initialize metadata elements
metadata<-NULL
metadata$contact_originator<-NULL
metadata$lineage<-NULL
metadata$description<-"The main processes applied to the primary datasets to generate this dataset are the followings:\n"
metadata$supplemental_information<-NULL

datasets_year_release<-as.numeric(datasets_year_release)

#### 1) Retrieve tuna RFMOs data from Sardara DB at level 0. 
cat("Begin: Retrieving primary datasets from Sardara DB... \n")
  source(paste0(url_scripts_create_own_tuna_atlas,"retrieve_nominal_catch.R"))
cat("Retrieving primary datasets from Sardara DB OK\n")

metadata$description<-paste0(metadata$description,"- The primary nominal (also called total) catch datasets released by the tuna RFMOs were merged.\n")
metadata$lineage<-c(metadata$lineage,"All the datasets were merged")


#### 2) Map code lists 

if (mapping_map_code_lists=="TRUE"){
  source(paste0(url_scripts_create_own_tuna_atlas,"map_code_lists.R"))
  cat("Mapping code lists...\n")
  nominal_catch<-function_map_code_lists("catch",mapping_csv_mapping_datasets_url,nominal_catch,mapping_keep_src_code)
  metadata$description<-paste0(metadata$description,nominal_catch$description)
  metadata$lineage<-c(metadata$lineage,nominal_catch$lineage)
  metadata$supplemental_information<-paste0(metadata$supplemental_information,nominal_catch$supplemental_information)
  nominal_catch<-nominal_catch$dataset
  cat("Mapping code lists OK\n")
  }


#### 9) Southern Bluefin Tuna (SBF): SBF data: keep data from CCSBT or data from the other tuna RFMOs?

if (!is.null(SBF_data_rfmo_to_keep)){
  source(paste0(url_scripts_create_own_tuna_atlas,"SBF_data_rfmo_to_keep.R"))
  nominal_catch<-function_SBF_data_rfmo_to_keep(SBF_data_rfmo_to_keep,nominal_catch)
  metadata$description<-paste0(metadata$description,nominal_catch$description)
  metadata$lineage<-c(metadata$lineage,nominal_catch$lineage)
  nominal_catch<-nominal_catch$dataset
  
}


dataset<-nominal_catch %>% group_by_(.dots = setdiff(colnames(nominal_catch),"value")) %>% dplyr::summarise(value=sum(value))
dataset<-data.frame(dataset)

dbDisconnect(con)


## fill some metadata elements
metadata$supplemental_information<-paste0(metadata$supplemental_information,"- Catches in the Pacific ocean are over-estimated. In fact, IATTC and WCPFC, who report the data for the Eastern Pacific and Western-Central Pacific ocean, respectively, have an overlapping area in their respective area of competence. Data from both RFMOs may be redundant in this overlapping zone.
- Geographical stratification in this dataset is: major FAO fishing area for the Indian ocean (IOTC), ",iccat_nominal_catch_spatial_stratification," for the Atlantic ocean (ICCAT), whole areas of competence of the respective RFMOs for the Pacific ocean (IATTC and WCPFC), area of competence of the CCSBT for the Southern Bluefin tuna.")
metadata$description<-paste0(metadata$description,"\n More details on the processes are provided in the supplemental information and in the lineage section.")
metadata$contact_originator<-unique(strsplit(metadata$contact_originator, ";")[[1]])
metadata$contact_originator<-paste(metadata$contact_originator,collapse = ";")
metadata$lineage<-unique(metadata$lineage)
lineage_metadata_format<-NULL
for (i in 1:length(metadata$lineage)){
  lineage_metadata_format<-paste0(lineage_metadata_format,"step",i,": ",metadata$lineage[i],"\n")
}
metadata$lineage<-lineage_metadata_format


## Retrieve the code lists to use for integration within the Tuna Atlas DB (input parameter of the function to load datasets)
fact<-"nominal_catch"
if (include_IOTC=="TRUE"){
  rfmo="IOTC"
}
if (include_ICCAT=="TRUE"){
  rfmo="ICCAT"
  fact<-paste(fact,iccat_nominal_catch_spatial_stratification,sep="_")
}
if (include_IATTC=="TRUE"){
  rfmo="IATTC"
}
if (include_WCPFC=="TRUE"){
  rfmo="WCPFC"
}
if (include_CCSBT=="TRUE"){
  rfmo="CCSBT"
}
if (mapping_map_code_lists=="TRUE" && mapping_csv_mapping_datasets_url=="http://data.d4science.org/ZWFMa3JJUHBXWk9NTXVPdFZhbU5BUFEyQnhUeWd1d3lHbWJQNStIS0N6Yz0"){
  rfmo="global"
  fact<-"nominal_catch"
}

table_urls_code_lists_to_use_to_load_datasets<-read.csv("https://raw.githubusercontent.com/ptaconet/rtunaatlas_scripts/master/tunaatlas_world/create_own_tuna_atlas/sourced_scripts/table_urls_code_lists_to_use_to_load_datasets.csv",stringsAsFactors = F)
path_csv_codelists <- table_urls_code_lists_to_use_to_load_datasets$url_df_codelist[which(table_urls_code_lists_to_use_to_load_datasets$rfmo==rfmo & table_urls_code_lists_to_use_to_load_datasets$fact==fact)]

df_codelists <- data.frame(lapply(read.csv(path_csv_codelists), as.character), stringsAsFactors=FALSE)
additional_metadata<-metadata


#### END
cat("End: Your tuna atlas dataset has been created! Your output data.frame is called 'output_dataset' \n")

