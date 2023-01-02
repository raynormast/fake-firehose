############################################################################
##
## This script sends URIs to fakerelay based on a saved JSON stream.
## It takes one argument, the input file name.
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

while true
do

    if [[ -f "./maxcurls" ]]
    then
        maxCurls=`cat ./maxcurls`
    fi


    ## Here we take the top 500 lines of the file -- so we are in FIFO 
    ## and pipe them thru uniq so we only pass unique URIs through to the fake relay
    ## This step easily cuts the total number of URIs in half and is the only way we can keep up

    ## Make sure that you have the name number in the following two lines. In this repo, it is currently at 500
    seed=`date +%Y%M%d%H%M%S%N`
    backfillFile="backfilluris.$seed.txt"
    sedExpression="1,${minURIs}d"
    sed -i $sedExpression "$source"
    head "$source" -n $minURIs | sort | uniq -u > "$backfillFile"

    ## Start looping through the unique URIs
    cat "$backfillFile" | \
    while read -r line
    do
        if [[ "$line" != "" ]]
        then

            uri=`echo $line | sed 's/data: //g' | jq .uri| sed 's/\"//g'`
            echo "[INFO] RUN-FIREHOSE: Posting $uri"

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

    linesLeft=`cat "$source"|wc -l` 
    echo "\n \n LINES LEFT: $linesLeft \n\n"
    rm "$backfillFile"
done