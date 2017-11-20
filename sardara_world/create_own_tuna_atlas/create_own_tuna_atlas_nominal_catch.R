######################################################################
##### 52North WPS annotations ##########
######################################################################
# wps.des: id = create_own_tuna_atlas_nominal_catch, title = Create your own georeferenced nominal catch Tuna Atlas dataset, abstract = This algorithm allows to create own regional or global tuna altas. It takes as input the public domain datasets of the five Tuna Regional Fisheries Management Organizations (tRFMOs) (IOTC|ICCAT|WCPFC|IATTC|CCSBT) stored within the Sardara database. It proposes a set of parameters to customize the computation of the tuna atlas. ;
# wps.in: id = include_IOTC, type = boolean, title = Include IOTC data (Indian Ocean) in the atlas (TRUE or FALSE), value = TRUE;
# wps.in: id = include_ICCAT, type = boolean, title = Include ICCAT data (Atlantic Ocean) in the tuna atlas?, value = TRUE;
# wps.in: id = include_IATTC, type = boolean, title = Include IATTC data (Eastern Pacific Ocean) in the tuna atlas?, value = TRUE;
# wps.in: id = include_WCPFC, type = boolean, title = Include WCPFC data (Western Pacific Ocean) in the tuna atlas?, value = TRUE;
# wps.in: id = include_CCSBT, type = boolean, title = Include CCSBT data (Southern hemisphere Oceans - only Southern Bluefin Tuna) in the atlas?, value = TRUE;
# wps.in: id = datasets_year_release, type = integer, title = Year of release of the datasets by the tRFMOs. First available year is 2017. Usually, datasets released in the year Y contain the time series from the beginning of the fisheries (e.g. 1950) to year Y-2 (included). For instance 2017 will extract the datasets released in 2017 and that cover the time series from 1950 to 2015 (included), value = 2017;
# wps.in: id = iccat_nominal_catch_spatial_stratification, type = string, title = Concerns ICCAT Nominal catch data. Use only if parameter include_ICCAT is set to TRUE. ICCAT nominal catch datasets can be spatially stratified either by sampling areas or by stock areas. Which spatial stratification to select for the output dataset? sampling_area or stock_area. ,value = "NULL|sampling_area|stock_area"
# wps.in: id = mapping_map_code_lists, type = boolean, title = Map code lists (gears, species, flags, schooltypes, catchtype)? When using multiple sources of data (i.e. multiple RFMOS), code lists used by the various tRFMOs might be different. They should therefore be mapped to single code lists in order to be able to compare the data. TRUE : map code lists. The url to the datasets providing the code list mappings to use must be set in the parameter mapping_source_mappings. See parameter mapping_source_mappings for more details. FALSE : do not map code lists. Output data will use input codes., value = TRUE ;
# wps.in: id = mapping_csv_mapping_datasets_url, type = string, title = Use only if parameter mapping_map_code_lists is set to TRUE. Path to the CSV file containing the dimensions that must be mapped and the name of the mapping dataset for each dimension mapped. The mapping datasets must be available in Sardara database. An example of this CSV can be found here: https://goo.gl/2hA1sq. , value="NULL" ;
# wps.in: id = mapping_keep_src_code, type = boolean, title = Use only if parameter mapping_map_code_lists is set to TRUE. In case of code list mapping (mapping_map_code_lists==TRUE) keep source coding system column? TRUE : conserve in the output dataset both source and target coding systems columns. FALSE : conserve only target coding system. , value=FALSE ;
# wps.in: id = overlapping_zone_iattc_wcpfc_data_to_keep, type = string, title = Concerns IATTC and WCPFC data. IATTC and WCPFC have an overlapping area in their respective area of competence. Which data should be kept for this zone? IATTC : keep data from IATTC. WCPFC : keep data from WCPFC. NULL : Keep data from both tRFMOs. Caution: with the option NULL, data in the overlapping zone are likely to be redundant., value = "IATTC|WCPFC|NULL";
# wps.in: id = SBF_data_rfmo_to_keep, type = string, title = Concerns Southern Bluefin Tuna (SBF) data. Use only if parameter include_CCSBT is set to TRUE. SBF tuna data do exist in both CCSBT data and the other tuna RFMOs data. Wich data should be kept? CCSBT : CCSBT data are kept for SBF. other_trfmos : data from the other TRFMOs are kept for SBF. NULL : Keep data from all the tRFMOs. Caution: with the option NULL, data in the overlapping zones are likely to be redundant., value = "CCSBT|other_trfmos|NULL";
# wps.out: id = zip_namefile, type = text/zip, title = Outputs are 3 csv files: the dataset of georeferenced catches + a dataset of metadata (including informations on the computation, i.e. how the primary datasets were transformed by each correction) [TO DO] + a dataset providing the code lists used for each dimension (column) of the output dataset [TO DO]. All outputs and codes are compressed within a single zip file. ; 

### Utile uniquement pour le tuna atlas Nominal catch   wps.in: id = iccat_nominal_catch_spatial_stratification, type = string, title = Concerns ICCAT Nominal catch data. Use only if parameter include_ICCAT is set to TRUE. ICCAT nominal catch datasets can be spatially stratified either by sampling areas or by stock areas. Which spatial stratification to choose? sampling_area or stock_area. ,value = "NULL|sampling_area|stock_area"


# Library rtunaatlas containing useful functions for this script
require(rtunaatlas)
require(dplyr)
require(data.table)
url_scripts_create_own_tuna_atlas<-"https://raw.githubusercontent.com/ptaconet/rtunaatlas_scripts/master/sardara_world/create_own_tuna_atlas/sourced_scripts/"

# connect to Sardara DB
con<-rtunaatlas::db_connection_sardara_world()

#### 1) Retrieve tuna RFMOs data from Sardara DB at level 0. Level 0 is the merging of the tRFMOs primary datasets, with the more complete possible value of georef_dataset per stratum (i.e. duplicated or splitted strata among the datasets are dealt specifically -> this is the case for ICCAT and IATTC)  ####
cat("Begin: Retrieving primary datasets from Sardara DB... \n")
  source(paste0(url_scripts_create_own_tuna_atlas,"retrieve_nominal_catch.R"))
cat("Retrieving primary datasets from Sardara DB OK\n")


#### 2) Map code lists 

if (mapping_map_code_lists==TRUE){
  source(paste0(url_scripts_create_own_tuna_atlas,"map_code_lists.R"))
  cat("Mapping code lists of nominal georef_dataset datasets...\n")
  nominal_catch<-function_map_dataset_codelists(nominal_catch,mapping_dataset,mapping_keep_src_code)
  cat("Mapping code lists of nominal georef_dataset datasets OK\n")
  }


#### 8) Overlapping zone (IATTC/WCPFC): keep data from IATTC or WCPFC?

if (overlapping_zone_iattc_wcpfc_data_to_keep!="NULL"){
  df<-nominal_catch
  source(paste0(url_scripts_create_own_tuna_atlas,"overlapping_zone_iattc_wcpfc_data_to_keep.R"))
  nominal_catch<-df
  rm(df)
}



#### 9) Southern Bluefin Tuna (SBF): SBF data: keep data from CCSBT or data from the other tuna RFMOs?

if (SBF_data_rfmo_to_keep!="NULL"){
  df<-nominal_catch
  source(paste0(url_scripts_create_own_tuna_atlas,"SBF_data_rfmo_to_keep.R"))
  nominal_catch<-df
  rm(df)
}



output_dataset<-nominal_catch %>% group_by_(.dots = setdiff(colnames(nominal_catch),"value")) %>% summarize(value=sum(value))

dbDisconnect(con)

#### END
cat("End: Your tuna atlas georef_dataset dataset has been created! \n")

