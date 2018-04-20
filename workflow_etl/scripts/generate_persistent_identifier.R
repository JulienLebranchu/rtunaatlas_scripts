generate_persistent_identifier<-function(metadata_and_parameterization,additional_metadata){
  
  words_to_replace<-gsub("[\\%\\%]", "", regmatches(metadata_and_parameterization$persistent_identifier, gregexpr("\\%.*?\\%", metadata_and_parameterization$persistent_identifier))[[1]])
  
  if (length(words_to_replace)>0){
    for (j in 1:length(words_to_replace)){
      if (words_to_replace[j] %in% names(additional_metadata)){
        persistent_identifier<-gsub(paste0("%",words_to_replace[j],"%"),as.character(additional_metadata[words_to_replace[j]]),metadata_and_parameterization$persistent_identifier)
      }
    }
  } else {
    persistent_identifier<-metadata_and_parameterization$persistent_identifier
  }
  
  return(persistent_identifier) 
}
  