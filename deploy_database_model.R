######################################################################
##### 52North WPS annotations ##########
######################################################################
# wps.des: id = deploy_database_model, title = Deploy a database on a PostgreSQL+PostGIS server, abstract = Customize the deployement of a database on a server. Prerequisites: A PostgreSQL + PostGIS model must be installed on a server. There must be an admin user and a user with select privileges. ;
# wps.in: id = db_name, type = string, title = Name of the database. , value = "tunaatlas";
# wps.in: id = host, type = string, title = Host server for the database. , value = "db-tuna.d4science.org";
# wps.in: id = db_admin_name, type = string, title = Name of the administrator role. , value = "tunaatlas_u";
# wps.in: id = admin_password, type = string, title = Password for administrator role of the database. , value = "****";
# wps.in: id = dimensions, type = string, title = Name of the dimensions to deploy. Each dimension must be separated by a comma. , value = "area,catchtype,unit,fadclass,flag,gear,schooltype,sex,sizeclass,species,time,source";
# wps.in: id = variables_and_associated_dimensions, type = string, title = Name of the variables to deploy. Each fact must be separated by a comma. , value = "catch=schooltype,species,time,area,gear,flag,catchtype,unit,source@effort=schooltype,time,area,gear,flag,unit,source@catch_at_size=schooltype,species,time,area,gear,flag,catchtype,sex,unit,sizeclass,source";

db_name="tunaatlas"
host="db-tuna.d4science.org"
db_admin_name="tunaatlas_u"
admin_password="****"
dimensions="area,catchtype,unit,flag,gear,schooltype,sex,sizeclass,species,time,source"
variables_and_associated_dimensions="catch=schooltype,species,time,area,gear,flag,catchtype,unit,source@effort=schooltype,time,area,gear,flag,unit,source@catch_at_size=schooltype,species,time,area,gear,flag,catchtype,sex,unit,sizeclass,source"


if(!require(RPostgreSQL)){
  install.packages("RPostgreSQL")
}
require(RPostgreSQL)

# Provide the path to the codes containing the SQL queries to execute to deploy the db model
path_to_sql_codes_folder<-"https://raw.githubusercontent.com/ptaconet/rtunaatlas_scripts/master/sql/deploy_database_model/"

# Connect to db with admin rights
drv <- dbDriver("PostgreSQL")
con <- dbConnect(drv, dbname=db_name, user=db_admin_name, password=admin_password, host=host)


## 1) Deploy schema metadata and associated tables

cat(paste0("Deploying schema metadata and tables...\n"))
# Read SQL query
fileName <- paste0(path_to_sql_codes_folder,"create_schema_metadata.sql")
sql_deploy_metadata<-paste(readLines(fileName), collapse=" ")
sql_deploy_metadata<-gsub("%db_admin%",db_admin_name,sql_deploy_metadata)

dbSendQuery(con,sql_deploy_metadata)

cat(paste0("END deploying schema metadata and tables\n"))

## 2) Deploy dimensions

# Create vector of dimensions to deploy
dimensions<-strsplit(dimensions, ",")[[1]]

# One by one, create the dimensions
for (i in 1:length(dimensions)){
  cat(paste0("Deploying dimension ",dimensions[i],"...\n"))
  
  if (dimensions[i]=="time"){
    fileName <- paste0(path_to_sql_codes_folder,"create_schema_dimension_time.sql")
  } else if (dimensions[i]=="sizeclass"){
    fileName <- paste0(path_to_sql_codes_folder,"create_schema_dimension_sizeclass.sql")
  } else {
    fileName <- paste0(path_to_sql_codes_folder,"create_schema_dimension.sql")
  }
  
  sql_deploy_dimension<-paste(readLines(fileName), collapse=" ")
  sql_deploy_dimension<-gsub("%db_admin%",db_admin_name,sql_deploy_dimension)
  sql_deploy_dimension<-gsub("%dimension_name%",dimensions[i],sql_deploy_dimension)
  
  dbSendQuery(con,sql_deploy_dimension)
  
  if (dimensions[i]=="area"){
    # Create table area.area_wkt
    sql_deploy_table_area_wkt<-paste(readLines(paste0(path_to_sql_codes_folder,"create_table_area_wkt.sql")), collapse=" ")
    sql_deploy_table_area_wkt<-gsub("%db_admin%",db_admin_name,sql_deploy_table_area_wkt)
    dbSendQuery(con,sql_deploy_table_area_wkt)
    
    # Update view area.area_labels
    sql_deploy_view_area_labels<-paste(readLines(paste0(path_to_sql_codes_folder,"create_view_area_labels.sql")), collapse=" ")
    sql_deploy_view_area_labels<-gsub("%db_admin%",db_admin_name,sql_deploy_view_area_labels)
    dbSendQuery(con,sql_deploy_view_area_labels)
    
  }
    
  cat(paste0("END deploying dimension ",dimensions[i],"\n"))
  
}


## 3) Deploy variable tables

facts<-strsplit(variables_and_associated_dimensions, "@")[[1]]

for (i in 1:length(facts)){
  
  fact_name<-sub('=.*', '', facts[i])
  dimensions_for_fact<-strsplit(sub('.*=', '', facts[i]),",")[[1]]

  cat(paste0("Deploying variable ",fact_name," with associated dimensions...\n"))
  
  sql_deploy_fact_table<-paste0("CREATE TABLE fact_tables.",fact_name,"(
                               id_",fact_name," SERIAL PRIMARY KEY,
                               id_metadata INTEGER REFERENCES metadata.metadata(id_metadata),")
  
  for (j in 1:length(dimensions_for_fact)){
    sql_deploy_fact_table<-paste0(sql_deploy_fact_table,"id_",dimensions_for_fact[j], " INTEGER REFERENCES ",dimensions_for_fact[j],".",dimensions_for_fact[j],"(id_",dimensions_for_fact[j],"),")
  }
  
  sql_deploy_fact_table<-paste0(sql_deploy_fact_table,"value numeric(12,2) NOT NULL);ALTER TABLE metadata.metadata
  OWNER TO ",db_admin_name,";
GRANT ALL ON TABLE fact_tables.",fact_name," TO ",db_admin_name,";

CREATE INDEX id_metadata_",fact_name,"_idx
  ON fact_tables.",fact_name,"
  USING btree
  (id_metadata);")
  
  dbSendQuery(con,sql_deploy_fact_table)
  
  sql_deploy_fact_table<-NULL
  
  cat(paste0("END Deploying fact table ",fact_name," with associated dimensions\n"))
  
}
  

