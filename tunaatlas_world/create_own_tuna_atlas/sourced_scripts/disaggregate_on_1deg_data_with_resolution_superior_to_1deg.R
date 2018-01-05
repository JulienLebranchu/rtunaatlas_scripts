cat("Disaggregating data that are defined on quadrants or areas superior to 1° quadrant resolution to corresponding 1° quadrant by dividing the georef_dataset equally on the overlappings 1° x 1° quadrants...\n")
georef_dataset<-rtunaatlas::spatial_curation_downgrade_resolution(con,georef_dataset,1)
georef_dataset<-georef_dataset$df

# fill metadata elements
lineage<-c(lineage,paste0("Data that were provided at spatial resolutions superior to 1° x 1°  were disaggregated to the corresponding 1° x 1°  quadrants by dividing the catch equally on the overlappings 1° x 1°  quadrants.	Information regarding the spatial disaggregation of data: The data that were expressed on resolutions wider than 1° grid resolutions and that were disaggregated to the corresponding(s) 1° quadrants represented stats_data_disaggregated_on_1_deg_weight % of the whole catches expressed in weight in the dataset and stats_data_disaggregated_on_1_deg_number % of the catches expressed in number."))
description<-paste0(description,"- Data that were provided at resolutions superior to 1° x 1° were disaggregated to the corresponding 1° x 1°quadrants by dividing the catch equally on the overlappings 1° x 1° quadrants.\n")

cat("Disaggregating data that are defined on quadrants or areas superior to 1° quadrant resolution to corresponding 1° quadrant OK\n")