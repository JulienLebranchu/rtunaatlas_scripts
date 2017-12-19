DROP VIEW IF EXISTS area.area_labels;

CREATE MATERIALIZED VIEW area.area_labels AS 
WITH vue AS (
SELECT 0 AS id_area,
    'UNK'::text AS codesource_area,
    NULL::text AS tablesource_area,
    'Unknown'::character varying AS source_label,
    'Inconnu'::character varying AS source_french_label,
    'Desconocido'::character varying AS source_spanish_label,
NULL::geometry AS geom
)
 SELECT vue.id_area,
    vue.codesource_area,
    vue.tablesource_area,
    vue.source_label,
    vue.source_french_label,
    vue.source_spanish_label,
    st_setsrid(vue.geom, 4326) AS geom
   FROM vue
;
