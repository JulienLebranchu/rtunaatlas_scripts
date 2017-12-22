######################################################################
##### 52North WPS annotations ##########
######################################################################
# wps.des: id = transform_and_load_source_datasets, title = Harmonize and load the primary tRFMOs dataset to the Tuna atlas database, abstract = Harmonize the structure of the primary tuna RFMOs datasets and load them within the Tuna Atlas database;
# wps.in: id = path_to_table_metadata_raw_datasets, type = string, title = Path to the table containing the metadata of the primary tRMFOs datasets to transform and load. See documentation to understand how this table must be filled. , value = "https://raw.githubusercontent.com/ptaconet/rtunaatlas_scripts/master/tunaatlas_world/metadata_source_datasets/metadata_raw_datasets_2017.csv";
# wps.in: id = db_name, type = string, title = Name of the database. , value = "tunaatlas";
# wps.in: id = host, type = string, title = Host server for the database. , value = "db-tuna.d4science.org";
# wps.in: id = db_admin_name, type = string, title = Name of the administrator role. , value = "tunaatlas_u";
# wps.in: id = admin_password, type = string, title = Password for administrator role of the database. , value = "****";



path_to_table_metadata_raw_datasets<-"https://raw.githubusercontent.com/ptaconet/rtunaatlas_scripts/master/tunaatlas_world/metadata_source_datasets/metadata_raw_datasets_2017.csv"
db_name="tunaatlas"
host="db-tuna.d4science.org"
db_admin_name="tunaatlas_u"
admin_password="****"



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
con <- dbConnect(drv, dbname=db_name, user=db_admin_name, password=admin_password, host=host)

# Read the table path_to_table_metadata_raw_datasets
table_metadata_raw_datasets<-read.csv(path_to_table_metadata_raw_datasets,stringsAsFactors = F)


# One by one, 1) harmonize the structure of the dataset and 2) load the dataset in the DB

for (df_to_harmonize in 1:nrow(table_metadata_raw_datasets)){

  rm(list=setdiff(ls(), c("df_to_harmonize","table_metadata_raw_datasets","con")))
  
  #### 1) Harmonize the structure
  cat(paste0("Start harmonization of ",table_metadata_raw_datasets$persistent_identifier[df_to_harmonize],"...\n"))
  
  # Get URL where primary dataset is stored 
  path_to_raw_dataset<-table_metadata_raw_datasets$source_dataset_path_dataset[df_to_harmonize]
  
  # Deal with special cases east_pacific_ocean_catch_5deg_1m_ll_tunaatlasIATTC_level0__shark and east_pacific_ocean_catch_5deg_1m_ll_tunaatlasIATTC_level0__tuna_billfish where there are 2 input datasets instead of 1
  if (table_metadata_raw_datasets$persistent_identifier[df_to_harmonize] %in% c("east_pacific_ocean_catch_5deg_1m_ll_tunaatlasIATTC_level0__shark","east_pacific_ocean_catch_5deg_1m_ll_tunaatlasIATTC_level0__tuna_billfish")){
    path_to_catch_dataset<-path_to_raw_dataset
    
    if (table_metadata_raw_datasets$persistent_identifier[df_to_harmonize]=="east_pacific_ocean_catch_5deg_1m_ll_tunaatlasIATTC_level0__shark"){
    path_to_effort_dataset<-table_metadata_raw_datasets$source_dataset_path_dataset[which(table_metadata_raw_datasets$persistent_identifier=="east_pacific_ocean_effort_5deg_1m_ll_tunaatlasIATTC_level0__shark")]
    }
    if (table_metadata_raw_datasets$persistent_identifier[df_to_harmonize]=="east_pacific_ocean_catch_5deg_1m_ll_tunaatlasIATTC_level0__tuna_billfish"){
      path_to_effort_dataset<-table_metadata_raw_datasets$source_dataset_path_dataset[which(table_metadata_raw_datasets$persistent_identifier=="east_pacific_ocean_effort_5deg_1m_ll_tunaatlasIATTC_level0__tuna_billfish")]
    }
  }
  
  # Deal with special cases atlantic_ocean_nominal_catch_tunaatlasICCAT_level0__bySamplingArea and atlantic_ocean_nominal_catch_tunaatlasICCAT_level0__byStockArea where there are 2 input datasets instead of 1
  if (table_metadata_raw_datasets$persistent_identifier[df_to_harmonize] == "atlantic_ocean_nominal_catch_tunaatlasICCAT_level0__bySamplingArea"){
    spatial_stratification<-"SampAreaCode"
  }
  if (table_metadata_raw_datasets$persistent_identifier[df_to_harmonize] == "atlantic_ocean_nominal_catch_tunaatlasICCAT_level0__byStockArea"){
    spatial_stratification<-"Stock"
  }
  
  path_to_metadata_file<-table_metadata_raw_datasets[df_to_harmonize,]
  # Harmonize the structure through the harmonization script. The input parameters of the script are path_to_raw_dataset and path_to_metadata_file. Output is the dataset harmonized
  source(table_metadata_raw_datasets$source_dataset_path_harmonization_script[df_to_harmonize])
  
  # To check if everything is ok:
  # str(dataset)
  # str(df_metadata)
  # str(df_codelists)
  
   cat(paste0("End of harmonization of ",table_metadata_raw_datasets$persistent_identifier[df_to_harmonize],"\n"))
   
  #### 2) Load dataset and metadata in the database
  cat(paste0("Start load in the database of ",table_metadata_raw_datasets$persistent_identifier[df_to_harmonize],"...\n"))
  
  df_codelists <- data.frame(lapply(df_codelists, as.character), stringsAsFactors=FALSE)
  # Load the dataset in database
  rtunaatlas::load_raw_dataset_in_db(con=con,
                                  df_to_load=dataset,
                                  df_metadata=df_metadata,
                                  df_codelists_input= df_codelists)
  
  cat(paste0("End load in the database of ",table_metadata_raw_datasets$persistent_identifier[df_to_harmonize],"\n"))
  
}

