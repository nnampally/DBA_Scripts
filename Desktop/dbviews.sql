--- view for current transaction blocking locks 

CREATE VIEW lock_monitor AS(
SELECT
  COALESCE(blockingl.relation::regclass::text,blockingl.locktype) as locked_item,
  now() - blockeda.query_start AS waiting_duration, blockeda.pid AS blocked_pid,
  blockeda.query as blocked_query, blockedl.mode as blocked_mode,
  blockinga.pid AS blocking_pid, blockinga.query as blocking_query,
  blockingl.mode as blocking_mode
FROM pg_catalog.pg_locks blockedl
JOIN pg_stat_activity blockeda ON blockedl.pid = blockeda.pid
JOIN pg_catalog.pg_locks blockingl ON(
  ( (blockingl.transactionid=blockedl.transactionid) OR
  (blockingl.relation=blockedl.relation AND blockingl.locktype=blockedl.locktype)
  ) AND blockedl.pid != blockingl.pid)
JOIN pg_stat_activity blockinga ON blockingl.pid = blockinga.pid
  AND blockinga.datid = blockeda.datid
WHERE NOT blockedl.granted
AND blockinga.datname = current_database()
);

SELECT * from lock_monitor;


-- Table: ddl_events

-- DROP TABLE ddl_events;

CREATE TABLE ddl_events
(
    command_tag text COLLATE pg_catalog."default",
    object_identity text COLLATE pg_catalog."default",
    object_type text COLLATE pg_catalog."default",
    user_account text COLLATE pg_catalog."default",
    command text COLLATE pg_catalog."default",
    last_ddl timestamp without time zone
)
WITH (
    OIDS = FALSE
)
TABLESPACE pg_default;


-- View: all_types

-- DROP VIEW all_types;

CREATE OR REPLACE VIEW all_types AS
 SELECT upper(pg_get_userbyid(t.typowner)::text) AS owner,
    upper(n.nspname::text) AS schema_name,
    upper(t.typname::text) AS type_name,
    t.oid AS type_oid,
        CASE
            WHEN t.typtype = 'c'::"char" THEN 'OBJECT'::text
            WHEN t.typtype = 'p'::"char" THEN 'COLLECTION'::text
            ELSE 'OTHER'::text
        END AS typecode,
        CASE
            WHEN c.relkind = 'c'::"char" THEN c.relnatts::integer
            ELSE 0
        END AS attributes
   FROM pg_type t
     LEFT JOIN pg_namespace n ON n.oid = t.typnamespace
     LEFT JOIN pg_class c ON t.typrelid = c.oid
  WHERE (t.typelem <> 0::oid OR c.relkind = 'c'::"char") AND t.typnamespace <> 11::oid AND (n.nspname <> ALL (ARRAY['pg_catalog'::name, 'information_schema'::name, 'sys'::name, 'dbo'::name, 'pg_toast'::name, 'utl_file'::name, 'dbms_output'::name, 'utl_tcp'::name, 'dbms_alert'::name, 'dbms_job'::name, 'dbms_lob'::name, 'dbms_pipe'::name, 'dbms_sql'::name, 'utl_smtp'::name, 'dbms_utility'::name, 'utl_mail'::name, 'utl_encode'::name, 'utl_file'::name]));




-- View: dba_constraints

-- DROP VIEW dba_constraints;

CREATE OR REPLACE VIEW dba_constraints AS
 SELECT upper(pg_get_userbyid(c.relowner)::text) AS owner,
    upper(pn.nspname::text) AS schema_name,
    upper(pc.conname::text) AS constraint_name,
    upper(pc.contype::text) AS constraint_type,
    upper(c.relname::text) AS table_name,
    upper(pc.consrc) AS search_condition,
        CASE
            WHEN pc.contype = 'f'::"char" THEN upper(pn2.nspname::text)
            ELSE NULL::text
        END AS r_owner,
        CASE
            WHEN pc.contype = 'f'::"char" THEN upper(pc2.conname::text)
            ELSE NULL::text
        END AS r_constraint_name,
    upper(pc.confdeltype::text) AS delete_rule,
    pc.condeferrable AS "deferrable",
    pc.condeferred AS deferred,
    upper(i.schemaname::text) AS index_owner,
    upper(i.indexname::text) AS index_name,
    pg_get_constraintdef(pc.oid) AS constraint_def
   FROM pg_constraint pc
     LEFT JOIN pg_namespace pn ON pn.oid = pc.connamespace
     LEFT JOIN pg_class c ON c.oid = pc.conrelid
     LEFT JOIN pg_indexes i ON i.indexname = pc.conname
     LEFT JOIN pg_class a ON a.oid = pc.confrelid
     LEFT JOIN pg_constraint pc2 ON pc2.conrelid = pc.confrelid AND pc2.contype = 'p'::"char" AND pc.contype = 'f'::"char"
     LEFT JOIN pg_namespace pn2 ON pn2.oid = pc2.connamespace;

-- View: dba_indexes

-- DROP VIEW dba_indexes;

CREATE OR REPLACE VIEW dba_indexes AS
 SELECT upper(pg_get_userbyid(c.relowner)::text) AS owner,
    upper(n.nspname::text) AS index_schema,
    upper(i.relname::text) AS index_name,
    'BTREE'::text AS index_type,
    upper(n.nspname::text) AS table_owner,
    upper(c.relname::text) AS table_name,
    'TABLE'::text AS table_type,
        CASE
            WHEN x.indisunique = true THEN 'UNIQUE'::text
            ELSE 'NONUNIQUE'::text
        END AS uniqueness,
    'N'::character(1) AS compression,
    upper(t.spcname::text) AS tablespace_name,
    'LOGGING'::text AS logging,
        CASE
            WHEN x.indisvalid = true THEN 'VALID'::text
            ELSE 'INVALID'::text
        END AS status,
    'NO'::character(3) AS partitioned,
    'N'::character(1) AS temporary,
    'N'::character(1) AS secondary,
    'NO'::character(3) AS join_index,
    'NO'::character(3) AS dropped
   FROM pg_index x
     JOIN pg_class c ON c.oid = x.indrelid
     JOIN pg_class i ON i.oid = x.indexrelid
     LEFT JOIN pg_namespace n ON n.oid = c.relnamespace
     LEFT JOIN pg_tablespace t ON t.oid = i.reltablespace
  WHERE c.relkind = 'r'::"char" AND i.relkind = 'i'::"char";


-- View: dba_sequences

-- DROP VIEW dba_sequences;

CREATE OR REPLACE VIEW dba_sequences AS
 SELECT upper(pg_get_userbyid(c.relowner)::text) AS sequence_owner,
    upper(c.relname::text) AS sequence_name,
    (showseq(c.oid::regclass::oid)).min_value AS min_value,
    (showseq(c.oid::regclass::oid)).max_value AS max_value,
    (showseq(c.oid::regclass::oid)).increment_by AS increment_by,
    (showseq(c.oid::regclass::oid)).cycle_flag AS cycle_flag,
    (showseq(c.oid::regclass::oid)).order_flag AS order_flag,
    (showseq(c.oid::regclass::oid)).cache_size AS cache_size,
    (showseq(c.oid::regclass::oid)).last_number AS last_number
   FROM pg_class c
  WHERE c.relkind = 'S'::"char";


-- View: dba_tables

-- DROP VIEW dba_tables;

CREATE OR REPLACE VIEW dba_tables AS
 SELECT upper(pg_get_userbyid(c.relowner)::character varying::text) AS owner,
    upper(n.nspname::text) AS schema_name,
    upper(c.relname::text) AS table_name,
    upper(t.spcname::text) AS tablespace_name,
    'VALID'::character varying(5) AS status,
        CASE
            WHEN n.nspname ~~ 'pg_temp_%'::text THEN 'Y'::text
            ELSE 'N'::text
        END::character(1) AS temporary
   FROM pg_class c
     LEFT JOIN pg_namespace n ON n.oid = c.relnamespace
     LEFT JOIN pg_tablespace t ON t.oid = c.reltablespace
  WHERE c.relkind = 'r'::"char";

ALTER TABLE dba_tables
    OWNER TO gp_eds_platform_ops;

GRANT ALL ON TABLE dba_tables TO gp_eds_etl;
GRANT ALL ON TABLE dba_tables TO gp_eds_platform_ops;
GRANT SELECT ON TABLE dba_tables TO gp_eds_readonly;


-- View: dba_tables_sizes

-- DROP VIEW dba_tables_sizes;

CREATE OR REPLACE VIEW dba_tables_sizes AS
 SELECT (n.nspname::text || '.'::text) || c.relname::text AS relation,
    pg_size_pretty(pg_total_relation_size(c.oid::regclass)) AS total_size
   FROM pg_class c
     LEFT JOIN pg_namespace n ON n.oid = c.relnamespace
  WHERE (n.nspname <> ALL (ARRAY['pg_catalog'::name, 'information_schema'::name])) AND c.relkind <> 'i'::"char" AND n.nspname !~ '^pg_toast'::text
  ORDER BY (pg_total_relation_size(c.oid::regclass)) DESC
 LIMIT 20;

--- Query below lists all table columns in a database --

select table_schema,
       table_name,
       ordinal_position as position,
       column_name,
       data_type,
       case when character_maximum_length is not null
            then character_maximum_length
            else numeric_precision end as max_length,
       is_nullable,
       column_default as default_value
from information_schema.columns
where table_schema not in ('information_schema', 'pg_catalog')
order by table_schema, 
         table_name,
         ordinal_position;
                                   

-- View: dba_triggers

-- DROP VIEW dba_triggers;

CREATE OR REPLACE VIEW dba_triggers AS
 SELECT n.nspname AS schema,
    p.proname AS name,
    pg_get_function_result(p.oid) AS result_data_type,
    pg_get_function_arguments(p.oid) AS argument_data_types,
        CASE
            WHEN p.proisagg THEN 'agg'::text
            WHEN p.proiswindow THEN 'window'::text
            WHEN p.prorettype = 'trigger'::regtype::oid THEN 'trigger'::text
            ELSE 'normal'::text
        END AS type,
        CASE
            WHEN p.provolatile = 'i'::"char" THEN 'immutable'::text
            WHEN p.provolatile = 's'::"char" THEN 'stable'::text
            WHEN p.provolatile = 'v'::"char" THEN 'volatile'::text
            ELSE NULL::text
        END AS volatility,
    pg_get_userbyid(p.proowner) AS owner,
    l.lanname AS language,
    p.prosrc AS source_code,
    obj_description(p.oid, 'pg_proc'::name) AS description
   FROM pg_proc p
     LEFT JOIN pg_namespace n ON n.oid = p.pronamespace
     LEFT JOIN pg_language l ON l.oid = p.prolang
  WHERE p.prorettype = 'trigger'::regtype::oid AND n.nspname <> 'pg_catalog'::name AND n.nspname <> 'information_schema'::name
  ORDER BY n.nspname, p.proname, (pg_get_function_arguments(p.oid));



