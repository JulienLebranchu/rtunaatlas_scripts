# workflow_tuna_atlas_dataset_to_generate_and_load

  workflow_tuna_atlas_dataset_to_generate_and_load<-function(con_admin,metadata_and_parameterization,year_tuna_atlas,vre_username,vre_token){
  
  cat(paste0("Start processing dataset ",metadata_and_parameterization$persistent_identifier,"\n"))
  
  # Generate dataset(s)
  dataset_and_metadata<-generate_dataset(metadata_and_parameterization)
  
  # in the case there is only 1 dataset in output of the script
  if (!is.list(dataset_and_metadata$dataset)){
    dataset_and_metadata$dataset<-list(dataset_and_metadata$dataset)
    dataset_and_metadata$additional_metadata<-list(dataset_and_metadata$additional_metadata)
  }
  
  # One by one load the datasets with their metadata
  for (n_dataset_to_load in 1:length(dataset_and_metadata$dataset)){
  dataset<-dataset_and_metadata$dataset[[n_dataset_to_load]]
  additional_metadata<-dataset_and_metadata$additional_metadata[[n_dataset_to_load]]
  
  # Complete metadata with values available in additional_metadata
  metadata_and_parameterization<-fill_missing_metadata(metadata_and_parameterization,additional_metadata)

  # Generate tuna atlas identifier
  metadata_and_parameterization$identifier<-generate_tuna_atlas_identifier(metadata_and_parameterization,dataset,year_tuna_atlas)
  
  # Push R script of dataset generation to the server
  metadata_and_parameterization<-push_R_script_to_server(metadata_and_parameterization,virtual_repository_with_R_files,vre_username,vre_token)
  
  # In the metadata, add the date of generation of the dataset
  metadata_and_parameterization$date<-paste0("publication=",Sys.Date(),";")
  
  # Generate metadata
  df_metadata<-rtunaatlas::generate_metadata(metadata_and_parameterization,dataset,additional_metadata=additional_metadata)
  
  # Open code list data frame. Either it is stored or it is generated in the dataset_and_metadata
  if (!is.na(metadata_and_parameterization$path_to_codelists_used_in_dataset)){
    df_codelists<-get_data_frame_code_lists(metadata_and_parameterization)
  } else {
    df_codelists<-dataset_and_metadata$df_codelists 
  }
  
  # Load dataset and metadata
    rtunaatlas::load_raw_dataset_in_db(con=con_admin,
                                       df_to_load=dataset,
                                       df_metadata=df_metadata,
                                       df_codelists_input=df_codelists)
  
  cat(paste0("End processing dataset ",metadata_and_parameterization$persistent_identifier,"\n"))
  
  }
  
}