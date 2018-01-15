


#year_tuna_atlas="2017"
#load_codelists=TRUE
#load_codelists_mappings=TRUE
#transform_and_load_primary_datasets=TRUE
#generate_and_load_global_tuna_atlas_datasets=TRUE
#metadata_and_parameterization_csv_codelists<-"https://raw.githubusercontent.com/ptaconet/rtunaatlas_scripts/master/tunaatlas_world/metadata_and_parameterization_files/metadata_codelists_2017.csv"
#metadata_and_parameterization_csv_mappings<-"https://raw.githubusercontent.com/ptaconet/rtunaatlas_scripts/master/tunaatlas_world/metadata_and_parameterization_files/metadata_mappings_2017.csv"
#metadata_and_parameterization_csv_primary_datasets<-"https://raw.githubusercontent.com/ptaconet/rtunaatlas_scripts/master/tunaatlas_world/metadata_and_parameterization_files/metadata_and_parameterization_primary_datasets_2017.csv"
#metadata_and_parameterization_ird_tuna_atlas_datasets<-"https://raw.githubusercontent.com/ptaconet/rtunaatlas_scripts/master/tunaatlas_world/metadata_and_parameterization_files/metadata_and_parameterization_tuna_atlas_datasets_2017.csv"
#repository_R_scripts<-"https://raw.githubusercontent.com/ptaconet/rtunaatlas_scripts/master/tunaatlas_world/workflow_etl"
#virtual_repository_with_R_files="/Workspace/VRE Folders/FAO_TunaAtlas/R_scripts/datasets_creation"
#vre_username="paultaconet"
#vre_token="****"
#db_name="tunaatlas"
#host="db-tuna.d4science.org"
#db_admin_name="tunaatlas_u"
#admin_password="****"

if(!require(RPostgreSQL)){
  install.packages("RPostgreSQL")
}

if(!require(rtunaatlas)){
  if(!require(devtools)){
    install.packages("devtools")
  }
  require(devtools)
  install_github("ptaconet/rtunaatlas")
}

require(RPostgreSQL)
require(rtunaatlas)


# Connect to db with admin rights
drv <- dbDriver("PostgreSQL")
con_admin <- dbConnect(drv, dbname=db_name, user=db_admin_name, password=admin_password, host=host)

# Source scripts
source(paste(repository_R_scripts,"open_dataset.R",sep="/"))
source(paste(repository_R_scripts,"generate_dataset.R",sep="/"))
source(paste(repository_R_scripts,"get_data_frame_code_lists.R",sep="/"))
source(paste(repository_R_scripts,"generate_tuna_atlas_identifier.R",sep="/"))
source(paste(repository_R_scripts,"push_R_script_to_server.R",sep="/"))
source(paste(repository_R_scripts,"workflow_tuna_atlas_dataset_to_load.R",sep="/"))
source(paste(repository_R_scripts,"workflow_tuna_atlas_dataset_to_generate_and_load.R",sep="/"))


## Main

if (load_codelists==TRUE){ ## Load the code lists
# Open csv metadata of code lists
table_metadata_and_parameterization<-read.csv(metadata_and_parameterization_csv_codelists,stringsAsFactors = F,colClasses = "character")
# One by one, load the code lists  
for (df_to_load in 1:nrow(table_metadata_and_parameterization)){
metadata_and_parameterization<-table_metadata_and_parameterization[df_to_load,]
workflow_tuna_atlas_dataset_to_load(con_admin,metadata_and_parameterization)
 }
}


if (load_codelists_mappings==TRUE){  ## Load the code lists mapping
# Open csv metadata of code list mappings
table_metadata_and_parameterization<-read.csv(metadata_and_parameterization_csv_mappings,stringsAsFactors = F,colClasses = "character")
# One by one, load the code lists mappings
for (df_to_load in 1:nrow(table_metadata_and_parameterization)){
metadata_and_parameterization<-table_metadata_and_parameterization[df_to_load,]
workflow_tuna_atlas_dataset_to_load(con_admin,metadata_and_parameterization)

 }
}


if (transform_and_load_primary_datasets==TRUE){  ### Harmonize and load the primary datasets
# Open csv metadata of primary datasets and related parameterization
table_metadata_and_parameterization<-read.csv(metadata_and_parameterization_csv_primary_datasets,stringsAsFactors = F,colClasses = "character")
# One by one, load the primary datasets
for (df_to_load in 1:nrow(table_metadata_and_parameterization)){
metadata_and_parameterization<-table_metadata_and_parameterization[df_to_load,]
workflow_tuna_atlas_dataset_to_generate_and_load(con_admin,metadata_and_parameterization,year_tuna_atlas,vre_username,vre_token)
 }
}


if (generate_and_load_global_tuna_atlas_datasets==TRUE){ ### Generate and load the global tuna atlas datasets
# Open csv metadata of ird tuna atlas datasets and related parameterization
table_metadata_and_parameterization<-read.csv(metadata_and_parameterization_ird_tuna_atlas_datasets,stringsAsFactors = F,colClasses = "character")
# One by one, generate and load the ird tuna atlas datasets
for (df_to_load in 1:nrow(table_metadata_and_parameterization)){
metadata_and_parameterization<-table_metadata_and_parameterization[df_to_load,]
workflow_tuna_atlas_dataset_to_generate_and_load(con_admin,metadata_and_parameterization,year_tuna_atlas,vre_username,vre_token)
 }
}

