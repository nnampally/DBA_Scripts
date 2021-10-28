DO $BODY$
DECLARE
      m_ text;
	  num_s bigint;
      num_e bigint;
	  r1 text;
	  r2 text;
	  chk_cond text;
	  c_table TEXT;
	  c_table1 text;
	  m_table1 text;
      end_date date;
      v_k int;
      v_start_time date;
      v_parent_schema                 text;
      v_parent_tablename              text;
      v_parent_tablespace             text;
      v_unlogged             text;
      v_control_type                  text;
v_control_exact_type            text;
v_intervel int;
---
--
--
      p_parent_table text:='public.test5';
      p_part_col text:='dt' ;--partition COLUMN
      p_type text:='range';  -- partition type range,hash
      p_interval text:='daily' ; --time:  daily, monthly,yearly , id : 10,1000 any range
      p_fk_cols text:='id'; -- constraint COLUMN
      p_uk_cols text:='id';
     -- p_constraint_type text[] DEFAULT NULL  -- constraint type PK,UK
      p_premake int:=6 ;-- no of partition tables to be created
      --p_inherit_fk boolean DEFAULT true
      --p_epoch text DEFAULT 'none'
     -- p_upsert text DEFAULT ''
      --p_publications text[] DEFAULT NULL
      --start_date TIMESTAMP := '2021-10-27 00:00:00' ;
BEGIN


v_start_time := current_date;

-- check tables existence

SELECT n.nspname, c.relname, t.spcname, c.relpersistence
INTO v_parent_schema, v_parent_tablename, v_parent_tablespace, v_unlogged
FROM pg_catalog.pg_class c
JOIN pg_catalog.pg_namespace n ON c.relnamespace = n.oid
LEFT OUTER JOIN pg_catalog.pg_tablespace t ON c.reltablespace = t.oid
WHERE n.nspname = split_part(p_parent_table, '.', 1)::name
AND c.relname = split_part(p_parent_table, '.', 2)::name;

SELECT CASE
            WHEN typname IN ('timestamptz', 'timestamp', 'date') THEN
                'time'
            WHEN typname IN ('int2', 'int4', 'int8') THEN
                'id'
       END as _case
, typname::text INTO v_control_type, v_control_exact_type
FROM pg_catalog.pg_type t
JOIN pg_catalog.pg_attribute a ON t.oid = a.atttypid
JOIN pg_catalog.pg_class c ON a.attrelid = c.oid
JOIN pg_catalog.pg_namespace n ON c.relnamespace = n.oid
WHERE n.nspname = v_parent_schema::name
AND c.relname = v_parent_tablename::name
AND a.attname = p_part_col::name;

IF v_parent_tablename IS NULL THEN
            RAISE EXCEPTION '42P01 : Unable to find given parent table in system catalogs. Please create parent table first, Ex: CREATE TABLE % () PARTITION BY % (%);', p_parent_table,p_type,p_part_col;
END IF;

IF p_type = 'range' THEN
        IF v_control_type = 'time' then
           IF  p_interval = 'daily' THEN

               EXECUTE FORMAT( 'CREATE TABLE  IF NOT EXISTS %s_default PARTITION OF %s default'
                   ,v_parent_tablename, p_parent_table);
                -- for backlog date
               SELECT current_date - interval '2 day' into v_start_time;

               for v_k in 1..p_premake loop
                     end_date= v_start_time+1;
                         r1 := v_parent_tablename||'_p'||to_char(v_start_time,'MMDD')::text;
                         IF p_fk_cols is null then
                            EXECUTE FORMAT( 'CREATE TABLE  IF NOT EXISTS %s PARTITION OF %s FOR VALUES FROM (''%s'') TO (''%s'')',r1, p_parent_table,v_start_time,end_date);
                         ELSE
                            EXECUTE FORMAT( 'CREATE TABLE  IF NOT EXISTS %s PARTITION OF %s ( CONSTRAINT %s_pkey PRIMARY KEY (%s) )
                                              FOR VALUES FROM (''%s'') TO (''%s'')',r1, p_parent_table,r1,p_fk_cols,v_start_time,end_date);
                         END IF;
                     v_start_time=end_date;
               end loop;
            ELSIF p_interval = 'monthly' THEN

               EXECUTE FORMAT( 'CREATE TABLE  IF NOT EXISTS %s_default PARTITION OF %s default'
                   ,v_parent_tablename, p_parent_table);
                -- for backlog date
               v_start_time=to_char(v_start_time,'YYYY-MM-01');
               for v_k in 1..p_premake loop
                     end_date= v_start_time + interval '1 month';
                         r1 := v_parent_tablename||'_p'||to_char(v_start_time,'MM_DD')::text;
                         IF p_fk_cols is null then
                            EXECUTE FORMAT( 'CREATE TABLE  IF NOT EXISTS %s PARTITION OF %s FOR VALUES FROM (''%s'') TO (''%s'')',r1, p_parent_table,v_start_time,end_date);
                         ELSE
                            EXECUTE FORMAT( 'CREATE TABLE  IF NOT EXISTS %s PARTITION OF %s ( CONSTRAINT %s_pkey PRIMARY KEY (%s) )
                                              FOR VALUES FROM (''%s'') TO (''%s'')',r1, p_parent_table,r1,p_fk_cols,v_start_time,end_date);
                         END IF;
                     v_start_time=end_date;
               end loop;
            ELSIF p_interval = 'yearly' THEN
            raise info 'Not compatable for now';
            END IF;  -- monthly
        ELSE     -- id
            v_intervel := p_interval::int;
            num_s = v_intervel;
            EXECUTE FORMAT( 'CREATE TABLE  IF NOT EXISTS %s_default PARTITION OF %s default'
                ,v_parent_tablename, p_parent_table);
            for v_k in 1..p_premake loop
                num_e=num_s+v_intervel;
                r2 = v_parent_tablename||'_p'||num_s;

                IF p_fk_cols is null then
                EXECUTE FORMAT( 'CREATE TABLE  IF NOT EXISTS %s.%s PARTITION OF %s FOR VALUES FROM (%s) TO (%s)'
                ,v_parent_schema,r2, p_parent_table,num_s,num_e);
                ELSE
                EXECUTE FORMAT( 'CREATE TABLE  IF NOT EXISTS %s.%s PARTITION OF %s 
                ( CONSTRAINT %s_pkey PRIMARY KEY (%s) ) FOR VALUES FROM (%s) TO (%s)'
                ,v_parent_schema,r2, p_parent_table,r2,p_fk_cols,num_s,num_e);
                END IF;

                num_s=num_e;
         end loop;

        END IF; -- range  type end

ELSIF  p_type = 'list' THEN
        RAISE NOTICE 'pass';
ELSIF  p_type = 'hash' THEN
        RAISE NOTICE 'pass';
END IF;



END;
$BODY$;
