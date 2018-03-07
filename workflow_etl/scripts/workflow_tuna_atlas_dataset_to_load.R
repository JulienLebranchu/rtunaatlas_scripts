# workflow tuna atlas code list or code list mapping to load (already generated)

workflow_tuna_atlas_dataset_to_load<-function(con_admin,metadata_and_parameterization){
  
  cat(paste0("Start processing dataset ",metadata_and_parameterization$persistent_identifier,"\n"))
  
  # Open the dataset
  dataset<-open_dataset(metadata_and_parameterization) 
  
  # Provide tuna atlas identifier
  metadata_and_parameterization$identifier<-metadata_and_parameterization$persistent_identifier
  
  # Generate metadata
  df_metadata<-rtunaatlas::generate_metadata(metadata_and_parameterization,dataset)
  
  # Load dataset and metadata
  if (metadata_and_parameterization$dataset_type=="codelist"){
  rtunaatlas::load_codelist_in_db(con=con_admin,
                                  df_to_load=dataset,
                                  df_metadata=df_metadata)
  } else if (metadata_and_parameterization$dataset_type=="mapping"){
    rtunaatlas::load_mapping_in_db(con=con_admin,
                                    df_to_load=dataset,
                                    df_metadata=df_metadata)
  }
  cat(paste0("End processing dataset ",metadata_and_parameterization$persistent_identifier,"\n"))
 
}