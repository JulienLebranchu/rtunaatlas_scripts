cat(paste0("Keeping only data from ",SBF_data_rfmo_to_keep," for the Southern Bluefin Tuna...\n"))
if (SBF_data_rfmo_to_keep=="CCSBT"){
  georef_dataset<-georef_dataset[ which(!(georef_dataset$species %in% "SBF" & georef_dataset$source_authority %in% c("ICCAT","IOTC","IATTC","WCPFC"))), ]
} else {
  georef_dataset<-georef_dataset[ which(!(georef_dataset$species %in% "SBF" & georef_dataset$source_authority == "CCSBT")), ]
}
cat(paste0("Keeping only data from ",SBF_data_rfmo_to_keep," for the Southern Bluefin Tuna OK\n"))