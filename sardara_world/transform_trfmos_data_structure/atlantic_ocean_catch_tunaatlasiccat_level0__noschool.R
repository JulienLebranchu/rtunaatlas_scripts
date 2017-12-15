######################################################################
##### 52North WPS annotations ##########
######################################################################
# wps.des: id = atlantic_ocean_catch_1deg_1m_tunaatlasiccat_level0__noschool, title = Harmonize data structure of ICCAT catch dataset, abstract = Harmonize the structure of ICCAT catch-and-effort datasets: (pid of output file = atlantic_ocean_catch_1deg_1m_tunaatlasiccat_level0__noschool). The only mandatory field is the first one. The metadata must be filled-in only if the dataset will be loaded in the Tuna atlas database. ;
# wps.in: id = path_to_raw_dataset, type = String, title = Path to the input dataset to harmonize (Miscroft Access (.mdb)). The input database being voluminous, the execution of the function might take long time. Input file must be structured as follow: https://goo.gl/A6qVhb, value = "https://goo.gl/A6qVhb";
# wps.in: id = path_to_metadata_file, type = String, title = NULL or path to the csv of metadata. The template file can be found here: https://raw.githubusercontent.com/ptaconet/rtunaatlas_scripts/master/sardara_world/transform_trfmos_data_structure/metadata_source_datasets_to_database/metadata_source_datasets_to_database_template.csv . If NULL, no metadata will be outputted., value = "NULL";
# wps.out: id = zip_namefile, type = text/zip, title = Dataset with structure harmonized + File of metadata (for integration within the Tuna Atlas database) + File of code lists (for integration within the Tuna Atlas database) ; 

#' @author Paul Taconet, IRD \email{paul.taconet@ird.fr}
#' 
#' @keywords Internal Commission for the Conservation of Atlantic Tuna tuna RFMO Sardara Global database on tuna fishieries
#'
#' @seealso \code{\link{convertDSD_iccat_ce_task2_ByOperationMode}} to convert ICCAT task 2 "by operation mode", \code{\link{convertDSD_iccat_nc}} to convert ICCAT nominal catch data structure


if(!require(rtunaatlas)){
  if(!require(devtools)){
    install.packages("devtools")
  }
  require(devtools)
  install_github("ptaconet/rtunaatlas")
}
if(!require(data.table)){
  install.packages("data.table")
}
if(!require(dplyr)){
  install.packages("dplyr")
}
if(!require(Hmisc)){
  install.packages("Hmisc")
}

require(rtunaatlas)
require(data.table)
require(dplyr)
require(Hmisc) # install mdb tools (http://svitsrv25.epfl.ch/R-doc/library/Hmisc/html/mdb.get.html)

  # Input data sample: No sample. Miscrosoft Acces DB. However after the commands that read the input DB the sample is the following:
  # StrataID DSetID FleetID GearGrpCode GearCode FileTypeCode YearC TimePeriodID SquareTypeCode QuadID Lat Lon Eff1 Eff1Type Eff2 Eff2Type DSetTypeID CatchUnit ALB BET     BFT BUM
  #         1      1 021ES00          TP     TRAP       OF-REP  1950           17            1x1      4  36   5    4 NO.TRAPS   NA                  nw        kg   0   0 6725000   0
  #         2      1 021ES00          TP     TRAP       OF-REP  1950           17            1x1      4  36   5    4 NO.TRAPS   NA                  nw        nr   0   0   52928   0
  #         3      2 026YU00          PS       PS       OF-REP  1950           17            5x5      1  40  15   14 NO.BOATS   NA                  -w        kg   0   0  657000   0
  #         4      3 021ES00          TP     TRAP       OF-REP  1951           17            1x1      4  36   5    4 NO.TRAPS   NA                  nw        kg   0   0 3072000   0
  #         5      3 021ES00          TP     TRAP       OF-REP  1951           17            1x1      4  36   5    4 NO.TRAPS   NA                  nw        nr   0   0   28654   0
  #         6      4 026YU00          PS       PS       OF-REP  1951           17            5x5      1  40  15   14 NO.BOATS   NA                  -w        kg   0   0  531000   0
  # SAI SKJ SWO WHM YFT BLF BLT BON BOP BRS CER FRI KGM KGX LTA MAW SLT SSM WAH oSmt BIL BLM MLS SBF SPF oTun BSH POR SMA MAK oSks FleetCode       FleetName FlagID FlagCode
  #    0   0   0   0   0   0   0   0   0   0   0   0   0   0   0   0   0   0   0    0   0   0   0   0   0    0   0   0   0   0    0    EU.ESP       EU.España     21   EU.ESP
  #    0   0   0   0   0   0   0   0   0   0   0   0   0   0   0   0   0   0   0    0   0   0   0   0   0    0   0   0   0   0    0    EU.ESP       EU.España     21   EU.ESP
  #    0   0   0   0   0   0   0   0   0   0   0   0   0   0   0   0   0   0   0    0   0   0   0   0   0    0   0   0   0   0    0       YUG Yugoslavia Fed.     26      YUG
  #    0   0   0   0   0   0   0   0   0   0   0   0   0   0   0   0   0   0   0    0   0   0   0   0   0    0   0   0   0   0    0    EU.ESP       EU.España     21   EU.ESP
  #    0   0   0   0   0   0   0   0   0   0   0   0   0   0   0   0   0   0   0    0   0   0   0   0   0    0   0   0   0   0    0    EU.ESP       EU.España     21   EU.ESP
  #    0   0   0   0   0   0   0   0   0   0   0   0   0   0   0   0   0   0   0    0   0   0   0   0   0    0   0   0   0   0    0       YUG Yugoslavia Fed.     26      YUG
  # FlagName StatusCode
  #        EU.España         CP
  #        EU.España         CP
  #  Yugoslavia Fed.        NCO
  #        EU.España         CP
  #        EU.España         CP
  #  Yugoslavia Fed.        NCO
  
  
  # Catch: final data sample:
  # Flag Gear time_start   time_end AreaName School Species CatchType CatchUnits Catch
  #  ARG   LL 1960-01-01 1960-02-01  6320020    ALL     ALB         C       MTNO 107.1
  #  ARG   LL 1960-01-01 1960-02-01  6320020    ALL     SWO         C       MTNO  46.6
  #  ARG   LL 1960-01-01 1960-02-01  6330045    ALL     ALB         C       MTNO   7.1
  #  ARG   LL 1960-01-01 1960-02-01  6330045    ALL     BET         C       MTNO  27.6
  #  ARG   LL 1960-01-01 1960-02-01  6330045    ALL     SWO         C       MTNO   1.4
  #  ARG   LL 1960-01-01 1960-02-01  6330045    ALL     YFT         C       MTNO   0.4

##Catches

ICCAT_CE_species_colnames<-c("ALB", "BET" ,"BFT","BUM","SAI","SKJ","SWO","WHM","YFT","BLF","BLT","BON","BOP","BRS","CER","FRI", "KGM","KGX","LTA", "MAW","SLT","SSM","WAH" , "oSmt" , "BIL", "BLM" ,"MLS","SBF" ,"SPF", "oTun" , "BSH", "POR" , "SMA", "MAK", "oSks")

# Requires library(Hmisc)
# Open the tables directly from the access database  
t2ce<-mdb.get(path_to_raw_dataset,tables='t2ce',stringsAsFactors=FALSE,strip.white=TRUE)
Flags<-mdb.get(path_to_raw_dataset,tables='Flags',stringsAsFactors=FALSE,strip.white=TRUE)

data_pivot_ICCAT<-left_join(t2ce,Flags,by="FleetID")  # equivalent to "select FlagCode,FlagID,t2ce.* from t2ce, Flags where t2ce.FleetID=Flags.FleetID"

catches_pivot_ICCAT<-FUN_catches_ICCAT_CE(data_pivot_ICCAT,ICCAT_CE_species_colnames)

#School
catches_pivot_ICCAT$School<-"ALL"

#Flag
catches_pivot_ICCAT$Flag<-catches_pivot_ICCAT$FlagCode

#CatchUnits
catches_pivot_ICCAT$CatchUnits<-catches_pivot_ICCAT$CatchUnit

  index.kg <- which( catches_pivot_ICCAT[,"CatchUnits"] == "kg" & catches_pivot_ICCAT[,"DSetTypeID"] == "-w" )
  catches_pivot_ICCAT[index.kg,"CatchUnits"]<- "MT"
  
  index.nr <- which( catches_pivot_ICCAT[,"CatchUnits"] == "nr"  & catches_pivot_ICCAT[,"DSetTypeID"] == "n-" )
  catches_pivot_ICCAT[index.nr,"CatchUnits"]<- "NO"               
  
  index.kgnr <- which( catches_pivot_ICCAT[,"CatchUnits"] == "kg" & catches_pivot_ICCAT[,"DSetTypeID"] == "nw" )
  catches_pivot_ICCAT[index.kgnr,"CatchUnits"]<- "MTNO"
  
  index.nrkg <- which( catches_pivot_ICCAT[,"CatchUnits"] == "nr"  & catches_pivot_ICCAT[,"DSetTypeID"] == "nw" )
  catches_pivot_ICCAT[index.nrkg,"CatchUnits"]<- "NOMT"            


### Reach the catches harmonized DSD using a function in ICCAT_functions.R
colToKeep_captures <- c("Flag","Gear","time_start","time_end","AreaName","School","Species","CatchType","CatchUnits","Catch")
catches<-ICCAT_CE_catches_pivotDSD_to_harmonizedDSD(catches_pivot_ICCAT,colToKeep_captures)

colnames(catches)<-c("flag","gear","time_start","time_end","area","schooltype","species","catchtype","unit","value")

### Compute metadata
if (path_to_metadata_file!="NULL"){
  source("https://raw.githubusercontent.com/ptaconet/rtunaatlas_scripts/master/sardara_world/transform_trfmos_data_structure/metadata_source_datasets_to_database/compute_metadata.R")
} else {
  df_metadata<-NULL
  df_codelists<-NULL
}


## To check the outputs:
# str(dataset)
# str(df_metadata)
# str(df_codelists)

