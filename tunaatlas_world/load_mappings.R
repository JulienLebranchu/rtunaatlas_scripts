######################################################################
##### 52North WPS annotations ##########
######################################################################
# wps.des: id = load_mappings, title = Load the mappings between code lists in the Tuna atlas database, abstract = Load the mapping between code lists in the Tuna atlas database;
# wps.in: id = path_to_table_metadata_mappings, type = string, title = Path to the table containing the metadata of the code list mappings to load. See documentation to understand how this table must be filled. , value = "https://raw.githubusercontent.com/ptaconet/rtunaatlas_scripts/master/tunaatlas_world/metadata_source_datasets/metadata_mappings_2017.csv";
# wps.in: id = db_name, type = string, title = Name of the database. , value = "tunaatlas";
# wps.in: id = host, type = string, title = Host server for the database. , value = "db-tuna.d4science.org";
# wps.in: id = db_admin_name, type = string, title = Name of the administrator role. , value = "tunaatlas_u";
# wps.in: id = admin_password, type = string, title = Password for administrator role of the database. , value = "****";

path_to_table_metadata_mappings<-"https://raw.githubusercontent.com/ptaconet/rtunaatlas_scripts/master/tunaatlas_world/metadata_source_datasets/metadata_mappings_2017.csv"
db_name="tunaatlas"
host="db-tuna.d4science.org"
db_admin_name="tunaatlas_u"
admin_password="****"

if(!require(RPostgreSQL)){
  install.packages("RPostgreSQL")
}
if(!require(dplyr)){
  install.packages("dplyr")
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
require(dplyr)

# Connect to db with write rights
drv <- dbDriver("PostgreSQL")
con <- dbConnect(drv, dbname=db_name, user=db_admin_name, password=admin_password, host=host)

# Read the table path_to_table_metadata_mappings
table_metadata_mappings<-read.csv(path_to_table_metadata_mappings,stringsAsFactors = F)


# One by one, load the code lists in the db

for (k in 1:nrow(table_metadata_mappings)){
  
  rm(list=setdiff(ls(), c("k","table_metadata_mappings","con")))
  
  # Read metadata
  df_metadata<-table_metadata_mappings[k,]
  
  cat(paste0("\nLoading ",df_metadata$persistent_identifier," in the database...\n"))
  
  # If the dataset is remote (ie stored on internet), download it locally to avoid errors when reading the dataset
  if (substr(df_metadata$source_dataset_path_dataset,1,4)=="http"){
    file_remote=TRUE
    cat(paste0("Downloading the file locally...\n"))
    file_name<-Sys.time()
    file_name<-gsub("-","_",Sys.time())
    file_name<-gsub(" ","_",file_name)
    file_name<-gsub(":","_",file_name)
    download.file(df_metadata$source_dataset_path_dataset,paste0(getwd(),"/",file_name,".csv"))
    df_metadata$source_dataset_path_dataset<-paste0(getwd(),"/",file_name,".csv")
    cat(paste0("END downloading the file locally\n"))
  } else { file_remote=FALSE }
  
  # Read code list
  df_to_load<-read.csv(df_metadata$source_dataset_path_dataset,stringsAsFactors = FALSE )
  
  # harmonize metadata
  df_metadata<-rtunaatlas::generate_metadata(df_metadata,"mapping")
  
  # Load in DB
  rtunaatlas::load_mapping_in_db(con,df_to_load,df_metadata)
  
  # Remove file from local
  if (file_remote==TRUE){
    file.remove(paste0(getwd(),"/",file_name,".csv"))
  }
  
  cat(paste0("\nEND load ",df_metadata$identifier," in the database\n"))
  
}
