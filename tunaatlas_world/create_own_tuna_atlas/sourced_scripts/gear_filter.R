function_gear_filter<-function(gear_filter,georef_dataset){

cat("Filtering gears...\n")
gear_filter<-unlist(strsplit(gear_filter, split=","))
georef_dataset<-georef_dataset %>% filter(gear %in% gear_filter)

# fill metadata elements
lineage<-"Only data from purse seiners and pole-and-liners were kept. These data are overall defined on 1° quadrant spatial resolutions in the source datasets. So as to keep only data from purse seiners and pole-and-liners, the following gears from the ISSCFG code list (resulting from the code list mapping stated above) were kept:  09.1 (Handlines and hand-operated pole-and-lines), 09.2 (Mechanized lines and pole-and-lines), 01.1 (Purse seines), 01.2 (Surrounding nets without purse lines)."

cat("Filtering gears OK\n")

return(list(dataset=georef_dataset,lineage=lineage))
}