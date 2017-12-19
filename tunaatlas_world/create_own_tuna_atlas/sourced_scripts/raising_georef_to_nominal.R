
cat("Raising georeferenced georef_dataset to nominal georef_dataset...\n")

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
  cat("Raising georeferenced georef_dataset of CCBST and WCPFC - if included in the Tuna Atlas - by gear, species, year, source authority and unit\n")
  catch_WCPFC_CCSBT_raised<-function_raise_data(source_authority_filter = c("WCPFC","CCSBT"),
                                                catch_df = georef_dataset,
                                                nominal_catch_df = nominal_catch,
                                                x_raising_dimensions = c("gear","species","year","source_authority","unit"))
  
  catch_WCPFC_CCSBT_raised<-catch_WCPFC_CCSBT_raised$df
} else {
  catch_WCPFC_CCSBT_raised<-NULL
}

if ( include_IOTC==TRUE | include_ICCAT==TRUE | include_IATTC==TRUE ) {
  cat("Raising georeferenced georef_dataset of IOTC, ICCAT and IATTC - if included in the Tuna Atlas - by gear, flag, species, year, source authority and unit\n")
  catch_IOTC_ICCAT_IATTC_raised<-function_raise_data(source_authority_filter = c("IOTC","ICCAT","IATTC"),
                                                     catch_df = georef_dataset,
                                                     nominal_catch_df = nominal_catch,
                                                     x_raising_dimensions = c("gear","flag","species","year","source_authority","unit"))
  
  catch_IOTC_ICCAT_IATTC_raised<-catch_IOTC_ICCAT_IATTC_raised$df
} else {
  catch_IOTC_ICCAT_IATTC_raised<-NULL
}

georef_dataset<-rbind(catch_WCPFC_CCSBT_raised,catch_IOTC_ICCAT_IATTC_raised)

rm(catch_WCPFC_CCSBT_raised)
rm(catch_IOTC_ICCAT_IATTC_raised)

cat("Raising georeferenced georef_dataset to nominal georef_dataset OK\n")
