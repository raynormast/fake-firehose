cat domains|grep -v "#"|while read -r host
do
   ./get-stream.sh $host &
done
