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


cat("Mapping code lists OK\n")