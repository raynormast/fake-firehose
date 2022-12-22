#!/bin/bash

echo > /config/urls.txt
echo > /config/hosts

# Get federated hosts and begin to stream them
cat /config/domains-federated | grep -v "##" | while read -r line
do
   #filter out empty lines
   if [[ "$line" != "" ]]; then
      echo "[INFO] Opening federated line $line"

      #Check for hashtags
      if [[ "$line" == *" #"* ]]; then

         echo "$line has hashtags!"

         # Get just the first field of the line, which is the host
         host=`echo $line | cut -d " " -f 1`
         tags=`echo $line | cut -d " " -f 1 --complement|tr "#" "\n "`
         for tag in $tags
         do
            if [[ $tag != "" ]]; then
            echo "Found tag $tag"
            # Create a url to fetch for each tag
            echo "https://$host/api/v1/streaming/hashtag?tag=$tag $host" >> /config/urls.txt
            fi
         done
      elif [[ "$line" != *" #"* ]]; then
         echo "$line didn't have hashtags"
         host=$line
         echo "https://$line/api/v1/streaming/public $line" >> /config/urls.txt
      fi 
      echo $host >> /config/hosts
   fi
done


# Get local hosts and begin to stream them
cat /config/domains-local | grep -v "##" | while read -r line
do
   #filter out empty lines
   if [[ "$line" != "" ]]; then
      echo "[INFO] Opening federated line $line"

      #Check for hashtags
      if [[ "$line" == *" #"* ]]; then

         echo "[INFO] $line has hashtags!"

         # Get just the first field of the line, which is the host
         host=`echo $line | cut -d " " -f 1`
         tags=`echo $line | cut -d " " -f 1 --complement|tr "#" "\n "`
         for tag in $tags
         do
            if [[ $tag != "" ]]; then
            echo "Found tag $tag"
            # Create a url to fetch for each tag
            echo "https://$host/api/v1/streaming/hashtag/local?tag=$tag $host" >> /config/urls.txt
            fi
         done
      elif [[ "$line" != *" #"* ]]; then
         echo "$line didn't have hashtags"
         host=$line
         echo "https://$line/api/v1/streaming/public/local $line" >> /config/urls.txt
      fi
      echo $host >> /config/hosts
   fi
done

cat /config/hashtags | grep -v "##" | while read -r hashtag; do
   hashtag=`echo $hashtag | cut -d "#" -f 2`
   sort /config/hosts | uniq -u |while read -r host; do
      if [[ $hashtag != "" && "$host" != "" ]]; then
         echo "https://$host/api/v1/streaming/hashtag?tag=$hashtag $host" >> /config/hashtag-urls.txt
      fi
   done
done

cat /config/hashtag-urls.txt >> /config/urls.txt

cat /config/urls.txt | while read -r url
do
   echo "[INFO] Opening $url to stream"
   sleep 0.1s
   ./stream-url.sh $url &
done

if [[ $runFirehose == true ]]
then
   /scripts/run-firehose.sh &
fi

## We don't have a health check, so just exit after an hour
# If your docker file has restart: always on this should gracefully exit, and 
# then restart
echo "[INFO] Container restart timoe is $restartTimeout"
sleep $restartTimeout
exit 0