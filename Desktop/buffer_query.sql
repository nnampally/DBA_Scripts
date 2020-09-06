
-- show running queries
SELECT pid, age(clock_timestamp(), query_start), usename, query
FROM pg_stat_activity
WHERE query != '<IDLE>' AND query NOT ILIKE '%pg_stat_activity%'
ORDER BY query_start desc;

--statiistic
select relname,last_vacuum, last_autovacuum, last_analyze, last_autoanalyze from pg_stat_user_tables;

--dead tuples
select relname, n_dead_tup, last_vacuum, last_autovacuum from
pg_catalog.pg_stat_all_tables
where n_dead_tup > 0 and relname =  'tablename' order by n_dead_tup desc;

--tables in buffer
SELECT  c.relname,
         pg_size_pretty(count(*) * 8192) as buffered, round(100.0 * count(*) / (SELECT setting FROM pg_settings WHERE name='shared_buffers')::integer,1) AS buffers_percent,
         round(100.0 * count(*) * 8192 / pg_relation_size(c.oid),1) AS percent_of_relation,
         round(100.0 * count(*) * 8192 / pg_table_size(c.oid),1) AS percent_of_table
FROM    pg_class c
         INNER JOIN pg_buffercache b
            ON b.relfilenode = c.relfilenode
         INNER JOIN pg_database d
             ON (b.reldatabase = d.oid AND d.datname = current_database())
GROUP BY c.oid,c.relname
ORDER BY 3 DESC
LIMIT 10;

-- how many indexes are in cache
SELECT sum(idx_blks_read) as idx_read, sum(idx_blks_hit)  as idx_hit, (sum(idx_blks_hit) - sum(idx_blks_read)) / sum(idx_blks_hit) as ratio
FROM pg_statio_user_indexes;



-- all tables and their size, with/without indexes
select datname, pg_size_pretty(pg_database_size(datname))
from pg_database
order by pg_database_size(datname) desc;

-- cache hit rates (should not be less than 0.99)
SELECT sum(heap_blks_read) as heap_read, sum(heap_blks_hit)  as heap_hit, (sum(heap_blks_hit) - sum(heap_blks_read)) / sum(heap_blks_hit) as ratio
FROM pg_statio_user_tables;

-- table index usage rates (should not be less than 0.99)

SELECT schemaname,relname,  n_live_tup rows_in_table , 
100 * idx_scan / (seq_scan + idx_scan) percent_of_times_index_used 
FROM pg_stat_user_tables 
where seq_scan + idx_scan > 0 
and 100 * idx_scan / (seq_scan + idx_scan) < 60
and n_live_tup > 100
ORDER BY percent_of_times_index_used DESC;
