url=$1 #A proper URL is all that should be sent to this script
host=$2

if [[ "$url" == "" ]]
then
    echo "Empty url, skipping" # Exit if an empty URL was sent
    exit 2
fi

while true # Loop endlessly
do
    today=`date +"%Y%m%d"`

    echo "Starting to stream $url in 5 seconds"
    echo "Archive status is $archive"

    sleep 5s;

    if [[ $archive != "true" ]]
    then
        curl -X "GET" "$url" \
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

                echo "STREAMING from $host $url"
                echo $uri >> "/data/$today.uris.txt"
            fi
        done
    else

        if [[ ! -d "/data/$today/" ]]
        then
            mkdir -p "/data/$today/"
        fi

        curl -X "GET" "$url" --no-progress-meter >> "/data/$today/$today.$host.json"
    fi

    # If we are in archive mode only, then back off if there is a curl error.
    if [[ $archive == "true" ]]
    then
        sleep 5m;
    fi

done

## Exit 0 by default
exit 0