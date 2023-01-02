############################################################################
##
## This script exports URIs from a saved JSON stream. It uses the same logic
## as stream-url.sh, except that it reads the JSON from a file.
## It takes one argument, the input file name.
##
############################################################################

source=$1

cat "$source"|grep -A 1 "event: update"|grep "data:" | \
while read -r line
do
    if [[ $line == *"uri"* ]]
    then
        uri=`echo $line | sed 's/data: //g' | jq .uri| sed 's/\"//g'`
        echo "$uri"
    fi
done