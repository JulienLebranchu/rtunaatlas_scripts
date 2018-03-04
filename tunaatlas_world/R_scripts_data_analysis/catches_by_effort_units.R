######################################################################
##### 52North WPS annotations ##########
######################################################################
# wps.des: id = get_catches_by_effort_units, title = Get for each strata the sum of the catch and the unit(s) of effort(s) that is (are) associated. 
# wps.in: id = materialized_view_efforts, type = string, title = materialized view or table of efforts, value = "tunaatlas_ird.global_effort_tunaatlasird_level0";
# wps.in: id = materialized_view_catches, type = string, title = materialized view or table of catches, value = "tunaatlas_ird.global_catch_tunaatlasird_level2";
# wps.out: id = zip_namefile, type = text/zip, title =  ; 

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
 
query<-paste(readLines("https://raw.githubusercontent.com/ptaconet/rtunaatlas_scripts/master/sql/queries_data_analysis/catches_by_effort_units.sql"), collapse="\n")
query<-gsub("%materialized_view_efforts%",materialized_view_efforts,query)
query<-gsub("%materialized_view_catches%",materialized_view_catches,query)

dataset<-dbGetQuery(con,query)


# Data curation
effort_list<-strsplit(dataset$effortunit_list, ",")
for (i in 1:length(effort_list)){
effort_list[[i]]<-sort(effort_list[[i]])
effort_list[[i]]<-paste0(effort_list[[i]],collapse = ",")
}

dataset$effortunit_list<-unlist(effort_list)

# Add a column to specify if the data is expressed in one of the standard effort units: FDAYS, HOOKS
standard_effort_units <- c("HOOKS", "FDAYS")
dataset$standard_effortunit <- grepl(paste(standard_effort_units,collapse="|"),dataset$effortunit_list)

# Add a column to specify if the data is expressed in one of the standard effort units OR one of the units for which we have conversion factors
#effort_units <- c("HOOKS", "FDAYS")
#dataset$standard_effortunit <- grepl(paste(standard_effort_units,collapse="|"),dataset$effortunit_list)


# Get strata expressed in various units
# strata_various_effort_units<- dataset %>% filter (grepl(",",effortunit_list))


# plot catches by year: stacked plot with categories by effortunit
data_aggregated_by_gear<- dataset %>% 
  filter (source_authority=="ICCAT") %>% 
  group_by(gear_label,standard_effortunit) %>% 
  summarise(Catch = sum(sum_catch,na.rm=TRUE))

ggplot(data=data_aggregated_by_gear, aes(x=gear_label, y=Catch, fill=standard_effortunit)) +
  geom_bar(stat="identity") +
  ggtitle("Distribution of the catches by gear, IOTC") +
  ylab("Catches (tons)") +
  xlab("Unit of effort")+
  scale_fill_manual(values=rainbow(2))+
  theme(axis.text.x = element_text(angle = 60, hjust = 1, colour="black"))

