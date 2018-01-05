cat(paste0("Keeping only data from ",overlapping_zone_iattc_wcpfc_data_to_keep," in the IATTC/WCPFC overlapping zone...\n"))
# query Sardara to get the codes of IATTC and WCPFC overlapping areas (stored under the view area.iattc_wcpfc_overlapping_cwp_areas)
query_areas_overlapping_zone_iattc_wcpfc<-"SELECT codesource_area from
(WITH iattc_area_of_competence AS (
         SELECT rfmos_convention_areas_fao.geom
           FROM area.rfmos_convention_areas_fao
          WHERE code::text = 'IATTC'::text
        ), wcpfc_area_of_competence AS (
         SELECT rfmos_convention_areas_fao.geom
           FROM area.rfmos_convention_areas_fao
          WHERE code::text = 'WCPFC'::text
        ), geom_iattc_wcpfc_intersection AS (
         SELECT st_collectionextract(st_intersection(iattc_area_of_competence.geom, wcpfc_area_of_competence.geom), 3) AS geom
           FROM iattc_area_of_competence,
            wcpfc_area_of_competence
        )
 SELECT area_labels.id_area,
    area_labels.codesource_area
   FROM area.area_labels,
    geom_iattc_wcpfc_intersection
  WHERE area_labels.tablesource_area = 'cwp_grid'::text AND st_within(area_labels.geom, geom_iattc_wcpfc_intersection.geom))tab;
"

overlapping_zone_iattc_wcpfc<-dbGetQuery(con, query_areas_overlapping_zone_iattc_wcpfc)

if (overlapping_zone_iattc_wcpfc_data_to_keep=="IATTC"){
  # If we choose to keep the data of the overlapping zone from the IATTC, we remove the data of the overlapping zone from the WCPFC dataset.
  df<-df[ which(!(df$geographic_identifier %in% overlapping_zone_iattc_wcpfc$codesource_area & df$source_authority == "WCPFC")), ]
} else if (overlapping_zone_iattc_wcpfc_data_to_keep=="WCPFC"){
  # If we choose to keep the data of the overlapping zone from the WCPFC, we remove the data of the overlapping zone from the IATTC dataset
  df<-df[ which(!(df$geographic_identifier %in% overlapping_zone_iattc_wcpfc$codesource_area & df$source_authority == "IATTC")), ]
}

# fill metadata elements
lineage<-c(lineage,paste0("Concerns IATTC and WCPFC data. IATTC and WCPFC have an overlapping area in their respective area of competence. Data from both RFMOs may be redundant in this overlapping zone. In the overlapping area, only data from ",overlapping_zone_iattc_wcpfc_data_to_keep," were kept.	Information regarding the data in the IATTC / WCPFC overlapping area: after the eventual other corrections applied, e.g. raisings, catch units conversions, etc., the ratio between the catches from IATTC and those from WCPFC was of: ratio_iattc_wcpf_mt for the catches expressed in weight and ratio_iattc_wcpf_no for the catches expressed in number."))
description<-paste0(description,"- In the IATTC/WCPFC overlapping area of competence, only data from ",overlapping_zone_iattc_wcpfc_data_to_keep," were kept\n")

cat(paste0("Keeping only data from ",overlapping_zone_iattc_wcpfc_data_to_keep," in the IATTC/WCPFC overlapping zone OK\n"))