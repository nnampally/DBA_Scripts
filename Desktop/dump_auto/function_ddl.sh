
echo  "Enter schema name: "
read schema_name
#echo $schema_name
echo "Dump type tables/functions/sequences/triggers/views/materializedview: "
read sub_dir
host="<>"
echo $host
user="<>"
db="<>"
export PGPASSFILE='~/.pgpass' 
export targetdir='~/Postgres_dumps'
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
    OWNER TO <>;
    

GRANT ALL ON SEQUENCE $schema_name.'|| sequence_name || ' TO <>;

GRANT ALL ON SEQUENCE $schema_name.'|| sequence_name || ' TO <>;' 

from information_schema.sequences where  sequence_name = '$Record1' 
and sequence_schema = '$schema_name';" >  "$schema_name.$Record1().sql" 

done

echo "completed $sub_dir dump"


