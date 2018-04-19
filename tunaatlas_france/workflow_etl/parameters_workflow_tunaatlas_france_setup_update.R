
rm(list=ls(all=TRUE))

### MANDATORY PARAMETERS
year_tuna_atlas="2017"
deploy_database_model=TRUE
load_codelists=TRUE
load_codelists_mappings=FALSE
transform_and_load_primary_datasets=TRUE
generate_and_load_global_tuna_atlas_datasets=FALSE
virtual_repository_with_R_files="/Workspace/VRE Folders/FrenchTropicalTunaAtlas/R_scripts/datasets_creation"
vre_username="paultaconet"
vre_token="***"
db_host="db-tuna.d4science.org"
db_name="tunaatlas_france"
db_admin_name="tunaatlas_admin"
db_admin_password="***"

### OPTIONAL PARAMETERS depending on the values set in the mandatory parameters
## db_read_name,dimensions,variables_and_associated_dimensions : fill-in only if deploy_database_model==TRUE
db_read_name="tunaatlas_inv"
db_dimensions="area,catchtype,unit,flag,gear,schooltype,sex,sizeclass,species,time,source,fadclass,program,settype,sizetype,ocean,vessel"
db_variables_and_associated_dimensions="vms=flag,gear,vessel,ocean,time,area,unit@fad=fadclass,ocean,time,area,unit@catch=schooltype,species,time,area,gear,flag,catchtype,unit,ocean,program,vessel@effort=schooltype,time,area,gear,flag,unit,ocean,program,vessel,settype@catch_at_size=schooltype,species,time,area,gear,flag,catchtype,sex,unit,sizeclass,program,sizetype,ocean,vessel"

## metadata_and_parameterization_csv_codelists : fill-in only if load_codelists==TRUE
metadata_and_parameterization_csv_codelists="https://raw.githubusercontent.com/ptaconet/rtunaatlas_scripts/master/tunaatlas_france/metadata_and_parameterization_files/metadata_codelists_2017.csv"

## metadata_and_parameterization_csv_primary_datasets : fill-in only if transform_and_load_primary_datasets==TRUE
metadata_and_parameterization_csv_primary_datasets="https://raw.githubusercontent.com/ptaconet/rtunaatlas_scripts/master/tunaatlas_france/metadata_and_parameterization_files/metadata_and_parameterization_tuna_atlas_france_primary_datasets_2017.csv"



