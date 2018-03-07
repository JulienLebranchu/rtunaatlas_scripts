
rm(list=ls(all=TRUE))

### MANDATORY PARAMETERS
year_tuna_atlas="2017"
deploy_database_model=TRUE
load_codelists=TRUE
load_codelists_mappings=TRUE
transform_and_load_primary_datasets=TRUE
generate_and_load_global_tuna_atlas_datasets=TRUE
virtual_repository_with_R_files="/Workspace/VRE Folders/FAO_TunaAtlas/R_scripts/datasets_creation"
vre_username="paultaconet"
vre_token="***"
db_host="db-tuna.d4science.org"
db_name="tunaatlas"
db_admin_name="tunaatlas_u"
db_admin_password="***"

### OPTIONAL PARAMETERS depending on the values set in the mandatory parameters
## db_read_name,dimensions,variables_and_associated_dimensions : fill-in only if deploy_database_model==TRUE
db_read_name="tunaatlas_inv"
db_dimensions="area,catchtype,unit,flag,gear,schooltype,sex,sizeclass,species,time,source"
db_variables_and_associated_dimensions="catch=schooltype,species,time,area,gear,flag,catchtype,unit,source@effort=schooltype,time,area,gear,flag,unit,source@catch_at_size=schooltype,species,time,area,gear,flag,catchtype,sex,unit,sizeclass,source"

## metadata_and_parameterization_csv_codelists : fill-in only if load_codelists==TRUE
metadata_and_parameterization_csv_codelists="https://raw.githubusercontent.com/ptaconet/rtunaatlas_scripts/master/tunaatlas_world/metadata_and_parameterization_files/metadata_codelists_2017.csv"

## metadata_and_parameterization_csv_mappings : fill-in only if load_codelists_mappings==TRUE
metadata_and_parameterization_csv_mappings="https://raw.githubusercontent.com/ptaconet/rtunaatlas_scripts/master/tunaatlas_world/metadata_and_parameterization_files/metadata_mappings_2017.csv"

## metadata_and_parameterization_csv_primary_datasets : fill-in only if transform_and_load_primary_datasets==TRUE
metadata_and_parameterization_csv_primary_datasets="https://raw.githubusercontent.com/ptaconet/rtunaatlas_scripts/master/tunaatlas_world/metadata_and_parameterization_files/metadata_and_parameterization_primary_datasets_2017.csv"

## metadata_and_parameterization_tuna_atlas_catch_datasets,metadata_and_parameterization_ird_tuna_atlas_nominal_catch_datasets : fill-in only if generate_and_load_global_tuna_atlas_datasets==TRUE
metadata_and_parameterization_tuna_atlas_catch_effort_datasets="https://raw.githubusercontent.com/ptaconet/rtunaatlas_scripts/master/tunaatlas_world/metadata_and_parameterization_files/metadata_and_parameterization_tuna_atlas_datasets_ird_2017.csv"
metadata_and_parameterization_tuna_atlas_nominal_catch_datasets="https://raw.githubusercontent.com/ptaconet/rtunaatlas_scripts/master/tunaatlas_world/metadata_and_parameterization_files/metadata_and_parameterization_tuna_atlas_nominal_catch_datasets_2017.csv"



