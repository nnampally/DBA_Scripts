show engine InnoDB status;

select * from information_schema.processlist where time > 300 and command != 'Sleep'  order by time desc limit 5;

select name, count from information_schema.INNODB_METRICS where name like '%hist%';

select sleep(651);

show full processlist;

-- to check locks in DB --

select a.requesting_trx_id, c.trx_mysql_thread_id requestion_trx_mysql_id, 
a.blocking_trx_id, 
b.trx_mysql_thread_id blocking_trx_mysql_id,c.trx_query requesting_trx_query
from information_schema.innodb_lock_waits a 
inner join information_schema.innodb_trx b on a.blocking_trx_id=b.trx_id 
inner join information_schema.innodb_trx c on a.requesting_trx_id=c.trx_id;


select * from information_schema.INNODB_TRX;




-------------------
1. Enabling Slow Query Log 
- slow_query = 1
- long_query_time = 651

This will capture any statement running for over 10 minutes in the slow query log file.

2. Enabled Enhanced Monitoring with granularity 5 sec
This is done to capture more graular detail when the CPU is high and give Support Engineers more insight which process is consuming more CPU.

3. Running Profiling on Statements
The following process helps identify the bottleneck:

-------------------------------------------------------------------------------------------------------------------------------
Profiling Queries:
----------------------
SET SESSION profiling=1;
Run query - SELECT * FROM table_name WHERE col = ?;
SHOW PROFILES;
SELECT * FROM information_schema.profiling WHERE query_id = ? -- from step 3
           SHOW PROFILE FOR QUERY ? -- from step 3
SET SESSION PROFILING=0;
-------------------------------------------------------------------------------------------------------------------------------

