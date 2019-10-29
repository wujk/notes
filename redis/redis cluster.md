# redis 集群
### 1、redis cluster的重要配置
    cluster-enabled <yes/no>
    
    cluster-config-file <filename>：这是指定一个文件，供cluster模式下的redis实例将集群状态保存在那里，包括集群中其他机器的信息，比如节点的上线和下限，故障转移，不是我们去维护的，给它指定一个文件，让redis自己去维护的
    
    cluster-node-timeout <milliseconds>：节点存活超时时长，超过一定时长，认为节点宕机，master宕机的话就会触发主备切换，slave宕机就不会提供服务

### 2、编写配置文件
    
    redis cluster集群，要求至少3个master，去组成一个高可用，健壮的分布式的集群，每个master都建议至少给一个slave，3个master，3个slave，最少的要求
    
    正式环境下，建议都是说在6台机器上去搭建，至少3台机器
    
    保证，每个master都跟自己的slave不在同一台机器上，如果是6台自然更好，一个master+一个slave就死了
    
    3台机器去搭建6个redis实例的redis cluster
    
    mkdir -p /etc/redis-cluster
    mkdir -p /var/log/redis
    mkdir -p /var/redis/7001
    
    port 7001
    cluster-enabled yes
    cluster-config-file /etc/redis-cluster/node-7001.conf
    cluster-node-timeout 15000
    daemonize	yes							
    pidfile		/var/run/redis_7001.pid 						
    dir 		/var/redis/7001		
    logfile /var/log/redis/7001.log
    bind 192.168.31.205	
    appendonly yes
    
    至少要用3个master节点启动，每个master加一个slave节点，先选择6个节点，启动6个实例
    
    将上面的配置文件，在/etc/redis下放6个，分别为: 7001.conf，7002.conf，7003.conf，7004.conf，7005.conf，7006.conf

### 3、准备生产环境的启动脚本

    在/etc/init.d下，放6个启动脚本，分别为: redis_7001, redis_7002, redis_7003, redis_7004, redis_7005, redis_7006
    
    每个启动脚本内，都修改对应的端口号

### 4、分别在3台机器上，启动6个redis实例

    将每个配置文件中的slaveof给删除

### 5、创建集群
    安装ruby：
    yum install -y ruby
    yum install -y rubygems
    gem install redis
    
    --------------------------------------以下为老版本创建集群--------------------------------------------------
    cp /usr/local/wujk/redis-5.0.5/src/redis-trib.rb /usr/local/bin
    
    redis-trib.rb create --replicas 1 192.168.31.205:7001 192.168.31.205:7002 192.168.31.206:7003 192.168.31.206:7004 192.168.31.207:7005 192.168.31.207:7006
    
    --replicas: 每个master有几个slave
    
    redis-trib.rb check 192.168.31.187:7001
    
    ---------------------------------------以下为新版本创建集群--------------------------------------------------------
    
    redis-cli --cluster create 192.168.31.205:7001 192.168.31.205:7002 192.168.31.206:7003 192.168.31.206:7004 192.168.31.207:7005 192.168.31.207:7006 --cluster-replicas 1 
    
    redis-cli --cluster check 192.168.31.205:7001
    
    
    
    6台机器，3个master，3个slave，尽量自己让master和slave不在一台机器上
 
### 6、访问集群
    redis-cli -h 192.168.31.207 -p 7001 -c （-c 命令是集群访问不加会出现error moved错误）
       
### 7、读写分离+高可用+多master
    读写分离：每个master都有一个slave
    高可用：master宕机，slave自动被切换过去
    多master：横向扩容支持更大数据量
    
### 8、水平扩容加入master
    搞一个7007.conf，再搞一个redis_7007启动脚本
    手动启动一个新的redis实例，在7007端口上
    --------------------------------------以下为老版本创建集群--------------------------------------------------
    redis-trib.rb add-node 192.168.31.208:7007 192.168.31.205:7001
    redis-trib.rb check 192.168.31.205:7001
    ---------------------------------------以下为新版本创建集群--------------------------------------------------------
    redis-cli --cluster add-node 192.168.31.208:7007 192.168.31.205:7001
    redis-cli --cluster check 192.168.31.205:7001
    
    连接到新的redis实例上，cluster nodes，确认自己是否加入了集群，作为了一个新的master
    
    resharding的意思就是把一部分hash slot从一些node上迁移到另外一些node上
    
    redis-trib.rb reshard 192.168.31.205:7001
    
    redis-cli --cluster reshard 192.168.31.205:7001
    
    要把之前3个master上，总共4096个hashslot迁移到新的第四个master上去
    
    How many slots do you want to move (from 1 to 16384)?  1000（移动几个slot）
    
    
### 9、水平扩容加入slave
    redis-trib.rb add-node --slave --master-id 28927912ea0d59f6b790a50cf606602a5ee48108 192.168.31.208:7008 192.168.31.205:7001
    
    redis-cli --cluster --slave --master-id 28927912ea0d59f6b790a50cf606602a5ee48108 192.168.31.208:7008 192.168.31.205:7001
    
### 10、删除node
       
    先用resharding将数据都移除到其他节点，确保node为空之后，才能执行remove操作
    
    redis-trib.rb del-node 192.168.31.205:7001 bd5a40a6ddccbd46a0f4a2208eb25d2453c2a8db
    
    redis-cli --cluster del-node 192.168.31.205:7001 bd5a40a6ddccbd46a0f4a2208eb25d2453c2a8db
    
    2个是1365，1个是1366
    
    当你清空了一个master的hashslot时，redis cluster就会自动将其slave挂载到其他master上去
    
    这个时候就只要删除掉master就可以了