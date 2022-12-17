while true
    do

    ## This assumes that we have other scripts that are writing to the file called
    ## $source, which here is today's date appended with .uris.txt
    today=`date +"%Y%m%d"`
    source="$today.uris.txt" 

    ## Here we take the top 500 lines of the file -- so we are in FIFO 
    ## and pipe them thru uniq so we only pass unique URIs through to the fake relay
    ##  This step easily cuts the total number of URIs in half and is the only way we can keep up

    ## Make sure that you have the name number in the following two lines. In this repo, it is currently at 500
    head "$source" -n 500 | sed 's/\"//g' | sort | uniq -u > backfilluris.txt
    sed -i '1,500d' "$source"

    ## Start looping through the unique URIs
    cat backfilluris.txt| \
    while read -r uri
        do 
        # echo BACKFILL $url;

            ## Send it to the fake relay as a background job
            curl -X "POST" "$fakeRelayHost" \
                -H "Authorization: Bearer $fakeRelayKey" \
                -H 'Content-Type: application/x-www-form-urlencoded; charset=utf-8' \
                --data-urlencode "statusUrl=$uri" &

            ## Don't overload the system on open curls. Wait until they are below a certain amount to move on
            ## Or have some fun, set this as high as you like and turn your computer into a space heater!
            curls=`ps -ef|grep curl|wc -l`
            until [ $curls -lt 100 ]
            do
                curls=`ps -ef|grep curl|wc -l`
                echo "Waiting for existing curls to finish, at $curls"
                linesLeft=`cat "$source"|wc -l` 
                echo "$linesLeft Total URIs left"
                sleep 1s
            done

        done

        linesLeft=`cat "$source"|wc -l` 

        ## Wait until the queue is at least 500 lines long, less than that
        ## and there are not enough lines to see if there are duplicates.
        until [ $linesLeft -gt 500 ]
        do
            linesLeft=`cat "$source"|wc -l` 
            sleep 1s
            echo "Waiting for more URIs to batch, currently at $linesLeft"

        done
done
