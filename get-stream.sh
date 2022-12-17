host=$1
while true
do
    today=`date +"%Y%m%d"`
    curl -X "GET" "https://$host/api/v1/streaming/public" \
         --no-progress-meter | \
        grep url | \
        sed 's/data://g' | \

     while read -r line
     do

         if [[ $line == *"uri"* ]]
         then
            url=`echo $line | jq .url| sed 's/\"//g'` 
            uri=`echo $line | jq .uri| sed 's/\"//g'`

            echo "$host $url"
            echo $uri >> "$today.uris.txt"

        fi
    done
done
