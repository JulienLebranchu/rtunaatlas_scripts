######################################################################
##### 52North WPS annotations ##########
######################################################################
# wps.des: id = create_own_tuna_atlas_catch, title = Create your own dataset of georeferenced catch Tuna Atlas, abstract = This algorithm allows to create own regional or global tuna altas. It takes as input the public domain datasets of the five Tuna Regional Fisheries Management Organizations (IOTC|ICCAT|WCPFC|IATTC|CCSBT) stored within the Sardara database. It proposes a set of parameters to customize the computation of the tuna atlas. ;
# wps.in: id = include_IOTC, type = boolean, title = Include IOTC data (Indian Ocean) in the atlas (TRUE or FALSE), value = TRUE;
# wps.in: id = include_ICCAT, type = boolean, title = Include ICCAT data (Atlantic Ocean) in the atlas?, value = TRUE;
# wps.in: id = include_IATTC, type = boolean, title = Include IATTC data (Eastern Pacific Ocean) in the atlas?, value = TRUE;
# wps.in: id = include_WCPFC, type = boolean, title = Include WCPFC data (Western Pacific Ocean) in the atlas?, value = TRUE;
# wps.in: id = include_CCSBT, type = boolean, title = Include CCSBT data (Southern hemisphere Oceans - only Southern Bluefin Tuna) in the atlas?, value = TRUE;
# wps.in: id = datasets_year_release, type = integer, title = Year of release of the datasets. First available year is 2017. Usually, datasets released in the year Y contain the time series from the beginning of the fisheries (e.g. 1950) to year Y-2 (included). For instance 2017 will extract the time series from 1950 to 2015 (included), value = 2017;
# wps.in: id = iccat_include_type_of_school, type = boolean, title = Concerns ICCAT Purse Seine data. Use only if parameter include_ICCAT is set to TRUE. ICCAT has two catch-and-efforts datasets: one that gives the detail of the type of school (Fad|Free school) for purse seine fisheries only and that starts in 1994 (called Task II catch|effort by operation mode Fad|Free school) and one that does not give the information of the type of school and that covers all the time period (from 1950) (called Task II catch|effort). These data are redundant (i.e. the data from the dataset Task II catch|effort by operation mode are also available in the dataset Task II catch|effort but in the latter the information on the type of school is not available). Combine both datasets to produce a dataset with fishing mode information (Fad | Free school)? TRUE : both datasets will be combined to produce a dataset with fishing mode information (Fad | free school). FALSE : Only the dataset without the type of school will be used. In that case the output dataset will not have the information on the fishing mode for ICCAT., value = TRUE;
# wps.in: id = iattc_raise_flags_to_schooltype, type = boolean, title = Concerns IATTC Purse Seine data. Use only if parameter include_IATTC is set to TRUE. For confidentiality policies, information on fishing country (flag) and type of school for the geo-referenced catches is available in separate files for the Eastern Pacific Ocean purse seine datasets. IATTC hence provides two public domain dataset: one with the information on the type of school and one with the information on the flag. Both datasets can be combined - using raising methods - to estimate the catches by both flag and type of school for purse seine fisheries. Combine both datasets? TRUE : both datasets (by fishing mode and by flag) will be combined - using raising methods i.e. dataset with the information on the flag will be raised to the dataset with the information on the type of school - to have the detail on both fishing mode and flag for each stratum. FALSE : Only one dataset will be used (either Flag or Type of school). The parameter dimension_to_use_if_no_raising_flags_to_schooltype allows to decide which dataset to use., value = TRUE;
# wps.in: id = iattc_dimension_to_use_if_no_raising_flags_to_schooltype, type = string, title = Concerns IATTC Purse Seine data. Use only if parameter iattc_raise_flags_to_schooltype is set to FALSE. In the case IATTC purse seine datasets are not combined (see description of parameter iattc_raise_flags_to_schooltype) which dataset to use? flag : use dataset with the information on flag. Information on type of school will therefore not be available. schooltype : use dataset with the information on type of school. Information on flag will therefore not be available., value = "flag|schooltype";
# wps.in: id = mapping_map_code_lists, type = boolean, title = Map code lists (gears, groups of gears, species, flags, schooltypes, catchtype)? When using multiple sources of data (i.e. multiple RFMOS), code lists might be different and should be mapped to global code lists so as to be able to compare the data. TRUE : map code lists. The datasets of code list mappings must be set in the parameter mapping_source_mappings. FALSE : do not map code lists. Output data will use input code lists., value = TRUE ;
# wps.in: id = mapping_csv_mapping_datasets_url, type = string, title = Use only if parameter mapping_map_code_lists is set to TRUE. Path to the CSV file where the user has set the dimensions that must be mapped and the names of the dataset mapping for each dimension mapped. The mapping datasets must be available in the database. An example of this CSV can be found here: https://goo.gl/2hA1sq. , value="NULL" ;
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
# wps.out: id = zip_namefile, type = text/zip, title = Outputs are: the file of georeferenced catches in csv format + . All outputs and codes are compressed within a single zip file. ; 

### Utile uniquement pour le tuna atlas Nominal catch   wps.in: id = iccat_nominal_catch_spatial_stratification, type = string, title = Concerns ICCAT Nominal catch data. Use only if parameter include_ICCAT is set to TRUE. ICCAT nominal catch datasets can be spatially stratified either by sampling areas or by stock areas. Which spatial stratification to choose? sampling_area or stock_area. ,value = "NULL|sampling_area|stock_area"

#include_IOTC=TRUE
#include_ICCAT=TRUE
#include_IATTC=TRUE
#include_WCPFC=TRUE
#include_CCSBT=TRUE
#datasets_year_release=2017
#iccat_include_type_of_school=TRUE
#iattc_raise_flags_to_schooltype=TRUE
#iattc_dimension_to_use_if_no_raising_flags_to_schooltype="NULL"
#mapping_map_code_lists=TRUE
#mapping_csv_mapping_datasets_url="https://goo.gl/2hA1sq"
#mapping_keep_src_code=FALSE
#gear_filter="NULL"
#unit_conversion_convert=TRUE
#unit_conversion_csv_conversion_factor_url="https://goo.gl/KriwxV"
#unit_conversion_codelist_geoidentifiers_conversion_factors="areas_conversion_factors_numtoweigth_ird"
#raising_georef_to_nominal=TRUE
#aggregate_on_5deg_data_with_resolution_inferior_to_5deg=TRUE
#disaggregate_on_5deg_data_with_resolution_superior_to_5deg=TRUE
#disaggregate_on_1deg_data_with_resolution_superior_to_1deg=FALSE
#spatial_curation_data_mislocated="reallocate"
#overlapping_zone_iattc_wcpfc_data_to_keep="IATTC"
#SBF_data_rfmo_to_keep="CCSBT"

# Library rtunaatlas containing useful functions for this script
require(rtunaatlas)
require(dplyr)
require(data.table)
# connect to Sardara DB
con<-rtunaatlas::db_connection_sardara_world()

#### 1) Retrieve tuna RFMOs data from Sardara DB at level 0. Level 0 is the merging of the tRFMOs primary datasets, with the more complete possible value of catch per stratum (i.e. duplicated or splitted strata among the datasets are dealt specifically -> this is the case for ICCAT and IATTC)  ####
cat("Begin: Retrieving primary datasets from Sardara DB... \n")

### 1.1 Retrieve georeferenced catch
catch<-NULL 

## IOTC 
if (include_IOTC==TRUE){
  cat("Retrieving IOTC georeferenced catch from Sardara database...\n")
  rfmo_catch<-rtunaatlas::iotc_catch_level0(datasets_year_release)
  catch<-rbind(catch,rfmo_catch)
  rm(rfmo_catch)
  cat("Retrieving IOTC georeferenced catch from Sardara database OK\n")
}

## WCPFC
if (include_WCPFC==TRUE){
  cat("Retrieving WCPFC georeferenced catch from Sardara database...\n")
  rfmo_catch<-rtunaatlas::wcpfc_catch_level0(datasets_year_release)
  catch<-rbind(catch,rfmo_catch)
  rm(rfmo_catch)
  cat("Retrieving WCPFC georeferenced catch from Sardara database OK\n")
}

## CCSBT
if (include_CCSBT==TRUE){
  cat("Retrieving CCSBT georeferenced catch from Sardara database...\n")
  rfmo_catch<-rtunaatlas::ccsbt_catch_level0(datasets_year_release)
  catch<-rbind(catch,rfmo_catch)
  rm(rfmo_catch)
  cat("Retrieving CCSBT georeferenced catch from Sardara database OK\n")
}

## IATTC
if (include_IATTC==TRUE){
  cat("Retrieving IATTC georeferenced catch from Sardara database...\n")
  rfmo_catch<-rtunaatlas::iattc_catch_level0(datasets_year_release,
                                             raise_flags_to_schooltype=iattc_raise_flags_to_schooltype,
                                             dimension_to_use_if_no_raising_flags_to_schooltype=iattc_dimension_to_use_if_no_raising_flags_to_schooltype)
  catch<-rbind(catch,rfmo_catch)
  rm(rfmo_catch)
  cat("Retrieving IATTC georeferenced catch from Sardara database OK\n")
}

## ICCAT
if (include_ICCAT==TRUE){
  cat("Retrieving ICCAT georeferenced catch from Sardara database...\n")
  rfmo_catch<-rtunaatlas::iccat_catch_level0(datasets_year_release,
                                             include_type_of_school=iccat_include_type_of_school)
  catch<-rbind(catch,rfmo_catch)
  rm(rfmo_catch)
  cat("Retrieving ICCAT georeferenced catch from Sardara database OK\n")
}


### 1.2 If data will be raised, retrieve nominal catch datasets
if (raising_georef_to_nominal==TRUE){
  
  cat("Retrieving RFMOs nominal catch (for raising)...\n")
  
  include_rfmo<-c(include_IOTC,include_IATTC,include_WCPFC,include_CCSBT,include_ICCAT)
  nominal_catch_datasets_permanent_identifiers<-c("indian_ocean_nominal_catch_tunaatlasIOTC_level0","east_pacific_ocean_nominal_catch_tunaatlasIATTC_level0","west_pacific_ocean_nominal_catch_tunaatlasWCPFC_level0","southern_hemisphere_oceans_nominal_catch_tunaatlasCCSBT_level0__byGear","atlantic_ocean_nominal_catch_tunaatlasICCAT_level0__bySamplingArea")
  
  nominal_catch_datasets_permanent_identifiers_to_keep<-NULL
  for (i in 1:length(include_rfmo)){
    if (include_rfmo[i]==TRUE){
      nominal_catch_datasets_permanent_identifiers_to_keep<-paste0(nominal_catch_datasets_permanent_identifiers_to_keep,",'",nominal_catch_datasets_permanent_identifiers[i],"'")
    }
  }
  nominal_catch_datasets_permanent_identifiers_to_keep<-substring(nominal_catch_datasets_permanent_identifiers_to_keep, 2)
  
  rfmo_nominal_catch_metadata<-dbGetQuery(con,paste0("SELECT * from metadata.metadata where dataset_permanent_identifier IN (",nominal_catch_datasets_permanent_identifiers_to_keep,") and dataset_name LIKE '%_",datasets_year_release,"_%'"))
  nominal_catch<-rtunaatlas::extract_and_merge_multiple_datasets(con,rfmo_nominal_catch_metadata,columns_to_keep=c("source_authority","species","gear","flag","time_start","time_end","geographic_identifier","unit","value"))
  
  # For ICCAT Nominal catch, we need to map flag code list, because flag code list used in nominal catch dataset is different from flag code list used in ICCAT task2; however we have to use the same flag code list for data raising. In other words, we express all ICCAT datasets following ICCAT task2 flag code list.
  # extract mapping
  df_mapping<-rtunaatlas::extract_dataset(con,list_metadata_datasets(con,dataset_name="codelist_mapping_flag_iccat_from_ncandcas_flag_iccat"))
  df_mapping$source_authority<-"ICCAT"
  nominal_catch<-rtunaatlas::map_codelist(nominal_catch,df_mapping,"flag")$df  
  
  cat("Retrieving RFMOs nominal catch (for raising) OK\n")
  
}

cat("Retrieving primary datasets from Sardara DB OK\n")


#### 2) Map code lists 

if (mapping_map_code_lists==TRUE){
  cat("Mapping code lists...\n")
  
  cat("Reading the CSV containing the dimensions to map + the names of the code list mapping datasets. Code list mapping datasets must be available in the database. \n")
  mapping_dataset<-read.csv(mapping_csv_mapping_datasets_url,stringsAsFactors = F,colClasses = "character")
  
  function_map_dataset_codelists<-function(dataset_to_map,mapping_dataset,mapping_keep_src_code){
    # Get the dimensions to map from the mapping_dataset
    dimension_to_map<-unique(mapping_dataset$dimensions_to_map)
    # One by one, map the dimensions
    for (i in 1:length(dimension_to_map)){ # i takes the values of the dimensions to map
      if (dimension_to_map[i] %in% colnames(dataset_to_map)){
        mapping_dataset_this_dimension<-mapping_dataset %>% filter (dimensions_to_map == dimension_to_map[i])  
        df_mapping_final_this_dimension<-NULL
        for (j in 1:nrow(mapping_dataset_this_dimension)){ # With this loop, we extract one by one, for 1 given dimension, the code list mapping datasets from the DB. The last line of the loop binds all the code list mappings datasets for this given dimension.
          df_mapping<-rtunaatlas::extract_dataset(con,list_metadata_datasets(con,dataset_name=mapping_dataset_this_dimension$db_mapping_dataset_name[j]))  # Extract the code list mapping dataset from the DB
          df_mapping$source_authority<-mapping_dataset_this_dimension$source_authority[j]  # Add the dimension "source_authority" to the mapping dataset. That dimension is not included in the code list mapping datasets. However, it is necessary to map the code list.
          df_mapping_final_this_dimension<-rbind(df_mapping_final_this_dimension,df_mapping)
        }
        dataset_to_map<-rtunaatlas::map_codelist(dataset_to_map,df_mapping_final_this_dimension,dimension_to_map[i],mapping_keep_src_code)$df  # Codes are mapped by tRFMOs (source_authority) 
      }
    }
    
    return(dataset_to_map)
  }
  
  cat("Mapping code lists of georeferenced catch datasets...\n")
  catch<-function_map_dataset_codelists(catch,mapping_dataset,mapping_keep_src_code)
  cat("Mapping code lists of georeferenced catch datasets OK\n")
  
  
  if(raising_georef_to_nominal==TRUE){
    cat("Mapping code lists of nominal catch datasets...\n")
    nominal_catch<-function_map_dataset_codelists(nominal_catch,mapping_dataset,mapping_keep_src_code)
    cat("Mapping code lists of nominal catch datasets OK\n")
  }
  
  cat("Mapping code lists OK\n")
}


#### 3) Filter data by groups of gears

if (gear_filter!="NULL"){
  cat("Filtering gears...\n")
  gear_filter<-unlist(strsplit(gear_filter, split=","))
  catch<-catch %>% filter(gear %in% gear_filter)
  cat("Filtering gears OK\n")
}


#### 4) Convert units

if (unit_conversion_convert==FALSE){      # If the user decides not to convert catchunits, nothing is done.
} else {  # else we convert catch units
  
  cat("Converting units of catch...\n")
  
  cat("Reading the conversion factors dataset. This dataset must be properly structured and the coding systems used in the dimensions of the conversion factors dataset must be the same as the ones used in the catch dataset. Additional information on the structure are provided here: https://ptaconet.github.io/rtunaatlas//reference/convert_unit.html\n")
  
  df_conversion_factor=read.csv(unit_conversion_csv_conversion_factor_url,stringsAsFactors = F,colClasses="character")
  
  ## Convert MTNO to MT and remove NOMT (we do not keep the data that were expressed in number with corresponding value in weight)
  catch$unit[which(catch$unit == "MTNO")]<-"MT"
  catch<-catch[!(catch$unit=="NOMT"),]
  
  catch<-convert_units(con = con,
                       df_input = catch,
                       df_conversion_factor = df_conversion_factor,
                       codelist_geoidentifiers_df_input = "areas_tuna_rfmos_task2",
                       codelist_geoidentifiers_conversion_factors = unit_conversion_codelist_geoidentifiers_conversion_factors
  )
  
  # to get stats on the process (useful for metadata)
  # catch$stats
  
  catch<-catch$df
  
  cat("Converting units of catch OK\n")
}


#### 5) Raise georeferenced catch to total (nominal) catch

if (raising_georef_to_nominal==FALSE) {   # We do not raise the data 
} else {  # else we raise the georeferenced catch to the total catch
  
  cat("Raising georeferenced catch to nominal catch...\n")
  
  # We have to separate the WCPFC and CCSBT from the other rfmos, because WCPFC and CCSBT georef catches do not have flag dimension available (hence we cannot use the flag dimension for the raising)
  
  # function to raise the data 
  function_raise_data<-function(source_authority_filter,catch_df,nominal_catch_df,x_raising_dimensions){
    
    # filter by source_authority
    catch_df<-catch_df[which(catch_df$source_authority %in% source_authority_filter),]
    nominal_catch_df<-nominal_catch_df[which(nominal_catch_df$source_authority %in% source_authority_filter),]
    
    # calculte raising factor dataset
    df_rf <- rtunaatlas::raise_get_rf(
      df_input_incomplete = catch_df,
      df_input_total = nominal_catch_df,
      x_raising_dimensions = x_raising_dimensions
    ) 
    
    # raise dataset
    catch_raised<-rtunaatlas::raise_incomplete_dataset_to_total_dataset(df_input_incomplete = catch_df,
                                                                        df_input_total = nominal_catch_df,
                                                                        df_rf = df_rf,
                                                                        x_raising_dimensions = x_raising_dimensions,
                                                                        threshold_rf = NULL)
    return(catch_raised)
    
  }
  
  
  if ( include_CCSBT==TRUE | include_WCPFC==TRUE ) {
    cat("Raising georeferenced catch of CCBST and WCPFC - if included in the Tuna Atlas - by gear, species, year, source authority and unit\n")
    catch_WCPFC_CCSBT_raised<-function_raise_data(source_authority_filter = c("WCPFC","CCSBT"),
                                                  catch_df = catch,
                                                  nominal_catch_df = nominal_catch,
                                                  x_raising_dimensions = c("gear","species","year","source_authority","unit"))
    
    catch_WCPFC_CCSBT_raised<-catch_WCPFC_CCSBT_raised$df
  } else {
    catch_WCPFC_CCSBT_raised<-NULL
  }
  
  if ( include_IOTC==TRUE | include_ICCAT==TRUE | include_IATTC==TRUE ) {
    cat("Raising georeferenced catch of IOTC, ICCAT and IATTC - if included in the Tuna Atlas - by gear, flag, species, year, source authority and unit\n")
    catch_IOTC_ICCAT_IATTC_raised<-function_raise_data(source_authority_filter = c("IOTC","ICCAT","IATTC"),
                                                       catch_df = catch,
                                                       nominal_catch_df = nominal_catch,
                                                       x_raising_dimensions = c("gear","flag","species","year","source_authority","unit"))
    
    catch_IOTC_ICCAT_IATTC_raised<-catch_IOTC_ICCAT_IATTC_raised$df
  } else {
    catch_IOTC_ICCAT_IATTC_raised<-NULL
  }
  
  catch<-rbind(catch_WCPFC_CCSBT_raised,catch_IOTC_ICCAT_IATTC_raised)
  
  rm(catch_WCPFC_CCSBT_raised)
  rm(catch_IOTC_ICCAT_IATTC_raised)
  
  cat("Raising georeferenced catch to nominal catch OK\n")
  
} 



#### 6) Spatial Aggregation / Disaggregation of data

## 6.1 Aggregate data on 5° resolution quadrants
if (aggregate_on_5deg_data_with_resolution_inferior_to_5deg==TRUE) { 
  cat("Aggregating data that are defined on quadrants or areas inferior to 5° quadrant resolution to corresponding 5° quadrant...\n")
  catch<-rtunaatlas::spatial_curation_upgrade_resolution(con,catch,5)
  catch<-catch$df
  cat("Aggregating data that are defined on quadrants or areas inferior to 5° quadrant resolution to corresponding 5° quadrant OK\n")
} 

## 6.2 Disggregate data on 5° resolution quadrants
if (disaggregate_on_5deg_data_with_resolution_superior_to_5deg==TRUE) { 
  cat("Disaggregating data that are defined on quadrants or areas superior to 5° quadrant resolution to corresponding 5° quadrant by dividing the catch equally on the overlappings 5° x 5° quadrants...\n")
  catch<-rtunaatlas::spatial_curation_downgrade_resolution(con,catch,5)
  catch<-catch$df
  cat("Disaggregating data that are defined on quadrants or areas superior to 5° quadrant resolution to corresponding 5° quadrant OK\n")
} 

## 6.3 Disggregate data on 1° resolution quadrants
if (disaggregate_on_1deg_data_with_resolution_superior_to_1deg==TRUE) { 
  cat("Disaggregating data that are defined on quadrants or areas superior to 1° quadrant resolution to corresponding 1° quadrant by dividing the catch equally on the overlappings 1° x 1° quadrants...\n")
  catch<-rtunaatlas::spatial_curation_downgrade_resolution(con,catch,1)
  catch<-catch$df
  cat("Disaggregating data that are defined on quadrants or areas superior to 1° quadrant resolution to corresponding 1° quadrant OK\n")
} 


#### 7) Reallocation of data mislocated (i.e. on land areas or without any spatial information) (data with no spatial information have the dimension "geographic_identifier" set to "UNK/IND" or NA)

if (spatial_curation_data_mislocated %in% c("reallocate","remove")){
  cat("Reallocating data that are in land areas...\n")
  
  #all the data that are inland or do not have any spatial stratification ("UNK/IND",NA) are dealt (either removed - spatial_curation_data_mislocated=="remove" - or reallocated - spatial_curation_data_mislocated=="reallocate" )
  
  areas_in_land<-rtunaatlas::spatial_curation_intersect_areas(con,catch,"areas_tuna_rfmos_task2","gshhs_world_coastlines")
  
  areas_in_land<-areas_in_land$df_input_areas_intersect_intersection_layer %>%
    group_by(geographic_identifier_source_layer) %>%
    summarise(percentage_intersection_total=sum(proportion_source_area_intersection))
  
  areas_in_land<-areas_in_land$geographic_identifier_source_layer[which(areas_in_land$percentage_intersection_total==1)]
  
  areas_with_no_spatial_information<-c("UNK/IND",NA)
  
  if (spatial_curation_data_mislocated=="remove"){ # We remove data that is mislocated
    cat("Removing data that are in land areas...\n")
    # remove rows with areas in land
    catch<-catch[ which(!(catch$geographic_identifier %in% c(areas_in_land,areas_with_no_spatial_information))), ] 
    cat("Removing data that are in land areas OK\n")
  }
  
  if (spatial_curation_data_mislocated=="reallocate"){   # We reallocate data that is mislocated (they will be equally distributed on areas with same reallocation_dimensions (month|year|gear|flag|species|schooltype).
    cat("Reallocating data that are in land areas...\n")
    catch_curate_data_mislocated<-rtunaatlas::spatial_curation_function_reallocate_data(df_input = catch,
                                                                                        dimension_reallocation = "geographic_identifier",
                                                                                        vector_to_reallocate = c(areas_in_land,areas_with_no_spatial_information),
                                                                                        reallocation_dimensions = setdiff(colnames(catch),c("value","geographic_identifier")))
    catch<-catch_curate_data_mislocated$df
    cat("Reallocating data that are in land areas OK\n")
  }
}



#### 8) Overlapping zone (IATTC/WCPFC): keep data from IATTC or WCPFC?

if (overlapping_zone_iattc_wcpfc_data_to_keep!="NULL"){
  cat(paste0("Keeping only data from ",overlapping_zone_iattc_wcpfc_data_to_keep," in the IATTC/WCPFC overlapping zone...\n"))
  # query Sardara to get the codes of IATTC and WCPFC overlapping areas (stored under the view area.iattc_wcpfc_overlapping_cwp_areas)
  query_areas_overlapping_zone_iattc_wcpfc<-"SELECT codesource_area from area.iattc_wcpfc_overlapping_cwp_areas"
  overlapping_zone_iattc_wcpfc<-dbGetQuery(con, query_areas_overlapping_zone_iattc_wcpfc)
  
  if (overlapping_zone_iattc_wcpfc_data_to_keep=="IATTC"){
    # If we choose to keep the data of the overlapping zone from the IATTC, we remove the data of the overlapping zone from the WCPFC dataset.
    catch<-catch[ which(!(catch$geographic_identifier %in% overlapping_zone_iattc_wcpfc$codesource_area & catch$source_authority == "WCPFC")), ]
  } else if (overlapping_zone_iattc_wcpfc_data_to_keep=="WCPFC"){
    # If we choose to keep the data of the overlapping zone from the WCPFC, we remove the data of the overlapping zone from the IATTC dataset
    catch<-catch[ which(!(catch$geographic_identifier %in% overlapping_zone_iattc_wcpfc$codesource_area & catch$source_authority == "IATTC")), ]
  }
  cat(paste0("Keeping only data from ",overlapping_zone_iattc_wcpfc_data_to_keep," in the IATTC/WCPFC overlapping zone OK\n"))
}



#### 9) Southern Bluefin Tuna (SBF): SBF data: keep data from CCSBT or data from the other tuna RFMOs?

if (SBF_data_rfmo_to_keep!="NULL"){
  cat(paste0("Keeping only data from ",SBF_data_rfmo_to_keep," for the Southern Bluefin Tuna...\n"))
  if (SBF_data_rfmo_to_keep=="CCSBT"){
    catch<-catch[ which(!(catch$species %in% "SBF" & catch$source_authority %in% c("ICCAT","IOTC","IATTC","WCPFC"))), ]
  } else {
    catch<-catch[ which(!(catch$species %in% "SBF" & catch$source_authority == "CCSBT")), ]
  }
  cat(paste0("Keeping only data from ",SBF_data_rfmo_to_keep," for the Southern Bluefin Tuna OK\n"))
}




#### END
cat("End: Your tuna atlas catch dataset has been created! \n")

