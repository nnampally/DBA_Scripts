-- View: dba_work.gp_array

-- DROP VIEW dba_work.gp_array;

CREATE OR REPLACE VIEW dba_work.gp_array AS 
 SELECT a.content AS seg_id, a.dbid AS primary_dbid, b.dbid AS mirror_dbid, a.role AS primary_role, b.role AS mirror_role, a.address AS primary_host, b.address AS mirror_host
   FROM ( SELECT gp_segment_configuration.dbid, gp_segment_configuration.content, gp_segment_configuration.role, gp_segment_configuration.preferred_role, gp_segment_configuration.mode, gp_segment_configuration.status, gp_segment_configuration.port, gp_segment_configuration.hostname, gp_segment_configuration.address, gp_segment_configuration.replication_port, gp_segment_configuration.san_mounts
           FROM gp_segment_configuration
          WHERE gp_segment_configuration.preferred_role = 'p'::"char") a, ( SELECT gp_segment_configuration.dbid, gp_segment_configuration.content, gp_segment_configuration.role, gp_segment_configuration.preferred_role, gp_segment_configuration.mode, gp_segment_configuration.status, gp_segment_configuration.port, gp_segment_configuration.hostname, gp_segment_configuration.address, gp_segment_configuration.replication_port, gp_segment_configuration.san_mounts
           FROM gp_segment_configuration
          WHERE gp_segment_configuration.preferred_role = 'm'::"char") b
  WHERE a.content = b.content
  ORDER BY a.content;

ALTER TABLE dba_work.gp_array
  OWNER TO gpadmin;

-------------------------------------------------------------------------
-- View: dba_work.gp_inventory_history

-- DROP VIEW dba_work.gp_inventory_history;

CREATE OR REPLACE VIEW dba_work.gp_inventory_history AS 
 SELECT DISTINCT x.ctime, x.bu, x.hostname, x.os_software, x.os_type, x.total_core, x.physical_core, x.logical_core, x.total_memory AS total_memory_gb, x.gp_version, x.psql_version, x.host_type, x.curr_db_count AS db_count, x.curr_total_db_size_gb AS total_db_sz_gb, COALESCE(max(
        CASE
            WHEN btrim(x.role::text) = 'p'::text THEN x.role_count
            ELSE NULL::bigint
        END), 0::bigint) AS primary_count, COALESCE(max(
        CASE
            WHEN btrim(x.role::text) = 'm'::text THEN x.role_count
            ELSE NULL::bigint
        END), 0::bigint) AS mirror_count, COALESCE(max(
        CASE
            WHEN btrim(x.data_filesystem) = '/data'::text THEN x.allocated_size
            ELSE NULL::numeric
        END), 0.00) AS data_allocated_gb, COALESCE(max(
        CASE
            WHEN btrim(x.data_filesystem) = '/data'::text THEN x.used_size
            ELSE NULL::numeric
        END), 0.00) AS data_used_gb, COALESCE(max(
        CASE
            WHEN btrim(x.data_filesystem) = '/data'::text THEN x.available_size
            ELSE NULL::numeric
        END), 0.00) AS data_free_gb, COALESCE(max(
        CASE
            WHEN btrim(x.data_filesystem) = '/appdata'::text THEN x.allocated_size
            ELSE NULL::numeric
        END), 0.00) AS appdata_allocated_gb, COALESCE(max(
        CASE
            WHEN btrim(x.data_filesystem) = '/appdata'::text THEN x.used_size
            ELSE NULL::numeric
        END), 0.00) AS appdata_used_gb, COALESCE(max(
        CASE
            WHEN btrim(x.data_filesystem) = '/appdata'::text THEN x.available_size
            ELSE NULL::numeric
        END), 0.00) AS appdata_free_gb, COALESCE(max(
        CASE
            WHEN btrim(x.data_filesystem) = '/data1p'::text THEN x.allocated_size
            ELSE NULL::numeric
        END), 0.00) AS data1p_allocated_gb, COALESCE(max(
        CASE
            WHEN btrim(x.data_filesystem) = '/data1p'::text THEN x.used_size
            ELSE NULL::numeric
        END), 0.00) AS data1p_used_gb, COALESCE(max(
        CASE
            WHEN btrim(x.data_filesystem) = '/data1p'::text THEN x.available_size
            ELSE NULL::numeric
        END), 0.00) AS data1p_free_gb, COALESCE(max(
        CASE
            WHEN btrim(x.data_filesystem) = '/data1m'::text THEN x.allocated_size
            ELSE NULL::numeric
        END), 0.00) AS data1m_allocated_gb, COALESCE(max(
        CASE
            WHEN btrim(x.data_filesystem) = '/data1m'::text THEN x.used_size
            ELSE NULL::numeric
        END), 0.00) AS data1m_used_gb, COALESCE(max(
        CASE
            WHEN btrim(x.data_filesystem) = '/data1m'::text THEN x.available_size
            ELSE NULL::numeric
        END), 0.00) AS data1m_free_gb, COALESCE(max(
        CASE
            WHEN btrim(x.data_filesystem) = '/data2p'::text THEN x.allocated_size
            ELSE NULL::numeric
        END), 0.00) AS data2p_allocated_gb, COALESCE(max(
        CASE
            WHEN btrim(x.data_filesystem) = '/data2p'::text THEN x.used_size
            ELSE NULL::numeric
        END), 0.00) AS data2p_used_gb, COALESCE(max(
        CASE
            WHEN btrim(x.data_filesystem) = '/data2p'::text THEN x.available_size
            ELSE NULL::numeric
        END), 0.00) AS data2p_free_gb, COALESCE(max(
        CASE
            WHEN btrim(x.data_filesystem) = '/data2m'::text THEN x.allocated_size
            ELSE NULL::numeric
        END), 0.00) AS data2m_allocated_gb, COALESCE(max(
        CASE
            WHEN btrim(x.data_filesystem) = '/data2m'::text THEN x.used_size
            ELSE NULL::numeric
        END), 0.00) AS data2m_used_gb, COALESCE(max(
        CASE
            WHEN btrim(x.data_filesystem) = '/data2m'::text THEN x.available_size
            ELSE NULL::numeric
        END), 0.00) AS data2m_free_gb
   FROM ( SELECT DISTINCT s.ctime, btrim(s.business_unit) AS bu, btrim(s.hostname) AS hostname, btrim(s.os_software) AS os_software, btrim(s.os_type) AS os_type, s.total_core, s.physical_core, s.logical_core, s.total_memory, btrim(s.gp_version) AS gp_version, btrim(s.psql_version) AS psql_version, btrim(s.host_type) AS host_type, s.curr_db_count, s.curr_total_db_size_gb, btrim(s.data_filesystem) AS data_filesystem, sc.preferred_role AS role, count(sc.preferred_role) AS role_count, count(*) AS cnt, max(s.allocated_size) AS allocated_size, max(s.used_size) AS used_size, max(s.available_size) AS available_size
           FROM ONLY _gp_inventory_history s
      LEFT JOIN gp_segment_configuration sc ON substr(btrim(s.hostname), 1, strpos(btrim(s.hostname), '.'::text) - 1) = btrim(sc.hostname)
     WHERE s.allocated_size IS NOT NULL
     GROUP BY s.ctime, btrim(s.business_unit), btrim(s.hostname), btrim(s.os_software), btrim(s.os_type), s.total_core, s.physical_core, s.logical_core, s.total_memory, btrim(s.gp_version), btrim(s.psql_version), btrim(s.host_type), s.curr_db_count, s.curr_total_db_size_gb, btrim(s.data_filesystem), sc.preferred_role
     ORDER BY s.ctime, btrim(s.business_unit), btrim(s.hostname), btrim(s.os_software), btrim(s.os_type), s.total_core, s.physical_core, s.logical_core, s.total_memory, btrim(s.gp_version), btrim(s.psql_version), btrim(s.host_type), s.curr_db_count, s.curr_total_db_size_gb, btrim(s.data_filesystem), sc.preferred_role, count(sc.preferred_role), count(*), max(s.allocated_size), max(s.used_size), max(s.available_size)) x
  WHERE x.cnt >= 1
  GROUP BY x.ctime, x.hostname, x.bu, x.os_software, x.os_type, x.total_core, x.physical_core, x.logical_core, x.total_memory, x.gp_version, x.psql_version, x.host_type, x.curr_db_count, x.curr_total_db_size_gb
  ORDER BY x.ctime, x.hostname, x.bu, x.os_software, x.os_type, x.total_core, x.physical_core, x.logical_core, x.total_memory, x.gp_version, x.psql_version, x.host_type, x.curr_db_count, x.curr_total_db_size_gb, COALESCE(max(
        CASE
            WHEN btrim(x.role::text) = 'p'::text THEN x.role_count
            ELSE NULL::bigint
        END), 0::bigint), COALESCE(max(
        CASE
            WHEN btrim(x.role::text) = 'm'::text THEN x.role_count
            ELSE NULL::bigint
        END), 0::bigint), COALESCE(max(
        CASE
            WHEN btrim(x.data_filesystem) = '/data'::text THEN x.allocated_size
            ELSE NULL::numeric
        END), 0.00), COALESCE(max(
        CASE
            WHEN btrim(x.data_filesystem) = '/data'::text THEN x.used_size
            ELSE NULL::numeric
        END), 0.00), COALESCE(max(
        CASE
            WHEN btrim(x.data_filesystem) = '/data'::text THEN x.available_size
            ELSE NULL::numeric
        END), 0.00), COALESCE(max(
        CASE
            WHEN btrim(x.data_filesystem) = '/appdata'::text THEN x.allocated_size
            ELSE NULL::numeric
        END), 0.00), COALESCE(max(
        CASE
            WHEN btrim(x.data_filesystem) = '/appdata'::text THEN x.used_size
            ELSE NULL::numeric
        END), 0.00), COALESCE(max(
        CASE
            WHEN btrim(x.data_filesystem) = '/appdata'::text THEN x.available_size
            ELSE NULL::numeric
        END), 0.00), COALESCE(max(
        CASE
            WHEN btrim(x.data_filesystem) = '/data1p'::text THEN x.allocated_size
            ELSE NULL::numeric
        END), 0.00), COALESCE(max(
        CASE
            WHEN btrim(x.data_filesystem) = '/data1p'::text THEN x.used_size
            ELSE NULL::numeric
        END), 0.00), COALESCE(max(
        CASE
            WHEN btrim(x.data_filesystem) = '/data1p'::text THEN x.available_size
            ELSE NULL::numeric
        END), 0.00), COALESCE(max(
        CASE
            WHEN btrim(x.data_filesystem) = '/data1m'::text THEN x.allocated_size
            ELSE NULL::numeric
        END), 0.00), COALESCE(max(
        CASE
            WHEN btrim(x.data_filesystem) = '/data1m'::text THEN x.used_size
            ELSE NULL::numeric
        END), 0.00), COALESCE(max(
        CASE
            WHEN btrim(x.data_filesystem) = '/data1m'::text THEN x.available_size
            ELSE NULL::numeric
        END), 0.00), COALESCE(max(
        CASE
            WHEN btrim(x.data_filesystem) = '/data2p'::text THEN x.allocated_size
            ELSE NULL::numeric
        END), 0.00), COALESCE(max(
        CASE
            WHEN btrim(x.data_filesystem) = '/data2p'::text THEN x.used_size
            ELSE NULL::numeric
        END), 0.00), COALESCE(max(
        CASE
            WHEN btrim(x.data_filesystem) = '/data2p'::text THEN x.available_size
            ELSE NULL::numeric
        END), 0.00), COALESCE(max(
        CASE
            WHEN btrim(x.data_filesystem) = '/data2m'::text THEN x.allocated_size
            ELSE NULL::numeric
        END), 0.00), COALESCE(max(
        CASE
            WHEN btrim(x.data_filesystem) = '/data2m'::text THEN x.used_size
            ELSE NULL::numeric
        END), 0.00), COALESCE(max(
        CASE
            WHEN btrim(x.data_filesystem) = '/data2m'::text THEN x.available_size
            ELSE NULL::numeric
        END), 0.00);

ALTER TABLE dba_work.gp_inventory_history
  OWNER TO gpadmin;

-------------------------------------------------------------------------------------
-- View: dba_work.gp_inventory_now

-- DROP VIEW dba_work.gp_inventory_now;

CREATE OR REPLACE VIEW dba_work.gp_inventory_now AS 
 SELECT DISTINCT x.ctime, x.bu, x.hostname, x.os_software, x.os_type, x.total_core, x.physical_core, x.logical_core, x.total_memory AS total_memory_gb, x.gp_version, x.psql_version, x.host_type, x.curr_db_count AS db_count, x.curr_total_db_size_gb AS total_db_sz_gb, COALESCE(max(
        CASE
            WHEN btrim(x.role::text) = 'p'::text THEN x.role_count
            ELSE NULL::bigint
        END), 0::bigint) AS primary_count, COALESCE(max(
        CASE
            WHEN btrim(x.role::text) = 'm'::text THEN x.role_count
            ELSE NULL::bigint
        END), 0::bigint) AS mirror_count, COALESCE(max(
        CASE
            WHEN btrim(x.data_filesystem) = '/data'::text THEN x.allocated_size
            ELSE NULL::numeric
        END), 0.00) AS data_allocated_gb, COALESCE(max(
        CASE
            WHEN btrim(x.data_filesystem) = '/data'::text THEN x.used_size
            ELSE NULL::numeric
        END), 0.00) AS data_used_gb, COALESCE(max(
        CASE
            WHEN btrim(x.data_filesystem) = '/data'::text THEN x.available_size
            ELSE NULL::numeric
        END), 0.00) AS data_free_gb, COALESCE(max(
        CASE
            WHEN btrim(x.data_filesystem) = '/appdata'::text THEN x.allocated_size
            ELSE NULL::numeric
        END), 0.00) AS appdata_allocated_gb, COALESCE(max(
        CASE
            WHEN btrim(x.data_filesystem) = '/appdata'::text THEN x.used_size
            ELSE NULL::numeric
        END), 0.00) AS appdata_used_gb, COALESCE(max(
        CASE
            WHEN btrim(x.data_filesystem) = '/appdata'::text THEN x.available_size
            ELSE NULL::numeric
        END), 0.00) AS appdata_free_gb, COALESCE(max(
        CASE
            WHEN btrim(x.data_filesystem) = '/data1p'::text THEN x.allocated_size
            ELSE NULL::numeric
        END), 0.00) AS data1p_allocated_gb, COALESCE(max(
        CASE
            WHEN btrim(x.data_filesystem) = '/data1p'::text THEN x.used_size
            ELSE NULL::numeric
        END), 0.00) AS data1p_used_gb, COALESCE(max(
        CASE
            WHEN btrim(x.data_filesystem) = '/data1p'::text THEN x.available_size
            ELSE NULL::numeric
        END), 0.00) AS data1p_free_gb, COALESCE(max(
        CASE
            WHEN btrim(x.data_filesystem) = '/data1m'::text THEN x.allocated_size
            ELSE NULL::numeric
        END), 0.00) AS data1m_allocated_gb, COALESCE(max(
        CASE
            WHEN btrim(x.data_filesystem) = '/data1m'::text THEN x.used_size
            ELSE NULL::numeric
        END), 0.00) AS data1m_used_gb, COALESCE(max(
        CASE
            WHEN btrim(x.data_filesystem) = '/data1m'::text THEN x.available_size
            ELSE NULL::numeric
        END), 0.00) AS data1m_free_gb, COALESCE(max(
        CASE
            WHEN btrim(x.data_filesystem) = '/data2p'::text THEN x.allocated_size
            ELSE NULL::numeric
        END), 0.00) AS data2p_allocated_gb, COALESCE(max(
        CASE
            WHEN btrim(x.data_filesystem) = '/data2p'::text THEN x.used_size
            ELSE NULL::numeric
        END), 0.00) AS data2p_used_gb, COALESCE(max(
        CASE
            WHEN btrim(x.data_filesystem) = '/data2p'::text THEN x.available_size
            ELSE NULL::numeric
        END), 0.00) AS data2p_free_gb, COALESCE(max(
        CASE
            WHEN btrim(x.data_filesystem) = '/data2m'::text THEN x.allocated_size
            ELSE NULL::numeric
        END), 0.00) AS data2m_allocated_gb, COALESCE(max(
        CASE
            WHEN btrim(x.data_filesystem) = '/data2m'::text THEN x.used_size
            ELSE NULL::numeric
        END), 0.00) AS data2m_used_gb, COALESCE(max(
        CASE
            WHEN btrim(x.data_filesystem) = '/data2m'::text THEN x.available_size
            ELSE NULL::numeric
        END), 0.00) AS data2m_free_gb
   FROM ( SELECT DISTINCT s.ctime, btrim(s.business_unit) AS bu, btrim(s.hostname) AS hostname, btrim(s.os_software) AS os_software, btrim(s.os_type) AS os_type, s.total_core, s.physical_core, s.logical_core, s.total_memory, btrim(s.gp_version) AS gp_version, btrim(s.psql_version) AS psql_version, btrim(s.host_type) AS host_type, s.curr_db_count, s.curr_total_db_size_gb, btrim(s.data_filesystem) AS data_filesystem, sc.preferred_role AS role, count(sc.preferred_role) AS role_count, count(*) AS cnt, max(s.allocated_size) AS allocated_size, max(s.used_size) AS used_size, max(s.available_size) AS available_size
           FROM ONLY _gp_inventory_now s
      LEFT JOIN gp_segment_configuration sc ON substr(btrim(s.hostname), 1, strpos(btrim(s.hostname), '.'::text) - 1) = btrim(sc.hostname)
     WHERE s.allocated_size IS NOT NULL
     GROUP BY s.ctime, btrim(s.business_unit), btrim(s.hostname), btrim(s.os_software), btrim(s.os_type), s.total_core, s.physical_core, s.logical_core, s.total_memory, btrim(s.gp_version), btrim(s.psql_version), btrim(s.host_type), s.curr_db_count, s.curr_total_db_size_gb, btrim(s.data_filesystem), sc.preferred_role
     ORDER BY s.ctime, btrim(s.business_unit), btrim(s.hostname), btrim(s.os_software), btrim(s.os_type), s.total_core, s.physical_core, s.logical_core, s.total_memory, btrim(s.gp_version), btrim(s.psql_version), btrim(s.host_type), s.curr_db_count, s.curr_total_db_size_gb, btrim(s.data_filesystem), sc.preferred_role, count(sc.preferred_role), count(*), max(s.allocated_size), max(s.used_size), max(s.available_size)) x
  WHERE x.cnt >= 1
  GROUP BY x.ctime, x.hostname, x.bu, x.os_software, x.os_type, x.total_core, x.physical_core, x.logical_core, x.total_memory, x.gp_version, x.psql_version, x.host_type, x.curr_db_count, x.curr_total_db_size_gb
  ORDER BY x.ctime, x.hostname, x.bu, x.os_software, x.os_type, x.total_core, x.physical_core, x.logical_core, x.total_memory, x.gp_version, x.psql_version, x.host_type, x.curr_db_count, x.curr_total_db_size_gb, COALESCE(max(
        CASE
            WHEN btrim(x.role::text) = 'p'::text THEN x.role_count
            ELSE NULL::bigint
        END), 0::bigint), COALESCE(max(
        CASE
            WHEN btrim(x.role::text) = 'm'::text THEN x.role_count
            ELSE NULL::bigint
        END), 0::bigint), COALESCE(max(
        CASE
            WHEN btrim(x.data_filesystem) = '/data'::text THEN x.allocated_size
            ELSE NULL::numeric
        END), 0.00), COALESCE(max(
        CASE
            WHEN btrim(x.data_filesystem) = '/data'::text THEN x.used_size
            ELSE NULL::numeric
        END), 0.00), COALESCE(max(
        CASE
            WHEN btrim(x.data_filesystem) = '/data'::text THEN x.available_size
            ELSE NULL::numeric
        END), 0.00), COALESCE(max(
        CASE
            WHEN btrim(x.data_filesystem) = '/appdata'::text THEN x.allocated_size
            ELSE NULL::numeric
        END), 0.00), COALESCE(max(
        CASE
            WHEN btrim(x.data_filesystem) = '/appdata'::text THEN x.used_size
            ELSE NULL::numeric
        END), 0.00), COALESCE(max(
        CASE
            WHEN btrim(x.data_filesystem) = '/appdata'::text THEN x.available_size
            ELSE NULL::numeric
        END), 0.00), COALESCE(max(
        CASE
            WHEN btrim(x.data_filesystem) = '/data1p'::text THEN x.allocated_size
            ELSE NULL::numeric
        END), 0.00), COALESCE(max(
        CASE
            WHEN btrim(x.data_filesystem) = '/data1p'::text THEN x.used_size
            ELSE NULL::numeric
        END), 0.00), COALESCE(max(
        CASE
            WHEN btrim(x.data_filesystem) = '/data1p'::text THEN x.available_size
            ELSE NULL::numeric
        END), 0.00), COALESCE(max(
        CASE
            WHEN btrim(x.data_filesystem) = '/data1m'::text THEN x.allocated_size
            ELSE NULL::numeric
        END), 0.00), COALESCE(max(
        CASE
            WHEN btrim(x.data_filesystem) = '/data1m'::text THEN x.used_size
            ELSE NULL::numeric
        END), 0.00), COALESCE(max(
        CASE
            WHEN btrim(x.data_filesystem) = '/data1m'::text THEN x.available_size
            ELSE NULL::numeric
        END), 0.00), COALESCE(max(
        CASE
            WHEN btrim(x.data_filesystem) = '/data2p'::text THEN x.allocated_size
            ELSE NULL::numeric
        END), 0.00), COALESCE(max(
        CASE
            WHEN btrim(x.data_filesystem) = '/data2p'::text THEN x.used_size
            ELSE NULL::numeric
        END), 0.00), COALESCE(max(
        CASE
            WHEN btrim(x.data_filesystem) = '/data2p'::text THEN x.available_size
            ELSE NULL::numeric
        END), 0.00), COALESCE(max(
        CASE
            WHEN btrim(x.data_filesystem) = '/data2m'::text THEN x.allocated_size
            ELSE NULL::numeric
        END), 0.00), COALESCE(max(
        CASE
            WHEN btrim(x.data_filesystem) = '/data2m'::text THEN x.used_size
            ELSE NULL::numeric
        END), 0.00), COALESCE(max(
        CASE
            WHEN btrim(x.data_filesystem) = '/data2m'::text THEN x.available_size
            ELSE NULL::numeric
        END), 0.00);

ALTER TABLE dba_work.gp_inventory_now
  OWNER TO gpadmin;

----------------------------------------------------------------------------------------------------------------------
-- View: dba_work.gp_inventory_report

-- DROP VIEW dba_work.gp_inventory_report;

CREATE OR REPLACE VIEW dba_work.gp_inventory_report AS 
 SELECT final_report.ctime, final_report.bu, final_report.environment, final_report.location, final_report.site, final_report.os_software, final_report.os_type, final_report.total_core, final_report.physical_core, final_report.logical_core, final_report.total_memory_gb, final_report.gp_version, final_report.psql_version, final_report.db_count, final_report.master_server, final_report.standby_server, final_report.segment_server_count, final_report.total_master_data_allocated_gb, final_report.total_primary_allocated_tb, final_report.total_mirror_allocated_tb, final_report.total_master_data_used_gb, final_report.total_primary_used_tb, final_report.total_mirror_used_tb
   FROM ( SELECT gp_inventory_now.ctime::date AS ctime, gp_inventory_now.bu, gp_inventory_now.os_software, gp_inventory_now.os_type, gp_inventory_now.total_core, gp_inventory_now.physical_core, gp_inventory_now.logical_core, gp_inventory_now.total_memory_gb, gp_inventory_now.gp_version, gp_inventory_now.psql_version, gp_inventory_now.db_count, COALESCE(max(
                CASE
                    WHEN gp_inventory_now.host_type = 'Master'::text THEN gp_inventory_now.hostname
                    ELSE NULL::text
                END), 'None'::text) AS master_server, COALESCE(max(
                CASE
                    WHEN gp_inventory_now.host_type = 'Standby'::text THEN gp_inventory_now.hostname
                    ELSE NULL::text
                END), 'None'::text) AS standby_server, COALESCE(count(
                CASE
                    WHEN gp_inventory_now.host_type = 'Segment'::text THEN gp_inventory_now.hostname
                    ELSE NULL::text
                END), 0::bigint) AS segment_server_count, COALESCE(max(
                CASE
                    WHEN gp_inventory_now.host_type = 'Master'::text OR gp_inventory_now.host_type = 'Standby'::text OR gp_inventory_now.host_type = 'Segment'::text THEN 
                    CASE
                        WHEN "substring"(gp_inventory_now.hostname, 1, 3) ~ 'dfw'::text THEN 'US'::text
                        WHEN "substring"(gp_inventory_now.hostname, 1, 3) ~ 'atl'::text THEN 'US'::text
                        WHEN "substring"(gp_inventory_now.hostname, 1, 3) ~ 'ult'::text THEN 'AUS'::text
                        WHEN "substring"(gp_inventory_now.hostname, 1, 3) ~ 'bkh'::text THEN 'AUS'::text
                        WHEN "substring"(gp_inventory_now.hostname, 1, 3) ~ 'bbl'::text THEN 'LAB'::text
                        ELSE 'None'::text
                    END
                    ELSE NULL::text
                END), 'None'::text) AS location, COALESCE(max(
                CASE
                    WHEN gp_inventory_now.host_type = 'Master'::text OR gp_inventory_now.host_type = 'Standby'::text OR gp_inventory_now.host_type = 'Segment'::text THEN 
                    CASE
                        WHEN "substring"(gp_inventory_now.hostname, 1, 3) ~ 'dfw'::text THEN 'Site P'::text
                        WHEN "substring"(gp_inventory_now.hostname, 1, 3) ~ 'atl'::text THEN 'Site S'::text
                        WHEN "substring"(gp_inventory_now.hostname, 1, 3) ~ 'ult'::text THEN 'Site S'::text
                        WHEN "substring"(gp_inventory_now.hostname, 1, 3) ~ 'bkh'::text THEN 'Site P'::text
                        WHEN "substring"(gp_inventory_now.hostname, 1, 3) ~ 'bbl'::text THEN 'LAB'::text
                        ELSE 'None'::text
                    END
                    ELSE NULL::text
                END), 'None'::text) AS site, COALESCE(max(
                CASE
                    WHEN gp_inventory_now.host_type = 'Master'::text OR gp_inventory_now.host_type = 'Standby'::text OR gp_inventory_now.host_type = 'Segment'::text THEN 
                    CASE
                        WHEN split_part(gp_inventory_now.hostname, '.'::text, 2) ~ 'nonprod'::text THEN 'Non-Prod'::text
                        WHEN split_part(gp_inventory_now.hostname, '.'::text, 2) ~ 'prod'::text THEN 'Prod'::text
                        WHEN split_part(gp_inventory_now.hostname, '.'::text, 2) ~ 'bblab'::text THEN 'BBLAB'::text
                        ELSE 'None'::text
                    END
                    ELSE NULL::text
                END), 'None'::text) AS environment, round(sum(gp_inventory_now.data_allocated_gb)) AS total_master_data_allocated_gb, round((sum(gp_inventory_now.data1p_allocated_gb) + sum(gp_inventory_now.data2p_allocated_gb)) / 1024::numeric) AS total_primary_allocated_tb, round((sum(gp_inventory_now.data1m_allocated_gb) + sum(gp_inventory_now.data2m_allocated_gb)) / 1024::numeric) AS total_mirror_allocated_tb, round(sum(gp_inventory_now.data_used_gb)) AS total_master_data_used_gb, round((sum(gp_inventory_now.data1p_used_gb) + sum(gp_inventory_now.data2p_used_gb)) / 1024::numeric) AS total_primary_used_tb, round((sum(gp_inventory_now.data1m_used_gb) + sum(gp_inventory_now.data2m_used_gb)) / 1024::numeric) AS total_mirror_used_tb
           FROM gp_inventory_now
          WHERE gp_inventory_now.host_type !~~ 'ETL'::text
          GROUP BY gp_inventory_now.ctime, gp_inventory_now.bu, gp_inventory_now.os_software, gp_inventory_now.os_type, gp_inventory_now.total_core, gp_inventory_now.physical_core, gp_inventory_now.logical_core, gp_inventory_now.total_memory_gb, gp_inventory_now.gp_version, gp_inventory_now.psql_version, gp_inventory_now.db_count) final_report;

ALTER TABLE dba_work.gp_inventory_report
  OWNER TO gpadmin;

----------------------------------------------------------------------------------------------------------------------------------------------------------
-- View: dba_work.gp_invt_rpt_new

-- DROP VIEW dba_work.gp_invt_rpt_new;

CREATE OR REPLACE VIEW dba_work.gp_invt_rpt_new AS 
 SELECT final_report.ctime, final_report.bu, final_report.environment, final_report.location, final_report.site, final_report.hostname, final_report.os_software, final_report.os_type, final_report.total_core, final_report.physical_core, final_report.logical_core, final_report.total_memory_gb, final_report.gp_version, final_report.psql_version, final_report.db_count, final_report.host_type, final_report.total_master_data_allocated_gb, final_report.total_primary_allocated_tb, final_report.total_mirror_allocated_tb, final_report.total_master_data_used_gb, final_report.total_primary_used_tb, final_report.total_mirror_used_tb
   FROM ( SELECT gp_inventory_now.ctime::date AS ctime, gp_inventory_now.bu, gp_inventory_now.hostname, gp_inventory_now.os_software, gp_inventory_now.os_type, gp_inventory_now.total_core, gp_inventory_now.physical_core, gp_inventory_now.logical_core, gp_inventory_now.total_memory_gb, gp_inventory_now.gp_version, gp_inventory_now.psql_version, gp_inventory_now.db_count, gp_inventory_now.host_type, 
                CASE
                    WHEN gp_inventory_now.host_type = 'Master'::text OR gp_inventory_now.host_type = 'Standby'::text OR gp_inventory_now.host_type = 'Segment'::text OR gp_inventory_now.host_type = 'ETL'::text THEN 
                    CASE
                        WHEN "substring"(gp_inventory_now.hostname, 1, 3) ~ 'dfw'::text THEN 'US'::text
                        WHEN "substring"(gp_inventory_now.hostname, 1, 3) ~ 'atl'::text THEN 'US'::text
                        WHEN "substring"(gp_inventory_now.hostname, 1, 3) ~ 'ult'::text THEN 'AUS'::text
                        WHEN "substring"(gp_inventory_now.hostname, 1, 3) ~ 'bkh'::text THEN 'AUS'::text
                        WHEN "substring"(gp_inventory_now.hostname, 1, 3) ~ 'bbl'::text THEN 'LAB'::text
                        ELSE 'None'::text
                    END
                    ELSE NULL::text
                END AS location, 
                CASE
                    WHEN gp_inventory_now.host_type = 'Master'::text OR gp_inventory_now.host_type = 'Standby'::text OR gp_inventory_now.host_type = 'Segment'::text OR gp_inventory_now.host_type = 'ETL'::text THEN 
                    CASE
                        WHEN "substring"(gp_inventory_now.hostname, 1, 3) ~ 'dfw'::text THEN 'Site P'::text
                        WHEN "substring"(gp_inventory_now.hostname, 1, 3) ~ 'atl'::text THEN 'Site S'::text
                        WHEN "substring"(gp_inventory_now.hostname, 1, 3) ~ 'ult'::text THEN 'Site S'::text
                        WHEN "substring"(gp_inventory_now.hostname, 1, 3) ~ 'bkh'::text THEN 'Site P'::text
                        WHEN "substring"(gp_inventory_now.hostname, 1, 3) ~ 'bbl'::text THEN 'LAB'::text
                        ELSE 'None'::text
                    END
                    ELSE NULL::text
                END AS site, 
                CASE
                    WHEN gp_inventory_now.host_type = 'Master'::text OR gp_inventory_now.host_type = 'Standby'::text OR gp_inventory_now.host_type = 'Segment'::text OR gp_inventory_now.host_type = 'ETL'::text THEN 
                    CASE
                        WHEN split_part(gp_inventory_now.hostname, '.'::text, 2) ~ 'nonprod'::text THEN 'Non-Prod'::text
                        WHEN split_part(gp_inventory_now.hostname, '.'::text, 2) ~ 'prod'::text THEN 'Prod'::text
                        WHEN split_part(gp_inventory_now.hostname, '.'::text, 2) ~ 'bblab'::text THEN 'BBLAB'::text
                        ELSE 'None'::text
                    END
                    ELSE NULL::text
                END AS environment, round(gp_inventory_now.data_allocated_gb) AS total_master_data_allocated_gb, round((gp_inventory_now.data1p_allocated_gb + gp_inventory_now.data2p_allocated_gb) / 1024::numeric) AS total_primary_allocated_tb, round((gp_inventory_now.data1m_allocated_gb + gp_inventory_now.data2m_allocated_gb) / 1024::numeric) AS total_mirror_allocated_tb, round(gp_inventory_now.data_used_gb) AS total_master_data_used_gb, round((gp_inventory_now.data1p_used_gb + gp_inventory_now.data2p_used_gb) / 1024::numeric) AS total_primary_used_tb, round((gp_inventory_now.data1m_used_gb + gp_inventory_now.data2m_used_gb) / 1024::numeric) AS total_mirror_used_tb
           FROM gp_inventory_now
          ORDER BY gp_inventory_now.host_type) final_report;

ALTER TABLE dba_work.gp_invt_rpt_new
  OWNER TO gpadmin;

----------------------------------------------------------------------------------------------------------------
-- View: dba_work.gp_log_database

-- DROP VIEW dba_work.gp_log_database;

CREATE OR REPLACE VIEW dba_work.gp_log_database AS 
 SELECT __gp_log_segment_ext.logtime, __gp_log_segment_ext.loguser, __gp_log_segment_ext.logdatabase, __gp_log_segment_ext.logpid, __gp_log_segment_ext.logthread, __gp_log_segment_ext.loghost, __gp_log_segment_ext.logport, __gp_log_segment_ext.logsessiontime, __gp_log_segment_ext.logtransaction, __gp_log_segment_ext.logsession, __gp_log_segment_ext.logcmdcount, __gp_log_segment_ext.logsegment, __gp_log_segment_ext.logslice, __gp_log_segment_ext.logdistxact, __gp_log_segment_ext.loglocalxact, __gp_log_segment_ext.logsubxact, __gp_log_segment_ext.logseverity, __gp_log_segment_ext.logstate, __gp_log_segment_ext.logmessage, __gp_log_segment_ext.logdetail, __gp_log_segment_ext.loghint, __gp_log_segment_ext.logquery, __gp_log_segment_ext.logquerypos, __gp_log_segment_ext.logcontext, __gp_log_segment_ext.logdebug, __gp_log_segment_ext.logcursorpos, __gp_log_segment_ext.logfunction, __gp_log_segment_ext.logfile, __gp_log_segment_ext.logline, __gp_log_segment_ext.logstack
   FROM ONLY __gp_log_segment_ext
UNION ALL 
 SELECT __gp_log_master_ext.logtime, __gp_log_master_ext.loguser, __gp_log_master_ext.logdatabase, __gp_log_master_ext.logpid, __gp_log_master_ext.logthread, __gp_log_master_ext.loghost, __gp_log_master_ext.logport, __gp_log_master_ext.logsessiontime, __gp_log_master_ext.logtransaction, __gp_log_master_ext.logsession, __gp_log_master_ext.logcmdcount, __gp_log_master_ext.logsegment, __gp_log_master_ext.logslice, __gp_log_master_ext.logdistxact, __gp_log_master_ext.loglocalxact, __gp_log_master_ext.logsubxact, __gp_log_master_ext.logseverity, __gp_log_master_ext.logstate, __gp_log_master_ext.logmessage, __gp_log_master_ext.logdetail, __gp_log_master_ext.loghint, __gp_log_master_ext.logquery, __gp_log_master_ext.logquerypos, __gp_log_master_ext.logcontext, __gp_log_master_ext.logdebug, __gp_log_master_ext.logcursorpos, __gp_log_master_ext.logfunction, __gp_log_master_ext.logfile, __gp_log_master_ext.logline, __gp_log_master_ext.logstack
   FROM ONLY __gp_log_master_ext
  ORDER BY 1;

ALTER TABLE dba_work.gp_log_database
  OWNER TO gpadmin;
GRANT ALL ON TABLE dba_work.gp_log_database TO gpadmin;

-----------------------------------------------------------------------------------------------------------------------
-- View: dba_work.gp_proc

-- DROP VIEW dba_work.gp_proc;

CREATE OR REPLACE VIEW dba_work.gp_proc AS 
 SELECT pg_resqueue.rsqname AS q_name, pg_stat_activity.usename AS u_name, pg_stat_activity.waiting AS "wait?", pg_stat_activity.procpid AS pid, pg_stat_activity.sess_id AS s_id, pg_stat_activity.client_addr AS ip_addr, now() - pg_stat_activity.query_start AS run_time, pg_stat_activity.current_query::character varying(60) AS sql_stmt_begins
   FROM pg_stat_activity
   JOIN pg_roles ON pg_stat_activity.usename = pg_roles.rolname
   LEFT JOIN pg_resqueue ON pg_roles.rolresqueue = pg_resqueue.oid
  ORDER BY now() - pg_stat_activity.query_start DESC;

ALTER TABLE dba_work.gp_proc
  OWNER TO gpadmin;
GRANT ALL ON TABLE dba_work.gp_proc TO gpadmin;
GRANT SELECT ON TABLE dba_work.gp_proc TO public;

-------------------------------------------------------------------------------------------------------------------------
-- View: dba_work.gp_rq

-- DROP VIEW dba_work.gp_rq;

CREATE OR REPLACE VIEW dba_work.gp_rq AS 
 SELECT pg_resqueue_status.rsqname AS q_name, pg_resqueue_status.rsqcountlimit AS q_limit, pg_resqueue_status.rsqcostlimit AS cost_limit, pg_resqueue_status.rsqcountvalue AS in_q, pg_resqueue_status.rsqholders AS running, pg_resqueue_status.rsqwaiters AS waiting
   FROM pg_resqueue_status
  ORDER BY pg_resqueue_status.rsqname;

ALTER TABLE dba_work.gp_rq
  OWNER TO gpadmin;
GRANT ALL ON TABLE dba_work.gp_rq TO gpadmin;
GRANT SELECT ON TABLE dba_work.gp_rq TO public;

------------------------------------------------------------------------------------------------------------------------
-- View: dba_work.long_running

-- DROP VIEW dba_work.long_running;

CREATE OR REPLACE VIEW dba_work.long_running AS 
 SELECT pg_stat_activity.sess_id AS session, pg_stat_activity.procpid AS os_process, pg_stat_activity.usename AS "user", pg_stat_activity.client_addr AS user_host, pg_stat_activity.current_query, now() - pg_stat_activity.query_start AS duration
   FROM pg_stat_activity
  WHERE pg_stat_activity.current_query <> ''::text AND pg_stat_activity.current_query <> '<IDLE>'::text AND (now() - pg_stat_activity.query_start) > '02:00:00'::interval;

ALTER TABLE dba_work.long_running
  OWNER TO gpadmin;
GRANT ALL ON TABLE dba_work.long_running TO gpadmin;
GRANT SELECT ON TABLE dba_work.long_running TO public;

---------------------------------------------------------------------------------------------------------------------------
-- View: dba_work.sessions_waiting

-- DROP VIEW dba_work.sessions_waiting;

CREATE OR REPLACE VIEW dba_work.sessions_waiting AS 
 SELECT a.sess_id AS session_waiting, a.usename AS user_waiting, a.current_query AS query_waiting, c.mppsessionid AS session_holding_lock, d.usename AS user_holding_lock, d.current_query AS query_holding_lock
   FROM pg_stat_activity a, pg_locks b, pg_locks c, pg_stat_activity d
  WHERE a.waiting = true AND a.sess_id = b.mppsessionid AND b.granted = false AND c.granted = true AND c.relation = b.relation AND c.mppsessionid = d.sess_id
  GROUP BY a.sess_id, a.usename, a.current_query, c.mppsessionid, d.usename, d.current_query;

ALTER TABLE dba_work.sessions_waiting
  OWNER TO gpadmin;
GRANT ALL ON TABLE dba_work.sessions_waiting TO gpadmin;
GRANT SELECT ON TABLE dba_work.sessions_waiting TO public;

