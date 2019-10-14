pids=`ps -ef | grep 'elasticsearch' | grep -v 'grep' | awk '{print $2}'`
for str in $pids
do
    echo $str
    kill -9 $str
done
