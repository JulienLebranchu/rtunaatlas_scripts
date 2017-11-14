######################################################################
##### 52North WPS annotations ##########
######################################################################
# wps.des: id = create_own_tuna_atlas_catch, title = Create your own georeferenced catch Tuna Atlas dataset, abstract = This algorithm allows to create own regional or global tuna altas. It takes as input the public domain datasets of the five Tuna Regional Fisheries Management Organizations (tRFMOs) (IOTC|ICCAT|WCPFC|IATTC|CCSBT) stored within the Sardara database. It proposes a set of parameters to customize the computation of the tuna atlas. ;
# wps.in: id = tuna_atlas_variable, type = string, title = Variable to extract: catch, effort, nominal catch or catch_at_size. For the time being, only catch and nominal catch work., value = "catch|effort|nominal_catch";
# wps.in: id = include_IOTC, type = boolean, title = Include IOTC data (Indian Ocean) in the atlas (TRUE or FALSE), value = TRUE;
# wps.in: id = include_ICCAT, type = boolean, title = Include ICCAT data (Atlantic Ocean) in the tuna atlas?, value = TRUE;
# wps.in: id = include_IATTC, type = boolean, title = Include IATTC data (Eastern Pacific Ocean) in the tuna atlas?, value = TRUE;
# wps.in: id = include_WCPFC, type = boolean, title = Include WCPFC data (Western Pacific Ocean) in the tuna atlas?, value = TRUE;
# wps.in: id = include_CCSBT, type = boolean, title = Include CCSBT data (Southern hemisphere Oceans - only Southern Bluefin Tuna) in the atlas?, value = TRUE;
# wps.in: id = datasets_year_release, type = integer, title = Year of release of the datasets by the tRFMOs. First available year is 2017. Usually, datasets released in the year Y contain the time series from the beginning of the fisheries (e.g. 1950) to year Y-2 (included). For instance 2017 will extract the datasets released in 2017 and that cover the time series from 1950 to 2015 (included), value = 2017;
# wps.in: id = iccat_include_type_of_school, type = boolean, title = Concerns ICCAT Purse Seine data. Use only if parameter include_ICCAT is set to TRUE. ICCAT disseminates two catch-and-efforts datasets: one that provides the detail of the type of school (Fad|Free school) for purse seine fisheries only and that starts in 1994 (called Task II catch|effort by operation mode Fad|Free school) and one that does not provide the information of the type of school and that covers all the time period (from 1950) (called Task II catch|effort). These data are redundant (i.e. the data from the dataset Task II catch|effort by operation mode are also available in the dataset Task II catch|effort but in the latter the information on the type of school is not available). Combine both datasets to produce a dataset with fishing mode information (Fad | Free school)? TRUE : both datasets will be combined to produce a dataset with fishing mode information (Fad | free school). FALSE : Only the dataset without the type of school will be used. In that case the output dataset will not have the information on the fishing mode for ICCAT., value = TRUE;
# wps.in: id = iattc_raise_flags_to_schooltype, type = boolean, title = Concerns IATTC Purse Seine data. Use only if parameter include_IATTC is set to TRUE. For confidentiality policies, information on fishing country (flag) and type of school for the geo-referenced catches is available in separate files for the Eastern Pacific Ocean purse seine datasets. IATTC hence provides two public domain dataset: one with the information on the type of school and one with the information on the flag. Both datasets can be combined - using raising methods - to estimate the catches by both flag and type of school for purse seine fisheries. Combine both datasets? TRUE : both datasets (by fishing mode and by flag) will be combined - using raising methods i.e. dataset with the information on the flag will be raised to the dataset with the information on the type of school - to have the detail on both fishing mode and flag for each stratum. FALSE : Only one dataset will be used (either Flag or Type of school). The parameter dimension_to_use_if_no_raising_flags_to_schooltype allows to decide which dataset to use., value = TRUE;
# wps.in: id = iattc_dimension_to_use_if_no_raising_flags_to_schooltype, type = string, title = Concerns IATTC Purse Seine data. Use only if parameter iattc_raise_flags_to_schooltype is set to FALSE. In the case IATTC purse seine datasets are not combined (see description of parameter iattc_raise_flags_to_schooltype) which dataset to use? flag : use dataset with the information on flag. Information on type of school will therefore not be available. schooltype : use dataset with the information on type of school. Information on flag will therefore not be available., value = "flag|schooltype";
# wps.in: id = mapping_map_code_lists, type = boolean, title = Map code lists (gears, species, flags, schooltypes, catchtype)? When using multiple sources of data (i.e. multiple RFMOS), code lists used by the various tRFMOs might be different. They should therefore be mapped to single code lists in order to be able to compare the data. TRUE : map code lists. The url to the datasets providing the code list mappings to use must be set in the parameter mapping_source_mappings. See parameter mapping_source_mappings for more details. FALSE : do not map code lists. Output data will use input codes., value = TRUE ;
# wps.in: id = mapping_csv_mapping_datasets_url, type = string, title = Use only if parameter mapping_map_code_lists is set to TRUE. Path to the CSV file containing the dimensions that must be mapped and the name of the mapping dataset for each dimension mapped. The mapping datasets must be available in Sardara database. An example of this CSV can be found here: https://goo.gl/2hA1sq. , value="NULL" ;
# wps.in: id = mapping_keep_src_code, type = boolean, title = In case of code list mapping (mapping_map_code_lists==TRUE) keep source coding system column? TRUE : conserve in the output dataset both source and target coding systems columns. FALSE : conserve only target coding system (i.e. mapped). , value=FALSE ;
# wps.in: id = gear_filter, type = Filter data by gear. Gear codes in this parameter must by the same as the ones used in the catch dataset (i.e. raw tRFMOs gear codes if no mapping or in case of mapping (mapping_map_code_lists=TRUE) codes used in the mapping code list). NULL : do not filter. If you want to filter, you must write the codes to filter by, separated by a comma in case of multiple codes.  , value = "NULL"
# wps.in: id = unit_conversion_convert, type = boolean, title = Convert units of fact? if TRUE you must fill-in the parameter unit_conversion_df_conversion_factor, value = FALSE;
# wps.in: id = unit_conversion_csv_conversion_factor_url, type = string, title = Use only if parameter unit_conversion_convert is set to TRUE. If units are converted, path to the csv containing the conversion factors dataset. The conversion factor dataset must be properly structured. The coding systems used in the dimensions of the conversion factors must be the same as the ones used in the catch dataset (i.e. raw tRFMOs codes or in case of mapping (mapping_map_code_lists=TRUE) codes used in the mapping code lists) except for spatial code list. Additional information on the structure are provided here: https://ptaconet.github.io/rtunaatlas//reference/convert_units.html , value = "NULL"
# wps.in: id = unit_conversion_codelist_geoidentifiers_conversion_factors, type = string, title = Use only if parameter unit_conversion_convert is set to TRUE. If units are converted, name of the coding system of the spatial dimension used in the conversion factor dataset (i.e. table name in Sardara database) or NULL if same spatial coding system as the one used in the dataset with units to convert. Additional information on the structure to respect are provided here: https://ptaconet.github.io/rtunaatlas//reference/convert_units.html (section Details), value = "NULL"
# wps.in: id = raising_georef_to_nominal, type = boolean, title =  Raise georeferenced catches to nominal catches? Depending on the availability of the flag dimension (currently not available for the geo-referenced catch-and-effort dataset from the WCPFC and CCSBT) the dimensions used for the raising are either {Flag|Species|Year|Gear} or {Species|Year|Gear}. Some catches cannot be raised because the combination {Flag|Species|Year|Gear} (resp. {Species|Year|Gear}) does exist in the geo-referenced catches but the same combination does not exist in the total catches. In this case non-raised catch data are kept. TRUE : Raise georeferenced catches to total catches. FALSE : Do not raise., value = TRUE;
# wps.in: id = aggregate_on_5deg_data_with_resolution_inferior_to_5deg, type = boolean, title =  Aggregate data that are defined on quadrants or areas inferior to 5° quadrant resolution to corresponding 5° quadrant? TRUE : Aggregate. Data that are provided at spatial resolutions superior to 5° x 5°  will be aggregated to the corresponding 5° quadrant. FALSE : Do not aggregate. Data that are provided at spatial resolutions superior to 5° x 5° will be will be kept as so. , value = FALSE;
# wps.in: id = disaggregate_on_5deg_data_with_resolution_superior_to_5deg, type = boolean, title = Disaggregate data that are defined on quadrants or areas superior to 5° quadrant resolution to 5° quadrant? TRUE : Disaggregate. Data that are provided at spatial resolutions superior to 5° x 5°  will be disaggregated to the corresponding 5°  x 5°  quadrants by dividing the catch equally on the overlappings 5° x 5°  quadrants. FALSE : Do not disaggregrate. Data that are provided at spatial resolutions inferior to 5° x 5° will be kept as so., value = FALSE;
# wps.in: id = disaggregate_on_1deg_data_with_resolution_superior_to_1deg, type = boolean, title = Same as parameter disaggregate_on_5deg_data_with_resolution_superior_to_5deg but for 1° resolutions  , value = FALSE;
# wps.in: id = spatial_curation_data_mislocated, type = string, title = Some data might be mislocated: either located on land areas or without any area information. This parameter allows to control what to do with these data. reallocate : Reallocate the mislocated data (equally distributed on areas with same dimensions (month|gear|flag|species|schooltype). no_reallocation : do not reallocate mislocated data. The output dataset will keep these data with their original location (eg on land or with no area information). remove : remove the mislocated data., value = "reallocate|no_reallocation|remove";
# wps.in: id = overlapping_zone_iattc_wcpfc_data_to_keep, type = string, title = Concerns IATTC and WCPFC data. IATTC and WCPFC have an overlapping area in their respective area of competence. Which data should be kept for this zone? IATTC : keep data from IATTC. WCPFC : keep data from WCPFC. NULL : Keep data from both tRFMOs. Caution: with the option NULL, data in the overlapping zone are likely to be redundant., value = "IATTC|WCPFC|NULL";
# wps.in: id = SBF_data_rfmo_to_keep, type = string, title = Concerns Southern Bluefin Tuna (SBF) data. Use only if parameter include_CCSBT is set to TRUE. SBF tuna data do exist in both CCSBT data and the other tuna RFMOs data. Wich data should be kept? CCSBT : CCSBT data are kept for SBF. other_trfmos : data from the other TRFMOs are kept for SBF. NULL : Keep data from all the tRFMOs. Caution: with the option NULL, data in the overlapping zones are likely to be redundant., value = "CCSBT|other_trfmos|NULL";
# wps.out: id = zip_namefile, type = text/zip, title = Outputs are 3 csv files: the dataset of georeferenced catches + a dataset of metadata (including informations on the computation, i.e. how the primary datasets were transformed by each correction) [TO DO] + a dataset providing the code lists used for each dimension (column) of the output dataset [TO DO]. All outputs and codes are compressed within a single zip file. ; 

### Utile uniquement pour le tuna atlas Nominal catch   wps.in: id = iccat_nominal_catch_spatial_stratification, type = string, title = Concerns ICCAT Nominal catch data. Use only if parameter include_ICCAT is set to TRUE. ICCAT nominal catch datasets can be spatially stratified either by sampling areas or by stock areas. Which spatial stratification to choose? sampling_area or stock_area. ,value = "NULL|sampling_area|stock_area"


# Library rtunaatlas containing useful functions for this script
require(rtunaatlas)
require(dplyr)
require(data.table)
url_scripts_create_own_tuna_atlas_catch<-"https://raw.githubusercontent.com/ptaconet/rtunaatlas_scripts/master/sardara_world/create_own_tuna_atlas/"

# connect to Sardara DB
con<-rtunaatlas::db_connection_sardara_world()

#### 1) Retrieve tuna RFMOs data from Sardara DB at level 0. Level 0 is the merging of the tRFMOs primary datasets, with the more complete possible value of georef_dataset per stratum (i.e. duplicated or splitted strata among the datasets are dealt specifically -> this is the case for ICCAT and IATTC)  ####
cat("Begin: Retrieving primary datasets from Sardara DB... \n")

### 1.1 Retrieve georeferenced georef_dataset
georef_dataset<-NULL 

## IOTC 
if (include_IOTC==TRUE){
  cat("Retrieving IOTC georeferenced catch from Sardara database...\n")
  rfmo_catch<-rtunaatlas::iotc_catch_level0(datasets_year_release)
  georef_dataset<-rbind(georef_dataset,rfmo_catch)
  rm(rfmo_catch)
  cat("Retrieving IOTC georeferenced catch from Sardara database OK\n")
}

## WCPFC
if (include_WCPFC==TRUE){
  cat("Retrieving WCPFC georeferenced catch from Sardara database...\n")
  rfmo_catch<-rtunaatlas::wcpfc_catch_level0(datasets_year_release)
  georef_dataset<-rbind(georef_dataset,rfmo_catch)
  rm(rfmo_catch)
  cat("Retrieving WCPFC georeferenced catch from Sardara database OK\n")
}

## CCSBT
if (include_CCSBT==TRUE){
  cat("Retrieving CCSBT georeferenced catch from Sardara database...\n")
  rfmo_catch<-rtunaatlas::ccsbt_catch_level0(datasets_year_release)
  georef_dataset<-rbind(georef_dataset,rfmo_catch)
  rm(rfmo_catch)
  cat("Retrieving CCSBT georeferenced catch from Sardara database OK\n")
}

## IATTC
if (include_IATTC==TRUE){
  cat("Retrieving IATTC georeferenced catch from Sardara database...\n")
  rfmo_catch<-rtunaatlas::iattc_catch_level0(datasets_year_release,
                                             raise_flags_to_schooltype=iattc_raise_flags_to_schooltype,
                                             dimension_to_use_if_no_raising_flags_to_schooltype=iattc_dimension_to_use_if_no_raising_flags_to_schooltype)
  georef_dataset<-rbind(georef_dataset,rfmo_catch)
  rm(rfmo_catch)
  cat("Retrieving IATTC georeferenced catch from Sardara database OK\n")
}

## ICCAT
if (include_ICCAT==TRUE){
  cat("Retrieving ICCAT georeferenced catch from Sardara database...\n")
  rfmo_catch<-rtunaatlas::iccat_catch_level0(datasets_year_release,
                                             include_type_of_school=iccat_include_type_of_school)
  georef_dataset<-rbind(georef_dataset,rfmo_catch)
  rm(rfmo_catch)
  cat("Retrieving ICCAT georeferenced catch from Sardara database OK\n")
}


### 1.2 If data will be raised, retrieve nominal catch datasets
if (raising_georef_to_nominal==TRUE){
  source(paste0(url_scripts_create_own_tuna_atlas_catch,"retrieve_nominal_catch.R"))
}

cat("Retrieving primary datasets from Sardara DB OK\n")


#### 2) Map code lists 

if (mapping_map_code_lists==TRUE){
  source(paste0(url_scripts_create_own_tuna_atlas_catch,"map_code_lists.R"))
}


#### 3) Filter data by groups of gears

if (gear_filter!="NULL"){
 source(paste0(url_scripts_create_own_tuna_atlas_catch,"gear_filter.R"))
}


#### 4) Convert units

if (unit_conversion_convert==TRUE){ 
 source(paste0(url_scripts_create_own_tuna_atlas_catch,"unit_conversion_convert.R"))
}


#### 5) Raise georeferenced georef_dataset to total (nominal) georef_dataset

if (raising_georef_to_nominal==TRUE) {   
  source(paste0(url_scripts_create_own_tuna_atlas_catch,"raising_georef_to_nominal.R"))
} 



#### 6) Spatial Aggregation / Disaggregation of data

## 6.1 Aggregate data on 5° resolution quadrants
if (aggregate_on_5deg_data_with_resolution_inferior_to_5deg==TRUE) { 
  source(paste0(url_scripts_create_own_tuna_atlas_catch,"aggregate_on_5deg_data_with_resolution_inferior_to_5deg.R"))
} 

## 6.2 Disggregate data on 5° resolution quadrants
if (disaggregate_on_5deg_data_with_resolution_superior_to_5deg==TRUE) { 
  source(paste0(url_scripts_create_own_tuna_atlas_catch,"disaggregate_on_5deg_data_with_resolution_superior_to_5deg.R"))
} 

## 6.3 Disggregate data on 1° resolution quadrants
if (disaggregate_on_1deg_data_with_resolution_superior_to_1deg==TRUE) { 
  source(paste0(url_scripts_create_own_tuna_atlas_catch,"disaggregate_on_1deg_data_with_resolution_superior_to_1deg.R"))
} 


#### 7) Reallocation of data mislocated (i.e. on land areas or without any spatial information) (data with no spatial information have the dimension "geographic_identifier" set to "UNK/IND" or NA)

if (spatial_curation_data_mislocated %in% c("reallocate","remove")){
  source(paste0(url_scripts_create_own_tuna_atlas_catch,"spatial_curation_data_mislocated.R"))
}



#### 8) Overlapping zone (IATTC/WCPFC): keep data from IATTC or WCPFC?

if (overlapping_zone_iattc_wcpfc_data_to_keep!="NULL"){
  source(paste0(url_scripts_create_own_tuna_atlas_catch,"overlapping_zone_iattc_wcpfc_data_to_keep.R"))
}



#### 9) Southern Bluefin Tuna (SBF): SBF data: keep data from CCSBT or data from the other tuna RFMOs?

if (SBF_data_rfmo_to_keep!="NULL"){
  source(paste0(url_scripts_create_own_tuna_atlas_catch,"SBF_data_rfmo_to_keep.R"))
}


dbDisconnect(con)

#### END
cat("End: Your tuna atlas georef_dataset dataset has been created! \n")

