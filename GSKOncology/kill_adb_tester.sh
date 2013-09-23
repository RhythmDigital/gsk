pid=$(ps -fe | grep '[a]db_tester' | awk '{print $2}')
if [[ -n $pid ]]; then
    kill $pid
else
    echo "Does not exist"
fi