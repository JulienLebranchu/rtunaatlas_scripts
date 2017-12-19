cat("Generating dataset of metadata...\n")
# Read metadata file
if (typeof(path_to_metadata_file)=="character"){
  metadata_file<-read.csv(path_to_metadata_file,stringsAsFactors = F)
} else {
  metadata_file<-path_to_metadata_file
}

### Get dataset_time_start and dataset_time_end
metadata_file$dataset_time_start<-as.character(min(as.Date(dataset$time_start)))
metadata_file$dataset_time_end<-as.character(max(as.Date(dataset$time_end)))

### Get datasets of code lists to load the dataset in the DB
df_codelists<-read.csv(metadata_file$source_dataset_path_csv_codelists)

# generate metadata file
metadata_file<-rtunaatlas::generate_metadata(metadata_file,"raw_dataset")

