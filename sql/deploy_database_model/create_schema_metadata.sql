
CREATE SCHEMA metadata
  AUTHORIZATION %db_admin%;

GRANT ALL ON SCHEMA metadata TO %db_admin%;
GRANT USAGE ON SCHEMA metadata TO %db_read%;
ALTER DEFAULT PRIVILEGES IN SCHEMA metadata GRANT SELECT ON TABLES TO %db_read%;


CREATE TABLE metadata.metadata
(
  id_metadata serial NOT NULL,
  identifier text,
  persistent_identifier text,
  title text,
  contacts_and_roles text,
  subject text,
  description text,
  date text,
format text,
language text,
relation text,
spatial_coverage text,
temporal_coverage text,
rights text,
source text,
lineage text,
supplemental_information text,
dataset_type text,
sql_query_dataset_extraction text,
database_table_name text,
database_view_name text,
  CONSTRAINT metadata_pkey PRIMARY KEY (id_metadata),
  CONSTRAINT unique_identifier UNIQUE (identifier)
);

ALTER TABLE metadata.metadata
  OWNER TO %db_admin%;
GRANT ALL ON TABLE metadata.metadata TO %db_admin%;


CREATE TABLE metadata.metadata_mapping
(
  metadata_mapping_id_from integer NOT NULL,
  metadata_mapping_id_to integer NOT NULL,
  metadata_mapping_relation_type character varying(40),
  metadata_mapping_description text,
  CONSTRAINT metadata_mapping_pkey PRIMARY KEY (metadata_mapping_id_from, metadata_mapping_id_to),
  CONSTRAINT metadata_mapping_metadata_mapping_id_from_fkey FOREIGN KEY (metadata_mapping_id_from)
      REFERENCES metadata.metadata (id_metadata) MATCH SIMPLE
      ON UPDATE NO ACTION ON DELETE NO ACTION,
  CONSTRAINT metadata_mapping_metadata_mapping_id_to_fkey FOREIGN KEY (metadata_mapping_id_to)
      REFERENCES metadata.metadata (id_metadata) MATCH SIMPLE
      ON UPDATE NO ACTION ON DELETE NO ACTION
);

ALTER TABLE metadata.metadata_mapping
  OWNER TO %db_admin%;
GRANT ALL ON TABLE metadata.metadata_mapping TO %db_admin%;

CREATE SCHEMA fact_tables
  AUTHORIZATION %db_admin%;

GRANT ALL ON SCHEMA fact_tables TO %db_admin%;
GRANT USAGE ON SCHEMA fact_tables TO %db_read%;
ALTER DEFAULT PRIVILEGES IN SCHEMA fact_tables GRANT SELECT ON TABLES TO %db_read%;

  
--CREATE TABLE metadata.codelists_codes_labels_column_names
--(
--  database_table_name text NOT NULL,
--  code_column character varying(30) NOT NULL,
--  label_column character varying(30),
--  CONSTRAINT codelists_codes_labels_column_names_pkey PRIMARY KEY (database_table_name, code_column)
--);

--ALTER TABLE metadata.codelists_codes_labels_column_names
--  OWNER TO %db_admin%;
--GRANT ALL ON TABLE metadata.codelists_codes_labels_column_names TO %db_admin%;

