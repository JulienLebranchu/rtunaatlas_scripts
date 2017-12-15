
# Read metadata file
if (typeof(metadata_file)=="character"){
metadata_file<-read.csv(path_to_metadata_file,stringsAsFactors = F)
} else {
metadata_file<-path_to_metadata_file
}

##### Generate the dataset of metadata, that will be loaded in the DB
df_metadata<-NULL

### dataset_time_start and dataset_time_starttime_end
df_metadata$dataset_time_start<-as.character(min(as.Date(dataset$time_start)))
df_metadata$dataset_time_end<-as.character(max(as.Date(dataset$time_end)))

### identifier
df_metadata$identifier<-gsub("tunaatlas",paste(df_metadata$dataset_time_start,df_metadata$dataset_time_end,"tunaatlas",sep="_"),metadata_file$persistent_identifier)
df_metadata$identifier<-gsub("level0",paste(metadata_file$year_tuna_atlas,"level0",sep="_"),df_metadata$identifier)
df_metadata$identifier<-gsub("-","_",df_metadata$identifier)

### persistent_identifier
df_metadata$persistent_identifier<-persistent_identifier

### title
df_metadata$title<-gsub("%date_start%",substr(df_metadata$dataset_time_start,1,4),metadata_file$title)
df_metadata$title<-gsub("%date_end%",substr(df_metadata$dataset_time_end,1,4),df_metadata$title)

### contacts_and_roles

## Function to generate contacts_and_roles when there are multiple roles
create_contacts_and_roles<-function(contacts_metadata_file,role_name){
  cont<-strsplit(contacts_metadata_file,split=";")[[1]] 
  contact<-NULL
  for (i in 1:length(cont)){
    contact<-paste0(contact,role_name,"=",cont[i],";")
  }
  return(contact)
}

## Get contacts and roles (all except for processor which will be dealt separately)
columns_contacts_and_roles<-colnames(metadata_file)[grep("contact_",colnames(metadata_file))]
columns_contacts_and_roles<-setdiff(columns_contacts_and_roles,"contact_processor")
roles<-gsub("contact_","",columns_contacts_and_roles)

contacts_and_roles<-NULL
for (j in 1:length(columns_contacts_and_roles)){
  contact_j<-create_contacts_and_roles(metadata_file[,columns_contacts_and_roles[j]],roles[j])
  contacts_and_roles<-paste0(contacts_and_roles,contact_j)
}

## Get contact and roles for processor
# Get number of steps
position_max_number_step<-max(gregexpr(pattern ="step\\d",metadata_file$lineage)[[1]])
number_of_steps<-substr(metadata_file$lineage, position_max_number_step+4, position_max_number_step+4)
number_of_steps<-as.numeric(number_of_steps)
# Create contacts_and_roles for processors
contact_processor<-NULL
for (i in 1:number_of_steps){
  contact_processor<-paste0(contact_processor,"processor_step",i,"=",metadata_file$contact_processor,";")
}


df_metadata$contacts_and_roles<-paste0(contacts_and_roles,contact_processor)

### subject
df_metadata$subject<-metadata_file$subject

### description
df_metadata$description<-metadata_file$description

### date
columns_dates<-colnames(metadata_file)[grep("date_",colnames(metadata_file))]
roles<-gsub("date_","",columns_dates)

date<-NULL
for (j in 1:length(columns_dates)){
  date<-paste0(date,roles[j],"=",metadata_file[,columns_dates[j]],";")
}

df_metadata$date<-date

### format
df_metadata$format<-metadata_file$format

### language
df_metadata$language<-metadata_file$language


### relation
columns_relation<-colnames(metadata_file)[grep("relation_",colnames(metadata_file))]
roles<-gsub("relation_","",columns_relation)

relation<-NULL
for (j in 1:length(columns_relation)){
  relation<-paste0(relation,roles[j],"=",metadata_file[,columns_relation[j]],";")
}

df_metadata$relation<-relation

### spatial_coverage
# TO DO AFTER THE UPLOAD OF THE DATASET

### temporal_coverage
df_metadata$temporal_coverage<-paste0("start=",df_metadata$dataset_time_start,";end=",df_metadata$dataset_time_end,";")

### rights
df_metadata$rights<-metadata_file$rights

### source
df_metadata$source<-metadata_file$source

### lineage
df_metadata$lineage<-gsub("%date_download%",metadata_file$date_download,metadata_file$lineage)
df_metadata$lineage<-gsub("%relation_source_dataset%",metadata_file$relation_source_dataset,df_metadata$lineage)
df_metadata$lineage<-gsub("%relation_source_download%",metadata_file$relation_source_download,df_metadata$lineage)

### supplemental_information
df_metadata$supplemental_information<-metadata_file$supplemental_information

### dataset_type
df_metadata$dataset_type<-"raw_dataset"

### sql_query_dataset_extraction
# TO DO AFTER THE UPLOAD OF THE DATASET

### database_table_name
df_metadata$database_table_name<-metadata_file$database_table_name

### database_view_name
df_metadata$database_view_name<-metadata_file$database_view_name


df_metadata<-data.frame(df_metadata,stringsAsFactors = FALSE)



### Get datasets of code lists to load the dataset in the DB
df_codelists<-read.csv(metadata_file$source_dataset_path_csv_codelists)
