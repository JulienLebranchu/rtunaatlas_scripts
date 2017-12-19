warning("This data are confidential. For diffusion please check with the database manager.")
cat("Please inform the database manager of your database usage. \n")

####################### Catch at size according to spatiotemporal resolution from T3+ database
# Author : Chloé Dalleau, M2 intern (IRD)
# Training supervisor : Paul Taconet (IRD)
# Date : 21/09/2017 
# 
# ## Purpose
# To determine the catch at size according to spatiotemporal resolution from T3+ database.
# 
# ## Note
# The Sardara referentials of this dataset are in "../sardara_code_liste/sardarafrance_t3plus_codelists.csv"
#
# ## Description
# 
# 1. Spatial grid and timetable are created
#   - Spatial grid contains geometries objects : polygon with the same SRID of data from T3+. The grid extent and the spatial step are choosen by users.
#   - Continuous calendar. The first date, final date and time step are choosen by users.
# 
# 2. Each activities are attibuted to an unique polygon according to selected method. One method is developed in this script : CWP rules from FAO. Warning, CWP rules can only use on spatial grid centred on 0. If not, the distribution of data could be wrong
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
# - timeStep : time step of timetable in day or month, type integer. Advice value : 15.
# - timeUnit : time unit, type character. Value : "day" or "month".
# - firstDate : fisrt date of calendar, type date. Advice value : "1800-01-01".
# - finalDate : final date of calendar, type date. Advice value : "2100-01-01" or Sys.Date().
# - method_asso : method used for data aggregation. In this case only CWP method is available. Value : "cwp"
# - agg_with_boat : optional dimension: keel code of boat. type = boolean. Value : "TRUE|FALSE"
# 
# ## Output data
# catch at size by :
# - flag : vessel flag. example : "FRA"
# - ocean : ocean where is located the activities. examples : "ATL" for Atlantic, "IND" for Indian
# - gear : vessel gear. example : "PS"
# - c_bat : optional. vessel keel code. example : "26"
# - time_start : start of time range. example : "1990-12-25"
# - time_stop : end of time range. example : "1991-01-08"
# - area : geometric coordinates of the spatial grid.
# - schooltype : type of scool. example : "IND" (unknown), "BL" (free school), "BO" (school below an object)
# - species : ID of species type (three letters). example : "SKJ"
# - sex : fish sex. example : "IND" for unknown, "M" for male, "F" for female
# - size_min : minimal of size range in cm. example : "10", "20"
# - size_step : size step in cm. fish size = size_min + size_step. example : "0", "1"
# - catchtype : type of catch. example : "L" for captured, "D" for rejected
# - catchunit : catch unit. example : "NO" for number of fish
# - catch : quantity of catches. example : "1.02"
# 
# ## WPS code
# - wps.des: id = catchatsizeaggregatet3plus, title = Tuna catch at size according to spatiotempral resolution from T3plus database, abstract = To determine the catch at size by spatiotemporal resolution from T3+ database;
# - wps.in: id = latMin, type = integer, title = Smallest latitude of spatial grid in degree. Range of values: -90° to 90°., value = "-90";
# - wps.in: id = latMaxTheory, type = integer, title = Biggest latitude wanted for the spatial grid in degree.The real end is calculated according to the latMin and the spatial step. Range of values: -90° to 90°., value = "90";
# - wps.in: id = lonMin, type = integer, title =  Smallest longitude of spatial grid in degree. Range of values : -180° to 180°., value = "-180";
# - wps.in: id = lonmaxTheory, type = integer, title =  Biggest longitude wanted for the spatial grid in degree.The real end is calculated according to the lonMin and the spatial step. Range of values : -180° to 180°., value = "180";
# - wps.in: id = spatialStep, type = real, title = Spatial resolution that fit the side of square polygon in degree. Range of values: 0.001° to 5°., value = "1";
# - wps.in: id = timeStep , type = integer, title = Temporal resolution of calendar in day or month., value = "15";
# - wps.in: id = timeunit , type = character, title = Time unit of temporal resolution, value = "day|month";
# - wps.in: id = firstdate , type = date, title = Fisrt date of calendar, value = "1800-01-01";
# - wps.in: id = finaldate , type = date, title = Final date of calendar, value = "2100-01-01";
# - wps.in: id = method_asso, type character. title = method used for data aggregation. In this case only CWP method is available. Value : "cwp"
# - wps.in: id = agg_with_boat, type = boolean. title =optional dimension: keel code of boat. Value : "TRUE|FALSE"
# - wps.out: id = catchatsizeaggregatet3pluscsv, type = text/zip, title = Catch at size from T3plus database according to spatiotemporal resolution ; 
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
# cat ("A VPN connection is necessary \n")
# call upon database manager for password (ob7@listes.ird.fr)
cat("Database connection in progress ... ")
con <- dbConnect(drv, dbname = "t3_prod",
                 host = "aldabra2", port = 5432,
                 user = "t3-user", password = "***")
cat(" ok \n")


######################### ######################### ######################### 
# Initialisation
######################### ######################### ######################### 
### Definition of spatial grid, squares compound
# spatial resolution
# side of a square, unit : degree, minimum value : 0.001 degree
spatialStep = 1/4
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

### Processing of data (No choice in this script version, see: catch_at_size_t3p_rand_eqd.R )
# method of association between fishery data and spatial grid
# methods is :
# * "CWP" method: the CWP rules of FAO are used
# for more information about CWP rules : http://www.fao.org/fishery/cwp/en
# WARNING CWP rules work only with a spatial grid which is centred of point 0.
method_asso = "cwp"

### boolean : if you want an aggregation with vessel keel code put TRUE
agg_with_boat = FALSE
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
              -- Sélection des activités  
              -------------------------------------------------------------------------
              act AS (
              SELECT
              -- création d'un identifiant spécifique à chaque activité par espèce, type de banc
              ROW_NUMBER() OVER (ORDER BY ocean.code, trip.vessel, activity.date, activity.number) AS id_set,
              CASE
              WHEN ocean.code=1 THEN 'ATL'::text -- ocean atlantique
              WHEN ocean.code=2 THEN 'IND'::text -- ocean indien
              WHEN ocean.code=3 THEN 'PAC'::text -- ocean pacifique
              ELSE 'UNK'::text
              END AS ocean,
              country.codeiso3 as flag,
              CASE
              WHEN vesselsimpletype.code=1 THEN 'PS'::text
              WHEN vesselsimpletype.code=2 THEN 'BB'::text
              WHEN vesselsimpletype.code=3 THEN 'UNK'::text --correspond à 'autre' de T3+
              WHEN vesselsimpletype.code=4 THEN 'LL'::text
              WHEN vesselsimpletype.code=5 THEN 'MIS'::text
              WHEN vesselsimpletype.code=6 THEN 'NK'::text
              END AS gear,
              vessel.keelcode AS c_bat,
              activity.date::DATE AS d_act,
              activity.number::numeric AS n_act,
              CASE
              WHEN schooltype.libelle4 = 'BL' THEN 'FS'::text -- banc libre, free school
              WHEN schooltype.libelle4 = 'BO' THEN 'LS'::text -- banc sous object
              WHEN schooltype.libelle4 = 'IND' THEN 'UNK'::text -- indéterminé, unknown
              END AS schooltype, 
              species.code3l AS species,
              'IND'::text AS sex,
              -- catchtype : rejeté ou capturé
              CASE
              -- ATTENTION les espèces considérées en tant que rejet on un code espèce compris dans l'interval [8, 800:899]
              WHEN species.code = 8::numeric THEN 'D'::text
              WHEN (species.code >= 800 AND species.code <= 899) THEN 'D'::text
              ELSE 'L'::text
              END AS catchtype,
              'NO'::text AS catchunit, -- NO: nombre d'individu
              1::numeric AS sizeinterval,
              samplesetspeciesfrequency.lflengthclass AS sizemin,
              samplesetspeciesfrequency.number::numeric AS catch,
              activity.longitude AS v_lo_act,
              activity.latitude AS v_la_act,
              activity.The_geom AS the_geom
              FROM
              spatial_data,
              public.activity
              INNER JOIN public.samplewell ON samplewell.activity=activity.topiaid
              INNER JOIN public.samplesetspeciesfrequency ON samplesetspeciesfrequency.samplewell=samplewell.topiaid
              INNER JOIN public.species ON samplesetspeciesfrequency.species=species.topiaid
              INNER JOIN public.schooltype ON (activity.schooltype=schooltype.topiaid)
              INNER JOIN public.trip ON (activity.trip=trip.topiaid)
              INNER JOIN public.ocean ON (activity.ocean=ocean.topiaid)
              INNER JOIN public.vessel ON (trip.vessel = vessel.topiaid)
              INNER JOIN public.country ON (vessel.flagcountry=country.topiaid)
              INNER JOIN public.vesseltype ON (vessel.vesseltype = vesseltype.topiaid)
              INNER JOIN public.vesselsimpletype ON (vesseltype.vesselsimpletype = vesselsimpletype.topiaid)
              WHERE
              --filtrage sur l'emprise totale de la grille
              ST_Covers(spatial_data.emprise,activity.the_geom)=true AND
              -- filtrage sur les activités comprisent entre la première et dernière date du calendrier
              (activity.date BETWEEN '",firstDate,"'::date AND '",finalDate,"'::date)
              ORDER BY
              ocean, flag, gear, c_bat, n_act, schooltype, species, sizemin
               -- limit 20
              )
              -------------------------------------------------------------------------
              -- Sélection des polygones se trouvant sur l'emprise des activités
              -------------------------------------------------------------------------
              , spatial_act AS (
              -- calcul de l'emprise spatiale des activités
              SELECT 
              ST_SetSRID(ST_Envelope(ST_Extent(the_geom)),4326) AS emprise
              FROM 
              act
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
              -- Detail des activités par polygones
              -------------------------------------------------------------------------
              data_by_area AS (
              -- détail des activités par polygone
              -- répétition de l'activité si associé à plusieurs polygones 
              SELECT 
              act.id_set AS ID, 
              act.ocean, 
              act.flag, 
              act.gear,
              act.c_bat,
              act.d_act, 
              act.n_act,  
              act.schooltype,
              act.species, 
              act.sex,
              act.sizeinterval,
              act.sizemin,
              act.catchtype,
              act.catchunit AS value_unit,
              act.catch::numeric AS value,
              act.the_geom,
              act.v_lo_act AS lon_data, 
              act.v_la_act AS lat_data, 
              restrict_polygon.geom AS area,
              restrict_polygon.cent_poly,
              restrict_polygon.lon_cent_poly,
              restrict_polygon.lat_cent_poly
              FROM 
              act,restrict_polygon 
              WHERE 
              -- ST_Covers : les activités sur les bordures sont associées au polygone
              ST_Covers(restrict_polygon.geom,act.the_geom)=true 
              ), area_process AS (
              -- lorsque qu'une activité est associée à plusieurs polygones
              -- les règles CWP sont appliquées afin de choisir un polygone
              -- /!\ la sélection du polygone ne fonctionne que sur une grille centré en 0 et régulière
              SELECT 
              data_by_area.ID,
              data_by_area.value,
              data_by_area.value_unit,
              CASE 
              WHEN lat_data>0 OR lat_data=0 THEN MAX(data_by_area.lat_cent_poly)
              WHEN lat_data<0 THEN MIN(data_by_area.lat_cent_poly)
              END lat_cent_poly,
              CASE 
              WHEN lon_data>0 OR lon_data=0 THEN MAX(data_by_area.lon_cent_poly)
              WHEN lon_data<0 THEN MIN(data_by_area.lon_cent_poly)
              END lon_cent_poly
              FROM 
              data_by_area
              GROUP BY 
              ID, value, value_unit, lat_data, lon_data
              ), act_by_select_area AS (
              -- détail des activités associées à un seul et unique polygone
              SELECT 
              data_by_area.ID,
              data_by_area.ocean, 
              data_by_area.c_bat,
              data_by_area.d_act, 
              data_by_area.n_act, 
              data_by_area.flag, 
              data_by_area.gear, 
              data_by_area.schooltype,
              data_by_area.species, 
              data_by_area.sex,
              data_by_area.sizeinterval,
              data_by_area.sizemin,
              data_by_area.catchtype, 
              area_process.value_unit AS catchunit, 
              area_process.value AS catch,  
              data_by_area.the_geom, 
              data_by_area.lat_data, 
              data_by_area.lon_data, 
              data_by_area.area, 
              data_by_area.cent_poly, 
              area_process.lon_cent_poly, 
              area_process.lat_cent_poly
              FROM 
              data_by_area 
              INNER JOIN area_process ON 
              -- NOTE : il est important de ne pas faire de jointure sur area_process.catch 
              --	afin de rendre possible le choix entre la méthode CWP et 
              --	la méthode d'égale distribution dans le script R par la suite
              (data_by_area.ID=area_process.ID AND
              data_by_area.lon_cent_poly=area_process.lon_cent_poly AND
              data_by_area.lat_cent_poly=area_process.lat_cent_poly)
              
              )
              -------------------------------------------------------------------------
              -- Detail des activités par polygones et par période
              -------------------------------------------------------------------------
              -- détail des activités selon la grille spatio-temporelle
              SELECT 
              act_by_select_area.ID,
              act_by_select_area.ocean,
              act_by_select_area.flag, 
              act_by_select_area.gear, 
              act_by_select_area.c_bat,
              act_by_select_area.d_act, 
              act_by_select_area.n_act, 
              ST_AsText(act_by_select_area.the_geom) AS the_geom, 
              act_by_select_area.lat_data, 
              act_by_select_area.lon_data,
              calendar.timestart,
              calendar.timeend, 
              ST_AsText(act_by_select_area.area) AS area,
              ST_AsText(act_by_select_area.cent_poly) AS cent_area,
              act_by_select_area.schooltype,
              act_by_select_area.species, 
              act_by_select_area.sex,
              act_by_select_area.sizeinterval,
              act_by_select_area.sizemin,
              act_by_select_area.catchtype, 
              act_by_select_area.catchunit, 
              act_by_select_area.catch
              FROM 
              act_by_select_area, calendar
              WHERE 
              (act_by_select_area.d_act BETWEEN calendar.timestart AND calendar.timeend)
              ", sep="")

### Logging of dataframe
# dataset contains non aggregated data 
dataset<-dbGetQuery(con, query)
cat(" ok \n")

### Disconnection of data base
dbDisconnect(con)

### Renamed column
# - ocean : ocean where is located the activities. examples : "ATL" for Atlantic, "IND" for Indian
# - flag : vessel flag. example : "FRA"
# - gear : vessel gear. example : "PS"
# - c_bat : optional. vessel keel code. example : "26"
# - d_act : date of fishing data. example: "1990-10-27"
# - n_act : set number. example: "1990-10-27"
# - the_geom : geometric coordinates of fishing data (WKT).
# - lat_data, lon_data : latitude and longitude of fishing data
# - time_start : start of time range. example : "1990-12-25"
# - time_stop : end of time range. example : "1991-01-08"
# - area : polygon geometric coordinates of the spatial grid.
# - cent_area : geometric coordinates of polygon centroid.
# - schooltype : type of scool. example : "IND" (unknown), "BL" (free school), "BO" (school below an object)
# - species : ID of species type (three letters). example : "SKJ"
# - sex : fish sex. example : "IND" for unknown, "M" for male, "F" for female
# - size_min : minimal of size range. example : "10", "20"
# - size_step : size step. fish size = size_min + size_step. example : "0", "1"
# - catchtype : type of catch. example : "L" for captured, "D" for rejected
# - catchunit : catch unit. example : "NO" for number of fish
# - catch : quantity of catches. example : "1.02"
names(dataset) <- c("ID", "ocean", "flag",  "gear", "c_bat", "d_act", "n_act", "the_geom", "lat_data", "lon_data",	"time_start",	"time_end",	"area", "cent_area", "schooltype", "species", "sex", "size_step", "size_min", "catchtype", "catchunit", "v_catch")
cat("Extract data ... ok \n")


######################### ######################### ######################### 
# Treatments
######################### ######################### ######################### 
cat("Data aggregation in progress ... ")
### Date treatments
dataset$time_start <- as.character(dataset$time_start)
# modify date end: exclusive
dataset$time_end <- as.Date.character(dataset$time_end) + 1
dataset$time_end <- as.character(dataset$time_end)

### Convert in a table (processing faster)
dataset_table<-data.table(dataset)

### Aggregation of data
# list of dimensions
dimensions <- c("ocean", "flag", "gear", if(agg_with_boat ==TRUE){"c_bat"} , "time_start", "time_end", "area",
                "schooltype", "species", "sex", "size_step", "size_min", "catchtype", "catchunit")
# aggregation (data.table package)
dataset_table <- dataset_table %>% group_by_(.dots=dimensions) %>% summarise(v_catch=round(sum(v_catch),3))

### Sort of data
dataset_table <- dataset_table[order(dataset_table$ocean, dataset_table$flag, dataset_table$gear, dataset_table$time_start, dataset_table$area, dataset_table$schooltype, dataset_table$species, dataset_table$catchtype, dataset_table$catchunit), ]

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

### Simplification of timeUnit for file title
if (timeUnit == "month") {
  timeUnit_metadata ="m"
} else {
  timeUnit_metadata ="d"
}

### Simplification of method name for file title and method description
if (method_asso == "cwp") {
  method_asso_metadata ="cwp"
  description_method_asso = "The processing uses only fishing activities and attributes each set to an unique polygon according to CWP rules (http://www.fao.org/fishery/cwp/en). WARNING CWP rules work only with a spatial grid which is centred of point 0."
} # else if (method_asso == "equaldistribution") {
#  method_asso_metadata ="eqd"
#  description_method_asso = "The processing uses only fishing activities and attributes each set to one or several polygons. If a fishing data is on several polygons (borders case) the fishing value are distribuated between these polygons. "
#} else if (method_asso == "random") {
#  method_asso_metadata ="rand"
#  description_method_asso = "The processing attributes fishing activities location to an unique polygon. If the location is between several polygons then the polygon is choice randomly."
#}

### Extra information for metadata
if (agg_with_boat == TRUE) {
  extra_info_boat = "The boat code fit vessel keel code."
} else {
  extra_info_boat = ""
}

# character string with list of dimenions
list_dimensions <-  dimensions[1]
for (i in 2:length(dimensions)){
  list_dimensions <- paste(list_dimensions," , ", dimensions[i], sep = "")
}

### Creation of metadata
dataset_name <- as.character(paste("indian_atlantic_oceans_catch_at_size_",spatialStep_filename,"deg_",timeStep,timeUnit_metadata,"_",first_date_dataset,"_",last_date_dataset,"_",method_asso_metadata,"_t3plus", sep=""))
dataset_release_date <- as.character(Sys.Date())
dataset_title <- as.character(paste("Catch at size of tuna and tuna-like species in the Atlantic and Indian oceans (",first_year_dataset, "-", last_year_dataset, ") for french surface fisheries by ",spatialStep_filename, "° / ",timeStep,timeUnit_metadata,"square (logbooks)", sep=""))
operator_contact_name <- as.character("Chloé Dalleau, Paul Taconet")
operator_contact_mail <- as.character("chloe.dalleau@ird.fr, paul.taconet@ird.fr")
operator_origin_institution <- as.character("IRD")
dataset_origin_institution <- as.character("IRD")
url_download_page <- as.character("")
table_description <- as.character(paste("This dataset lists catch at size (in cm) of tuna and tuna-like species in the Atlantic and Indian oceans for french surface fisheries from ", first_year_dataset, " to ", last_year_dataset, " aggregated on a ",spatialStep_filename, " degrees and ",timeStep," ",timeUnit," grid resolution (logbooks). These data come from T3plus database and are collected by French National Research Institute for Sustainable Development (IRD). T3plus database gathers the fine data for seine and pole-and-line vessel from french surface tuna fisheries and partners. This database allows to correct catch data and forcast size samples. ",description_method_asso,"The catch values (number of catch : NO) can have digits after the decimal point because some sizes are converted dorsal length to fork length. Concerning calendar, time_start is inclusive and time_end exclusive. If there are no set in a polygon for a period, this level are not in this dataset.",extra_info_boat,sep=""))
table_short_description <- paste("Catch at size by ",list_dimensions,sep = "")
dataset_description_report_original_url <- as.character("")
table_sql_query <- paste("Query to create the dataset from T3plus database. Executed the ", as.character(Sys.Date()), ". ",as.character(query), sep="")
view_name <- as.character(paste("tunaatlas_ird.ind_atl_catch_",spatialStep_filename,"deg_",timeStep,timeUnit_metadata,"_",first_date_dataset,"_",last_date_dataset,"_",method_asso_metadata,"_balbaya", sep=""))
## Treatment steps
# spatial extent for steps
spatial_extent <- paste("BOX(",lonMin," ", latMin,",",lonMaxTheory," ", latMaxTheory,")", sep = "")
# steps
step_metadata <- paste(
  "step1: Catch data from T3plus database were collated and harmonized.
  step2: Only data included in ",spatial_extent," from ", firstDate," to ", finalDate," are used. 
  step3: A regular grid composed of square polygons was created. The spatial extent is ",spatial_extent," with a resolution of ",spatialStep," decimal degrees.
  step4: A continius calendar was created from ", firstDate," to ", finalDate," with a period of ",timeStep," ",timeUnit,"(s) . The time start of period is inclusive and time end is exclusive.
  step5: Each fishing data was associated to one polygon using the data geolocalisation.", description_method_asso,"
  step6: Each fishing data was associated to one periode of time.
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
cat("- optional dimension: aggregation with boat ", agg_with_boat, "\n")

cat("Data available in : \n")
cat(filepath_dataset, "\n")
cat(filepath_metadata, "\n")