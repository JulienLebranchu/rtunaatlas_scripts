cat("Reallocating data that are in land areas...\n")

#all the data that are inland or do not have any spatial stratification ("UNK/IND",NA) are dealt (either removed - spatial_curation_data_mislocated=="remove" - or reallocated - spatial_curation_data_mislocated=="reallocate" )

areas_in_land<-rtunaatlas::spatial_curation_intersect_areas(con,georef_dataset,"areas_tuna_rfmos_task2","gshhs_world_coastlines")

areas_in_land<-areas_in_land$df_input_areas_intersect_intersection_layer %>%
  group_by(geographic_identifier_source_layer) %>%
  summarise(percentage_intersection_total=sum(proportion_source_area_intersection))

areas_in_land<-areas_in_land$geographic_identifier_source_layer[which(areas_in_land$percentage_intersection_total==1)]

areas_with_no_spatial_information<-c("UNK/IND",NA)

if (spatial_curation_data_mislocated=="remove"){ # We remove data that is mislocated
  cat("Removing data that are in land areas...\n")
  # remove rows with areas in land
  georef_dataset<-georef_dataset[ which(!(georef_dataset$geographic_identifier %in% c(areas_in_land,areas_with_no_spatial_information))), ] 
  cat("Removing data that are in land areas OK\n")
}

if (spatial_curation_data_mislocated=="reallocate"){   # We reallocate data that is mislocated (they will be equally distributed on areas with same reallocation_dimensions (month|year|gear|flag|species|schooltype).
  cat("Reallocating data that are in land areas...\n")
  catch_curate_data_mislocated<-rtunaatlas::spatial_curation_function_reallocate_data(df_input = georef_dataset,
                                                                                      dimension_reallocation = "geographic_identifier",
                                                                                      vector_to_reallocate = c(areas_in_land,areas_with_no_spatial_information),
                                                                                      reallocation_dimensions = setdiff(colnames(georef_dataset),c("value","geographic_identifier")))
  georef_dataset<-catch_curate_data_mislocated$df
  cat("Reallocating data that are in land areas OK\n")
}