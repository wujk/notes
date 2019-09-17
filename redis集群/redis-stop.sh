pids=`ps -ef | grep 'redis' | grep -v 'grep' | awk '{print $2}'`
for str in $pids
do
    echo $str
    kill -9 $str
done
