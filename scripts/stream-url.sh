url=$1 #A proper URL is all that should be sent to this script
host=$2
errors=0

if [[ "$url" == "" ]]
then
    echo "[WARN] Empty url, skipping" # Exit if an empty URL was sent
    exit 2
fi

# if [[ "$checkUrl" != *"200"* ]]
# then
#     echo "[WARN] Server threw an error, skipping"
# fi

# Check to see if domain name resolves. If not, exist
if [[ ! `dig $host +short` ]]
then
    echo "[WARN] DNS Lookup failed for $host, skipping"
fi

echo "[INFO] Archive is $archive"

while true # Loop endlessly
do

    today=`date +"%Y%m%d"`

    echo "[INFO] Starting to stream $url in 5 seconds"
    echo "[INFO] Archive status is $archive"

    sleep 5s;

    # Im archive mode we'll only fetch the json stream to save resources from jq and sed
    if [[ $archive != "true" ]]
    then
    #Not in archive mode

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

                echo "[INFO] STREAMING from $host $url"
                echo $uri >> "/data/$today.uris.txt"
            fi
        done
    # In archive mode
    else

        if [[ ! -d "/data/$today/" ]]
        then
            mkdir -p "/data/$today/"
        fi

        curl -X "GET" "$url" --no-progress-meter >> "/data/$today/$today.$host.json"
    fi

    # Basic exponential backoff
    ((++errors))
    sleepseconds=$((errors*errors))
    
    # Don't allow a back off for more than 5 minutes.
    # Because we expect this container to reset occasionally to kill hanging curl processes
    # a graceful exit will wait for all scripts to stop. So, it will take at least as long as $sleepseconds
    # to stop.
    if [[ $sleepseconds -gt 299 ]]
    then
        sleepseconds=300
    fi

    sleep $sleepseconds;
    
    echo "[WARN] Streaming abrubtly stopped for $host, streaming will pause for $sleepseconds seconds before retrying."

done

## Exit 0 by default
exit 0