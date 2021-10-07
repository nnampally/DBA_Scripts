-- Description of all schema objects.

SELECT N.NSPNAME AS "Schema",
	C.RELNAME AS "Name",
	CASE C.RELKIND
					WHEN 'r' THEN 'table'
					WHEN 'v' THEN 'view'
					WHEN 'm' THEN 'materialized view'
					WHEN 'i' THEN 'index'
					WHEN 'S' THEN 'sequence'
					WHEN 's' THEN 'special'
					WHEN 'f' THEN 'foreign table'
					WHEN 'p' THEN 'partitioned table'
					WHEN 'I' THEN 'partitioned index'
	END AS "Type",
	PG_CATALOG.PG_GET_USERBYID(C.RELOWNER) AS "Owner",
	PG_CATALOG.OBJ_DESCRIPTION(C.OID,'pg_class') AS "Description"
FROM PG_CATALOG.PG_CLASS C
LEFT JOIN PG_CATALOG.PG_NAMESPACE N ON N.OID = C.RELNAMESPACE
WHERE N.NSPNAME not in ('pg_toast','pg_catalog','information_schema') 
-- or N.NSPNAME = '<schema>'
AND PG_CATALOG.OBJ_DESCRIPTION(C.OID,'pg_class') is null -- to object without comments

ORDER BY 1,2;


-- Description on roles.

SELECT r.rolname, r.rolsuper, r.rolinherit,
  r.rolcreaterole, r.rolcreatedb, r.rolcanlogin,
  r.rolconnlimit, 
  ARRAY(SELECT b.rolname
        FROM pg_catalog.pg_auth_members m
        JOIN pg_catalog.pg_roles b ON (m.roleid = b.oid)
        WHERE m.member = r.oid) as memberof
, r.rolreplication
, r.rolbypassrls
, r.rolvaliduntil
, pg_catalog.shobj_description(r.oid, 'pg_authid') AS description
FROM pg_catalog.pg_roles r
WHERE 
--r.rolname = 'nnampally' 
pg_catalog.shobj_description(r.oid, 'pg_authid') is null -- pg_catalog.shobj_description(r.oid, 'pg_authid')  = '<role>'
and r.rolname not like 'pg_%'
ORDER BY 1;
