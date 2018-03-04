-- Get, for each strata, the sum of the catch and the unit(s) of effort(s) that is (are) associated. Output data is a table with the following columns: source_authority, time_start, time_end, geographical_identifier, gear_label, flag, effortunit_list, sum_catch
-- @param %materialized_view_efforts% : materialized view or table of efforts. value = tunaatlas_ird.global_effort_tunaatlasird_level0
-- @param %materialized_view_catches% : materialized view or table of catch. value = tunaatlas_ird.global_catch_tunaatlasird_level2
-- Associated R script to exploit this query can be found here: https://github.com/ptaconet/rtunaatlas_scripts/blob/master/tunaatlas_world/R_scripts_data_analysis/catches_by_effort_units.R
-- author: paul.taconet@ird.fr , 2018-03-04

WITH efforts_without_schooltype AS (
                    SELECT
                    source_authority,
                    time_start,
                    time_end,
                    geographic_identifier,
                    gear_label,
                    flag,
                    unit  
                    FROM 
                    %materialized_view_efforts%
                    GROUP BY 
                    source_authority,
                    time_start,
                    time_end,
                    geographic_identifier,
                    gear_label,
                    flag,
                    unit
                    ), 
                    efforts AS (
                    SELECT
                    source_authority,
                    time_start,
                    time_end,
                    geographic_identifier,
                    gear_label,
                    flag,
                    string_agg(unit, ',') AS effortunit_list  
                    FROM 
                    efforts_without_schooltype
                    GROUP BY 
                    source_authority,
                    time_start,
                    time_end,
                    geographic_identifier,
                    gear_label,
                    flag
),
                    catches AS (
                    SELECT
                    source_authority,
                    time_start,
                    time_end,
                    geographic_identifier,
                    gear_label,
                    flag,
                    sum(value) as sum_catch
                    FROM %materialized_view_catches%
                    where unit IN ('MT','MTNO')
                    group by 
                    source_authority,
                    time_start,
                    time_end,
                    geographic_identifier,
                    gear_label,
                    flag
                    )
                    SELECT 
                    source_authority,
                    time_start,
                    time_end,
                    geographic_identifier,
                    gear_label,
                    flag,
                    effortunit_list,
                    sum_catch
                    FROM efforts 
                    FULL JOIN catches USING (source_authority,
                    time_start,
                    time_end,
                    geographic_identifier,
                    gear_label,
                    flag)
