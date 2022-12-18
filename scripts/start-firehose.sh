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

## Don't let the container exit
while true; do sleep 1; done