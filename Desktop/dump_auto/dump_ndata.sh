

echo  "Enter schema name: "
read schema_name
#echo $schema_name
echo "Dump type Tables/Functions/Triggers/Views/Materializedview: "
read sub_dir
host="<>"
user="edsadmin"
db="ohl"
export PGPASSFILE='/Users/.pgpass' 
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
echo 'completed dump'


