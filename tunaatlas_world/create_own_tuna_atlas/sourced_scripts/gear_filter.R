cat("Filtering gears...\n")
gear_filter<-unlist(strsplit(gear_filter, split=","))
georef_dataset<-georef_dataset %>% filter(gear %in% gear_filter)
cat("Filtering gears OK\n")