cat("Aggregating data that are defined on quadrants or areas inferior to 5° quadrant resolution to corresponding 5° quadrant...\n")
georef_dataset<-rtunaatlas::spatial_curation_upgrade_resolution(con,georef_dataset,5)
georef_dataset<-georef_dataset$df
cat("Aggregating data that are defined on quadrants or areas inferior to 5° quadrant resolution to corresponding 5° quadrant OK\n")