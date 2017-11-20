cat(paste0("Keeping only data from ",SBF_data_rfmo_to_keep," for the Southern Bluefin Tuna...\n"))
if (SBF_data_rfmo_to_keep=="CCSBT"){
  df<-df[ which(!(df$species %in% "SBF" & df$source_authority %in% c("ICCAT","IOTC","IATTC","WCPFC"))), ]
} else {
  df<-df[ which(!(df$species %in% "SBF" & df$source_authority == "CCSBT")), ]
}
cat(paste0("Keeping only data from ",SBF_data_rfmo_to_keep," for the Southern Bluefin Tuna OK\n"))