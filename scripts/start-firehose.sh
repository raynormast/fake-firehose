#!/bin/bash

cat /config/domains-federated|grep -v "#"|while read -r host
do
   if [[ "$host" != "" ]]
   then
      /scripts/get-stream.sh $host "federated" &
   fi
done

cat /config/domains-local|grep -v "#"|while read -r host
do
   if [[ "$host" != "" ]]
   then
      /scripts/get-stream.sh $host "local" &
   fi
done

if [[ $runFirehose == true ]]
then
   /scripts/run-firehose.sh &
fi

## We don't have a health check, so just exit after an hour
# If your docker file has restart: always on this should gracefully exit, and 
# then restart
sleep 1h
exit 0