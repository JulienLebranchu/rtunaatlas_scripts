
####################### Aggregation of geolocalistions data according to spatiotemporal resolution from ob7 database
# Author : Chloe Dalleau, Geomatic engineer (IRD)
# Supervisors : Paul Taconet (IRD), Julien Barde (IRD)
# Date : 15/02/2018 
# 
# wps.des: id = aggregation_location, title = Aggregation of geolocalisation data according to spatiotemporal resolution from ob7 database, abstract = Calculation of facts (ie. : catch, catch at size, effort and fad) by spatiotemporal resolution from ob7 database.;
# wps.in: id = file_name, type = character, title = Name of the R script which contains all the specific parameter of the fact (connection query and column names for sql data AND aggregation parameters : list of output dimensions - aggregate variable name - column name of object identifier - fact name) , value = "catch_balbaya|effort_balbaya|catch_at_size_t3p|catch_observe|effort_observe|catch_at_size_observe|fad_fads";
# wps.in: id = file_path_parameter, type = character, title = File path of the R script which contains all the specific parameter of the fact;
# wps.in: id = sql_limit, type = integer, title = SQL limit for the query., value = "1000";
# wps.in: id = latmin, type = integer, title = Smallest latitude of spatial zone extent in degree. Range of values: -90° to 90°., value = "-90";
# wps.in: id = latmax, type = integer, title = Biggest latitude of spatial zone extent in degree. Range of values: -90° to 90°., value = "90";
# wps.in: id = lonmin, type = integer, title =  Smallest longitude of spatial zone extent in degree. Range of values : -180° to 180°., value = "-180";
# wps.in: id = lonmax, type = integer, title =  Biggest longitude of spatial zone extent in degree. Range of values : -180° to 180°., value = "180";
# wps.in: id = intersection_layer_type, type = string, title = Type of layer to use to intersect the data, value = "grid|shapefile|eez";
# wps.in: id = grid_spatial_resolution, type = real, title = If intersection_layer_type="grid", spatial resolution that fits sides of the grid square polygons in degree. Range of values: 0.001° to 5°., value = "1";
# wps.in: id = shapefile_directory_url, type = real, title = If intersection_layer_type="shapefile", directory where the shapefile is stored, value = "/home/ptaconet/Documents/eez_marineregions_10";
# wps.in: id = shapefile_name, type = real, title = If intersection_layer_type="shapefile", name of the shapefile (without the extension)., value = "eez_v10_indian_atlantic_oceans";
# wps.in: id = shapefile_colname_geographic_identifier, type = real, title = If intersection_layer_type="shapefile", name of the unique identifier column, value = "NULL";
# wps.in: id = data_crs, type = boolean, title = a character string of projection arguments of data. The arguments must be entered exactly as in the PROJ.4 documentation, vale="+init=epsg:4326 +proj=longlat +datum=WGS84";
# wps.in: id = temporal_resolution , type = integer, title = Temporal resolution of calendar in day or month., value = "15";
# wps.in: id = temporal_resolution_unit , type = character, title = Time unit of temporal resolution, value = "day|month|year";
# wps.in: id = first_date , type = date, title = First date of calendar, value = "1800-01-01";
# wps.in: id = final_date , type = date, title = Final date of calendar, value = "2100-01-01";
# wps.in: id = spatial_association_method, type character. title = Method used for data aggregation random method (if a fishing data is on several polygons (borders case) the polygon is chosen randomly), equal distribution method (if a fishing data is on several polygons (borders case) the fishing value are distribuated between these polygons) or cwp method (The processing attributes each geolocation to an unique polygon according to CWP rules (from FAO) (http://www.fao.org/fishery/cwp/en)) are available. Value : "random|equaldistribution|cwp"
# wps.in: id = aggregate_data, type = boolean. title = Put TRUE if for aggregated data in the output, value : "TRUE|FALSE"
# wps.in: id = program_observe, type = boolean. title = For data from observe database, put TRUE to have the dimension "program" in output data, value : "TRUE|FALSE"
# wps.in: id = file_path_metadata_model, type = character. title = File path of the metadata model;
# wps.out: id = output_data, type = text/zip, title = Aggregated data by space and by time; 
#########################

# path_to_query
# path_to_databases_credentials
# database_name
# sql_limit
# latmin
# latmax
# lonmin
# lonmax
# intersection_layer_type
# grid_spatial_resolution
# shapefile_directory_url
# shapefile_name
# shapefile_colname_geographic_identifier
# data_crs
# temporal_resolution
# temporal_resolution_unit
# first_date
# final_date
# method_asso
# aggregate_data
# metric_to_keep
# program_observe
# colname_shapefile_unique_identifier

######################### ######################### ######################### 
# Packages
######################### ######################### ######################### 

# Packages
require(rtunaatlas)
require(dplyr)
require(rgdal)


######################### ######################### ######################### 
# Initialisation
######################### ######################### ######################### 
latmin <- as.numeric(latmin)
latmax <- as.numeric(latmax)
lonmin <- as.numeric(lonmin)
lonmax <- as.numeric(lonmax)
temporal_resolution<-as.numeric(temporal_resolution)
grid_spatial_resolution<-as.numeric(grid_spatial_resolution)
year_tuna_atlas<-as.numeric(year_tuna_atlas)
data_crs <- "+init=epsg:4326 +proj=longlat +datum=WGS84"



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

dataset<-dbGetQuery(con, sql_query)
cat("Query ok \n")

### Disconnect from database
dbDisconnect(con)


######################### ######################### ######################### 
# Treatments
######################### ######################### ######################### 

cat("Creating sp SpatialPolygon to aggregate data...\n")

## Create aggregation layer
if (intersection_layer_type=="shapefile"){
  ### If not a grid, prepare data for integration within the aggregation function. Input is a shp that needs to be converted to SpatialPolygonDataFrame
  intersection_layer<-readOGR(shapefile_directory_url,shapefile_name)
  intersection_layer<-spTransform(intersection_layer, CRS(data_crs))
  names(intersection_layer)[which(names(intersection_layer) == shapefile_colname_geographic_identifier)]<-"geographic_identifier"
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
  latmin=min(dataset$lat)
  latmax=max(dataset$lat)
  lonmin=min(dataset$lon)
  lonmax=max(dataset$lon)
  intersection_layer <- rtunaatlas::create_grid(latmin,latmax,lonmin,lonmax,grid_spatial_resolution,crs=data_crs,centred=centred_grid)
}

cat("Creating sp SpatialPolygon to aggregate data OK\n")

cat("\n Creation of temporal calendar ... ")

### create calendar
if (is.null(first_date)){
  first_date<-min(dataset$date)
}
if (is.null(final_date)){
  final_date<-max(dataset$date)
}
calendar <- rtunaatlas::create_calendar(first_date,final_date,temporal_resolution,temporal_resolution_unit)

cat("\n Creation of temporal calendar OK ")

##
if (!is.null(columns_to_keep)){
dataset<-dataset[,colnames(dataset) %in% c(unlist(strsplit(columns_to_keep, split=",")),"date","lat","lon","value","id_object","id_trajectory")]
}

# filter the dataset before executing the aggregation function
dataset<-dataset %>% filter(date>=first_date,date<=final_date,lat>=latmin,lat<=latmax,lon>=lonmin,lon<=lonmax )

cat("Aggregating the data spatio-temporally...\n")

## noms de colonne obligatoire : time, lat, lon
dataset<-rtunaatlas::rasterize_geo_timeseries(df_input=dataset,
                                  intersection_layer=intersection_layer,
                                  calendar=calendar,
                                  data_crs=data_crs,
                                  aggregate_data=aggregate_data,
                                  spatial_association_method=spatial_association_method,
                                  buffer=buffer_size)

cat("Aggregating the data spatio-temporally OK \n")


# Keep select column as value and remove the others (sd_value, min_value, etc.)
dataset$value<-dataset[,paste0(metric_to_keep,"_value")]
dataset<-dataset[ , !(grepl("_value",colnames(dataset)))==TRUE]


# ######################### ######################### ######################### 
# # Metadata
# ######################### ######################### ######################### 
cat("Generating metadata... \n")

additional_metadata<-NULL
additional_metadata$supplemental_information<-paste0("The following query was executed on the ",database_name," database on the ",Sys.Date()," to extract the data :\n",sql_query)

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
additional_metadata$lineage <- paste0("step1: The following query was executed on the ",database_name," database on the ",Sys.Date(),":\n",sql_query,".
                   step2: Data were spatially and temporally filtred as follow: spatial extent {latmin,latmax,lonmin,lonmax}:{",latmin,",",latmax,",",lonmin,",",lonmax,"} and temporal extent {first_date,final_date}:{",first_date,",",final_date,"}
                   step3: Data were aggregated on ",lineage_intersection_layer_type," and ",temporal_resolution," ",temporal_resolution_unit," timeframe by the following dimensions: ",columns_to_keep,". ",lineage_asso," 
                   step4: Data were uploaded in the French tropical tuna atlas database.")

cat("Generating metadata OK \n")
cat("The dataset has been created \n")
