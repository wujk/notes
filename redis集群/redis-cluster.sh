topdir=/usr/local/kevin
ip1=192.168.140.159:7001
ip2=192.168.140.159:7002
ip3=192.168.140.159:7003
ip4=192.168.140.159:7004
ip5=192.168.140.159:7005
ip6=192.168.140.159:7006
pass=pass
cd $topdir
./redis-stop.sh
./redis-start.sh
files=`find $topdir -name redis-cli`
echo 'files:'${files}'......'
file=`echo ${files} | awk -F ' ' '{print $1}'`
echo $file 
result=$(echo yes | $file --cluster create $ip1 $ip2 $ip3 $ip4 $ip5 $ip6 -a $pass --cluster-replicas 1)
echo $result
