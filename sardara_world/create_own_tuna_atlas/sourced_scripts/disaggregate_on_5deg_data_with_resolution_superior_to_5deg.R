cat("Disaggregating data that are defined on quadrants or areas superior to 5° quadrant resolution to corresponding 5° quadrant by dividing the georef_dataset equally on the overlappings 5° x 5° quadrants...\n")
georef_dataset<-rtunaatlas::spatial_curation_downgrade_resolution(con,georef_dataset,5)
georef_dataset<-georef_dataset$df
cat("Disaggregating data that are defined on quadrants or areas superior to 5° quadrant resolution to corresponding 5° quadrant OK\n")