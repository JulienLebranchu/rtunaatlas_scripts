cat(paste0("Keeping only data from ",overlapping_zone_iattc_wcpfc_data_to_keep," in the IATTC/WCPFC overlapping zone...\n"))
# query Sardara to get the codes of IATTC and WCPFC overlapping areas (stored under the view area.iattc_wcpfc_overlapping_cwp_areas)
query_areas_overlapping_zone_iattc_wcpfc<-"SELECT codesource_area from area.iattc_wcpfc_overlapping_cwp_areas"
overlapping_zone_iattc_wcpfc<-dbGetQuery(con, query_areas_overlapping_zone_iattc_wcpfc)

if (overlapping_zone_iattc_wcpfc_data_to_keep=="IATTC"){
  # If we choose to keep the data of the overlapping zone from the IATTC, we remove the data of the overlapping zone from the WCPFC dataset.
  georef_dataset<-georef_dataset[ which(!(georef_dataset$geographic_identifier %in% overlapping_zone_iattc_wcpfc$codesource_area & georef_dataset$source_authority == "WCPFC")), ]
} else if (overlapping_zone_iattc_wcpfc_data_to_keep=="WCPFC"){
  # If we choose to keep the data of the overlapping zone from the WCPFC, we remove the data of the overlapping zone from the IATTC dataset
  georef_dataset<-georef_dataset[ which(!(georef_dataset$geographic_identifier %in% overlapping_zone_iattc_wcpfc$codesource_area & georef_dataset$source_authority == "IATTC")), ]
}
cat(paste0("Keeping only data from ",overlapping_zone_iattc_wcpfc_data_to_keep," in the IATTC/WCPFC overlapping zone OK\n"))