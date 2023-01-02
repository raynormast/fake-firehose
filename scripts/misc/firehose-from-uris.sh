############################################################################
##
## This script sends URIs to fakerelay based on a saved file of URIS, one
## URI per line. It takes on argument, the filename with the URIs
##
## The significant difference is that the JSON stream has already been processed
## so this script can post the URIs much faster, as it doesn't have to run the
## JSON stream through jq
##
############################################################################

## Look for environmental variables. Because this script may be run outside of docker
## there is a good change that they are not set, if they are not, attempt to set them
## via the .env.production file. If that fails warn and keep going
if [[ ! $loadEnv && -f  ../../.env.production ]]
then
    echo "[INFO] Did not detect that environmental variables are set, attempting to set via ../../.env.production"
    source ../../.env.production
fi

if [[ ! $loadEnv  ]]
then
    echo "[WARN] Cannot find environemtnal variables, expect things to break ahead"
    sleep 5s
fi

today=`date +"%Y%m%d"`

## The source file we are reading from
source=$1

## Here we take the top $minURIs lines of the file -- so we are in FIFO 
## and pipe them thru uniq so we only pass unique URIs through to the fake relay
## This step easily cuts the total number of URIs in half and is the only way we can keep up

seed=`date +%Y%M%d%H%M%S%N`
backfillFile="backfilluris.$seed.txt"
cat "$source" | sort | uniq -u > "$backfillFile"

## Start looping through the unique URIs
cat "$backfillFile" | \
while read -r line
do
    if [[ "$line" != "" ]]
    then

        uri=$line
        echo "[INFO] RUN-FIREHOSE: Posting $uri"
        sleep 1s

        ## Send it to the fake relay as a background job
        curl -X "POST" "$fakeRelayHost" \
            -H "Authorization: Bearer $fakeRelayKey" \
            -H 'Content-Type: application/x-www-form-urlencoded; charset=utf-8' \
            --data-urlencode "statusUrl=$uri" \
            --no-progress-meter &

        ## Don't overload the system on open curls. Wait until they are below a certain amount to move on
        ## Or have some fun, set this as high as you like and turn your computer into a space heater!
        curls=`ps -ef|grep curl|wc -l`
        until [ $curls -lt $maxCurls ]
        do
            curls=`ps -ef|grep curl|wc -l`
            echo "[INFO] RUN-FIREHOSE: Waiting for existing curls to finish, at $curls"
            linesLeft=`cat "$source"|wc -l` 
            echo "[INFO] RUN-FIREHOSE:$linesLeft Total URIs left"
            sleep 5s
        done
    fi

done

rm "$backfillFile"