generate_tuna_atlas_persistent_identifier<-function(metadata_and_parameterization,fact){
  
  # Get input parameters names and values
  parameters_columns<-colnames(metadata_and_parameterization)[which(grepl("parameter_",colnames(metadata_and_parameterization)))]
  for (i in 1:length(parameters_columns)){
    assign(gsub("parameter_","",parameters_columns[i]), metadata_and_parameterization[,parameters_columns[i]],envir=.GlobalEnv)
  }
  
  ## spatialcoverage
  spatialcoverage<-NULL
  if (include_IOTC=="TRUE") {
    spatialcoverage=c(spatialcoverage,"indian")
  }
  if (include_ICCAT=="TRUE") {
    spatialcoverage=c(spatialcoverage,"atlantic")
  }
  if (include_IATTC=="TRUE") {
    spatialcoverage=c(spatialcoverage,"east_pacific")
  }
  if (include_WCPFC=="TRUE") {
    spatialcoverage=c(spatialcoverage,"west_pacific")
  }
  if (include_CCSBT=="TRUE") {
    spatialcoverage=c(spatialcoverage,"southern_hemispheres")
  }
  
  spatialcoverage<-paste(spatialcoverage,sep="",collapse="_")
  spatialcoverage<-paste(spatialcoverage,"oceans",sep="_")
  
  if (include_IOTC=="TRUE" && include_ICCAT=="TRUE" && include_IATTC=="TRUE" && include_WCPFC=="TRUE" && include_CCSBT=="TRUE"){
    spatialcoverage="global"
  } 
  
  ## spatial resolution
  if (aggregate_on_5deg_data_with_resolution_inferior_to_5deg=="TRUE" && disaggregate_on_5deg_data_with_resolution_superior_to_5deg %in% c("disaggregate","remove")){
    spatialresolution="5deg"
  }
  if (disaggregate_on_1deg_data_with_resolution_superior_to_1deg %in% c("disaggregate","remove")){
    spatialresolution="1deg"
  }
  
  
  ## temporal resolution
  temporalresolution="1m"
  
  ## source
  source<-paste0("tunaatlas",tolower(metadata_and_parameterization$source))
  
  ## level
  if (unit_conversion_convert=="FALSE" && spatial_curation_data_mislocated %in% c("no_reallocation","remove") && raising_georef_to_nominal=="FALSE") {
    level<-"level0"
  } else if (unit_conversion_convert=="TRUE" && spatial_curation_data_mislocated=="reallocate" && raising_georef_to_nominal=="FALSE"){
    level<-"level1"
  } else if (unit_conversion_convert=="TRUE" && spatial_curation_data_mislocated=="reallocate" && raising_georef_to_nominal=="TRUE"){
    level<-"level2"
  } else {
    level<-NULL
  }
  
  ## generate persistent identifier 
  persistent_identifier<-paste(spatialcoverage,fact,spatialresolution,temporalresolution,source,level,sep="_")
  return(persistent_identifier)
  
}