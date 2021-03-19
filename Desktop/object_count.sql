SELECT
	n.nspname as schema_name
	,CASE c.relkind
	   WHEN 'r' THEN 'table'
	   WHEN 'v' THEN 'view'
	   WHEN 'i' THEN 'index'
	   WHEN 'S' THEN 'sequence'
	   WHEN 's' THEN 'special'
	END as object_type
	,count(1) as object_count
FROM pg_catalog.pg_class c
LEFT JOIN pg_catalog.pg_namespace n ON n.oid = c.relnamespace
WHERE c.relkind IN ('r','v','i','S','s')
 and n.nspname = '<schema name>'
GROUP BY  n.nspname,
	CASE c.relkind
	   WHEN 'r' THEN 'table'
	   WHEN 'v' THEN 'view'
	   WHEN 'i' THEN 'index'
	   WHEN 'S' THEN 'sequence'
	   WHEN 's' THEN 'special'
	END
	--where
ORDER BY n.nspname,
	CASE c.relkind
	   WHEN 'r' THEN 'table'
	   WHEN 'v' THEN 'view'
	   WHEN 'i' THEN 'index'
	   WHEN 'S' THEN 'sequence'
	   WHEN 's' THEN 'special'
	END; 
