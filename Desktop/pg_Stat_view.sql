SELECT DISTINCT D.DATNAME AS DB_NAME,
	R.ROLNAME AS USERNAME,
	s.calls,s.max_time ,s.mean_time,s.total_time,s.stddev_time, s.rows ,s.shared_blks_hit , s.shared_blks_read,s.temp_blks_written, s.query
FROM PG_STAT_STATEMENTS S,
	PG_ROLES R,
	PG_DATABASE D
WHERE S.USERID = R.OID
AND S.DBID = D.OID
AND D.DATNAME not in ('postgres','rdsadmin') 
AND D.datallowconn = true
AND QUERY NOT ILIKE '%pg_stat_Statements%'
and s.total_time > 1
order by s.calls desc ,  s.max_time desc, s.total_time desc;

