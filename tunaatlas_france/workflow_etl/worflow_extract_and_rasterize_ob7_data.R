## WORKFLOW TO EXTRACT SPATIO-TEMPORAL FINE GRAINED DATA FROM A POSTGRESQL DATABASE AND AGGREGATE THEM SPATIALLY AND TEMPORALLY
# Author : Chloe Dalleau (IRD), revised by Paul Taconet (IRD)
# Date : 15/05/2018 
## Description of the workflow:
# wps.des: id = workflow_extract_and_rasterize_ob7_data, title = Workflow to extract spatio-temporal fine grained data from a PostgreSQL database and aggregate them spatially and temporally , abstract = This script extracts multi-dimensional fine grained spatial time series from a PostgreSQL database and aggregates them in space and time. Fine grained data might be either points or trajectories. The spatial zone to aggregate the data might be either a regular grid or a shapefile;
# wps.des: id = path_to_query, type = character, title = Path/URL of the sql file where the query to execute to extract the data from the database is stored. The query must extract a dataset with the appropriate structure, which is: 0 to n columns of dimensions (e.g. species, gear, flag, etc.), 1 column named "date" representing the date (type: timestamp), 2 columns named "lat" and "lon" representing respectively the latitude and the longitude of the point (type: numeric), 1 column named "value" representing the value for the given association of dimensions (type: numeric), and in case of trajectory dataset 2 additional columns named "id_object" and "id_trajectory" representing respectively the identifier of the object and the identifier of the object's trajectory (type: integer) (these two columns enable to further create the trajectories), value="http://data.d4science.org/L3pxZ3pqbGVreG11czdsSkRIa0EvekhjTkVKaHg4Z2dHbWJQNStIS0N6Yz0";
# wps.des: id = path_to_databases_credentials, type = character, title = path/URL of the csv file where the credentials of the database to connect to in order to execute the query is stored. The file contains the following columns filled-in with the appropriate values: dbname, host, port, user, password., value = "/home/ptaconet/Documents/connection_bdd.csv";
# wps.des: id = database_name, type = character, title = Name of the database to connect to in order to execute the query. value = "balbaya";
# wps.des: id = sql_limit, type = character, title = SQL LIMIT for the extraction of the data by the query stored under path_to_query. Useful to test the code in case of query returning a big amount of rows. If no limit, put NULL. value = "LIMIT 100";
# wps.des: id = latmin, type = character, title = Restriction / filter on the latitude to aggregate the data (minimum latitude), value = "-90";
# wps.des: id = latmax, type = character, title = Restriction / filter on the latitude to aggregate the data (maximum latitude), value = "90";
# wps.des: id = lonmin, type = character, title = Restriction / filter on the longitude to aggregate the data (minimum longitude), value = "-180";
# wps.des: id = lonmax, type = character, title = Restriction / filter on the longitude to aggregate the data (maximum longitude), value = "-180";
# wps.des: id = intersection_layer_type, type = character, title = Type of spatial layer to use to aggregate the data. "grid" stands for a regular grid and "shapefile" for a shapefile., value="grid";
# wps.des: id = grid_spatial_resolution, type = character, title = Set only if intersection_layer_type=="grid". Spatial resolution of the grid (in degrees). , value = "0.33";
# wps.des: id = shapefile_url, type = character, title = Set only if intersection_layer_type=="shapefile". path/URL of the shapefile to aggregate the data. , value = "/home/ptaconet/Documents/eez_marineregions_10/eez_v10_indian_atlantic_oceans.shp";
# wps.des: id = shapefile_colname_geographic_identifier, type = character, title = Set only if intersection_layer_type=="shapefile". Name of the column providing the unique identifiers in the shapefile., value = "MRGID";
# wps.des: id = temporal_resolution, type = character, title = Temporal resolution of output aggregated dataset. In day, month or year (see: temporal_resolution_unit). Note: for 1/2 month put temporal_reso=0.5 and temporal_reso_unit="month" , value = "1";
# wps.des: id = temporal_resolution_unit, type = character, title = Temporal resolution unit., value="day|month|year";
# wps.des: id = first_date, type = character, title = Restriction / filter on the date to aggregate the data (minimum date), value = "1950-01-01";
# wps.des: id = final_date, type = character, title =  Restriction / filter on the date to aggregate the data (maximum date), value = "2017-12-31";
# wps.des: id = spatial_association_method, type = character, title = Method to use for the aggregation of the fine grained data that fall on a border of the grid/polygon. equaldistribution = Data are redistributed equally between the bordering polygons. cwp = Data are attributed to a cell following the Coordinating Working Party on Fishery Statistics (CWP) rules, i.e. they were assigned to the cell closest to the point of latitude = 0 and longitude = 0. random = Data are attributed randomly to one of the bordering cell/polygon. Currently only "equaldistribution" is implemented., value : "equaldistribution|random|cwp";
# wps.des: id = aggregate_data, type = boolean, title = Aggregate the data spatially and temporally? TRUE outputs a dataset aggregated spatially and temporally. FALSE outputs a non-aggregated dataset. , value : "TRUE|FALSE";
# wps.des: id = metric_to_keep, type = character, title = Many functions can be used to aggregate the values of the data. This function enables to choose which function should be kept., value="sum|mean|n|sd|min|max";
# wps.des: id = buffer_size, type = character, title = Size of the buffer to compute the surface variable in case of trajectory., value = "37";
# wps.des: id = columns_to_keep, type = character, title = In the output dataset, name of the columns to keep. This parameters enable to restrict the number of columns of the output dataset compared to what the input query returns (i.e. the input query might return more columns that those desired in the output aggregated dataset)., value = "ocean,flag,gear,vessel";
# wps.out: id = dataset, type = data.frame, title = The dataset aggregated spatially and temporally according to the input parameters. Another output, called 'additional_metadata', is a data.frame of useful metadata computed dynamically (i.e. in function of the input parameters) ;

######################### ######################### ######################### 
# Packages
######################### ######################### ######################### 

if(!require(rtunaatlas)){
  if(!require(devtools)){
    install.packages("devtools")
  }
  require(devtools)
  install_github("ptaconet/rtunaatlas")
}

if(!require(dplyr)){
  install.packages("dplyr")
}
if(!require(dplyr)){
  install.packages("data.table")
}
if(!require(dplyr)){
  install.packages("rgdal")
}
if(!require(dplyr)){
  install.packages("sf")
}

require(rtunaatlas)
require(data.table)
require(dplyr)
require(rgdal)
require(sf)

######################### ######################### ######################### 
# Database connection
######################### ######################### ######################### 

cat("Database connection in progress ... ")
## loads the PostgreSQL driver

# Get database credentials
db_connection<-read.csv(path_to_databases_credentials,colClasses = "character")
db_connection<-db_connection[which(db_connection$dbname==database_name),]

drv <- dbDriver("PostgreSQL")
con <- dbConnect(drv, dbname = database_name,
                 host = db_connection$host, port = db_connection$port,
                 user = db_connection$user, password = db_connection$password)

### Logging of dataframe
# dataset contains non aggregated data
cat("Querying DB ... ")

# Read query and replace by values set as input parameters
sql_query<-paste(readLines(path_to_query), collapse="\n")
sql_query<-gsub("%first_date%",first_date,sql_query)
sql_query<-gsub("%final_date%",final_date,sql_query)
sql_query<-gsub("%size_measure_type%","'L1','TL', 'SL', 'LJFL', 'CLJFL', 'EFL', 'DL', 'CTL', 'SCL', 'CCL', 'FL'",sql_query)
sql_query<-paste(sql_query,sql_limit,sep=" ")

dataset_output_query<-dbGetQuery(con, sql_query)
dataset_output_query$date<-as.POSIXct(dataset_output_query$date)
cat("Query ok \n")

### Disconnect from database
dbDisconnect(con)


## keep only desired columns
if (!is.null(columns_to_keep)){
dataset_output_query<-dataset_output_query[,colnames(dataset_output_query) %in% c(unlist(strsplit(columns_to_keep, split=",")),"date","lat","lon","value","id_object","id_trajectory")]
}

# filter the dataset  spatially and temporally
if (is.null(first_date)){
  first_date<-min(dataset_output_query$date)
}
if (is.null(final_date)){
  final_date<-max(dataset_output_query$date)
}
latmin <- as.numeric(latmin)
latmax <- as.numeric(latmax)
lonmin <- as.numeric(lonmin)
lonmax <- as.numeric(lonmax)
dataset_output_query<-dataset_output_query %>% filter(date>=first_date,date<=final_date,lat>=latmin,lat<=latmax,lon>=lonmin,lon<=lonmax )

if (grepl("/", temporal_resolution)){
temporal_resolution_list<-unlist(strsplit(temporal_resolution, split="/")) 
} else {
  temporal_resolution_list<-temporal_resolution
  }
temporal_resolution_list<-as.numeric(temporal_resolution_list)
    
if (grepl("/", temporal_resolution_unit)){    
temporal_resolution_unit_list<-unlist(strsplit(temporal_resolution_unit, split="/")) 
} else {
  temporal_resolution_unit_list<-temporal_resolution_unit
  }

if (intersection_layer_type=="grid"){
if (grepl("/", grid_spatial_resolution)){        
grid_spatial_resolution_list<-unlist(strsplit(grid_spatial_resolution, split="/")) 
} else {
  grid_spatial_resolution_list<-grid_spatial_resolution
  }
grid_spatial_resolution_list<-as.numeric(grid_spatial_resolution_list)
}


#year_tuna_atlas<-as.numeric(year_tuna_atlas)
data_crs <- "+init=epsg:4326 +proj=longlat +datum=WGS84"

## initialization of output datasets
datasets_all<-list()
additional_metadata_all<-list()

for (k in 1:length(temporal_resolution_list)){

  temporal_resolution <- temporal_resolution_list[k]
  temporal_resolution_unit <- temporal_resolution_unit_list[k]
  if (intersection_layer_type=="grid"){
  grid_spatial_resolution <- grid_spatial_resolution_list[k]
  }
  
######################### ######################### ######################### 
# Processings
######################### ######################### ######################### 

cat("Creating sf SpatialPolygon to aggregate data...\n")

## Create aggregation layer
if (intersection_layer_type=="shapefile"){
  ### If not a grid, prepare data for integration within the aggregation function. Input is a shp that needs to be converted to SpatialPolygonDataFrame
  intersection_layer <- st_read(shapefile_url)
  st_crs(intersection_layer) <- data_crs
  names(intersection_layer)[which(names(intersection_layer) == shapefile_colname_geographic_identifier)]<-"geographic_identifier"
  intersection_layer<-intersection_layer[,"geographic_identifier"]
} else if (intersection_layer_type=="eez"){
  ## Get the EEZ from the marineregions (covering indian and atlantic oceans)
  xmin_plot=-60
  ymin_plot=-60
  xmax_plot=102
  ymax_plot=65  
  dsn<-paste("WFS:http://geo.vliz.be/geoserver/MarineRegions/ows?service=WFS&version=1.0.0&request=GetFeature&maxFeatures=2&typeName=MarineRegions:eez&BBOX=",xmin_plot,",",ymin_plot,",",xmax_plot,",",ymax_plot,sep="")
  intersection_layer<-readOGR(dsn,"MarineRegions:eez")
  names(intersection_layer)[which(names(intersection_layer) == "geoname")]<-"geographic_identifier"
} else if (intersection_layer_type=="grid"){
  centred_grid=TRUE
  latmin=min(dataset_output_query$lat)
  latmax=max(dataset_output_query$lat)
  lonmin=min(dataset_output_query$lon)
  lonmax=max(dataset_output_query$lon)
  intersection_layer <- rtunaatlas::create_grid(latmin,latmax,lonmin,lonmax,grid_spatial_resolution,crs=data_crs,centred=centred_grid)
}

# Convert to sf 
intersection_layer<-st_as_sf(intersection_layer)

cat("Creating sf SpatialPolygon to aggregate data OK\n")

cat("\n Creation of temporal calendar ... ")
  
calendar <- rtunaatlas::create_calendar(first_date,final_date,temporal_resolution,temporal_resolution_unit)

cat("\n Creation of temporal calendar OK ")

cat("Aggregating the data spatio-temporally...\n")

## noms de colonne obligatoire : time, lat, lon
dataset_processed<-rtunaatlas::rasterize_geo_timeseries(df_input=dataset_output_query,
                                  intersection_layer=intersection_layer,
                                  calendar=calendar,
                                  data_crs=data_crs,
                                  aggregate_data=aggregate_data,
                                  spatial_association_method=spatial_association_method,
                                  buffer=buffer_size)

cat("Aggregating the data spatio-temporally OK \n")
dataset<-list()
additional_metadata<-list()
metric_to_keep<-unlist(strsplit(metric_to_keep, split=","))

# Data that do not intersect any polygon of the intersection layer have the geographic_identifier set to NA
dataset_processed <- dataset_processed %>% mutate(geographic_identifier = if_else(is.na(geographic_identifier),"ALL",geographic_identifier))
#dataset_processed <- dataset_processed %>% mutate(geom_wkt = if_else(is.na(geom_wkt),"ALL",geom_wkt))

cat("Generating metadata... \n")
for (i in 1:length(metric_to_keep)){
n<-length(datasets_all)+1
# Keep select column as value and remove the others (sd_value, min_value, etc.)
dataset_processed$value<-dataset_processed[,paste0(metric_to_keep[i],"_value")]
datasets_all[[n]]<-dataset_processed[ , !(grepl("_value",colnames(dataset_processed)))==TRUE]
datasets_all[[n]]<-datasets_all[[n]] %>% filter (value > 0)

# ######################### ######################### ######################### 
# # Setting Metadata
# ######################### ######################### ######################### 


additional_metadata_this_df<-NULL
additional_metadata_this_df$supplemental_information<-paste0("The following query was executed on the ",database_name," database on the ",Sys.Date()," to extract the data :\n",sql_query)

switch(spatial_association_method,
"cwp" = {lineage_asso = "Data whose spatial location (point) fell on a border of the grid were attributed to a cell following the Coordinating Working Party on Fishery Statistics (CWP) rules, i.e. they were assigned to the cell closest to the point of latitude = 0 and longitude = 0 (see http://www.fao.org/fishery/cwp/en for additional information)."}, 
"random" = {lineage_asso =  "Data whose spatial location (point) fell on a border of the grid/polygon were attributed randomly to one of the bordering cell/polygon."},
"equaldistribution" = {lineage_asso =  "Data whose spatial location (point) fell on a border of the grid/polygon were redistributed equally between the bordering polygons."}
)

if (intersection_layer_type=="grid"){
  lineage_intersection_layer_type<-paste0("a regular grid of ",grid_spatial_resolution,"° longitude and latitude")
} else if (intersection_layer_type=="shapefile"){
  lineage_intersection_layer_type<-"the geospatial areas"
}
additional_metadata_this_df$lineage <- paste0("step1: The following query was executed on the ",database_name," database on the ",Sys.Date(),":\n",sql_query,".
                   step2: Data were spatially and temporally filtred as follow: spatial extent {latmin,latmax,lonmin,lonmax}:{",latmin,",",latmax,",",lonmin,",",lonmax,"} and temporal extent {first_date,final_date}:{",first_date,",",final_date,"}
                   step3: Data were aggregated on ",lineage_intersection_layer_type," and ",temporal_resolution," ",temporal_resolution_unit," timeframe by the following dimensions: ",columns_to_keep,". ",lineage_asso," 
                   step4: Data were uploaded in the French tropical tuna atlas database.")

additional_metadata_this_df$metric<-metric_to_keep[i]

switch(metric_to_keep[i],
       "n" = {additional_metadata_this_df$metric_label = "number"}, 
       "sum" = {additional_metadata_this_df$metric_label  =  "sum"},
       "mean" = {additional_metadata_this_df$metric_label  =  "average"},
       "sd" = {additional_metadata_this_df$metric_label  =  "standard deviation"},
       "min" = {additional_metadata_this_df$metric_label  =  "minumum"},
       "max" = {additional_metadata_this_df$metric_label  =  "maximum"},
       "distance" = {additional_metadata_this_df$metric_label  =  "Distance traveled by"
                     additional_metadata_this_df$metric_unit = "expressed in kilometers"},
       "ndistance" = {additional_metadata_this_df$metric_label  =  "Normalized distance traveled by"
                      additional_metadata_this_df$metric_unit = "normalized"}
)

if (metric_to_keep[i]=="surface"){
  if (database_name=="fads_20160813"){
    additional_metadata_this_df$metric_label="Area of influence of"
  } else if (database_name=="balbaya"){
    additional_metadata_this_df$metric_label= "Surface explored by"
  }
  additional_metadata_this_df$metric_unit = "expressed in square kilometers"
}

if  (metric_to_keep[i]=="nsurface"){
  if (database_name=="fads_20160813"){
    additional_metadata_this_df$metric_label="Normalized area of influence of"
  } else if (database_name=="balbaya"){
    additional_metadata_this_df$metric_label= "Normalized surface explored by"
  }
  additional_metadata_this_df$metric_unit = "normalized"
}


additional_metadata_this_df$spatial_association_method<-spatial_association_method
additional_metadata_this_df$grid_spatial_resolution<-gsub(".","_",grid_spatial_resolution,fixed=TRUE)
additional_metadata_this_df$temporal_resolution<-gsub(".","_",temporal_resolution,fixed=TRUE)
additional_metadata_this_df$grid_spatial_resolution_title<-gsub(".",",",grid_spatial_resolution,fixed=TRUE)
additional_metadata_this_df$temporal_resolution_title<-gsub(".",",",temporal_resolution,fixed=TRUE)
additional_metadata_this_df$temporal_resolution_unit<-temporal_resolution_unit

  additional_metadata_all[[n]]<-additional_metadata_this_df

}

}

additional_metadata <- additional_metadata_all
rm(additional_metadata_all)

dataset <- datasets_all
rm(datasets_all)

cat("Generating metadata OK \n")
cat("The dataset has been created \n")
