
cat("Raising georeferenced dataset to nominal dataset\n")

# We have to separate the WCPFC and CCSBT from the other rfmos, because WCPFC and CCSBT georef catches do not have flag dimension available (hence we cannot use the flag dimension for the raising)

# function to raise the data 
function_raise_data<-function(source_authority_filter,dataset_df,nominal_dataset_df,x_raising_dimensions){
  
  # filter by source_authority
  dataset_df<-dataset_df[which(dataset_df$source_authority %in% source_authority_filter),]
  nominal_dataset_df<-nominal_dataset_df[which(nominal_dataset_df$source_authority %in% source_authority_filter),]
  
  # calculate raising factor dataset
  df_rf <- rtunaatlas::raise_get_rf(
    df_input_incomplete = dataset_df,
    df_input_total = nominal_dataset_df,
    x_raising_dimensions = x_raising_dimensions
  ) 
  
  # raise dataset
  catch_raised<-rtunaatlas::raise_incomplete_dataset_to_total_dataset(df_input_incomplete = dataset_df,
                                                                      df_input_total = nominal_dataset_df,
                                                                      df_rf = df_rf,
                                                                      x_raising_dimensions = x_raising_dimensions,
                                                                      threshold_rf = NULL)
  return(catch_raised)
  
}


if ( include_CCSBT==TRUE | include_WCPFC==TRUE ) {
  
  if (fact=="catch"){
    x_raising_dimensions=c("gear","species","year","source_authority","unit")
  } else if (fact=="effort"){
    x_raising_dimensions=c("gear","year","source_authority","unit")
  }
  
  cat(paste0("Raising georeferenced dataset of CCBST and WCPFC - if included in the Tuna Atlas - by ",paste(x_raising_dimensions,collapse = ","),"\n"))
  catch_WCPFC_CCSBT_raised<-function_raise_data(source_authority_filter = c("WCPFC","CCSBT"),
                                                dataset_df = georef_dataset,
                                                nominal_dataset_df = nominal_catch,
                                                x_raising_dimensions = x_raising_dimensions)
  
  catch_WCPFC_CCSBT_raised<-catch_WCPFC_CCSBT_raised$df
} else {
  catch_WCPFC_CCSBT_raised<-NULL
}

if ( include_IOTC==TRUE | include_ICCAT==TRUE | include_IATTC==TRUE ) {
  
  if (fact=="catch"){
    x_raising_dimensions=c("gear","flag","species","year","source_authority","unit")
  } else if (fact=="effort"){
    x_raising_dimensions=c("gear","flag","year","source_authority","unit")
  }
  
  cat(paste0("Raising georeferenced dataset of IOTC, ICCAT and IATTC - if included in the Tuna Atlas - by ",paste(x_raising_dimensions,collapse = ","),"\n"))
  catch_IOTC_ICCAT_IATTC_raised<-function_raise_data(source_authority_filter = c("IOTC","ICCAT","IATTC"),
                                                     dataset_df = georef_dataset,
                                                     nominal_dataset_df = nominal_catch,
                                                     x_raising_dimensions = x_raising_dimensions)
  
  catch_IOTC_ICCAT_IATTC_raised<-catch_IOTC_ICCAT_IATTC_raised$df
} else {
  catch_IOTC_ICCAT_IATTC_raised<-NULL
}

georef_dataset<-rbind(catch_WCPFC_CCSBT_raised,catch_IOTC_ICCAT_IATTC_raised)

rm(catch_WCPFC_CCSBT_raised)
rm(catch_IOTC_ICCAT_IATTC_raised)

# fill metadata elements
metadata$lineage<-c(metadata$lineage,paste0("Catch-and-effort data are data aggregated over spatio-temporal strata that are collected by the CPCs or the tRFMOs in some cases. Generally, catch-and-effort data are defined over one month time period and 1° or 5° size square spatial resolution. Following ICCAT, catch and fishing effort statistics are defined as “the complete species (tuna, tuna like species and sharks) catch composition (in weight <kg> or/and in number of fish) obtained by a given amount of effort (absolute value) in a given stratification or detail level (stratum). T2CE are basically data obtained from sampling a portion of the individual fishing operations of a given fishery in a specified period of time.” (ICCAT Task 2). Hence, geo-referenced catch data and associated effort can represent only part of the total catches. Geo-referenced catches were raised to the total catches for all tRFMOs. Depending on the availability of the vessel flag reporting country dimension (currently not available for the geo-referenced catch-and-effort dataset from the Western-Central Pacific Ocean), the dimensions used for the raising are either {Flag, Species, Year, Gear} or {Species, Year, Gear}. Some catches cannot be raised because the combination {Flag, Species, Year, Gear} (resp. {Species, Year, Gear}) does exist in the geo-referenced catches but the same combination does not exist in the total catches. In this case, non-raised catch data were kept. Most catch-and-effort data have catches inferior to the catch available in the nominal catch dataset for a given stratum. However, in some cases the value of catch in the catch-and-effort data can be greater than the one in the nominal catch. In this cas, the catch was ''downgraded'' to the nominal catch one.	Information regarding the raising process for this dataset: Before the raising process, perc_georef_data_over_total_dataset_before_raising % of the catches of the nominal catch datasets were available in the catch-and-effort datasets. After the raising process, this percentage reached perc_georef_data_over_total_dataset_after_raising %. This percentage might not be 100 because of the following reasons: i) perc_georef_data_do_not_exist_in_total_data % of the catches available in the catch-and-effort dataset had no correspondance in the nominal catch (i.e. the strata exists in the catch-and-effort dataset but does not exist in the nominal catch dataset); ii) perc_total_data_do_not_exist_in_georef_data % of the catches available in the nominal catch dataset had no correspondance in the catch-and-effort dataset (i.e. the strata exists in the nominal catch dataset but does not exist in the catch-and-effort dataset"))
metadata$description<-paste0(metadata$description,"- Geo-referenced ",fact," were raised to the total ",fact,"\n")
metadata$supplemental_information<-paste0(metadata$supplemental_information,"- Geo-referenced ",fact," were raised to the total catches for all tRFMOs. Depending on the availability of the flag dimension (currently not available for the geo-referenced catch-and-effort dataset from the Western-Central Pacific Ocean), the dimensions used for the raising are either {Flag, Species, Year, Gear} or {Species, Year, Gear}. Some ",fact," cannot be raised because the combination {Flag, Species, Year, Gear} (resp. {Species, Year, Gear}) does exist in the geo-referenced ",fact," but the same combination does not exist in the total catches. In this case, non-raised ",fact," data were kept. Most catch-and-effort data have catches inferior to the catch available in the nominal catch dataset for a given stratum. However, in some cases the value of catch in the catch-and-effort data can be greater than the one in the nominal catch. In this case, the catch was 'downgraded' to the nominal catch one.\n")

cat("Raising georeferenced dataset to nominal dataset OK\n")
