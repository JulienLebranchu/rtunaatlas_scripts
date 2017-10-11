library("RPostgreSQL")
drv <- dbDriver("PostgreSQL")
con <- dbConnect(drv, dbname="sardara_world", user="invsardara", password="fle087", host="db-tuna.d4science.org")

query_view_name<-"SELECT * FROM metadata.metadata WHERE id_metadata=686"
view_name<-dbGetQuery(con,query_view_name)


function_get_keywords_institutions(dataset){
  
  # get all institutions associated to the genealogy of the dataset
  
  "SELECT distinct dataset_origin_institution,name_en_origin_institution
  FROM metadata.metadata 
JOIN metadata.origin_institution
ON origin_institution.code_origin_institution=metadata.dataset_origin_institution
WHERE id_metadata IN 
  (SELECT metadata_mapping_id_to
  FROM metadata.metadata_mapping
  WHERE metadata_mapping_id_from=",dataset$id_metadata,"
  )"
  
  
  
}