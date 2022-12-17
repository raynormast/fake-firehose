cat domains|while read -r host
do
   ./get-stream.sh $host &
done
