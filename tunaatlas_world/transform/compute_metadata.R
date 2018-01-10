cat("Generating dataset of metadata...\n")
# Read metadata file
if (typeof(path_to_metadata_file)=="character"){
  df_metadata<-read.csv(path_to_metadata_file,stringsAsFactors = F)
} else {
  df_metadata<-path_to_metadata_file
}

### Get dataset_time_start and dataset_time_end
df_metadata$dataset_time_start<-as.character(min(as.Date(dataset$time_start)))
df_metadata$dataset_time_end<-as.character(max(as.Date(dataset$time_end)))

### Get list of dimensions associated to the dataset
# Check one by one if the columns have different values
dimensions<-NULL
for (col in 1:ncol(dataset)){
  dimension_name<-colnames(dataset[col])
  if (!(dimension_name %in% c("value","time_start","time_end"))){
    unique_values<-unique(dataset[dimension_name])
    if (nrow(unique_values)>1){
      dimensions<-paste(dimensions,dimension_name,sep=", ")
    }
  }
}

if ("time_start" %in% colnames(dataset)){
  dimensions<-paste(dimensions,"time",sep=", ")
}

dimensions<-substring(dimensions, 2)

df_metadata$subject<-paste0("DIMENSIONS =",dimensions," ; ",df_metadata$subject)

# generate metadata file
df_metadata<-rtunaatlas::generate_metadata(df_metadata,"raw_dataset")

