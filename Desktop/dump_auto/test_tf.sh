

echo  "Enter schema name: "
read schema_name
#echo $schema_name
echo "Dump type Tables/Functions/Sequences/Triggers/Views: "
read sub_dir
host="<>"
user="edsadmin"
db="ohl"
export PGPASSFILE='/Users/.pgpass' #'~/.pgpass'
export targetdir='/Users/Desktop/OHL-Postgres'
echo $targetdir
cd $targetdir

if [ -d $schema_name ]; then
    echo "$schema_name directory already exists";
else 
    `mkdir -p $targetdir/$schema_name`;
    echo "$schema_name directory created"
fi
cd $targetdir/$schema_name

if [ -d $sub_dir ]; then
    echo "$sub_dir directory already exists";
else 
`mkdir -p $targetdir/$schema_name/$sub_dir`;
echo "$sub_dir directory created"
fi

cd $targetdir/$schema_name/$sub_dir

if [ $sub_dir == 'Tables' ]; then
    echo "Dumping $sub_dir"
    psql -h $host -U $user -d $db -c  "select schemaname||'.'||tablename as table from pg_tables  where schemaname = '$schema_name' " | while read -a Record ;  do
    #echo 'helpp'
    case  "$Record" in 
    *$schema_name* )
    #echo $Record
    #echo "testd"
    pg_dump -h $host -U $user -d $db -t $Record --schema-only -Fp --no-tablespaces --verbose > $Record.sql
    ;;
    esac
    done
    echo "$sub_dir dump completed for  $schema_name schema"
elif  [ $sub_dir == 'Functions' ]; then
    echo "Dumping $sub_dir"
    psql -h $host -U $user -d $db -X -A -t -c  \
                            "select proname
                            FROM pg_proc p
                            INNER JOIN pg_namespace ns ON p.pronamespace = ns.oid
                            WHERE ns.nspname = '$schema_name';  "  | while read -a Record1 ;  do
                            #echo $Record1

                            psql -h $host -U $user -d $db -X -A -t -c  \
                            "SELECT 
                            '-- FUNCTION: ' || ns.nspname||'.'||proname||'()
                            -- DROP FUNCTION' || ns.nspname||'.'||proname||'();   

                            '
                            || pg_get_functiondef(p.oid) || ';


                          
                            as function

                            FROM pg_proc p
                            INNER JOIN pg_namespace ns ON p.pronamespace = ns.oid
                            WHERE ns.nspname = '$schema_name' and proname = '$Record1';  " > "$schema_name.$Record1().sql"  #| while read -r Record ;  do

    done
    echo "$sub_dir dump completed for  $schema_name schema"

elif  [ $sub_dir == 'Sequences' ]; then
    echo "Dumping $sub_dir"
    psql -h $host -U $user -d $db -X -A -t -c  \
                                            "select sequence_name
                                            from information_schema.sequences
                                            WHERE sequence_schema = '$schema_name';"  | while read -a Record1 ;  do
                                            # echo $Record1
                                            psql -h $host -U $user -d $db -X -A -t -c  \
                                            " SELECT '
                                            -- SEQUENCE: $schema_name.'||sequence_name||'

                                            -- DROP SEQUENCE $schema_name.'|| sequence_name || ';

                                            CREATE SEQUENCE  $schema_name.'||sequence_name || ';

                                            ALTER SEQUENCE $schema_name.' || sequence_name||
                                                ' 
                                                OWNER TO gp_eds_owner;
                                                

                                            GRANT ALL ON SEQUENCE $schema_name.'|| sequence_name || ' TO gp_eds_etl;

                                            GRANT ALL ON SEQUENCE $schema_name.'|| sequence_name || ' TO gp_eds_owner;' 

                                            from information_schema.sequences where  sequence_name = '$Record1' 
                                            and sequence_schema = '$schema_name';" >  "$schema_name.$Record1().sql" 

    done

    echo "$sub_dir dump completed for  $schema_name schema"
elif  [ $sub_dir == 'Views' ]; then
    echo "Dumping $sub_dir"
    psql -h $host -U $user -d $db -c  "select table_schema||'.'||table_name from INFORMATION_SCHEMA.views where table_schema  = '$schema_name' " | while read -a Record ;  do
    #echo 'helpp'
    case  "$Record" in 
    *$schema_name* )
    #echo $Record
    #echo "testd"
    pg_dump -h $host -U $user -d $db -t $Record --schema-only -Fp --no-tablespaces --verbose > $Record.sql
    ;;
    esac
    done
    echo "$sub_dir dump completed for  $schema_name schema"
else 
    echo "Out of functionality "
fi



