-- FUNCTION: func_inventory_movement_insert_trigger()

-- DROP FUNCTION func_inventory_movement_insert_trigger();

CREATE FUNCTION func_inventory_movement_insert_trigger()
    RETURNS trigger
    LANGUAGE 'plpgsql'
    COST 100
    VOLATILE NOT LEAKPROOF
AS $BODY$
DECLARE
      m_ int;
	  y_ bigint;
	  r1 text;
	  r2 text;
	  chk_cond text;
	  c_table TEXT;
	  c_table1 text;
	  m_table1 text;
	 
    
    BEGIN

      m_ := to_char(NEW.report_date,'MM');
	  y_ := to_char(NEW.report_date,'YYYY');
      c_table := TG_TABLE_NAME || '_' || 'y'||y_||'m'||m_;
	  --raise info '%',c_table;
	  c_table1 := 'child_tables.' || c_table;
	  --raise info '%',c_table1;
      m_table1 := 'core.'||TG_TABLE_NAME;
	  -- raise info '%',m_table1;

      IF NOT EXISTS(SELECT relname FROM pg_class WHERE relname=c_table) THEN
	
      RAISE NOTICE 'values out of range partition, creating  partition table:  child_tables.%',c_table;
		
	    r1 := y_||'-'|| m_||'-01';
		r2 := y_||'-'|| m_+1 ||'-01';
		
		IF m_ = 12 then r2 := y_+1||'-01-01'  ; 
		END IF;
		chk_cond := 'report_date >= '''|| r1 ||''' AND report_date < ''' || r2 || '''';
        EXECUTE 'CREATE TABLE ' || c_table || '(check ('|| chk_cond||')) INHERITS (' ||'core.'|| TG_TABLE_NAME || ');';
		-- Create index on new child table

        EXECUTE  'Create index on ' || c_table1 ||'(report_date);';

        EXECUTE 'ALTER TABLE '||c_table1 ||' OWNER to gp_eds_owner;'; 

        EXECUTE 'GRANT ALL ON TABLE '||c_table1 ||' TO gp_eds_etl;';

        EXECUTE 'GRANT ALL ON TABLE '||c_table1 ||' TO gp_eds_platform_ops;';

        EXECUTE 'GRANT SELECT ON TABLE '||c_table1 ||' TO gp_eds_readonly;';

       END IF;
	  
      EXECUTE 'INSERT INTO ' || c_table1 || ' SELECT(' || m_table1 || ' ' || quote_literal(NEW) || ').* RETURNING load_dttm;';
	  
      RETURN NULL;
    END;
$BODY$;
