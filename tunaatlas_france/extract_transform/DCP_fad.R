warning("This data are confidential. For diffusion please check with the database manager.")
cat("Please inform the database manager of your database usage. \n")

####################### FADS aggregation according to spatiotemporal resolution from FAD database
# Author : Chloé Dalleau, M2 intern (IRD)
# Training supervisor : Paul Taconet (IRD)
# Date : 21/09/2017 
# 
# ## Purpose
# To determine the quantity of FADS according to spatiotemporal resolution from FADS database.
#
# ## Note
# The Sardara referentials of this dataset are in "../sardara_code_liste/sardarafrance_fads_codelists.csv"
# 
# ## Description
# 
# 1. Spatial grid and timetable are created
#   - Spatial grid contains geometries objects : polygon with the same SRID of data from FAD. The grid extent and the spatial step are choosen by users.
#   - Continuous calendar. The first date, final date and time step are choosen by users. 
# 
# 2. Each fads position are attibuted to an unique polygon according to random polygon.
#     Before part "treatments" the data are extracted from database and storaged in a data.frame.
#     This data are available in 'dataset' but they aren't aggregated.
# 
# 3. The wanted dimensions are merged
# 
# 
# ## Input data
# - data connection to PosGreSQL : call upon database manager for password (ob7@listes.ird.fr)
# - latMin : Smallest latitude of spatial grid in degree, type integer. Range of values : -90° to 90°. Advice value = -90°
# - latMaxTheory : Biggest latitude wanted for the spatial grid in degree, type integer. The real end is calculated according to the latMin and the spatial step. Range of values : -90° to 90°. Advice value = 90°.
# - lonMin : Smallest longitude of spatial grid in degree, type integer. Range of values : -180° to 180°. Advice value = -180°
# - lonMaxTheory : Biggest longitude wanted for the spatial grid in degree, type integer. The real end is calculated according to the lonMin and the spatial step. Range of values : -180° to 180°. Advice value = 180°.
# - spatialStep: Side of square polygon in degree, type real. Range of values : 0° to 90°. Advice value 1°.
# - timeStep : time step of timetable in day or month, type integer. Advice value : 15 (days).
# - timeUnit : time unit, type character. Value : "day" or "month".
# - firstDate : fisrt date of calendar, type date. Advice value : "1800-01-01".
# - finalDate : final date of calendar, type date. Advice value : "2100-01-01" or Sys.Date().
# - method_asso : method used for data aggregation. In this case only random method is available. Value : "random"
# - agg_days : optional dimension: number of day that a FAD is stayed in a spatiotemporal resolution. type = boolean. Value : "TRUE|FALSE"
# 
# ## Output data
# fads by:
# - fad_class : fads classes. examples : "W" for at sea and "B" for on boat
# - time_start : start of calendar. example : "1990-12-25"
# - time_stop : end of calendar. example : "1991-01-08"
# - area : geometric coordinates of polygons (spatial grid) 
# - days : number of days. example : "2"
# - fadunit : fads unit. example : "NO" for metric nomber
# - fads : quantity of fads example : "1"
# 
# ## WPS code 
# - wps.des: id = fadsaggregatefads, title = number of fads according to spatiotempral resolution from FADS database, abstract = To determine catches by spatiotemporal resolution from FADS database.;
# - wps.in: id = latMin, type = integer, title = Smallest latitude of spatial grid in degree. Range of values: -90° to 90°., value = "-90";
# - wps.in: id = latMaxTheory, type = integer, title = Biggest latitude wanted for the spatial grid in degree.The real end is calculated according to the latMin and the spatial step. Range of values: -90° to 90°., value = "90";
# - wps.in: id = lonMin, type = integer, title =  Smallest longitude of spatial grid in degree. Range of values : -180° to 180°., value = "-180";
# - wps.in: id = lonmaxTheory, type = integer, title =  Biggest longitude wanted for the spatial grid in degree.The real end is calculated according to the lonMin and the spatial step. Range of values : -180° to 180°., value = "180";
# - wps.in: id = spatialStep, type = real, title = Spatial resolution that fit the side of square polygon in degree. Range of values: 0.001° to 5°., value = "1";
# - wps.in: id = timeStep , type = integer, title = Temporal resolution of calendar in day or month., value = "15";
# - wps.in: id = timeunit , type = character, title = Time unit of temporal resolution, value = "day|month";
# - wps.in: id = firstdate , type = date, title = Fisrt date of calendar, value = "1800-01-01";
# - wps.in: id = finaldate , type = date, title = Final date of calendar, value = "2100-01-01";
# - wps.in: id = timeunit , type = character, title = Time unit of temporal resolution, value = "day|month";
# - wps.in: id = method_asso, type = character,  title = method used for data aggregation. In this case only random method is available. Value : "random"
# - wps.in: id = agg_days, type = boolean,  title = optional dimension: number of day that a FAD is stayed in a spatiotemporal resolution. Value : "TRUE|FALSE"
# - wps.out: id = fadaggregatefadscsv, type = text/zip, title = Number of fad from FADS database by fad class ; 
#########################

######################### ######################### ######################### 
# Packages
######################### ######################### ######################### 
### Clean the global environnement
rm(list=ls())

### Set working directory (put yours)
setwd("~/Documents/BDD/script_final/script_R")

### Packages
require("RPostgreSQL")
library(htmltools)
library(knitr)
library(jsonlite)
library(rmarkdown)
library(formatR)
library(tictoc)
require(data.table)
require(dplyr)

### Fonctions
source("functions.R")

### Time start
tic.clear()
tic()

### Loads the PostgreSQL driver
drv <- dbDriver("PostgreSQL")

######################### ######################### ######################### 
# Database connection
######################### ######################### ######################### 
## creates a connection to the postgres database
## note that "con" will be used later in each connection to the database
# call upon database manager for password (ob7@listes.ird.fr)
cat("Database connection in progress ... ")
con <- dbConnect(drv, dbname = "fads_20160813",
                 host = "aldabra2", port = 5432,
                 user = "fads_inv", password = "***")
cat(" ok \n")


######################### ######################### ######################### 
# Initialisation
######################### ######################### ######################### 
### Definition of spatial grid, squares compound
# spatial resolution
# side of a square, unit : degree, minimum value : 0.001 degree
spatialStep = 1/2
# truncate spatial step
spatialStep=round(spatialStep, digits = 3)
# latitude
# smallest latitude for the spatial grid, range of value: -90° to 90°
latMin= -90
# biggest latitude wanted for the spatial grid, range of value: -90° to 90°
# Note : the real biggest latitude will be calculate in the function create_grid according to the spatialStep
latMaxTheory = 90
# longitude
# smallest longitude for the spatial grid, range of value: -180° to 180°
lonMin= -180
# biggest longitude wanted for the spatial grid, range of value: -180° to 180°
# Note : the real biggest latitude will be calculate in the function create_grid according to the spatialStep
lonMaxTheory = 180

### Definition of calendar
# time step
timeStep=15
# unit : "day"(default) or "month"
timeUnit = "day"
# warning the same first date has to used to compare 2 objects
firstDate = "1800-01-01"
finalDate = Sys.Date() # advice : Sys.Date() for current date


# Processing of data (No choice in this script version)
# method of association between fishery data and spatial grid
# methods is "random"
# "random": If a DCP is on several polygons (borders case) the polygon is chosen randomly.
method_asso = "random"

### boolean : if you want an aggregation with "number of day" put TRUE
agg_with_days = FALSE
cat("Initialisation ... ok \n")


######################### ######################### ######################### 
# SQL query
######################### ######################### ######################### 
cat("SQL query in progress ... ")
query<- paste("
              WITH
              -------------------------------------------------------------------------
              -- Création des fonctions des grilles spatiale et temporelle
              -------------------------------------------------------------------------
              ", create_grid(latMin,latMaxTheory,lonMin,lonMaxTheory,spatialStep),"
              ,",create_timetable(firstDate,finalDate,timeStep,timeUnit),"
              ,
              -------------------------------------------------------------------------
              -- Sélection des positions de DCP avec les dimensions souhaitées
              -------------------------------------------------------------------------
              fad AS (
              SELECT
              positions_class.buoy_id AS fad_id,
              positions_class.section_num_flip2 AS section_id,
              positions_class.clean_pt_id AS pos_id,
              positions_class.pt_date::date AS date,
              positions_class.pt_geom AS the_geom,		
              ST_X(positions_class.pt_geom) AS lon_fad,
              ST_Y(positions_class.pt_geom) AS lat_fad,
              positions_class.class_flip2 AS fad_class
              FROM 
              spatial_data,
              fads_classified.positions_class		
              INNER JOIN fads_stats.segments_stats ON 
              (positions_class.buoy_id = segments_stats.buoy_id AND
              positions_class.clean_pt_id = segments_stats.start_clean_pt_id)
              
              WHERE 
              model_id=1 AND
              --filtrage sur l'emprise totale de la grille 
              ST_Covers(spatial_data.emprise,positions_class.pt_geom)=true AND
              -- filtrage sur les activités comprisent entre la première et dernière date du calendrier
              (positions_class.pt_date BETWEEN '",firstDate,"'::date AND '",finalDate,"'::date)
              -- limit 10
              )
              -------------------------------------------------------------------------
              -- Sélection des polygones se trouvant sur l'emprise des activités
              -------------------------------------------------------------------------
              , spatial_act AS (
              -- calcul de l'emprise spatiale des activitées
              SELECT 
              ST_SetSRID(ST_Envelope(ST_Extent(the_geom)),4326) AS emprise
              FROM 
              fad
              ), restrict_polygon AS (
              -- sélection des polygones ayant une intersection avec 
              -- l'emprise des activités
              SELECT 
              polygon.*
              FROM 
              polygon, spatial_act
              WHERE
              ST_Intersects(polygon.geom,spatial_act.emprise)=true
              ),
              -------------------------------------------------------------------------
              -- Detail des positions de DCP par polygones
              -------------------------------------------------------------------------
              data_by_area AS (
              -- détail des positions de DCP par polygone
              -- duplication de la ligne si le DCP est situé sur une bordure
              SELECT 
              fad.pos_id AS ID,
              fad.fad_id,
              fad.section_id,
              fad.date,
              fad.the_geom,
              fad.lon_fad,
              fad.lat_fad,
              fad.fad_class,
              restrict_polygon.geom AS area,
              restrict_polygon.cent_poly,
              RANDOM() AS rand_value
              FROM 
              fad,restrict_polygon 
              WHERE 
              -- ST_Covers : les DCP sur les bordures sont associées au polygone
              ST_Covers(restrict_polygon.geom,fad.the_geom)=true 
              ), select_area AS (
              -- détail des positions de DCP associées à un seul et unique polygone
              SELECT 
              data_by_area.ID,
              max(rand_value) AS rand_value
              FROM 
              data_by_area 
              GROUP by 
              ID
              
              ), fad_by_select_area AS (
              -- détail des positions de DCP associées à un seul et unique polygone
              SELECT 
              data_by_area.ID,
              data_by_area.fad_id,
              data_by_area.section_id,
              data_by_area.fad_class,
              data_by_area.date,
              data_by_area.the_geom, 
              data_by_area.lat_fad, 
              data_by_area.lon_fad, 
              data_by_area.area, 
              data_by_area.cent_poly,
              select_area.rand_value
              FROM 
              data_by_area 
              INNER JOIN select_area ON 
              (data_by_area.ID=select_area.ID AND 
              data_by_area.rand_value=select_area.rand_value)
              
              ),
              -------------------------------------------------------------------------
              -- Detail des positions de DCP par polygones et par période
              -------------------------------------------------------------------------
              fad_by_area_time AS (
              SELECT 
              fad_by_select_area.ID,
              fad_by_select_area.fad_id,
              fad_by_select_area.section_id,
              fad_by_select_area.fad_class,
              fad_by_select_area.date,  
              calendar.timestart,
              calendar.timeend, 
              fad_by_select_area.the_geom, 
              fad_by_select_area.lat_fad, 
              fad_by_select_area.lon_fad, 
              fad_by_select_area.area,
              fad_by_select_area.cent_poly
              FROM 
              fad_by_select_area, calendar
              WHERE 
              (fad_by_select_area.date BETWEEN calendar.timestart AND calendar.timeend)
              ORDER BY 
              fad_id, timestart
              ),
              -------------------------------------------------------------------------
              -- Calcul du nombre de jour passé par un DCP pour une résolution spatiotemporelle donnée
              -------------------------------------------------------------------------
              fad_extrem_days AS (
              -- sélection des date min et max
              SELECT DISTINCT
              fad_by_area_time.fad_id, 
              fad_by_area_time.section_id, 
              fad_by_area_time.fad_class,
              fad_by_area_time.timestart, 
              fad_by_area_time.timeend, 
              fad_by_area_time.area,
              fad_by_area_time.cent_poly,
              MIN(fad_by_area_time.date) AS min_date,
              MAX(fad_by_area_time.date) AS max_date
              FROM 
              fad_by_area_time
              GROUP BY
              fad_id, section_id, fad_class, timestart, timeend, area, cent_poly
              ORDER BY 
              fad_id, section_id, fad_class, timestart, area
              ), fad_days AS (
              -- calcul du nombre de jour
              SELECT 
              fad_extrem_days.fad_id, 
              fad_extrem_days.section_id, 
              fad_extrem_days.fad_class,
              fad_extrem_days.timestart, 
              fad_extrem_days.timeend, 
              fad_extrem_days.area,
              fad_extrem_days.cent_poly,
              fad_extrem_days.min_date,
              fad_extrem_days.max_date,
              CASE
              WHEN max_date - min_date=0 THEN 1::numeric
              ELSE max_date - min_date
              END AS days
              FROM 
              fad_extrem_days
              ORDER BY 
              fad_id, section_id, fad_class, timestart, area
              )
              -------------------------------------------------------------------------
              -- Calcul du nombre de DCP distinct par résolution spatio-temporelle
              -------------------------------------------------------------------------
              SELECT DISTINCT
              fad_days.fad_id, 
              fad_days.section_id, 
              fad_days.fad_class,
              fad_days.timestart, 
              fad_days.timeend, 
              ST_AsText(fad_days.area) AS area,
              ST_AsText(fad_days.cent_poly) AS cent_area,
              fad_days.days::numeric
              FROM 
              fad_days
              ORDER BY 
              fad_id, section_id, fad_class, timestart, area, days
              ", sep="")

### Logging of dataframe
# dataset contains non aggregated data
dataset<-dbGetQuery(con, query)
cat(" ok \n")

### Disconnection of data base
dbDisconnect(con)

### Renamed column
# - fad_class : fads classes. examples : "W" for at sea and "B" for on boat
# - section : numbering of tracking section. exemple: 
#           fad_class = B B W W W W B W W W 
#           section =   1 1 2 2 2 2 3 4 4 4
# - time_start : start of calendar. example : "1990-12-25"
# - time_stop : end of calendar. example : "1991-01-08"
# - area : geometric coordinates of polygons (spatial grid) 
# - days : number of days. example : "2"
# - fadunit : fads unit. example : "NO" for metric nomber
# - fads : quantity of fads example : "1"
names(dataset) <- c( "fad_id", "section", "fad_class", "time_start",	"time_end",	"area", "cent_poly", "days")
cat("Extract data ... ok \n")


######################### ######################### ######################### 
# Treatments
######################### ######################### ######################### 
cat("Data aggregation in progress ... ")
### Date treatments
dataset$time_start <- as.character(dataset$time_start)
# modify time end: exclusive
dataset$time_end <- as.Date.character(dataset$time_end) + 1 # /!\ as.Date removes 1 day
dataset$time_end <- as.character(dataset$time_end)

### Convert in a table (processing faster)
dataset_table<-data.table(dataset)

### Add number of fad and unit
dataset_table<- cbind(dataset_table,rep("NO"), rep(as.numeric(1)))
setnames(dataset_table, c(9,10), c("fadunit","v_fad"))

### Aggregation of data
# list of dimensions
dimensions <- c("fad_class", "section", "time_start", "time_end", "area", if(agg_with_days ==TRUE){"days"}, "fadunit")
# aggregation (data.table package)
dataset_table <- dataset_table %>% group_by_(.dots=dimensions) %>% summarise(v_catch=round(sum(v_fad),3))

### Convert in a dataframe
dataset<-data.frame(dataset_table)
cat(" ok \n")


######################### ######################### ######################### 
# Metadata
######################### ######################### ######################### 
cat("Metadata in progress ... ")
### Extraction of first and final date of the dataset
first_date_dataset <- strftime(min(dataset$time_start), "%Y_%m_%d")
first_year_dataset <- strftime(min(dataset$time_start), "%Y")
last_date_dataset <- strftime(max(dataset$time_start), "%Y_%m_%d")
last_year_dataset <- strftime(max(dataset$time_start), "%Y")
spatialStep_filename = gsub("[.]","",spatialStep) #replace "." by nothing for file name

### Simplification of timeUnit for metadata
if (timeUnit == "month") {
  timeUnit_metadata ="m"
} else {
  timeUnit_metadata ="d"
}
### Description of aggregation method for metadata
method_asso_metadata ="rand"
description_method_asso = "The processing attributes fad location to an unique polygon. If the location is between several polygons then the polygon is choice randomly."

### Extra information for metadata
if (agg_with_days == TRUE) {
  extra_info_days = " The 'days' fit number of continous days in a spatio-temporal resolution."
} else {
  extra_info_days = ""
}
# character string with list of dimenions
list_dimensions <-  dimensions[1]
for (i in 2:length(dimensions)){
  list_dimensions <- paste(list_dimensions," , ", dimensions[i], sep = "")
}

### Creation of metadata
dataset_name <- as.character(paste("indian_atlantic_oceans_fads_",spatialStep_filename,"deg_",timeStep,timeUnit_metadata,"_",first_date_dataset,"_",last_date_dataset,"_fads", sep=""))
dataset_release_date <- as.character(Sys.Date())
dataset_title <- as.character(paste("FADS in the Atlantic and Indian oceans (",first_year_dataset, "-", last_year_dataset, ") for french surface fisheries by ",spatialStep_filename, "° / ",timeStep,timeUnit_metadata,"square", sep=""))
operator_contact_name <- as.character("Chloé Dalleau, Paul Taconet")
operator_contact_mail <- as.character("chloe.dalleau@ird.fr, paul.taconet@ird.fr")
operator_origin_institution <- as.character("IRD")
dataset_origin_institution <- as.character("IRD")
url_download_page <- as.character("")
table_description <- as.character(paste("This dataset lists FADS (Fishing Aggregating Device) in the Atlantic and Indian oceans for french surface fisheries from ", first_year_dataset, " to ", last_year_dataset, " aggregated on a ",spatialStep_filename, " degrees and ",timeStep," ",timeUnit," grid resolution. These data come from FADS database and are collected by French National Research Institute for Sustainable Development (IRD). FADS database gathers the fine data from french surface tuna fisheries and partners. This database contains data about FADS location. The location are classified according to RandomForest method and each location is predict at sea or on boat.",description_method_asso," If there are no FADS in a polygon for a period, this level are not in this dataset.", extra_info_days,sep=""))
table_short_description <- paste("fads by ",list_dimensions,sep = "")
dataset_description_report_original_url <- as.character("")
table_sql_query <- paste("Query to create the dataset from FADS database. Executed the ", as.character(Sys.Date()), ". ",as.character(query), sep="")
view_name <- as.character(paste("tunaatlas_ird.ind_atl_fad_",spatialStep_filename,"deg_",timeStep,timeUnit_metadata,"_",first_date_dataset,"_",last_date_dataset,"_",method_asso_metadata,"_fads", sep=""))
## Treatment steps
# spatial extent for steps
spatial_extent <- paste("BOX(",lonMin," ", latMin,",",lonMaxTheory," ", latMaxTheory,")", sep = "")
# steps
step_metadata <- paste(
  "step1: FAD data from FADS database were collated and harmonized.
  step2: Only data included in ",spatial_extent," from ", firstDate," to ", finalDate," are used. 
  step3: A regular grid composed of square polygons was created. The spatial extent is ",spatial_extent," with a resolution of ",spatialStep," decimal degrees.
  step4: A continius calendar was created from ", firstDate," to ", finalDate," with a period of ",timeStep," ",timeUnit,"(s) . The time start of period is inclusive and time end is exclusive.
  step5: Each data was associated to one or several polygons using the data geolocalisation.", description_method_asso,"
  step6: Each data was associated to one periode of time.
  step7: Data were aggregated according to :",list_dimensions,".
  step8: Metadata were created according to the input data and the source database.
  step9: CSV files were created.
  "
  , sep="")

### Creation of metadata dataframe
metadata_element <- c("dataset_title","dataset_name","dataset_release_date","operator_contact_name","operator_contact_mail","operator_origin_institution","dataset_origin_institution","url_download_page","table_description","table_short_description","dataset_description_report_original_url","table_sql_query", "Steps", "view_name")
metadata_description <- c("Title of the dataset", "Name of the dataset","Date of release of the dataset", "Name of the operator that uploads the dataset", "E-mail adress of the operator that uploads the dataset","Insititution of the operator that uploads the dataset","Name of the RFMO or organization from which the dataset comes from (e.g. ICCAT)", "URL of the original dataset", "Long description of the dataset", "Short description of the dataset", "URL of the original document that describes the dataset", "SQL query", "Treatment steps", "View name in database")
metadata_value <- c(dataset_title ,dataset_name ,dataset_release_date, operator_contact_name, operator_contact_mail, operator_origin_institution, dataset_origin_institution, url_download_page, table_description, table_short_description, dataset_description_report_original_url,table_sql_query, step_metadata,view_name)
metadata <- data.frame(metadata_element,metadata_description, metadata_value)
colnames(metadata) <- c("metadata element","description", "value")
cat(" ok \n")

######################### ######################### ######################### 
# Export
######################### ######################### ######################### 
cat("Data and metadata export in progress ... ")
### Definition of file name
# file name for dataset
filepath = "../resultat_csv/"
filepath_dataset = paste(filepath,dataset_name,".csv", sep="")
# file name for dataset metadata
filepath_metadata = paste(filepath,"metadata_",dataset_name,".csv", sep="")

### Creation of csv file
# dataset
write.csv(dataset, file = filepath_dataset, row.names = FALSE)
# dataset metadata
write.csv(metadata, file = filepath_metadata, row.names = FALSE)
cat(" ok \n")


######################### ######################### ######################### 
# Summarry
######################### ######################### ######################### 
### Run time
cat("Run time : ")
toc()
tic.clear()
cat("\n")

### Other informations
spatial_extent <- paste("BOX(",lonMin," ", latMin,",",lonMaxTheory," ", latMaxTheory,")", sep = "")
cat("Summary : \n")
cat("- spatial extent: ", spatial_extent, "\n")
cat("- spatial step: ", spatialStep, "°", "\n")
cat("- time extent: ", firstDate, " to ", as.character(finalDate), "\n")
cat("- time step: ", timeStep, timeUnit,"(s)", "\n")
cat("- aggragation method: ", method_asso, "\n")
cat("- optional dimension: aggregation with days ", agg_with_days, "\n")

cat("Data available in : \n")
cat(filepath_dataset, "\n")
cat(filepath_metadata, "\n")