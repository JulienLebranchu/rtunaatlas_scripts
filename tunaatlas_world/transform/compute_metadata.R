cat("Generating dataset of metadata...\n")
# Read metadata file
if (typeof(path_to_df_metadata)=="character"){
  df_metadata<-read.csv(path_to_df_metadata,stringsAsFactors = F)
} else {
  df_metadata<-path_to_df_metadata
}

### Get dataset_time_start and dataset_time_end
df_metadata$dataset_time_start<-as.character(min(as.Date(dataset$time_start)))
df_metadata$dataset_time_end<-as.character(max(as.Date(dataset$time_end)))

### Get datasets of code lists to load the dataset in the DB
df_codelists<-read.csv(df_metadata$source_dataset_path_csv_codelists)

# generate metadata file
df_metadata<-rtunaatlas::generate_metadata(df_metadata,"raw_dataset")

