# workflow_tuna_atlas_dataset_to_generate_and_load

  workflow_tuna_atlas_dataset_to_generate_and_load<-function(con_admin,metadata_and_parameterization,year_tuna_atlas,vre_username,vre_token){
  
  cat(paste0("Start processing dataset ",metadata_and_parameterization$persistent_identifier,"\n"))
  
  # Generate dataset
  dataset_and_metadata<-generate_dataset(metadata_and_parameterization)
  dataset<-dataset_and_metadata$dataset
  additional_metadata<-dataset_and_metadata$metadata
  
  # Generate tuna atlas identifier
  metadata_and_parameterization$identifier<-generate_tuna_atlas_identifier(metadata_and_parameterization,dataset,year_tuna_atlas)
  
  # Push R script of dataset generation to the server
  metadata_and_parameterization<-push_R_script_to_server(metadata_and_parameterization,virtual_repository_with_R_files,vre_username,vre_token)
  
  # In the metadata, add a link to the primary tRFMO dataset stored permanently
  metadata_and_parameterization$relation_source_dataset_persistent_url<-metadata_and_parameterization$parameter_path_to_raw_dataset
  
  # Generate metadata
  df_metadata<-rtunaatlas::generate_metadata(metadata_and_parameterization,dataset,metadata=additional_metadata)
  
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
  