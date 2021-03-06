######################################################################
##### 52North WPS annotations ##########
######################################################################
# wps.des: id = create_own_tuna_atlas_catch_effort, title = Create your own georeferenced Tuna Atlas dataset of catch or efforts, abstract = This algorithm allows to create own regional or global tuna atlas of geo-referenced gridded catch or efforts. It takes as input the public domain datasets of the five Tuna Regional Fisheries Management Organizations (tRFMOs) (IOTC ICCAT WCPFC IATTC CCSBT) stored within the Tuna atlas database. It proposes a set of parameters to customize the computation of the tuna atlas. ;
# wps.in: id = fact, type = string, title = Variable output of the tuna atlas (catch or effort), value = "catch|effort";
# wps.in: id = include_IOTC, type = string, title = Include IOTC data (Indian Ocean) in the atlas (TRUE or FALSE), value = "TRUE|FALSE";
# wps.in: id = include_ICCAT, type = string, title = Include ICCAT data (Atlantic Ocean) in the tuna atlas?, value = "TRUE|FALSE";
# wps.in: id = include_IATTC, type = string, title = Include IATTC data (Eastern Pacific Ocean) in the tuna atlas?, value = "TRUE|FALSE";
# wps.in: id = include_WCPFC, type = string, title = Include WCPFC data (Western Pacific Ocean) in the tuna atlas?, value = "TRUE|FALSE";
# wps.in: id = include_CCSBT, type = string, title = Include CCSBT data (Southern hemisphere Oceans - only Southern Bluefin Tuna) in the atlas?, value = "TRUE|FALSE";
# wps.in: id = datasets_year_release, type = string, title = Year of release of the datasets by the tRFMOs. First available year is 2017. Usually datasets released in the year Y contain the time series from the beginning of the fisheries (e.g. 1950) to year Y-2 (included). For instance 2017 will extract the datasets released in 2017 and that cover the time series from 1950 to 2015 (included), value = "2017";
# wps.in: id = iccat_ps_include_type_of_school, type = string, title = Concerns ICCAT Purse Seine data. Use only if parameter include_ICCAT is set to TRUE. ICCAT disseminates two catch-and-efforts datasets: one that provides the detail of the type of school (Fad|Free school) for purse seine fisheries only and that starts in 1994 (called Task II catch|effort by operation mode Fad|Free school) and one that does not provide the information of the type of school and that covers all the time period (from 1950) (called Task II catch|effort). These data are redundant (i.e. the data from the dataset Task II catch|effort by operation mode are also available in the dataset Task II catch|effort but in the latter the information on the type of school is not available). Combine both datasets to produce a dataset with fishing mode information (Fad | Free school)? TRUE : both datasets will be combined to produce a dataset with fishing mode information (Fad | free school). FALSE : Only the dataset without the type of school will be used. In that case the output dataset will not have the information on the fishing mode for ICCAT., value = "TRUE|FALSE";
# wps.in: id = iattc_ps_raise_flags_to_schooltype, type = string, title = Concerns IATTC Purse Seine data. Use only if parameter include_IATTC is set to TRUE. For confidentiality policies information on fishing country (flag) and type of school for the geo-referenced catches is available in separate files for the Eastern Pacific Ocean purse seine datasets. IATTC hence provides two public domain dataset: one with the information on the type of school and one with the information on the flag. Both datasets can be combined - using raising methods - to estimate the catches by both flag and type of school for purse seine fisheries. Combine both datasets? TRUE : both datasets (by fishing mode and by flag) will be combined - using raising methods i.e. dataset with the information on the flag will be raised to the dataset with the information on the type of school - to have the detail on both fishing mode and flag for each stratum. FALSE : Only one dataset will be used (either Flag or Type of school). The parameter dimension_to_use_if_no_raising_flags_to_schooltype allows to decide which dataset to use., value = "TRUE|FALSE";
# wps.in: id = iattc_ps_dimension_to_use_if_no_raising_flags_to_schooltype, type = string, title = Concerns IATTC Purse Seine data. Use only if parameter include_IATTC is set to TRUE and parameter iattc_raise_flags_to_schooltype is set to FALSE. In the case IATTC purse seine datasets are not combined (see description of parameter iattc_raise_flags_to_schooltype) which dataset to use? flag : use dataset with the information on flag. Information on type of school will therefore not be available. schooltype : use dataset with the information on type of school. Information on flag will therefore not be available., value = "flag|schooltype";
# wps.in: id = iattc_ps_catch_billfish_shark_raise_to_effort, type = boolean, title = Concerns IATTC Purse Seine data. Use only if parameter include_IATTC is set to TRUE and parameter variable is set to 'catch'. In addition to the separation flag / schooltype (see above) IATTC Purse seine catch-and-effort are available in 3 separate files according to the group of species: tuna, billfishes, sharks. This is due to the fact that PS data is collected from 2 sources: observer and fishing vessel logbooks. Observer records are used when available, and for unobserved trips logbooks are used. Both sources collect tuna data but only observers collect shark and billfish data. So as an example a strata may have observer effort and the number of sets from the observed trips would be counted for tuna and shark and billfish. But there may have also been logbook data for unobserved sets in the same strata so the tuna catch and number of sets for a cell would be added. This would make a higher total number of sets for tuna catch than shark or billfish. So efforts in the billfish and shark datasets might represent only a proportion of the total effort allocated in some strata since it is the observed effort i.e. for which there was an observer onboard. As a result catch in the billfish and shark datasets might represent only a proportion of the total catch allocated in a some strata. TRUE: Raise billfish (resp. shark) catch to the ratio  effort tuna / effort billfish (resp. shark). FALSE: Keep billfish (resp. shark) catch as they are provided in the billfish (resp. shark) catch datasets., value = "TRUE|FALSE";
# wps.in: id = mapping_map_code_lists, type = string, title = Map code lists (gears|species|flags|schooltypes|catchtype)? When using multiple sources of data (i.e. multiple RFMOS) code lists used by the various tRFMOs might be different. They should therefore be mapped to single code lists in order to be able to compare the data. TRUE : map code lists. The url to the datasets providing the code list mappings to use must be set in the parameter mapping_source_mappings. See parameter mapping_source_mappings for more details. FALSE : do not map code lists. Output data will use input codes., value = "TRUE|FALSE" ;
# wps.in: id = mapping_csv_mapping_datasets_url, type = string, title = Use only if parameter mapping_map_code_lists is set to TRUE. Path to the CSV file containing the dimensions that must be mapped and the name of the mapping dataset for each dimension mapped. The mapping datasets must be available in Tuna atlas database.  A template can be found here: https://goo.gl/YZmeDV . , value="http://data.d4science.org/ZWFMa3JJUHBXWk9NTXVPdFZhbU5BUFEyQnhUeWd1d3lHbWJQNStIS0N6Yz0" ;
# wps.in: id = mapping_keep_src_code, type = string, title = Use only if parameter mapping_map_code_lists is set to TRUE. In case of code list mapping (mapping_map_code_lists is TRUE) keep source coding system column? TRUE : conserve in the output dataset both source and target coding systems columns. FALSE : conserve only target coding system. , value="FALSE|TRUE" ;
# wps.in: id = gear_filter, type = string, title = Filter data by gear. Gear codes in this parameter must by the same as the ones used in the catch dataset (i.e. raw tRFMOs gear codes if no mapping or in case of mapping (mapping_map_code_lists is TRUE) codes used in the mapping code list). NULL : do not filter. If you want to filter you must write the codes to filter by separated by a comma in case of multiple codes.  , value = "NULL";
# wps.in: id = unit_conversion_convert, type = string, title = Convert units of measure? if TRUE you must fill in the parameter unit_conversion_df_conversion_factor. , value = "FALSE|TRUE";
# wps.in: id = unit_conversion_csv_conversion_factor_url, type = string, title = Use only if parameter unit_conversion_convert is set to TRUE. If units are converted path to the csv containing the conversion factors dataset. The conversion factor dataset must be properly structured. A template can be found here: https://goo.gl/i7QJYC . The coding systems used in the dimensions of the conversion factors must be the same as the ones used in the catch dataset (i.e. raw tRFMOs codes or in case of mapping (mapping_map_code_lists isTRUE) codes used in the mapping code lists) except for spatial code list. Additional information on the structure are provided here: https://ptaconet.github.io/rtunaatlas//reference/convert_units.html , value = "http://data.d4science.org/Z3V2RmhPK3ZKVStNTXVPdFZhbU5BTTVaWnE3VFAzaElHbWJQNStIS0N6Yz0";
# wps.in: id = unit_conversion_codelist_geoidentifiers_conversion_factors, type = string, title = Use only if parameter unit_conversion_convert is set to TRUE. If units are converted name of the coding system of the spatial dimension used in the conversion factor dataset (i.e. identifier of the layer in the Tuna atlas database)., value = "areas_conversion_factors_numtoweigth_ird";
# wps.in: id = raising_georef_to_nominal, type = string, title =  Geo-referenced catch data and associated effort can represent only part of the total catches. Raise georeferenced catches to nominal catches? Depending on the availability of the flag dimension (currently not available for the geo-referenced catch-and-effort dataset from the WCPFC and CCSBT) the dimensions used for the raising are either {Flag|Species|Year|Gear} or {Species|Year|Gear}. Some catches cannot be raised because the combination {Flag|Species|Year|Gear} (resp. {Species|Year|Gear}) does exist in the geo-referenced catches but the same combination does not exist in the total catches. In this case non-raised catch data are kept. TRUE : Raise georeferenced catches to total catches. FALSE : Do not raise., value = "TRUE|FALSE";
# wps.in: id = raising_do_not_raise_wcfpc_data, type = string, title =  WCPFC georeferenced data are already raised [terminer la description]. TRUE : Do not Raise WCPFC georeferenced catches to total catches. FALSE : Raise., value = "TRUE|FALSE";
# wps.in: id = raising_raise_only_for_PS_LL, type = string, title =  Raise the data only for Purse Seiners and Longliners (i.e. do not raise for artisanal fisheries) [terminer la description]. TRUE : Raise only for PS and LL. FALSE : Raise for all gears., value = "TRUE|FALSE";
# wps.in: id = aggregate_on_5deg_data_with_resolution_inferior_to_5deg, type = string, title =  Aggregate data that are defined on quadrants or areas inferior to 5° quadrant resolution to corresponding 5° quadrant? TRUE : Aggregate. Data that are provided at spatial resolutions superior to 5° x 5°  will be aggregated to the corresponding 5° quadrant. FALSE : Do not aggregate. Data that are provided at spatial resolutions superior to 5° x 5° will be will be kept as so. , value = "TRUE|FALSE";
# wps.in: id = disaggregate_on_5deg_data_with_resolution_superior_to_5deg, type = string, title = What to do with data that are defined on quadrants or areas superior to 5° quadrant resolution to 5° quadrant? none: Do not do anything. Data that are provided at spatial resolutions inferior to 5° x 5° will be kept as so. disaggregate : data that are provided at spatial resolutions superior to 5° x 5°  will be disaggregated to the corresponding 5°  x 5°  quadrants by dividing the catch equally on the overlappings 5° x 5°  quadrants. remove : Data that are provided at spatial resolutions superior to 5° x 5°  will be removed from the dataset. , value = "none|disaggregate|remove";
# wps.in: id = disaggregate_on_1deg_data_with_resolution_superior_to_1deg, type = string, title = Same as parameter disaggregate_on_5deg_data_with_resolution_superior_to_5deg but for 1° resolutions  , value = "none|disaggregate|remove";
# wps.in: id = spatial_curation_data_mislocated, type = string, title = Some data might be mislocated: either located on land areas or without any area information. This parameter allows to control what to do with these data. reallocate : Reallocate the mislocated data (equally distributed on areas with same dimensions (month|gear|flag|species|schooltype). no_reallocation : do not reallocate mislocated data. The output dataset will keep these data with their original location (eg on land or with no area information). remove : remove the mislocated data., value = "remove|reallocate|no_reallocation";
# wps.in: id = overlapping_zone_iattc_wcpfc_data_to_keep, type = string, title = Concerns IATTC and WCPFC data. IATTC and WCPFC have an overlapping area in their respective area of competence. Which data should be kept for this zone? IATTC : keep data from IATTC. WCPFC : keep data from WCPFC. NULL : Keep data from both tRFMOs. Caution: with the option NULL data in the overlapping zone are likely to be redundant., value = "IATTC|WCPFC|NULL";
# wps.in: id = SBF_data_rfmo_to_keep, type = string, title = Concerns Southern Bluefin Tuna (SBF) data. Use only if parameter fact is set to 'catch' and parameter include_CCSBT is set to TRUE. SBF tuna data do exist in both CCSBT data and the other tuna RFMOs data. Wich data should be kept? CCSBT : CCSBT data are kept for SBF. other_trfmos : data from the other TRFMOs are kept for SBF. NULL : Keep data from all the tRFMOs. Caution: with the option NULL data in the overlapping zones are likely to be redundant., value = "CCSBT|other_trfmos|NULL";
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

# connect to Tuna atlas database
con<-rtunaatlas::db_connection_tunaatlas_world()

# initialize metadata elements
metadata<-NULL
metadata$contact_originator<-NULL
metadata$lineage<-NULL
metadata$description<-"The main processes applied to generate this dataset are the followings:\n"
metadata$supplemental_information<-NULL

#### 1) Retrieve tuna RFMOs data from Tuna atlas DB at level 0. Level 0 is the merging of the tRFMOs primary datasets, with the more complete possible value of georef_dataset per stratum (i.e. duplicated or splitted strata among the datasets are dealt specifically -> this is the case for ICCAT and IATTC)  ####
cat("Begin: Retrieving primary datasets from Tuna atlas DB... \n")

### 1.1 Retrieve georeferenced catch or effort
dataset<-NULL 

datasets_year_release<-as.numeric(datasets_year_release)
  
## IOTC 
if (include_IOTC=="TRUE"){
  cat("Retrieving IOTC georeferenced dataset from the Tuna atlas database...\n")
  rfmo_dataset<-rtunaatlas::get_rfmos_datasets_level0("IOTC",fact,datasets_year_release)
  dataset<-rbind(dataset,rfmo_dataset)
  rm(rfmo_dataset)
  # fill metadata elements
  metadata$contact_originator<-paste0(metadata$contact_originator,"fabio.fiorellato@iotc.org")
  metadata$lineage<-c(metadata$lineage,"Public domain datasets from IOTC were collated through the RFMO website (www.iotc.org). Their structure (i.e. column organization and names) was harmonized and they were loaded in the Tuna atlas database.")
  cat("Retrieving IOTC georeferenced dataset from the Tuna atlas database OK\n")
}

## WCPFC
if (include_WCPFC=="TRUE"){
  cat("Retrieving WCPFC georeferenced dataset from the Tuna atlas database...\n")
  rfmo_dataset<-rtunaatlas::get_rfmos_datasets_level0("WCPFC",fact,datasets_year_release)
  dataset<-rbind(dataset,rfmo_dataset)
  rm(rfmo_dataset)
  # fill metadata elements
  metadata$contact_originator<-paste(metadata$contact_originator,"PeterW@spc.int",sep=";")
  metadata$lineage<-c(metadata$lineage,"Public domain datasets from WCPFC were collated through the RFMO website (www.wcpfc.int). Their structure (i.e. column organization and names) was harmonized and they were loaded in the Tuna atlas database.")
  cat("Retrieving WCPFC georeferenced dataset from the Tuna atlas database OK\n")
}

## CCSBT
if (include_CCSBT=="TRUE"){
  cat("Retrieving CCSBT georeferenced dataset from the Tuna atlas database...\n")
  rfmo_dataset<-rtunaatlas::get_rfmos_datasets_level0("CCSBT",fact,datasets_year_release)
  dataset<-rbind(dataset,rfmo_dataset)
  rm(rfmo_dataset)
  # fill metadata elements
  metadata$contact_originator<-paste(metadata$contact_originator,"CMillar@ccsbt.org",sep=";")
  metadata$lineage<-c(metadata$lineage,"Public domain datasets from CCSBT were collated through the RFMO website (www.ccsbt.org). Their structure (i.e. column organization and names) was harmonized and they were loaded in the Tuna atlas database.")
  cat("Retrieving CCSBT georeferenced dataset from the Tuna atlas database OK\n")
}

## IATTC
if (include_IATTC=="TRUE"){
  cat("Retrieving IATTC georeferenced dataset from the Tuna atlas database...\n")
  rfmo_dataset<-rtunaatlas::get_rfmos_datasets_level0("IATTC",
                                                      fact,
                                                      datasets_year_release,
                                                      iattc_ps_raise_flags_to_schooltype=iattc_ps_raise_flags_to_schooltype,
                                                      iattc_ps_dimension_to_use_if_no_raising_flags_to_schooltype=iattc_ps_dimension_to_use_if_no_raising_flags_to_schooltype,
                                                      iattc_ps_catch_billfish_shark_raise_to_effort=iattc_ps_catch_billfish_shark_raise_to_effort)
  dataset<-rbind(dataset,rfmo_dataset)
  rm(rfmo_dataset)
  # fill metadata elements
  metadata$contact_originator<-paste(metadata$contact_originator,"nvogel@iattc.org",sep=";")
  metadata$lineage<-c(metadata$lineage,"Public domain datasets from IATTC were collated through the RFMO website (www.iattc.org). Their structure (i.e. column organization and names) was harmonized and they were loaded in the Tuna atlas database.")
  cat("Retrieving IATTC georeferenced dataset from the Tuna atlas database OK\n")
}

## ICCAT
if (include_ICCAT=="TRUE"){
  cat("Retrieving ICCAT georeferenced dataset from the Tuna atlas database...\n")
  rfmo_dataset<-rtunaatlas::get_rfmos_datasets_level0("ICCAT",
                                                      fact,
                                                      datasets_year_release,
                                                      iccat_ps_include_type_of_school=iccat_ps_include_type_of_school)
  dataset<-rbind(dataset,rfmo_dataset)
  rm(rfmo_dataset)
  # fill metadata elements
  metadata$contact_originator<-paste(metadata$contact_originator,"carlos.palma@iccat.int",sep=";")
  metadata$lineage<-c(metadata$lineage,"Public domain datasets from ICCAT were collated through the RFMO website (www.iccat.int). Their structure (i.e. column organization and names) was harmonized and they were loaded in the Tuna atlas database.")
  cat("Retrieving ICCAT georeferenced dataset from the Tuna atlas database OK\n")
}

dataset$time_start<-substr(as.character(dataset$time_start), 1, 10)
dataset$time_end<-substr(as.character(dataset$time_end), 1, 10)

georef_dataset<-dataset
rm(dataset)

### 1.2 If data will be raised, retrieve nominal catch datasets
if (raising_georef_to_nominal=="TRUE"){
  source(paste0(url_scripts_create_own_tuna_atlas,"retrieve_nominal_catch.R"))
}

cat("Retrieving primary datasets from the Tuna atlas DB OK\n")

# fill some metadata elements
if (include_ICCAT=="TRUE"){
  if(iccat_ps_include_type_of_school=="TRUE"){
    lineage_iccat="Both datasets were combined to produce a dataset that covers the whole time period, with fishing mode information (Fad | free school)."
  } else {
    lineage_iccat="Only the dataset without the type of school was used. Hence, the output dataset does not have the information on fishing mode for ICCAT Purse seine data."
  }
  metadata$lineage<-c(metadata$lineage,paste0("Concerns ICCAT purse seine datasets. ICCAT delivers two catch-and-efforts datasets for purse seiners: one that gives the detail of the type of school (Fad|Free school) for purse seine fisheries and that starts in 1994 (called Task II catch|effort by operation mode Fad|Free school) and one that does not give the information of the type of school and that covers all the time period (from 1950) (called Task II catch|effort). These data are redundant (i.e. the data from the dataset Task II catch|effort by operation mode are also available in the dataset Task II catch|effort) but in the latter, the information on the type of school is not available. ",lineage_iccat))
}

if (include_IATTC=="TRUE"){
  if (iattc_ps_raise_flags_to_schooltype=="TRUE"){
    lineage_iattc<-paste0("For each stratum, the ",fact," coming from the flag-detailed dataset was raised to the ",fact," coming from the school type-detailed dataset to get an estimation of the ",fact," by flag and school type in each stratum.")
    metadata$supplemental_information<-paste0(metadata$supplemental_information,"- For confidentiality policies, information on flag and school type for the geo-referenced ",fact," is available in separate files for East Pacific Ocean Purse seine datasets collated from the IATTC. For each stratum, the ",fact," from the flag-detailed dataset was raised to the ",fact," from the school type-detailed dataset to get an estimation of the ",fact," by flag and school type in each stratum.\n")
    } else {
    if (iattc_ps_dimension_to_use_if_no_raising_flags_to_schooltype=="flag"){
      lineage_iattc<-"Only the dataset with the information on the fishing country was used. Hence, the output dataset does not have the information on fishing mode for IATTC Purse seine data."
    } else if (iattc_ps_dimension_to_use_if_no_raising_flags_to_schooltype=="schooltype"){
    lineage_iattc<-"Only the dataset with the information on the fishing mode was used. Hence, the output dataset does not have the information on fishing country for IATTC Purse seine data."
    }

  }
  
  metadata$lineage<-c(metadata$lineage,paste0("Concerns IATTC purse seine datasets: For confidentiality policies, information on flag and school type for the geo-referenced catches is available in separate files for the eastern Pacific Ocean purse seine datasets. ",lineage_iattc))  

  lineage_iattc<-"Concerns IATTC purse seine datasets: IATTC Purse seine catch-and-effort are available in 3 separate files according to the group of species: tuna, billfishes, sharks. This is due to the fact that PS data is collected from 2 sources: observer and fishing vessel logbooks. Observer records are used when available, and for unobserved trips logbooks are used. Both sources collect tuna data but only observers collect shark and billfish data. As an example, a strata may have observer effort and the number of sets from the observed trips would be counted for tuna and shark and billfish. But there may have also been logbook data for unobserved sets in the same strata so the tuna catch and number of sets for a cell would be added. This would make a higher total number of sets for tuna catch than shark or billfish. Efforts in the billfish and shark datasets might hence represent only a proportion of the total effort allocated in some strata since it is the observed effort, i.e. for which there was an observer onboard."
  if (fact=="catch" && iattc_ps_catch_billfish_shark_raise_to_effort=="TRUE"){
    metadata$lineage<-c(metadata$lineage,paste0(lineage_iattc," As a result, catch in the billfish and shark datasets might represent only a proportion of the total catch allocated in some strata. Hence, shark and billfish catch were raised to the fishing effort reported in the tuna dataset."))
  }
  
  if (fact=="effort"){
    metadata$lineage<-c(metadata$lineage,paste0(lineage_iattc," Only efforts from the Tuna dataset were kept."))
  }
}



metadata$lineage<-c(metadata$lineage,"All the datasets were merged")

#metadata$description<-paste0(metadata$description,"- Catch-and-effort data are disseminated in such way that redundancy may exist between the various datasets released, or that dimensions may be split over the datasets for some strata. To cope with these issues and get one single and more complete possible value of ",fact," per stratum (i.e. with all the available dimensions), these datasets had to be merged in specific ways - i.e. not simply merging them but removing the duplicated strata or reassembling the strata with all the available dimensions split over the datasets.\n")
metadata$description<-paste0(metadata$description,"- Strata described by all the dimensions of interest (i.e. species, flag, gear, school association, year, month, area) were re-assembled from multiple data sets of aggregated ",fact,"\n")



#### 2) Map code lists 

if (mapping_map_code_lists=="TRUE"){
  source(paste0(url_scripts_create_own_tuna_atlas,"map_code_lists.R"))
  
  cat("Mapping code lists of georeferenced datasets...\n")
  georef_dataset<-function_map_code_lists(fact,mapping_csv_mapping_datasets_url,georef_dataset,mapping_keep_src_code)
  metadata$description<-paste0(metadata$description,georef_dataset$description)
  metadata$lineage<-c(metadata$lineage,georef_dataset$lineage)
  metadata$supplemental_information<-paste0(metadata$supplemental_information,georef_dataset$supplemental_information)
  georef_dataset<-georef_dataset$dataset
  cat("Mapping code lists of georeferenced datasets OK\n")
  
  if(raising_georef_to_nominal=="TRUE"){
    cat("Mapping code lists of nominal catch datasets...\n")
    nominal_catch<-function_map_code_lists("catch",mapping_csv_mapping_datasets_url,nominal_catch,mapping_keep_src_code)$dataset
    cat("Mapping code lists of nominal catch datasets OK\n")
  }
}


#### 3) Filter data by groups of gears

if (!is.null(gear_filter)){
  source(paste0(url_scripts_create_own_tuna_atlas,"gear_filter.R"))
  georef_dataset<-function_gear_filter(gear_filter,georef_dataset)
  metadata$lineage<-c(metadata$lineage,georef_dataset$lineage)
  georef_dataset<-georef_dataset$dataset
}


#### 4) Convert units

if (unit_conversion_convert=="TRUE"){ 
  source(paste0(url_scripts_create_own_tuna_atlas,"unit_conversion_convert.R"))
  georef_dataset<-function_unit_conversion_convert(con,fact,unit_conversion_csv_conversion_factor_url,unit_conversion_codelist_geoidentifiers_conversion_factors,mapping_map_code_lists,georef_dataset)
  metadata$description<-paste0(metadata$description,georef_dataset$description)
  metadata$lineage<-c(metadata$lineage,georef_dataset$lineage)
  metadata$supplemental_information<-paste0(metadata$supplemental_information,georef_dataset$supplemental_information)
  georef_dataset<-georef_dataset$dataset
}


#### 5) Raise georeferenced to total (nominal) dataset

if (raising_georef_to_nominal=="TRUE") {   
  source(paste0(url_scripts_create_own_tuna_atlas,"raising_georef_to_nominal.R"))
  
  if (fact=="catch"){
    dataset_to_compute_rf=georef_dataset
    x_raising_dimensions=c("flag","gear","species","year","source_authority")
  } else if (fact=="effort"){    ## If we raise the efforts, the RF is calculated using the georeferenced catch data. Hence, we need to retrieve the georeferenced catch data.
    cat("Catch datasets must be retrieved and processed in order to raise efforts. \nRetrieving georeferenced catch datasets from the Tuna atlas database...\n")
    dataset_catch<-NULL
    if (include_IOTC=="TRUE"){
      rfmo_dataset<-rtunaatlas::get_rfmos_datasets_level0("IOTC","catch",datasets_year_release)
      dataset_catch<-rbind(dataset_catch,rfmo_dataset)
      rm(rfmo_dataset)
    }
    if (include_WCPFC=="TRUE"){
      rfmo_dataset<-rtunaatlas::get_rfmos_datasets_level0("WCPFC","catch",datasets_year_release)
      dataset_catch<-rbind(dataset_catch,rfmo_dataset)
      rm(rfmo_dataset)
    }
    if (include_CCSBT=="TRUE"){
      rfmo_dataset<-rtunaatlas::get_rfmos_datasets_level0("CCSBT","catch",datasets_year_release)
      dataset_catch<-rbind(dataset_catch,rfmo_dataset)
      rm(rfmo_dataset)
    }
    if (include_IATTC=="TRUE"){
      rfmo_dataset<-rtunaatlas::get_rfmos_datasets_level0("IATTC",
                                                          "catch",
                                                          datasets_year_release,
                                                          iattc_ps_raise_flags_to_schooltype=iattc_ps_raise_flags_to_schooltype,
                                                          iattc_ps_dimension_to_use_if_no_raising_flags_to_schooltype=iattc_ps_dimension_to_use_if_no_raising_flags_to_schooltype,
                                                          iattc_ps_catch_billfish_shark_raise_to_effort=TRUE)
      dataset_catch<-rbind(dataset_catch,rfmo_dataset)
      rm(rfmo_dataset)
    }
    if (include_ICCAT=="TRUE"){
      rfmo_dataset<-rtunaatlas::get_rfmos_datasets_level0("ICCAT",
                                                          "catch",
                                                          datasets_year_release,
                                                          iccat_ps_include_type_of_school=iccat_ps_include_type_of_school)
      dataset_catch<-rbind(dataset_catch,rfmo_dataset)
      rm(rfmo_dataset)
    }
    
    
    if (mapping_map_code_lists=="TRUE"){
      dataset_catch<-function_map_code_lists("catch",mapping_csv_mapping_datasets_url,dataset_catch,mapping_keep_src_code)$dataset
    }
    
    if (!is.null(gear_filter)){
      dataset_catch<-function_gear_filter(gear_filter,dataset_catch)$dataset
    }
    dataset_catch$time_start<-substr(as.character(dataset_catch$time_start), 1, 10)
    dataset_catch$time_end<-substr(as.character(dataset_catch$time_end), 1, 10)
    if (unit_conversion_convert=="TRUE"){ 
      # We use our conversion factors (IRD). This should be an input parameter of the script
      dataset_catch<-function_unit_conversion_convert(con,fact="catch",unit_conversion_csv_conversion_factor_url="http://data.d4science.org/Z3V2RmhPK3ZKVStNTXVPdFZhbU5BTTVaWnE3VFAzaElHbWJQNStIS0N6Yz0",unit_conversion_codelist_geoidentifiers_conversion_factors="areas_conversion_factors_numtoweigth_ird",mapping_map_code_lists,dataset_catch)$dataset
    }
    
    dataset_to_compute_rf=dataset_catch
    rm(dataset_catch)
    x_raising_dimensions=c("flag","gear","year","source_authority")
  }
    
    georef_dataset<-function_raising_georef_to_nominal(fact,georef_dataset,dataset_to_compute_rf,nominal_catch,x_raising_dimensions,raising_do_not_raise_wcfpc_data,raising_raise_only_for_PS_LL)
    rm(dataset_to_compute_rf)
    metadata$description<-paste0(metadata$description,georef_dataset$description)
    metadata$lineage<-c(metadata$lineage,georef_dataset$lineage)
    metadata$supplemental_information<-paste0(metadata$supplemental_information,georef_dataset$supplemental_information)
    georef_dataset<-georef_dataset$dataset
    
} 



#### 6) Spatial Aggregation / Disaggregation of data

## 6.1 Aggregate data on 5° resolution quadrants
if (aggregate_on_5deg_data_with_resolution_inferior_to_5deg=="TRUE") { 
  source(paste0(url_scripts_create_own_tuna_atlas,"aggregate_on_5deg_data_with_resolution_inferior_to_5deg.R"))
  georef_dataset<-function_aggregate_on_5deg_data_with_resolution_inferior_to_5deg(con,georef_dataset)
  metadata$description<-paste0(metadata$description,georef_dataset$description)
  metadata$lineage<-c(metadata$lineage,georef_dataset$lineage)
  georef_dataset<-georef_dataset$dataset
} 

## 6.2 Disggregate data on 5° resolution quadrants
if (disaggregate_on_5deg_data_with_resolution_superior_to_5deg %in% c("disaggregate","remove")) {
  source(paste0(url_scripts_create_own_tuna_atlas,"disaggregate_on_resdeg_data_with_resolution_superior_to_resdeg.R"))
  georef_dataset<-function_disaggregate_on_resdeg_data_with_resolution_superior_to_resdeg(con,georef_dataset,5,disaggregate_on_5deg_data_with_resolution_superior_to_5deg)
  metadata$description<-paste0(metadata$description,georef_dataset$description)
  metadata$lineage<-c(metadata$lineage,georef_dataset$lineage)
  georef_dataset<-georef_dataset$dataset
}

## 6.3 Disggregate data on 1° resolution quadrants
if (disaggregate_on_1deg_data_with_resolution_superior_to_1deg %in% c("disaggregate","remove")) { 
  source(paste0(url_scripts_create_own_tuna_atlas,"disaggregate_on_resdeg_data_with_resolution_superior_to_resdeg.R"))
  georef_dataset<-function_disaggregate_on_resdeg_data_with_resolution_superior_to_resdeg(con,georef_dataset,1,disaggregate_on_1deg_data_with_resolution_superior_to_1deg)
  metadata$description<-paste0(metadata$description,georef_dataset$description)
  metadata$lineage<-c(metadata$lineage,georef_dataset$lineage)
  georef_dataset<-georef_dataset$dataset
} 


#### 7) Reallocation of data mislocated (i.e. on land areas or without any spatial information) (data with no spatial information have the dimension "geographic_identifier" set to "UNK/IND" or NA)

if (spatial_curation_data_mislocated %in% c("reallocate","remove")){
  source(paste0(url_scripts_create_own_tuna_atlas,"spatial_curation_data_mislocated.R"))
  georef_dataset<-function_spatial_curation_data_mislocated(con,georef_dataset,spatial_curation_data_mislocated)
  metadata$description<-paste0(metadata$description,georef_dataset$description)
  metadata$lineage<-c(metadata$lineage,georef_dataset$lineage)
  georef_dataset<-georef_dataset$dataset
}



#### 8) Overlapping zone (IATTC/WCPFC): keep data from IATTC or WCPFC?

if (include_IATTC=="TRUE" && include_WCPFC=="TRUE" && !is.null(overlapping_zone_iattc_wcpfc_data_to_keep)){
  source(paste0(url_scripts_create_own_tuna_atlas,"overlapping_zone_iattc_wcpfc_data_to_keep.R"))
  georef_dataset<-function_overlapping_zone_iattc_wcpfc_data_to_keep(con,overlapping_zone_iattc_wcpfc_data_to_keep,georef_dataset)
  metadata$description<-paste0(metadata$description,georef_dataset$description)
  metadata$lineage<-c(metadata$lineage,georef_dataset$lineage)
  georef_dataset<-georef_dataset$dataset
  }



#### 9) Southern Bluefin Tuna (SBF): SBF data: keep data from CCSBT or data from the other tuna RFMOs?

if (fact=="catch" && include_CCSBT=="TRUE" && !is.null(SBF_data_rfmo_to_keep)){
  source(paste0(url_scripts_create_own_tuna_atlas,"SBF_data_rfmo_to_keep.R"))
  georef_dataset<-function_SBF_data_rfmo_to_keep(SBF_data_rfmo_to_keep,georef_dataset)
  metadata$description<-paste0(metadata$description,georef_dataset$description)
  metadata$lineage<-c(metadata$lineage,georef_dataset$lineage)
  georef_dataset<-georef_dataset$dataset
  }



dataset<-georef_dataset %>% group_by_(.dots = setdiff(colnames(georef_dataset),"value")) %>% dplyr::summarise(value=sum(value))
dataset<-data.frame(dataset)

dbDisconnect(con)

## fill some metadata elements
metadata$description<-paste0(metadata$description,"\n More details on the processes are provided in the supplemental information and in the lineage section.")
metadata$supplemental_information<-paste0(metadata$supplemental_information,"- Note that some data can be expressed at temporal resolutions greater than 1 month.\n")
metadata$contact_originator<-unique(strsplit(metadata$contact_originator, ";")[[1]])
metadata$contact_originator<-paste(metadata$contact_originator,collapse = ";")
metadata$lineage<-unique(metadata$lineage)
lineage_metadata_format<-NULL
for (i in 1:length(metadata$lineage)){
  lineage_metadata_format<-paste0(lineage_metadata_format,"step",i,": ",metadata$lineage[i],"\n")
}
metadata$lineage<-lineage_metadata_format


## Retrieve the code lists to use for integration within the Tuna Atlas DB (input parameter of the function to load datasets)
metadata$contact_data_structure_definition="paul.taconet@ird.fr"
if (include_IOTC=="TRUE"){
rfmo="IOTC"
  }
if (include_ICCAT=="TRUE"){
  rfmo="ICCAT"
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
  metadata$contact_data_structure_definition="fdiwg@rda-groups.org"
}

table_urls_code_lists_to_use_to_load_datasets<-read.csv("https://raw.githubusercontent.com/ptaconet/rtunaatlas_scripts/master/tunaatlas_world/create_own_tuna_atlas/sourced_scripts/table_urls_code_lists_to_use_to_load_datasets.csv",stringsAsFactors = F)
path_csv_codelists <- table_urls_code_lists_to_use_to_load_datasets$url_df_codelist[which(table_urls_code_lists_to_use_to_load_datasets$rfmo==rfmo & table_urls_code_lists_to_use_to_load_datasets$fact==fact)]
df_codelists <- data.frame(lapply(read.csv(path_csv_codelists), as.character), stringsAsFactors=FALSE)

if (fact=="effort" & mapping_map_code_lists=="FALSE" & unit_conversion_convert=="TRUE"){
  # Levels 1 and 2 of non-global datasets should be expressed with tRFMOs code lists. However, for the effort unit code list and in those cases, we take the tuna atlas effort unit codes although this is not perfect. but going back to tRFMOs codes is too complicated 
  df_codelists$code_list_identifier[which(df_codelists$dimension=="unit")]<-"effortunit_rfmos"
}

additional_metadata<-metadata


#### END
cat("End: Your tuna atlas dataset has been created! Your output data.frame is called 'dataset' \n")

