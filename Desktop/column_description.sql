 SELECT n.nspname AS schema_name,
    c.relname AS table_name,
    a.attname AS column_name,
    d.description
   FROM pg_class c
     JOIN pg_attribute a ON c.oid = a.attrelid
     LEFT JOIN pg_namespace n ON n.oid = c.relnamespace
     LEFT JOIN pg_tablespace t ON t.oid = c.reltablespace
     LEFT JOIN pg_description d ON d.objoid = c.oid AND d.objsubid = a.attnum
  WHERE (c.relkind = ANY (ARRAY['r'::"char", 'v'::"char"])) AND (n.nspname <> ALL (ARRAY['mdclog'::name, 'information_schema'::name, 'pg_catalog'::name])) AND n.nspname !~~ '%pg_temp_%'::text AND (a.attname <> ALL (ARRAY['ctid'::name, 'cmax'::name, 'cmin'::name, 'xmax'::name, 'xmin'::name, 'tableoid'::name]))
  ORDER BY n.nspname, c.relname, a.attname;
