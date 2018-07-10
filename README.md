# Global Tuna Atlas - How to setup and update the database and the catalogue

This document aims at presenting quickly how to setup and update the global tuna atlas database. For additional information, please check the document [Global tuna atlas - technical documentation located](https://docs.google.com/document/d/1jxaE4iMiBI1TsG0Qb0siPal_1g_VHgUufCvA9DX009M/edit?usp=sharing) 

## Prerequisites :

- An administrator account on the [FAO Tuna Atlas Virtual Research Environment](https://bluebridge.d4science.org/web/fao_tunaatlas). When you get your account, note your username and token (then can be found on the homepage of the VRE).
- [for the setup only] The following servers and configurations :
  - A PostgreSQL database (version 9.4.12) with one administrator role, one role with USAGE privileges, and the PostGIS extension enabled (version 2.3). The DB should be empty. 
  - An instance of Geonetwork (version 3.0.4)
  - An instance of Geoserver (version 2.10.5). There must be 7 workspaces named: tunaatlas_ird, tunaatlas_fao, tunaatlas_iotc, tunaatlas_iccat, tunaatlas_iattc, tunaatlas_ccsbt, tunaatlas_wcpfc respectively linked to 7 stores named sardara_jdni_ird, sardara_jdni_fao, sardara_jdni_iotc, sardara_jdni_iccat, sardara_jdni_iattc, sardara_jdni_ccsbt, sardara_jdni_wcpfc, all pointing to the above PostgreSQL + PostGIS database
- The administrator credentials to those servers

The servers mentioned previously have already been installed and configured for the current running version of tuna atlas. In case you want to test the setup or update you should install your own servers. 

## Setup the database :

1. Connect to the [FAO Tuna Atlas VRE](https://bluebridge.d4science.org/web/fao_tunaatlas) with your credentials 
2. On the Rstudio instance of the VRE, copy and paste the following R script (workflow to setup or update the tuna atlas DB): https://github.com/ptaconet/rtunaatlas_scripts/blob/master/tunaatlas_world/workflow_etl/workflow_tuna_atlas_setup_and_update.R 
3. Replace the following parameters as follow (and leave the others with their default values):
  - vre_username=”[your Tuna atlas VRE username]”
  - vre_token=”[your Tuna atlas VRE token]”
  - db_host=”[the database host]”
  - db_name=”[the database name]”
  - db_admin_name=”[the database admin name]”
  - db_admin_password=”[the database admin password]”
  - db_read_name=”[the database usage name]”
4. Execute the whole script

## Update the database : 

The overall objective is to fill-in a csv file using as template the file used for the previous year’s update ; and then execute a workflow using that file as input.

1. Connect to the [FAO Tuna Atlas VRE](https://bluebridge.d4science.org/web/fao_tunaatlas) with your credentials 
2. Open the Tuna Atlas VRE workspace (https://goo.gl/mmHp2v) and create a new folder under “Source_data” named after the current year (e.g. “2018”) . Create 5 sub-folders named after the 5 tuna RFMOs (IOTC, ICCAT, IATTC, WCPFC, CCSBT) under that folder.
3. Under the folder “Source_data”, locate the folder of the previous year (e.g. “2017”). Open that folder. Locate the file named “metadata_and_parameterization_primary_datasets_[YYYY].csv” and open it. This is the file that must be filled-in with the information for the current year. The dictionary (i.e. meaning of the columns) of this table is available here: https://docs.google.com/document/d/1oqf_j4PDmyeJyETK6sqRxZzMjTRIqeJ6NuI86kov6vo/edit#heading=h.v17e9wc961o2 . On this file, one row represents one source dataset that was collated at the year Y-1 from the RFMOs to generate the tuna atlas. One single primary dataset might appear in several rows in the table. This is normal, since one single primary dataset can result in two datasets in the database (e.g. the case of the catch-and-effort primary datasets, for which one primary dataset results in one catch dataset and one effort dataset in the tuna atlas data DB). The objective is, relying on the table of the year Y-1,  to fill-in the table for the current year with the up-to-date information. Annex 1 presents how to fill-in the table. Please read the annex 1 in order to properly fill-in the table.
4. Once the table filled-in, store it on the VRE folder created at the Step 2). 
5. Copy and paste on the Rstudio instance of the VRE the R workflow to setup or update the tuna atlas DB, located [here](https://docs.google.com/document/d/1jxaE4iMiBI1TsG0Qb0siPal_1g_VHgUufCvA9DX009M/edit?usp=sharing) 
6. Replace the following parameters as follow (and leave the others with their default values):
  - deploy_database_model=FALSE
  - load_codelists=FALSE
  - load_codelists_mappings=FALSE
  - vre_username=”[your Tuna atlas VRE username]”
  - vre_token=”[your Tuna atlas VRE token]”
  - db_host=”[the database host]”
  - db_name=”[the database name]”
  - db_admin_name=”[the database admin name]”
  - db_admin_password=”[the database admin password]”
  - db_read_name=”[the database usage name]”
  - year_tuna_atlas="[current year, e.g. 2018]"
  - metadata_and_parameterization_csv_primary_datasets=”[URL of the table stored on the VRE folder in step 4]”
7. Execute the whole script



## Setup / Update the Catalogue :

1. Import on the Rstudio instance of the Tuna Atlas VRE the folder named “metadata_and_data_access_workflow_v3” located here: https://goo.gl/KRmjaK.
2. Open the script “workflow_configuration_Postgres_tunaatlasworld.json” and replace the credentials of the servers (db, gcube, sdi) with the appropriate values.
3. Open the script “scripts/write_Dublin_Core_metadata.R” and look for the input parameter named “SQL_query_metadata”. This parameter enables to set the (meta)data that will be published on the Geonetwork and the Geoserver. At the setup of the DB, set the parameter to “SELECT * FROM metadata.metadata ORDER BY id_metadata”. At its update, open the table metadata.metadata on the database, locate the datasets to publish (i.e. the ones for which the identifiers end up with the current year) and set the parameter to “SELECT * FROM metadata.metadata WHERE [where clause to select the datasets to publish] ORDER BY id_metadata”
4. Open and execute the whole script “workflow_main_Postgres.R”



## Annex 1: How to fill-in the file “metadata_and_parameterization_primary_datasets_[YYYY].csv” 

One by one, the datasets must be located on the tRFMOs websites and the metadata which describes each dataset must be reported in each row of the table. In order to ease the location of the dataset, the column “relation_source_download” of the “metadata_and_parameterization_primary_datasets” table  (see point 3)  provides the URL of the page where the dataset was download at the year Y-1. It might be useful in order to locate the dataset at the year Y, since the URL might not have changed. Some datasets have also been sent via e-mail by the data managers (in that case the column relation_source_download is set to “asked to and provided by e-mail”). It is noteworthy that the URLs are those working at the time the datasets are collated, and might therefore not work anymore one year after, when the atlas is updated.

When a primary dataset is located on the tRFMO website (or received by e-mail), the following tasks must be achieved chronologically:

- Download the dataset;
- If the dataset is provided in MS Excel format, manually convert it to csv format (removing the eventual rows before the header and with a comma (“,”) separator). Likewise, if the dataset in is a zip file, unzip it. DBF and MS Access formats do not have to be converted to csv;
Store the dataset on the Tuna Atlas VRE workspace under the appropriate folder (e.g. ICCAT, IATTC, etc. - see above section preparation). 
Replace the following columns of the “metadata_and_parameterization_primary_datasets” table for the given dataset by the appropriate values (mandatory):
  - “parameter_path_to_raw_dataset” with the path of the dataset stored on the VRE workspace ;
  - parameter_path_to_effort_dataset only for datasets whose persistent_identifiers == east_pacific_ocean_catch_5deg_1m_ll_tunaatlasIATTC_level0__shark or east_pacific_ocean_catch_5deg_1m_ll_tunaatlasIATTC_level0__tuna_billfish;
  - All the “contact” columns;
  - All the “date” columns ;
  - All the “relation” columns;
  - “description”;

- Replace the following columns by the appropriate values, or leave what is proposed by default:
  - “title”
  - “lineage”

- Replace the following columns by the appropriate values, or leave them empty if no information:
  - “subject”
  - “supplemental_information”
  - “rights”
  - “format”
  - “language”

