

echo  "Enter schema name: "
read schema_name
#echo $schema_name
echo "Dump type Tables/Functions/Triggers/Views/Materializedview: "
read sub_dir
host="<>"
user="<>"
db="<>"
export PGPASSFILE='~/.pgpass' 
export targetdir='~/Postgres_dumps' # export targetdir=pwd
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

psql -h $host -U $user -d $db -c  "SELECT ns.nspname||'.'||proname||'()' as function FROM pg_proc p INNER JOIN pg_namespace ns ON p.pronamespace = ns.oid WHERE ns.nspname = '$schema_name'" | while read -a Record ;  do

#psql -h $host -U $user -d $db -c  "select schemaname||'.'||tablename as table from pg_tables  where schemaname = '$schema_name' " | while read -a Record ;  do
 #echo 'helpp'
 case  "$Record" in 
 *$schema_name* )
 echo $Record > $Record.sql
 #echo "testd"
 # pg_dump -h $host -U $user -d $db -f $Record --schema-only -Fp --verbose > $Record.sql
 ;;
 esac
 
done
echo 'completed dump'


