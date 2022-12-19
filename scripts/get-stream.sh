host=$1
type=$2
hashtag=$1

if [[ "$host" == "" ]]
then
    echo "Empty host: $host"
    exit 2
fi

while true
do
    today=`date +"%Y%m%d"`

    case "$type" in
        "federated")
            fetch="https://$host/api/v1/streaming/public";;
        "local")
            fetch="https://$host/api/v1/streaming/public?local=true";;

    esac

    echo "Starting to stream $fetch in 5 seconds"

    sleep 5s;

    curl -X "GET" "$fetch" \
         --no-progress-meter | \
        tee -a "/data/$today.json" | \
        grep url | \
        sed 's/data://g' | \

     while read -r line
     do

         if [[ $line == *"uri"* ]]
         then
            url=`echo $line | jq .url| sed 's/\"//g'` 
            uri=`echo $line | jq .uri| sed 's/\"//g'`

            echo "STREAMING: $host $url"
            echo $uri >> "/data/$today.uris.txt"

        fi
    done
done