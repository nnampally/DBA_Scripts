SELECT
    pid,
    datname,
    usename,
    client_addr,
   state,
    wait_event_type || ': ' || wait_event AS wait_event,
    pg_catalog.pg_blocking_pids(pid) AS blocking_pids,
     pg_catalog.to_char(backend_start, 'YYYY-MM-DD HH24:MI:SS TZ') AS backend_start,
    --pg_catalog.to_char(state_change, 'YYYY-MM-DD HH24:MI:SS TZ') AS state_change,
    pg_catalog.to_char(query_start, 'YYYY-MM-DD HH24:MI:SS TZ') AS query_start,
    backend_type,
    CASE WHEN state = 'active' THEN ROUND((extract(epoch from now() - query_start) / 60)::numeric, 2) ELSE 0 END AS active_since,
	query
FROM
    pg_catalog.pg_stat_activity
	where usename != 'rdsadmin'
ORDER BY pid
