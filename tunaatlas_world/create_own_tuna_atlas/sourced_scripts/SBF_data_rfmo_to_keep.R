cat(paste0("Keeping only data from ",SBF_data_rfmo_to_keep," for the Southern Bluefin Tuna...\n"))
if (SBF_data_rfmo_to_keep=="CCSBT"){
  df<-df[ which(!(df$species %in% "SBF" & df$source_authority %in% c("ICCAT","IOTC","IATTC","WCPFC"))), ]
} else {
  df<-df[ which(!(df$species %in% "SBF" & df$source_authority == "CCSBT")), ]
}

# fill metadata elements
lineage<-c(lineage,paste0("Concerns Southern Bluefin Tuna (SBF) data: SBF tuna data do exist in both CCSBT data and the other tuna RFMOs data. Data from CCSBT and the other RFMOs may be redundant. For the Southern Bluefin Tuna, only data from ",SBF_data_rfmo_to_keep," were kept.	Information regarding the SBF data: after the eventual other corrections applied, e.g. raisings, units conversions, etc., the ratio between the catches from CCSBT and those from the other RFMOs for SBF was of: ratio_ccsbt_otherrfmos_mt for the catches expressed in weight. A total of catches_sbf_ccsbt_no fishes were available in the CCSBT datasets - while no data in number were available in the other RFMOs datasets.\n"))
description<-paste0(description,"- For the Southern Bluefin Tuna, only data from ",SBF_data_rfmo_to_keep," were kept\n")

cat(paste0("Keeping only data from ",SBF_data_rfmo_to_keep," for the Southern Bluefin Tuna OK\n"))