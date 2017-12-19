
CREATE SCHEMA %dimension_name%
  AUTHORIZATION %db_admin%;

GRANT ALL ON SCHEMA %dimension_name% TO %db_admin%;
GRANT USAGE ON SCHEMA %dimension_name% TO %db_datareader%;


CREATE TABLE %dimension_name%.%dimension_name%
(
  id_%dimension_name% serial NOT NULL,
  codesource_%dimension_name% text,
  tablesource_%dimension_name% text,
  id_metadata integer,
  CONSTRAINT %dimension_name%_pkey PRIMARY KEY (id_%dimension_name%),
  CONSTRAINT %dimension_name%_id_metadata_fkey FOREIGN KEY (id_metadata)
      REFERENCES metadata.metadata (id_metadata) MATCH SIMPLE
      ON UPDATE NO ACTION ON DELETE NO ACTION,
  CONSTRAINT %dimension_name%_codesource_%dimension_name%_tablesource_%dimension_name%_key UNIQUE (codesource_%dimension_name%, tablesource_%dimension_name%)
);

ALTER TABLE %dimension_name%.%dimension_name%
  OWNER TO %db_admin%;
GRANT ALL ON TABLE %dimension_name%.%dimension_name% TO %db_admin%;
GRANT SELECT ON TABLE %dimension_name%.%dimension_name% TO %db_datareader%;


CREATE TABLE %dimension_name%.%dimension_name%_mapping
(
  %dimension_name%_mapping_id_from integer NOT NULL,
  %dimension_name%_mapping_id_to integer NOT NULL,
  %dimension_name%_mapping_relation_type character varying(20) NOT NULL,
  id_metadata integer,
  CONSTRAINT %dimension_name%_mapping_pkey PRIMARY KEY (%dimension_name%_mapping_id_from, %dimension_name%_mapping_id_to, %dimension_name%_mapping_relation_type),
  CONSTRAINT %dimension_name%_mapping_%dimension_name%_mapping_id_from_fkey FOREIGN KEY (%dimension_name%_mapping_id_from)
      REFERENCES %dimension_name%.%dimension_name% (id_%dimension_name%) MATCH SIMPLE
      ON UPDATE NO ACTION ON DELETE NO ACTION,
  CONSTRAINT %dimension_name%_mapping_%dimension_name%_mapping_id_to_fkey FOREIGN KEY (%dimension_name%_mapping_id_to)
      REFERENCES %dimension_name%.%dimension_name% (id_%dimension_name%) MATCH SIMPLE
      ON UPDATE NO ACTION ON DELETE NO ACTION,
  CONSTRAINT %dimension_name%_mapping_id_metadata_fkey FOREIGN KEY (id_metadata)
      REFERENCES metadata.metadata (id_metadata) MATCH SIMPLE
      ON UPDATE NO ACTION ON DELETE NO ACTION
);

ALTER TABLE %dimension_name%.%dimension_name%_mapping
  OWNER TO %db_admin%;
GRANT ALL ON TABLE %dimension_name%.%dimension_name%_mapping TO %db_admin%;
GRANT SELECT ON TABLE %dimension_name%.%dimension_name%_mapping TO %db_datareader%;

CREATE VIEW %dimension_name%.%dimension_name%_labels AS 
 SELECT 0 AS id_%dimension_name%,
    'UNK'::text AS codesource_%dimension_name%,
    NULL::text AS tablesource_%dimension_name%,
    'Unknown'::character varying AS source_label,
    'Inconnu'::character varying AS source_french_label,
    'Desconocido'::character varying AS source_spanish_label;
