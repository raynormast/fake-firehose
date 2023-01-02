## The file you want to import
file=$1
base=`basename "$file"`

if [[ ! -f "$file" ]]
then
    echo "[WARN] File not found, exiting, $file" 
    exit 2
fi

cat "$file" |grep "data: " | while read -r line
do
    if [[ $line == *"uri"* ]]
    then
        echo $line |sed 's/data://g'| jq .uri| sed 's/\"//g' >>  "./$base.uris.txt" &
    fi
done


## Exit 0 by default
exit 0