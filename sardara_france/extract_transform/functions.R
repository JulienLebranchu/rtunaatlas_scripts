####################### List of functions
# Author : Chloé Dalleau, M2 intern (IRD)
# Training supervisor : Paul Taconet (IRD)
# Date : 19/09/2017 
# 
# ## Summary 
# 1. create_grid : Return a regular spatial grid in postgis SQL
# 2. create_timetable : Return a continus calendar in posgis SQL
# 3. association_method : If a data is on spatial grid border: Process the select method : CWP rules (on spatial grid centred on 0), equal distribution or random distribution

######################### ######################### ######################### 
create_grid<-function(latMin,latMaxTheory,lonMin,lonMaxTheory,spatialStep)
{
  #' Return a spatial grid in postgis SQL
  #'
  #' Return postgis SQL query that allows creating a spatial grid with parameters extent and resolution.
  #' The function has to be ran in function WITH of postgreSQL.
  #'
  #' @param spatialStep square side of the spatial grid in degree, type = integer;
  #' @param latMin smallest latitude for the spatial grid in degree, type = integer;
  #' @param latMaxTheory biggest latitude wanted for the spatial grid in degree, 
  #' the real biggest latitude will be calculate later according to the spatialStep, type = integer;
  #' @param lonMin smallest longitude for the spatial grid in degree, type = integer;
  #' @param lonMaxTheory biggest longitude wanted for the spatial grid in degree, 
  #' the real biggest longitude will be calculate later according to the spatialStep, type = integer;
  #'
  #' @return return postgis SQL query :
  #' spatial_data.emprise : spatial extent of selected coordonates by users
  #' spatial_data.reso_sp : spatial resolution choosen by users
  #' grid_lat_multi : list of latitude multiplied by 'multiplicateur' (from latMin to [latMax-SaptialStep]) using the spatial step 
  #' grid_lon_multi : list of longitude multiplied by 'multiplicateur' (from lonMax to [lonMax-SaptialStep]) using the spatial step,
  #' grid : list of possible combination of geometric coordinate using grid_lat and grid_lon
  #' polygon : polygon list of spatial grid (geometry)
  #' 
  #' @author Chloé Dalleau, \email{chloe.dalleau@ird.fr}
  #' @keywords sql, spatial, grid
  #'
  #' @examples
  #' query <- paste("
  #'  WITH subquery1 AS (
  #'      SELECT * FROM table
  #' ),"
  #' , create_grid(-85,85,-100,150,5) ,
  #' ", subquery2 AS (
  #'      SELECT * FROM table2
  #' )
  #' SELECT * FROM subquery1, subquery2, polygon
  #'  ", sep="")
  
  
  # calculation of the last latitude according to spatialStep
  latMax = latMin + ceiling(abs(latMaxTheory-latMin)/spatialStep)*spatialStep
  
  # calculation of the last latitude according to spatialStep
  lonMax= lonMin + ceiling(abs(lonMaxTheory-lonMin)/spatialStep)*spatialStep
  
  # calculation of "multiplicateur"
  # function generate_series is used for generate series
  # integer has to used in this function
  # "multiplicateur" allows to create series with integer for float spatial step
  number= spatialStep
  multiplicateur = 1
  if (number<1) {
    while (number != 0) {
      multiplicateur=multiplicateur*10
      number=number*10
      # round because it can create digits >3
      number=round(number-round(trunc(number)), digits = 3)
    }
  }
  
  sql_for_grid <- paste("
                        spatial_data AS (
                        -- emprise et résolution spatiale choisies par l'utilisateur
                        SELECT
                        ST_SetSRID(ST_Makepolygon(ST_MakeLine(array[
                        ST_MakePoint(",lonMin,", ",latMin,"),
                        ST_MakePoint(",lonMin,", ",latMax,"),
                        ST_MakePoint(",lonMax,", ",latMax,"),
                        ST_MakePoint(",lonMax,", ",latMin,"),
                        ST_MakePoint(",lonMin,", ",latMin,")
                        ])), 4326) AS emprise,
                        ",spatialStep," AS reso_sp,
                        -- le multiplicateur permet de générer une série avec des nombres entiers
                        -- (qui est une condition d'utilisation de la fontion generate_series)
                        -- il est calculé en fonction de la précision de la résolution spatiale
                        ",multiplicateur," AS multiplicateur
                        ), emprise_sp_multi as (
                        -- points de l'emprise et resolution spatile multipliés par le multiplicateur
                        -- afin de créer des séries représentant les latitudes et les longitudes.
                        -- multiplicateur permet d'obtenir des nombres entiers pour le generate_series
                        SELECT 
                        ST_Ymin(spatial_data.emprise)*multiplicateur AS ymin_multi,
                        ST_Ymax(spatial_data.emprise)*multiplicateur AS ymax_multi,
                        ST_Xmin(spatial_data.emprise)*multiplicateur AS xmin_multi,
                        ST_Xmax(spatial_data.emprise)*multiplicateur AS xmax_multi,
                        reso_sp*multiplicateur AS reso_sp_multi
                        FROM 
                        spatial_data
                        ), grid_lat_multi AS (
                        -- création des points de latitude(*multiplicateur) selon l'emprise et la resolution spatiale
                        -- soustraction de la resolution spatiale au Ymax afin de correspondre à l'emprise choisie 
                        -- lors de la création des polygones
                        SELECT 
                        generate_series(ymin_multi::integer ,(ymax_multi - reso_sp_multi)::integer,reso_sp_multi::integer) AS latmulti
                        FROM
                        emprise_sp_multi
                        ORDER BY 
                        latmulti
                        ), grid_lon_multi AS (
                        -- création des points de longitude(*multiplicateur) selon l'emprise et la resolution spatiale
                        -- soustraction de la resolution spatiale au Xmax afin de correspondre à l'emprise choisie 
                        -- lors de la création des polygones
                        SELECT
                        generate_series(xmin_multi::integer,(xmax_multi - reso_sp_multi)::integer,reso_sp_multi::integer) AS lonmulti
                        FROM
                        emprise_sp_multi
                        ORDER BY 
                        lonmulti
                        ), grid AS (
                        -- liste des combinaisons de latitude/longitude
                        -- division par le multiplicateur afin d'avoir les points correspondant à l'emprise initiale
                        SELECT 
                        grid_lat_multi.latmulti/spatial_data.multiplicateur::float AS lat,
                        grid_lon_multi.lonmulti/spatial_data.multiplicateur::float AS lon
                        FROM 
                        grid_lat_multi, grid_lon_multi, spatial_data
                        ORDER BY 
                        lat, lon
                        ), make_polygon AS (
                        -- création des polygones de la grille spatiale
                        SELECT 
                        ST_SetSRID(ST_Makepolygon(ST_MakeLine(array[
                        ST_MakePoint(lon, lat),
                        ST_MakePoint(lon, lat+reso_sp),
                        ST_MakePoint(lon+reso_sp, lat+reso_sp),
                        ST_MakePoint(lon+reso_sp, lat),
                        ST_MakePoint(lon, lat)
                        ])), 4326) AS geom
                        FROM 
                        grid, spatial_data
                        ), polygon AS (
                        SELECT 
                        make_polygon.geom, 
                        ST_Centroid(make_polygon.geom) AS cent_poly,
                        ST_X(ST_Centroid(make_polygon.geom)) AS lon_cent_poly,
                        ST_Y(ST_Centroid(make_polygon.geom)) AS lat_cent_poly	
                        FROM 
                        make_polygon
                        )
                        ", sep="")
  
  return(sql_for_grid)
}


######################### ######################### ######################### 
create_timetable<-function(firstdate,finaldate,timestep,timeunit)
{
  
  #' Return a calendar in posgis SQL
  #'
  #'Return postgis SQL query that allows creating a continuous calendar between two date and with a temporal resolution in days or months.
  #' The function has to be ran in function WITH of postgreSQL. 
  #'
  #' @param firstdate first date of timetable, format : YYYY-MM-DD, type = character;
  #' @param finaldate final date of timetable, format : YYYY-MM-DD, type = character;
  #' @param timestep time step of timetable in day or month , type = integer;
  #' @param timeunit time unit of timestep, accepted value : "day" or "month", type = character;
  #' 
  #' @return character string with a main SQL query:
  #' calendar : timetable according to first date, final date, time step and time unit 
  #' 
  #' @author Chloé Dalleau, \email{chloe.dalleau@ird.fr}
  #' @keywords sql, timetable, day, month
  #'
  #' @examples
  #' query <- paste("
  #'  WITH subquery1 AS (
  #'      SELECT * FROM table
  #' ),"
  #' , create_timetable('1800-01-01','2100-01-01',15,"day") ,
  #' ", subquery2 AS (
  #'      SELECT * FROM table2
  #' )
  #' SELECT * FROM subquery1, subquery2, calendar
  #'  ", sep="")
  
  
  timeunit <- as.character(timeunit)
  firstdate <- as.character(firstdate)
  finaldate <- as.character(finaldate)
  
  
  if (timeunit=="month") {
    
    sql_for_timetable <- paste("
                               calcul_annee AS (
                               SELECT age('",finaldate,"','",firstdate,"') AS interv
                               ), calcul_mois AS (
                               SELECT (date_part('year', interv)*12 + date_part('month', interv))::integer AS m
                               FROM calcul_annee
                               ), series_mois AS (
                               SELECT generate_series(0,m/",timestep,") AS n
                               FROM calcul_mois
                               ), pre_calendar AS (
                               SELECT  date '",firstdate,"' + (",timestep,"*n || 'month')::INTERVAL AS timestart,
                               date '",firstdate,"' + (",timestep,"*(n+1) || 'month')::INTERVAL AS timeend
                               FROM   series_mois
                               ), calendar AS (
                               SELECT timestart, timeend - interval '1 day' AS timeend
                               FROM pre_calendar
                               )
                               ", sep="") 
    
  } else if (timeunit=="day" & timestep==15) {
    
    sql_for_timetable <- paste("
                               calcul_annee AS (
                               SELECT 
                               age('",finaldate,"','",firstdate,"') AS interv
                               ), calcul_mois AS (
                               SELECT 
                               (date_part('year', interv)*12 + date_part('month', interv))::integer AS m,
                               date_part('month', interv) AS month
                               FROM calcul_annee  
                               ), series_mois AS (
                               SELECT 
                               generate_series(0,m) AS n
                               FROM 
                               calcul_mois       
                               ), quinzaine1 AS (
                               SELECT  
                               date '",firstdate,"' + (n || 'month')::INTERVAL AS timestart,
                               date '",firstdate,"' + (n || 'month')::INTERVAL  + (14 || 'day')::INTERVAL AS timeend
                               FROM   
                               series_mois       
                               ORDER BY 
                               timestart
                               ), quinzaine2 AS (
                               SELECT  
                               date '",firstdate,"' + (n || 'month')::INTERVAL + (15 || 'day')::INTERVAL AS timestart,
                               date '",firstdate,"' + (n+1 || 'month')::INTERVAL  - (1 || 'day')::INTERVAL AS timeend
                               FROM   
                               series_mois       
                               ), precalendar AS (
                               SELECT timestart, timeend FROM quinzaine1
                               UNION
                               SELECT timestart, timeend FROM quinzaine2
                               ), calendar AS (
                               SELECT 
                               timestart,
                               timeend
                               FROM
                               precalendar
                               ORDER BY
                               timestart
                               )
                               ", sep="") 
    
  } else {
    
    timestep_minus_one = timestep-1
    
    sql_for_timetable <- paste("
                               number_period AS (
                               -- calcul de la longueur de la séquence temporelle :
                               -- nombre de jour entre les dates de départ et de fin
                               -- divisé par la résolution temporelle choisie
                               -- renvoi un nombre au format integer, (note :  2431.6 arrondi à 2431)
                               SELECT (date '",finaldate,"' - date '",firstdate,"')/",timestep," AS n
                               ), series AS (
                               -- génère une serie correspondant à la longueur de la séquence voulue
                               SELECT generate_series(0, n) AS n
                               FROM number_period
                               ), calendar AS (
                               -- création du calendier 
                               SELECT  date '",firstdate,"' + (",timestep,"*n || ' day')::INTERVAL AS timestart,
                               date '",firstdate,"' + integer '",timestep_minus_one,"' + (",timestep,"*n || ' day')::INTERVAL AS timeend
                               FROM   series
                               )
                               ", sep="")
    
  }
  
  return(sql_for_timetable)
}

######################### ######################### ######################### 
association_method <-function(method)
{
  #' Process the select method : randomly distribution or equal distribution
  #'
  #' Return postgis SQL query that allows to associate a point, like fishery data, to a polygon, like spatial grid, with the select method. Two methods are created : randomly distribution or equal distribution. These methods are used when a point are on more than one polygon. Equal distribution is a équal distribution of values between the select polygons. If a fishing data is on several polygons (borders case) the polygon is chosen randomly
  #' The function has to be ran in function WITH of postgreSQL.
  #'
  #' @param association method between a fishery data and a polygon
  #'
  #' @return return postgis SQL query :
  #' area_process : list of data ID associate with polygons according to the select method
  #' 
  #' @author Chloé Dalleau, \email{chloe.dalleau@ird.fr}
  #' @keywords CWP, distribution, geometry
  #'
  #' @examples
  #' query <- paste("
  #'  WITH subquery1 AS (
  #'      SELECT * FROM table
  #' ),"
  #' , association_method("equaldistribution") ,
  #' ", subquery2 AS (
  #'      SELECT * FROM table2
  #' )
  #' SELECT * FROM subquery1, subquery2, polygon
  #'  ", sep="")
  
 if (method=="equaldistribution") {
    sql_for_association <- paste("
                                 -------------------------------------------------------------------------
                                 -- Association method between fishery data and polygon
                                 -------------------------------------------------------------------------
                                 number_polygon AS (
                                  -- on compte le nombre de polygone intersecté
                                 SELECT 
                                 ID,
                                 COUNT(ID) AS number_poly
                                 FROM 
                                 data_by_area
                                 GROUP BY 
                                 ID
                                 ), area_process AS ( 
                                 -- lorsque qu'une activité est associée à plusieurs polygones
                                 -- la quantité de capture est divisé par le nombre de polygones associés
                                 -- NOTE : il est important de garder cent_poly
                                 --	afin de rendre possible le choix entre la méthode aléatoire et 
                                 --	la méthode d'égale distributiondans le script R par la suite
                                 SELECT 
                                 data_by_area.ID,
                                 data_by_area.value_unit,
                                 data_by_area.cent_poly,
                                 ROUND(data_by_area.value/number_polygon.number_poly,3) AS value
                                 FROM 
                                 data_by_area
                                 INNER JOIN number_polygon ON data_by_area.ID=number_polygon.ID
                                 )
                                 ", sep="")
} else if (method=="random") {
  sql_for_association <- paste("
                               
                               random_value AS (
                                -- ajout d'une valeur aléatoire à chaque ligne
                               SELECT 
                               ID,
                               data_by_area.cent_poly,
                               data_by_area.value_unit,
                               data_by_area.value,
                               RANDOM() AS rand_value
                               FROM 
                               data_by_area 
                               ), pre_process AS (
                               -- on choisi l'ID avec la valeure aléatoire maximale
                               SELECT 
                               random_value.ID,
                               random_value.value_unit,
                               random_value.value,
                               max(rand_value) AS rand_value
                               FROM 
                               random_value
                               GROUP by 
                               ID, value_unit, value
                               
                               ), area_process AS (
                               -- on fait une jointure afin d'avoir dans area_process le polygon et la valeur aléatoire
                               SELECT 
                               pre_process.ID,
                               pre_process.value_unit,
                               pre_process.value,
                               random_value.cent_poly,
                               pre_process.rand_value
                               FROM 
                               pre_process JOIN random_value ON 
                        					pre_process.ID=random_value.ID AND 
                        					pre_process.rand_value=random_value.rand_value
                               )
                               ", sep="")
}

   return(sql_for_association)
}

