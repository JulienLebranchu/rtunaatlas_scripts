######################################################################
##### 52North WPS annotations ##########
######################################################################
# wps.des: id = get_catches_by_effort_units, title = Get the sum of the catch and the unit(s) of effort(s) that is (are) associated. 
# wps.in: id = materialized_view_efforts, type = string, title = materialized view or table of efforts, value = "tunaatlas_ird.global_effort_tunaatlasird_level0";
# wps.in: id = materialized_view_catches, type = string, title = materialized view or table of catches, value = "tunaatlas_ird.global_catch_tunaatlasird_level2";
# wps.out: id = , type = text/zip, title = Various plots showing the distribution of the catches by gears and units of efforts; 

materialized_view_efforts<-"tunaatlas_ird.global_effort_tunaatlasird_level0"
materialized_view_catches<-"tunaatlas_ird.global_catch_tunaatlasird_level2"

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

if(!require(data.table)){
  install.packages("data.table")
}

if(!require(data.table)){
  install.packages("ggplot2")
}

require(rtunaatlas)
require(dplyr)
require(data.table)
require(ggplot2)

con=db_connection_tunaatlas_world()

# Query database 
query<-paste(readLines("https://raw.githubusercontent.com/ptaconet/rtunaatlas_scripts/master/sql/queries_data_analysis/catches_by_effort_units.sql"), collapse="\n")
query<-gsub("%materialized_view_efforts%",materialized_view_efforts,query)
query<-gsub("%materialized_view_catches%",materialized_view_catches,query)

dataset<-dbGetQuery(con,query)


# Data curation
effort_list<-strsplit(dataset$unit, ",")
for (i in 1:length(effort_list)){
effort_list[[i]]<-sort(effort_list[[i]])
effort_list[[i]]<-paste0(effort_list[[i]],collapse = ",")
}

dataset$unit<-unlist(effort_list)


conversion_factors<-read.csv("http://data.d4science.org/a0dmK1hxNGdNemp3YjQ5TkhSblNHdlBSL1c3UEpmQjhHbWJQNStIS0N6Yz0",colClasses = "character", stringsAsFactors = F)

dataset_with_single_effort_unit<-dataset[which(!(grepl(",",dataset$unit))),]
dataset_with_multiple_effort_unit<-dataset[which(grepl(",",dataset$unit)),]

dataset_with_single_effort_unit<-left_join(dataset_with_single_effort_unit,conversion_factors)

combination<-unique(dataset_with_multiple_effort_unit[,c('gear','source_authority','unit')])

combination$unit_target<-NA
combination$conversion_factor<-NA
for (i in 1:nrow(combination)){
  for (j in 1:nrow(conversion_factors)){
    if (combination$gear[i]==conversion_factors$gear[j] & combination$source_authority[i]==conversion_factors$source_authority[j] & grepl(conversion_factors$unit[j],combination$unit[i])){
      combination$unit_target[i]=conversion_factors$unit_target[j]
      combination$conversion_factor[i]=conversion_factors$conversion_factor[j]
      
    } 
  } 
}

dataset_with_multiple_effort_unit<-left_join(dataset_with_multiple_effort_unit,combination)

dataset<-rbind(dataset_with_single_effort_unit,dataset_with_multiple_effort_unit)

vector_standard_effortunits<-c("HOOKS","FDAYS")

index_conversion_factors_available<-which(!(is.na(dataset$unit_target)))
dataset$unit[index_conversion_factors_available]<-dataset$unit_target[index_conversion_factors_available]
dataset$units_available <- grepl(paste(vector_standard_effortunits,collapse="|"),dataset$unit)

index_units_available_not_standard<-which(dataset$units_available=="FALSE")
dataset$units_available[index_units_available_not_standard]<-dataset$unit[index_units_available_not_standard]


# End data curation


# Function to plot data by gear and unit of effort. 
function_plot_by_gear_effortunit<-function(source_authority_filter,column_units){
  
  dataset$unit_to_plot<-dataset[,column_units]
  
  data_aggregated<- dataset %>% 
    filter (source_authority==source_authority_filter) %>% 
    group_by(gear_label,unit_to_plot) %>% 
    summarise(Catch = sum(sum_catch,na.rm=TRUE))
  
  ncol<-length(unique(data_aggregated$unit_to_plot))
  
  ggplot(data=data_aggregated, aes(x=gear_label, y=Catch, fill=unit_to_plot)) +
    geom_bar(stat="identity") +
    ggtitle(paste0("Distribution of the catches by gear and units of efforts , ",source_authority_filter)) +
    ylab("Catches (tons)") +
    xlab("Gear")+
    scale_fill_manual(values=rainbow(ncol))+
    theme(axis.text.x = element_text(angle = 60, hjust = 1, colour="black"))
  
}

# Plot data by gears and unit of effort (to plot 1 by 1)
function_plot_by_gear_effortunit("IOTC","unit")
function_plot_by_gear_effortunit("ICCAT","unit")
function_plot_by_gear_effortunit("WCPFC","unit")
function_plot_by_gear_effortunit("IATTC","unit")
function_plot_by_gear_effortunit("CCSBT","unit")


# Plot availability of data expressed in either HOOKS or FDAYS or the factors of conversion available  (to plot 1 by 1). in the output plot, TRUE indicates that the effort is available in one of the standard units or that a factor of conversion does exist to convert the data to a standard unit.
function_plot_by_gear_effortunit("IOTC","units_available")
function_plot_by_gear_effortunit("ICCAT","units_available")
function_plot_by_gear_effortunit("IATTC","units_available")
function_plot_by_gear_effortunit("WCPFC","units_available")
function_plot_by_gear_effortunit("CCSBT","units_available")
