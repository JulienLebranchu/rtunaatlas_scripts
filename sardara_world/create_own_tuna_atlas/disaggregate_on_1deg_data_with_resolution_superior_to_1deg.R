cat("Disaggregating data that are defined on quadrants or areas superior to 1° quadrant resolution to corresponding 1° quadrant by dividing the georef_dataset equally on the overlappings 1° x 1° quadrants...\n")
georef_dataset<-rtunaatlas::spatial_curation_downgrade_resolution(con,georef_dataset,1)
georef_dataset<-georef_dataset$df
cat("Disaggregating data that are defined on quadrants or areas superior to 1° quadrant resolution to corresponding 1° quadrant OK\n")