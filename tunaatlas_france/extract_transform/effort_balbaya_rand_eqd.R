warning("This data are confidential. For diffusion please check with the database manager.")
cat("Please inform the database manager of your database usage. \n")

####################### Effort according to spatiotemporal resolution from Balbaya database
# Author : Chloé Dalleau, M2 intern (IRD)
# Training supervisor : Paul Taconet (IRD)
# Date : 21/09/2017 
# 
# ## Purpose
# To determine the effort according to spatiotemporal resolution from Balbaya database in 3 units (sets duration, sea duration, fishing duration).
#
# ## Note
# The Sardara referentials of this dataset are in "../sardara_code_liste/sardarafrance_balbaya_codelists.csv"
#
# ## Description
# 
# 1. Spatial grid and timetable are created
#   - Spatial grid contains geometries objects : polygon with the same SRID of data from Balbaya. The grid extent and the spatial step are choosen by users.
#   - Continuous calendar. The first date, final date and time step are choosen by users.
# 
# 2. Each activities are attibuted to an unique polygon according to selected method. Two methods are developed : equal distribution and random distribution
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
# - method_asso : method used for data aggregation, type character. random method or equal distribution method are available. Value : "random|equaldistribution"
# - agg_with_boat : optional dimension: keel code of boat. type = boolean. Value : "TRUE|FALSE"
# - agg_with_set_type : optional dimension: type of set. type = boolean. Value : "TRUE|FALSE"
# 
# ## Output data
# effort by :
# - ocean : ocean where is located the activities. examples : "ATL" for Atlantic, "IND" for Indian
# - flag : vessel flag. example : "FRA"
# - gear : vessel gear. example : "PS"
# - c_bat : optional. vessel keel code. example : "26"
# - time_start : start of calendar. example : "1990-12-25"
# - time_stop : end of calendar. example : "1991-01-08"
# - area : geometric coordinates of the spatial grid extent.
# - schooltype : type of scool. example : "IND" (unknown), "BL" (free school), "BO" (school below an object)
# - settype : optional. type of set. example : "POS" (positive), "NEG" (negative/null), "ALL" (positive + negative/null)
# - effortUnits : effort unit. example : "SETS" number of set, "DUR.SETS" for sets duration, "HOURS" sea duration, "FHOURS" fishing duration, "BOATS" number of boat
# - effort :  effort. example : "1.02"
# 
# ## WPS code
# - wps.des: id = effortaggregatebalbaya, title =  Efforts according to spatiotempral resolution from Balbaya database, abstract = To determine the  effort by spatiotemporal resolution from Balbaya database in 4 units (number of set, sets duration, sea duration, fishing duration);
# - wps.in: id = latMin, type = integer, title = Smallest latitude of spatial grid in degree. Range of values: -90° to 90°., value = "-90";
# - wps.in: id = latMaxTheory, type = integer, title = Biggest latitude wanted for the spatial grid in degree.The real end is calculated according to the latMin and the spatial step. Range of values: -90° to 90°., value = "90";
# - wps.in: id = lonMin, type = integer, title =  Smallest longitude of spatial grid in degree. Range of values : -180° to 180°., value = "-180";
# - wps.in: id = lonmaxTheory, type = integer, title =  Biggest longitude wanted for the spatial grid in degree.The real end is calculated according to the lonMin and the spatial step. Range of values : -180° to 180°., value = "180";
# - wps.in: id = spatialStep, type = real, title = Spatial resolution that fit the side of square polygon in degree. Range of values: 0.001° to 5°., value = "1";
# - wps.in: id = timeStep , type = integer, title = Temporal resolution of calendar in day or month., value = "15";
# - wps.in: id = timeunit , type = character, title = Time unit of temporal resolution, value = "day|month";
# - wps.in: id = firstdate , type = date, title = Fisrt date of calendar, value = "1800-01-01";
# - wps.in: id = finaldate , type = date, title = Final date of calendar, value = "2100-01-01";
# - wps.in: id = method_asso, type character. title = Method used for data aggregation random method or equal distribution method are available. Value : "random|equaldistribution"
# - wps.in: id = agg_with_boat, type = boolean. title =optional dimension: keel code of boat. Value : "TRUE|FALSE"
# - wps.in: id =  agg_with_set_type, type = boolean. title =optional dimension: type of set. Value : "TRUE|FALSE"
# - wps.out: id = effortaggregatebalbayacsv, type = text/zip, title = Effort from Balbaya database by ocean, flag, gear,(keel code vessel), timetable,  area, school type, (set type), effort units, effort ;  
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
con <- dbConnect(drv, dbname = "balbaya",
                 host = "aldabra2", port = 5432,
                 user = "invbalbaya", password = "***")
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
finalDate = Sys.Date() # advice : Sys.Date() for current day

### Processing of data (to use CWP method, see: effort_balbaya_cwp.R )
# method of association between fishery data and spatial grid
# methods are :"equaldistribution" or "random"
# * "equaldistribution" method: If a fishing data is on several polygons (borders case) the fishing value are distribuated between these polygons
# * "random": If a fishing data is on several polygons (borders case) the polygon is chosen randomly.
method_asso = "random"

### boolean : if you want an aggregation with vessel keel code put TRUE
agg_with_boat = FALSE

### boolean : if you want an aggregation with kind of set put TRUE
agg_with_set_type = FALSE

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
              -- Sélection des activités avec les dimensions souhaitées
              -------------------------------------------------------------------------
              union_effort AS (
              -- fusion des différents types d'effort dans la colonne effort
              -- la colonne unité d'effort permet de différencier les types d'effort
              (
              SELECT 
              -- temps en mer
              activite.c_bat,
              activite.d_act, 
              activite.n_act,
              'ALL'::text AS settype,
              'HOURS'::text AS effortunit,
              activite.v_tmer AS effort
              FROM 
              public.activite
              WHERE
              -- filtrage sur les activités de pêche
              -- les types d'opération NULL sont comptabilisé car elles n'étaient pas renseigné à une époque
              (public.activite.c_opera IS NULL OR public.activite.c_opera IN (0,1,2,14) ) AND
              activite.v_tmer IS NOT NULL
              -- limit 10
              )
              UNION
              (
              SELECT 
              -- temps de recherche 
              activite.c_bat,
              activite.d_act, 
              activite.n_act,
              'ALL'::text AS settype,
              'FHOURS'::text AS effortunit,
              activite.v_tpec AS effort
              FROM 
              public.activite
              WHERE
              -- filtrage sur les activités de pêche
              -- les types d'opération NULL sont comptabilisé car elles n'étaient pas renseigné à une époque
              (public.activite.c_opera IS NULL OR public.activite.c_opera IN (0,1,2,14) ) AND
              activite.v_tpec IS NOT NULL
              -- limit 10
              )
              UNION
              (
              SELECT 
              -- durée de calée
              activite.c_bat,
              activite.d_act, 
              activite.n_act,
              CASE 
              WHEN activite.v_nb_calee_pos >0 THEN 'POS'
              WHEN activite.v_nb_calee_neg >0 THEN 'NEG'
              ELSE 'ALL'
              END AS settype,
              'DUR.SETS'::text AS effortunit,
              activite.v_dur_cal AS effort
              FROM 
              public.activite	
              WHERE
              -- filtrage sur les activités de pêche
              -- les types d'opération NULL sont comptabilisé car elles n'étaient pas renseigné à une époque
              (public.activite.c_opera IS NULL OR public.activite.c_opera IN (0,1,2,14) ) AND
              activite.v_dur_cal !=0 OR NOT NULL
              -- limit 10
              )
              UNION 
              (
              SELECT 
              -- nombre de set positif
              activite.c_bat,
              activite.d_act, 
              activite.n_act,
              'POS'::text AS settype,
              'SETS'::text AS effortunit,
              activite.v_nb_calee_pos AS effort
              FROM 
              public.activite	
              WHERE
              -- filtrage sur les activités de pêche
              -- les types d'opération NULL sont comptabilisé car elles n'étaient pas renseigné à une époque
              (public.activite.c_opera IS NULL OR public.activite.c_opera IN (0,1,2,14) ) AND
              activite.v_nb_calee_pos!=0 OR NOT NULL	
              -- limit 10
              )
              UNION 
              (
              SELECT 
              -- nombre de calée NULL (négatif)
              activite.c_bat,
              activite.d_act, 
              activite.n_act,
              'NEG'::text AS settype,
              'SETS'::text AS effortunit,
              activite.v_nb_calee_neg AS effort
              FROM 
              public.activite	
              
              WHERE
              -- filtrage sur les activités de pêche
              -- les types d'opération NULL sont comptabilisé car elles n'étaient pas renseigné à une époque
              (public.activite.c_opera IS NULL OR public.activite.c_opera IN (0,1,2,14) ) AND
              activite.v_nb_calee_neg !=0 OR NOT NULL	
              -- limit 10
              )	
              ),act AS (
              SELECT  
              -- création d'un identifiant spécifique à chaque activité
              ROW_NUMBER() OVER (ORDER BY activite.c_ocea, activite.c_bat,activite.d_act, activite.n_act) AS ID,
              CASE
              WHEN activite.c_ocea=1 THEN 'ATL'::text -- ocean atlantique
              WHEN activite.c_ocea=2 THEN 'IND'::text -- ocean indien
              WHEN activite.c_ocea=3 THEN 'PAC'::text -- ocean pacifique
              ELSE 'UNK'::text
              END AS ocean,
              pavillon.c_pays_fao AS flag,  
              engin.c_engin_4l AS gear, 
              union_effort.c_bat,
              union_effort.d_act, 
              union_effort.n_act,
              CASE
              WHEN type_banc.l4c_tban = 'BL' THEN 'FS'::text -- banc libre, free school
              WHEN type_banc.l4c_tban = 'BO' THEN 'LS'::text -- banc sous object
              WHEN (type_banc.l4c_tban = 'IND' OR NULL) THEN 'UNK'::text -- indéterminé, unknown
              END AS schooltype,
              union_effort.settype,
              union_effort.effortunit,
              union_effort.effort,
              activite.v_la_act AS lat_data, 
              activite.v_lo_act AS lon_data, 
              activite.the_geom
              FROM 
              spatial_data,
              union_effort
              LEFT JOIN public.activite ON (union_effort.c_bat=activite.c_bat AND 
              union_effort.d_act=activite.d_act AND
              union_effort.n_act=activite.n_act)
              LEFT JOIN public.type_banc ON activite.c_tban = type_banc.c_tban
              LEFT JOIN public.bateau ON activite.c_bat = bateau.c_bat
              LEFT JOIN public.pavillon ON bateau.c_pav_b = pavillon.c_pav_b 
              LEFT JOIN public.type_bateau ON bateau.c_typ_b = type_bateau.c_typ_b 
              LEFT JOIN public.engin ON type_bateau.c_engin = engin.c_engin 
              WHERE
              --filtrage sur l'emprise totale de la grille  
              ST_Covers(spatial_data.emprise,activite.the_geom)=true AND
              -- filtrage sur les activités comprisent entre la première et dernière date du calendrier
              (activite.d_act BETWEEN '",firstDate,"'::date AND '",finalDate,"'::date) AND
              -- filtrage sur les activités de pêche
              -- les types d'opération NULL sont comptabilisé car elles n'étaient pas renseigné à une époque
              (public.activite.c_opera IS NULL OR public.activite.c_opera IN (0,1,2,14) )
              ORDER BY 
              ocean, flag, gear, c_bat, d_act, n_act,v_tmer, v_tpec, v_dur_cal,
              schooltype, lat_data, lon_data, the_geom   
              )
              -------------------------------------------------------------------------
              -- Sélection des polygones se trouvant sur l'emprise des activités
              -------------------------------------------------------------------------
              , spatial_act AS (
              -- calcul de l'emprise spatiale des activitées
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
              act.ID, 
              act.ocean, 
              act.flag, 
              act.gear,
              act.c_bat,
              act.d_act, 
              act.n_act,
              act.effortunit AS value_unit,
              act.effort::numeric AS value,  
              act.schooltype,
              act.settype,
              act.the_geom,
              act.lon_data, 
              act.lat_data, 
              restrict_polygon.geom AS area,
              restrict_polygon.cent_poly,
              restrict_polygon.lon_cent_poly,
              restrict_polygon.lat_cent_poly
              FROM 
              act,restrict_polygon 
              WHERE 
              -- ST_Covers : les activités sur les bordures sont associées au polygone
              ST_Covers(restrict_polygon.geom,act.the_geom)=true 
              ), ",association_method(method_asso),"
              , act_by_select_area AS (
              -- détail des activités associées à un seul et unique polygone
              SELECT 
              area_process.ID,
              data_by_area.ocean,  
              data_by_area.flag, 
              data_by_area.gear,
              data_by_area.c_bat,
              data_by_area.d_act, 
              data_by_area.n_act, 
              data_by_area.schooltype, 
              data_by_area.settype,
              area_process.value_unit AS effortunit, 
              area_process.value AS effort,  
              data_by_area.the_geom, 
              data_by_area.lat_data, 
              data_by_area.lon_data, 
              data_by_area.area, 
              data_by_area.cent_poly, 
              data_by_area.lon_cent_poly, 
              data_by_area.lat_cent_poly
              FROM 
              data_by_area
              INNER JOIN area_process ON area_process.ID=data_by_area.ID AND 
              area_process.cent_poly = data_by_area.cent_poly
              )
              -------------------------------------------------------------------------
              -- Detail des activités par polygones et par période
              -------------------------------------------------------------------------
              --act_by_area_time AS (
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
              ST_Astext(act_by_select_area.area) AS area,
              ST_Astext(act_by_select_area.cent_poly) AS cent_area,
              act_by_select_area.schooltype,
              act_by_select_area.settype,
              act_by_select_area.effortunit,
              act_by_select_area.effort
              FROM 
              act_by_select_area, calendar
              WHERE 
              (act_by_select_area.d_act BETWEEN calendar.timestart AND calendar.timeend)
              ", sep="")

### Logging of dataframe
# dataset contains non aggregated data 
dataset<-dbGetQuery(con, query)
cat("ok \n")

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
# - time_start : start of calendar. example : "1990-12-25"
# - time_stop : end of calendar. example : "1991-01-08"
# - area : geometric coordinates of the spatial grid extent.
# - schooltype : type of scool. example : "IND" (unknown), "BL" (free school), "BO" (school below an object)
# - settype : optional. type of set. example : "POS" (positive), "NEG" (negative/null), "ALL" (positive + negative/null)
# - effortUnits : effort unit. example : "SETS" number of set, "DUR.SETS" for sets duration, "HOURS" sea duration, "FHOURS" fishing duration, "BOATS" number of boat
# - v_effort :  effort. example : "1.02"
names(dataset) <- c( "ID", "ocean", "flag", "gear", "c_bat", "d_act", "n_act", "the_geom", "lat_data", "lon_data",	"time_start",	"time_end",	"area", "cent_area",	"schooltype", "settype", "effortunit", "v_effort")
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

### Creation of boats effort
# selection of boats dimensions
data_cbat <-dataset_table[,c(2,3,4,5,11,12,13,14), with=FALSE] 
# deletion of duplicate lines (exemple : 2 activities for a boat in the same day and the same area)
data_cbat <- data_cbat %>% distinct(ocean, flag, gear, c_bat, time_start, time_end, area, cent_area) 
# add effort dimensions for boats
data_cbat_effort<- cbind(data_cbat,rep("ALL"),rep("ALL"),rep("BOATS"), rep(as.numeric(1)))
setnames(data_cbat_effort, c(9,10,11,12), c("schooltype" ,"settype", "effortunit","v_effort"))

### Aggregation of data
# list of dimensions
dimensions <- c("ocean", "flag", "gear", if(agg_with_boat ==TRUE){"c_bat"}, "time_start", "time_end",
                "area", "cent_area", "schooltype", if(agg_with_boat ==TRUE){"settype"} , "effortunit")
## aggregation (data.table package)
# aggregation of data effort (except boats effort)
dataset_table <- dataset_table %>% group_by_(.dots=dimensions) %>% summarise(v_effort=round(sum(v_effort),3))
# aggregation of boats effort
data_cbat_effort <- data_cbat_effort %>% group_by_(.dots=dimensions) %>% summarise(v_effort=round(sum(v_effort),3))

### Merge of data
l = list(dataset_table,data_cbat_effort)
dataset_final <- rbindlist(l, use.names=TRUE)

### Sort of data
dataset_final <-dataset_final[order(dataset_final$ocean, dataset_final$flag, dataset_final$gear, dataset_final$time_start, dataset_final$area, dataset_final$schooltype, dataset_final$effortunit), ]


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
# if (method_asso == "cwp") {
#  method_asso_metadata ="cwp"
#  description_method_asso = "The processing uses only fishing activities and attributes each set to an unique polygon according to CWP rules (http://www.fao.org/fishery/cwp/en). WARNING CWP rules work only with a spatial grid which is centred of point 0."
#} else 
if (method_asso == "equaldistribution") {
  method_asso_metadata ="eqd"
  description_method_asso = "The processing uses only fishing activities and attributes each set to one or several polygons. If a fishing data is on several polygons (borders case) the fishing value are distribuated between these polygons. "
} else if (method_asso == "random") {
  method_asso_metadata ="rand"
  description_method_asso = "The processing attributes fishing activities location to an unique polygon. If the location is between several polygons then the polygon is choice randomly."
}

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
dataset_name <- as.character(paste("indian_atlantic_oceans_effort_",spatialStep_filename,"deg_",timeStep,timeUnit_metadata,"_",first_date_dataset,"_",last_date_dataset,"_",method_asso_metadata,"_balbaya", sep=""))
dataset_release_date <- as.character(Sys.Date())
dataset_title <- as.character(paste("Fishing effort of tuna and tuna-like species in the Atlantic and Indian oceans (",first_year_dataset, "-", last_year_dataset, ") for french surface fisheries by ",spatialStep_filename, "° / ",timeStep,timeUnit_metadata,"square (logbooks)", sep=""))
operator_contact_name <- as.character("Chloé Dalleau, Paul Taconet")
operator_contact_mail <- as.character("chloe.dalleau@ird.fr, paul.taconet@ird.fr")
operator_origin_institution <- as.character("IRD")
dataset_origin_institution <- as.character("IRD")
url_download_page <- as.character("")
table_description <- as.character(paste("This dataset lists fishing effort of tuna and tuna-like species in the Atlantic and Indian oceans for french surface fisheries from ", first_year_dataset, " to ", last_year_dataset, " aggregated on a ",spatialStep_filename, " degrees and ",timeStep," ",timeUnit," grid resolution (logbooks). These data come from Balbaya database and are collected by French National Research Institute for Sustainable Development (IRD).  Balbaya database gathers the fine data for seine and pole-and-line vessel from french surface tuna fisheries and partners. This database contains data about landing, individual sample and correct catches and fishery efforts by set. ",description_method_asso,"Concerning calendar, time_start is inclusive and time_end exclusive. If there are no set in a polygon for a period, this level are not in this dataset.",extra_info_boat,sep=""))
table_short_description <- paste("Effort by ",list_dimensions,sep = "")
dataset_description_report_original_url <- as.character("")
table_sql_query <- paste("Query to create the dataset from Balbaya database. Executed the ", as.character(Sys.Date()), ". ",as.character(query), sep="")
view_name <- as.character(paste("tunaatlas_ird.ind_atl_effort_",spatialStep_filename,"deg_",timeStep,timeUnit_metadata,"_",first_date_dataset,"_",last_date_dataset,"_",method_asso_metadata,"_balbaya", sep=""))
## Treatment steps
# spatial extent for steps
spatial_extent <- paste("BOX(",lonMin," ", latMin,",",lonMaxTheory," ", latMaxTheory,")", sep = "")
# steps
step_metadata <- paste(
  "step1: Effort data from Balbaya database were collated and harmonized.
  step2: Only data included in ",spatial_extent," from ", firstDate," to ", finalDate," are used. 
  step3: A regular grid composed of square polygons was created. The spatial extent is ",spatial_extent," with a resolution of ",spatialStep," decimal degrees.
  step4: A continius calendar was created from ", firstDate," to ", finalDate," with a period of ",timeStep," ",timeUnit,"(s) . The time start of period is inclusive and time end is exclusive.
  step5: Each fishing data was associated to ", if (method_asso=="equaldistribution"){"one or several polygons"} else {"one polygon"} ," using the data geolocalisation.", description_method_asso,"
  step6: Each fishing data was associated to one periode of time.
  step7: Number of boat in a resolution spatio-temporal is calculated.
  step8: Data were aggregated according to :",list_dimensions,".
  step9: Metadata were created according to the input data and the source database.
  step10: CSV files were created.
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
cat("- optional dimension: aggregation with set type ", agg_with_set_type, "\n")

cat("Data available in : \n")
cat(filepath_dataset, "\n")
cat(filepath_metadata, "\n")