cd /usr/local/kevin/7001/redis01
rm -f nodes-*.conf
rm -f *.rdb
./src/redis-server redis.conf

cd /usr/local/kevin/7002/redis02
rm -f nodes-*.conf
rm -f *.rdb
./src/redis-server redis.conf

cd /usr/local/kevin/7003/redis03
rm -f nodes-*.conf
rm -f *.rdb
./src/redis-server redis.conf

cd /usr/local/kevin/7004/redis04
rm -f nodes-*.conf
rm -f *.rdb
./src/redis-server redis.conf

cd /usr/local/kevin/7005/redis05
rm -f nodes-*.conf
rm -f *.rdb
./src/redis-server redis.conf

cd /usr/local/kevin/7006/redis06
rm -f nodes-*.conf
rm -f *.rdb
./src/redis-server redis.conf
