######################################################################
##### 52North WPS annotations ##########
######################################################################
# wps.des: id = load_datasets_in_database, title = Load datasets in the database , abstract = This script enable to load a dataset and related metadata in the database;
# wps.in: id = path_to_table_parameterization_datasets, type = string, title = Path to the table containing the metadata and parameters. See documentation to understand how this table must be filled. , value = "https://raw.githubusercontent.com/ptaconet/rtunaatlas_scripts/master/tunaatlas_world/metadata_and_parameterization_files/metadata_codelists_2017.csv";
# wps.in: id = year_tuna_atlas, type = string, title = Year of the Tuna atlas , value = "2017";
# wps.in: id = db_name, type = string, title = Name of the database. , value = "tunaatlas";
# wps.in: id = host, type = string, title = Host server for the database. , value = "db-tuna.d4science.org";
# wps.in: id = db_admin_name, type = string, title = Name of the administrator role. , value = "tunaatlas_u";
# wps.in: id = admin_password, type = string, title = Password for administrator role of the database. , value = "****";

rm(list=ls(all=TRUE))

path_to_table_parameterization_datasets<-"https://raw.githubusercontent.com/ptaconet/rtunaatlas_scripts/master/tunaatlas_world/metadata_and_parameterization_files/metadata_and_parameterization_tuna_atlas_datasets_2017.csv"
virtual_repository_with_R_files="/Workspace/VRE Folders/FAO_TunaAtlas/R_scripts/datasets_creation"
year_tuna_atlas="2017"
db_name="tunaatlas"
host="db-tuna.d4science.org"
db_admin_name="tunaatlas_u"
admin_password="21c0551e7ed2911"


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

## open csv that contain the parameterization of the tuna atlas datasets
metadata_and_parameterization_dataset<-read.csv(path_to_table_parameterization_datasets,stringsAsFactors = F,colClasses = "character")

## Execute each row of the dataset

for (df_to_load in 1:nrow(metadata_and_parameterization_dataset)){
  
rm(list=setdiff(ls(), c("metadata_and_parameterization_dataset","df_to_load","con_admin","year_tuna_atlas","virtual_repository_with_R_files")))
  
# Retrieve only the row for the current metadata dataset
metadata_and_parameterization_this_df<-metadata_and_parameterization_dataset[df_to_load,]

cat(paste0("Start processing dataset ",metadata_and_parameterization_this_df$persistent_identifier,"\n"))

## Two cases: either the dataset is already created, or it has to be created with an R script.
# If the dataset is already created, the column "path_to_dataset" is filled with the url where the dataset (in csv format) is available. In this case, we get the dataset as data.frame
# If the dataset is not generated, it will be generated through an R script. The path to the R script as well as the parameterization for the dataset to generate are stored on a csv file. The path to this csv file is available in the column "path_to_parameterization_file_to_generate_dataset" 
if (!(is.na(metadata_and_parameterization_this_df$path_to_dataset))){
  
  # If the dataset is remote (ie stored on internet), download it locally to avoid errors when reading the dataset
  if (substr(metadata_and_parameterization_this_df$path_to_dataset,1,4)=="http"){
    cat(paste0("Downloading the file locally...\n"))
    file_name<-Sys.time()
    file_name<-gsub("-","_",Sys.time())
    file_name<-gsub(" ","_",file_name)
    file_name<-gsub(":","_",file_name)
    download.file(metadata_and_parameterization_this_df$path_to_dataset,paste0(getwd(),"/",file_name,".csv"))
    metadata_and_parameterization_this_df$path_to_dataset<-paste0(getwd(),"/",file_name,".csv")
    cat(paste0("END downloading the file locally\n"))
  }
  
  # Read the file. All the columns are read as characters
  cat(paste0("Reading the file...\n"))
  dataset<-read.csv(metadata_and_parameterization_this_df$path_to_dataset,stringsAsFactors = FALSE,colClasses="character")
  file.remove(paste0(getwd(),"/",file_name,".csv"))
} else { # In that case, the dataset is generated through an R script. The path to the R script as well as the parameterization for the dataset to generate are stored on a csv file. The path to this csv file is available in the column "path_to_parameterization_file_to_generate_dataset"
  
  # Read parameterization file 
  parameterization_file<-read.csv(metadata_and_parameterization_this_df$path_to_parameterization_file_to_generate_dataset,stringsAsFactors = FALSE,colClasses="character")
  
  # Retrieve only current line (based on persistent_identifier)
  parameterization_this_df<-parameterization_file[which(parameterization_file$persistent_identifier==metadata_and_parameterization_this_df$persistent_identifier),]
  
  # Get input parameters for the script
  parameters_columns<-setdiff(colnames(parameterization_this_df),c("persistent_identifier","path_to_script_dataset_generation"))
  for (i in 1:length(parameters_columns)){
    assign(parameters_columns[i], parameterization_this_df[,parameters_columns[i]])
  }
  
  ## Source script to generate the dataset, with above parameterization
  cat("Starting generation of the dataset...\n")
  source(parameterization_this_df$path_to_script_dataset_generation)
  dataset$time_start<-substr(as.character(dataset$time_start), 1, 10)
  dataset$time_end<-substr(as.character(dataset$time_end), 1, 10)
  dataset<-data.frame(dataset)
  
  cat("End generation of the dataset\n")
  
  # at this point, the dataset is generated and is available as an R data.frame named "dataset"
  
}
  

### Generate metadata dataset
# Before executing the function "generate_metadata_dataset", some metadata have to be filled or completed (in case of a raw_dataset)
if(metadata_and_parameterization_this_df$dataset_type=="raw_dataset"){
  
### identifier
dataset_time_start<-as.character(min(as.Date(dataset$time_start)))
dataset_time_end<-as.character(max(as.Date(dataset$time_end)))
metadata_and_parameterization_this_df$identifier<-gsub("tunaatlas",paste(dataset_time_start,dataset_time_end,"tunaatlas",sep="_"),metadata_and_parameterization_this_df$persistent_identifier)
metadata_and_parameterization_this_df$identifier<-gsub("level",paste0(year_tuna_atlas,"_level"),metadata_and_parameterization_this_df$identifier)
metadata_and_parameterization_this_df$identifier<-gsub("-","_",metadata_and_parameterization_this_df$identifier)
  
}  else {
  metadata_and_parameterization_this_df$identifier<-metadata_and_parameterization_this_df$persistent_identifier
} 

### If the dataset was generated by a R script, push the script to a server and save its path in the metadata under the column "relation" with name 'script_dataset_generation'
if (is.na(metadata_and_parameterization_this_df$path_to_dataset)){
  ## Save the R code with the parameterization for the current dataset
  RFileName<-paste0(metadata_and_parameterization_this_df$identifier,".R")
  download.file(parameterization_this_df$path_to_script_dataset_generation,paste0(getwd(),"/",RFileName))
  fConn <- file(paste0(getwd(),"/",RFileName), 'r+')
  Lines <- readLines(fConn)
  parameters_with_values<-NULL
  for (i in 1:length(parameters_columns)){
    if (nchar(parameterization_this_df[,parameters_columns[i]])>0){
      parameters_with_values<-paste0(parameters_with_values,parameters_columns[i],"<-'",parameterization_this_df[,parameters_columns[i]],"'\n")
    }
  }
  writeLines(c(paste0("### Parameters \n",parameters_with_values,"\n"), Lines), con = fConn) 
  
  close(fConn)
 
 ## Push R code in the VRE WS
  source("http://svn.research-infrastructures.eu/public/d4science/gcube/trunk/data-analysis/RConfiguration/RD4SFunctions/workspace_interaction.r")
  uploadWS(virtual_repository_with_R_files,RFileName,overwrite=T)
  RFileURL <- getPublicFileLinkWS(paste(virtual_repository_with_R_files,RFileName,sep="/"))
  
 ## Add URL to the metadata
  metadata_and_parameterization_this_df$relation_script_dataset_generation<-RFileURL
 
 ## remove R script from local
 file.remove(paste0(getwd(),"/",RFileName))
  
}
  

# Complete metadata with any other parameter that might have been generated through the R script of dataset generation. It will be pasted
parameters<-colnames(metadata_and_parameterization_this_df)
for (i in 1:length(parameters)){
  if (exists(parameters[i],mode="character")){
    metadata_and_parameterization_this_df[,parameters[i]]<-gsub("@@automatically generated@@","",metadata_and_parameterization_this_df[,parameters[i]])
    metadata_and_parameterization_this_df[,parameters[i]]<-paste(metadata_and_parameterization_this_df[,parameters[i]],get(parameters[i]),sep="\n")
  }
}

df_metadata<-rtunaatlas::generate_metadata(metadata_and_parameterization_this_df,dataset)


## In case of a raw_dataset, the loading function takes as input parameter a csv containing, for each dimension, to code lists used. The code lists must be available on the DB.
# Either the path to the csv is set on the metadata file (in this case, the column 'path_to_codelists_used_in_dataset' is not set to [automatically generated]), or it is generated in the R script that generates the dataset
if(metadata_and_parameterization_this_df$dataset_type=="raw_dataset"){
  if (metadata_and_parameterization_this_df$path_to_codelists_used_in_dataset!="@@automatically generated@@"){
    ### Get datasets of code lists to load the dataset in the DB
    df_codelists<-read.csv(metadata_and_parameterization_this_df$path_to_codelists_used_in_dataset)
    df_codelists<-data.frame(lapply(df_codelists, as.character), stringsAsFactors=FALSE)
  }
}



# Load the dataset in database
cat("Loading dataset in the db...\n")
if (metadata_and_parameterization_this_df$dataset_type=="raw_dataset"){
rtunaatlas::load_raw_dataset_in_db(con=con_admin,
                                  df_to_load=dataset,
                                  df_metadata=df_metadata,
                                  df_codelists_input=df_codelists)
} else if (metadata_and_parameterization_this_df$dataset_type=="codelist"){
  rtunaatlas::load_codelist_in_db(con=con_admin,
                                     df_to_load=dataset,
                                     df_metadata=df_metadata)
  
} else if (metadata_and_parameterization_this_df$dataset_type=="mapping"){
  rtunaatlas::load_mapping_in_db(con=con_admin,
                                  df_to_load=dataset,
                                  df_metadata=df_metadata)
  
}

cat("End loading dataset in the db\n")

cat(paste0("End processing dataset ",metadata_and_parameterization_this_df$persistent_identifier,"\n"))

  
}
