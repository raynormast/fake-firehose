#!/bin/bash

cat /config/domains|grep -v "#"|while read -r host
do
   /scripts/get-stream.sh $host &
done

while true; do sleep 1; done