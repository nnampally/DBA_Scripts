SELECT d.datname as "Name",
       split_part(unnest(d.datacl)::text, '=', 1) AS Access_privileges
       --pg_catalog.shobj_description(d.oid, 'pg_database') as "Description"
FROM pg_catalog.pg_database d
  JOIN pg_catalog.pg_tablespace t on d.dattablespace = t.oid
WHERE d.datname = current_database()
ORDER BY 1) dt
where Access_privileges like '%developer'
