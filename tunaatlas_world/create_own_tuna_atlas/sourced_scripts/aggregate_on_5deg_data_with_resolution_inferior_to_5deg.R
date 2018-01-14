cat("Aggregating data that are defined on quadrants or areas inferior to 5° quadrant resolution to corresponding 5° quadrant...\n")
georef_dataset<-rtunaatlas::spatial_curation_upgrade_resolution(con,georef_dataset,5)
georef_dataset<-georef_dataset$df

# fill metadata elements
metadata$lineage<-c(metadata$lineage,"Data that were provided at spatial resolutions inferior to 5° x 5°  were aggregated to the corresponding 5° x 5°  quadrant.")
metadata$description<-paste0(metadata$description,"- Data that were provided at resolutions inferior to 5° x 5°  were aggregated to the corresponding 5° x 5°  quadrant.")

cat("Aggregating data that are defined on quadrants or areas inferior to 5° quadrant resolution to corresponding 5° quadrant OK\n")