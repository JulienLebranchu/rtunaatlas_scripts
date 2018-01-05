cat("Mapping code lists...\n")

cat("Reading the CSV containing the dimensions to map + the names of the code list mapping datasets. Code list mapping datasets must be available in the database. \n")
mapping_dataset<-read.csv(mapping_csv_mapping_datasets_url,stringsAsFactors = F,colClasses = "character")

function_map_dataset_codelists<-function(dataset_to_map,mapping_dataset,mapping_keep_src_code){
  # Get the dimensions to map from the mapping_dataset
  dimension_to_map<-unique(mapping_dataset$dimensions_to_map)
  # One by one, map the dimensions
  for (i in 1:length(dimension_to_map)){ # i takes the values of the dimensions to map
    if (dimension_to_map[i] %in% colnames(dataset_to_map)){
      mapping_dataset_this_dimension<-mapping_dataset %>% filter (dimensions_to_map == dimension_to_map[i])  
      df_mapping_final_this_dimension<-NULL
      for (j in 1:nrow(mapping_dataset_this_dimension)){ # With this loop, we extract one by one, for 1 given dimension, the code list mapping datasets from the DB. The last line of the loop binds all the code list mappings datasets for this given dimension.
        df_mapping<-rtunaatlas::extract_dataset(con,list_metadata_datasets(con,dataset_name=mapping_dataset_this_dimension$db_mapping_dataset_name[j]))  # Extract the code list mapping dataset from the DB
        df_mapping$source_authority<-mapping_dataset_this_dimension$source_authority[j]  # Add the dimension "source_authority" to the mapping dataset. That dimension is not included in the code list mapping datasets. However, it is necessary to map the code list.
        df_mapping_final_this_dimension<-rbind(df_mapping_final_this_dimension,df_mapping)
      }
      dataset_to_map<-rtunaatlas::map_codelist(dataset_to_map,df_mapping_final_this_dimension,dimension_to_map[i],mapping_keep_src_code)$df  # Codes are mapped by tRFMOs (source_authority) 
    }
  }
  
  return(dataset_to_map)
}

# fill metadata elements
lineage<-c(lineage,paste0("Coding systems and nomenclatures used to describe the data (e.g. gears, flags, species) may differ according to tRFMOs. Codes used by the tuna RFMOs in their respective datasets were mapped to global code lists (ISSCFG, ISO3 countries codes, ASFIS). These mappings have been done with the collaboration of the Secretariats. Some codes could not have been mapped to standard code lists, for some tRFMOs own-defined codes that usually are aggregation of existing codes (e.g. flag “IDPH” - Indonesia and Philippines – for WCPFC; species “Otun” - other tuna – for ICCAT). In those cases, the code for species was set to UNK (Unknown). However, these codes have been mapped with more aggregated code lists – i.e. group of species. Information regarding the data that have species set to Unknown (i.e. data for which raw species do not have any correspondence in ASFIS): the catches that have species set to Unknown represent percentage_catches_species_unknown_mt % of the catches expressed in weight and percentage_catches_species_unknown_no % of the catches expressed in number of fishes."))
description<-paste0(description,"- Original code were mapped with standard FAO code lists (for gears, species, flags). These mappings were in collaboration with the RFMOs secretariats.\n")
supplemental_information<-paste0(supplemental_information,"- Some codes could not have been mapped to standard code lists, for some tRFMOs own-defined codes that usually are aggregation of existing codes (e.g. flag IDPH - Indonesia and Philippines for WCPFC; species Otun - other tuna for ICCAT). In those cases, the code for species was set to UNK (Unknown). However, these codes have been mapped with more aggregated code lists i.e. group of species.\n")

cat("Mapping code lists OK\n")