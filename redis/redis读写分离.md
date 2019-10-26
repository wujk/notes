# redis读写分离

### 一、redis replication
###### 1、redis replication的核心机制
    （1）redis采用异步方式复制数据到slave节点，不过redis 2.8开始，slave node会周期性地确认自己每次复制的数据量
    （2）一个master node是可以配置多个slave node的
    （3）slave node也可以连接其他的slave node
    （4）slave node做复制的时候，是不会block master node的正常工作的
    （5）slave node在做复制的时候，也不会block对自己的查询操作，它会用旧的数据集来提供服务; 但是复制完成的时候，需要删除旧数据集，加载新数据集，这个时候就会暂停对外服务了
    （6）slave node主要用来进行横向扩容，做读写分离，扩容的slave node可以提高读的吞吐量
    
    slave，高可用性，有很大的关系
    
###### 2、master持久化对于主从架构的安全保障的意义
    如果采用了主从架构，那么建议必须开启master node的持久化！
    不建议用slave node作为master node的数据热备，因为那样的话，如果你关掉master的持久化，可能在master宕机重启的时候数据是空的，然后可能一经过复制，salve node数据也丢了
    master -> RDB和AOF都关闭了 -> 全部在内存中
    master宕机，重启，是没有本地数据可以恢复的，然后就会直接认为自己IDE数据是空的
    master就会将空的数据集同步到slave上去，所有slave的数据全部清空
    100%的数据丢失
    master节点，必须要使用持久化机制
    第二个，master的各种备份方案，要不要做，万一说本地的所有文件丢失了; 从备份中挑选一份rdb去恢复master; 这样才能确保master启动的时候，是有数据的
    即使采用了后续讲解的高可用机制，slave node可以自动接管master node，但是也可能sentinal还没有检测到master failure，master node就自动重启了，还是可能导致上面的所有slave node数据清空故障

### 二、主从架构
###### 1、主从架构的核心原理
    当启动一个slave node的时候，它会发送一个PSYNC命令给master node
    
    如果这是slave node重新连接master node，那么master node仅仅会复制给slave部分缺少的数据; 否则如果是slave node第一次连接master node，那么会触发一次full resynchronization
    开始full resynchronization的时候，master会启动一个后台线程，开始生成一份RDB快照文件，同时还会将从客户端收到的所有写命令缓存在内存中。RDB文件生成完毕之后，master会将这个RDB发送给slave，slave会先写入本地磁盘，然后再从本地磁盘加载到内存中。然后master会将内存中缓存的写命令发送给slave，slave也会同步这些数据。
    
    slave node如果跟master node有网络故障，断开了连接，会自动重连。master如果发现有多个slave node都来重新连接，仅仅会启动一个rdb save操作，用一份数据服务所有slave node。

###### 2、主从复制的断点续传
    从redis 2.8开始，就支持主从复制的断点续传，如果主从复制过程中，网络连接断掉了，那么可以接着上次复制的地方，继续复制下去，而不是从头开始复制一份
    master node会在内存中常见一个backlog，master和slave都会保存一个replica offset还有一个master id，offset就是保存在backlog中的。如果master和slave网络连接断掉了，slave会让master从上次的replica offset开始继续复制
    但是如果没有找到对应的offset，那么就会执行一次full resynchronization

###### 3、无磁盘化复制

    master在内存中直接创建rdb，然后发送给slave，不会在自己本地落地磁盘了

    repl-diskless-sync
    repl-diskless-sync-delay，等待一定时长再开始复制，因为要等更多slave重新连接过来

###### 4、过期key处理
    slave不会过期key，只会等待master过期key。如果master过期了一个key，或者通过LRU淘汰了一个key，那么会模拟一条del命令发送给slave。

###### 5、完整复制过程
    （1）slave node启动，仅仅保存master node的信息，包括master node的host和ip，但是复制流程没开始
     master host和ip是从哪儿来的，redis.conf里面的slaveof配置的
    （2）slave node内部有个定时任务，每秒检查是否有新的master node要连接和复制，如果发现，就跟master node建立socket网络连接
    （3）slave node发送ping命令给master node
    （4）口令认证，如果master设置了requirepass，那么salve node必须发送masterauth的口令过去进行认证
    （5）master node第一次执行全量复制，将所有数据发给slave node
    （6）master node后续持续将写命令，异步复制给slave node

###### 6、数据同步相关的核心机制
    指的就是第一次slave连接msater的时候，执行的全量复制，那个过程里面你的一些细节的机制
    
    （1）master和slave都会维护一个offset
    
    master会在自身不断累加offset，slave也会在自身不断累加offset
    slave每秒都会上报自己的offset给master，同时master也会保存每个slave的offset
    
    这个倒不是说特定就用在全量复制的，主要是master和slave都要知道各自的数据的offset，才能知道互相之间的数据不一致的情况
    
    （2）backlog
    
    master node有一个backlog，默认是1MB大小
    master node给slave node复制数据时，也会将数据在backlog中同步写一份
    backlog主要是用来做全量复制中断候的增量复制的
    
    （3）master run id
    
    info server，可以看到master run id
    如果根据host+ip定位master node，是不靠谱的，如果master node重启或者数据出现了变化，那么slave node应该根据不同的run id区分，run id不同就做全量复制
    如果需要不更改run id重启redis，可以使用redis-cli debug reload命令
    
    （4）psync
    
    从节点使用psync从master node进行复制，psync runid offset
    master node会根据自身的情况返回响应信息，可能是FULLRESYNC runid offset触发全量复制，可能是CONTINUE触发增量复制

###### 7、全量复制
    （1）master执行bgsave，在本地生成一份rdb快照文件
    （2）master node将rdb快照文件发送给salve node，如果rdb复制时间超过60秒（repl-timeout），那么slave node就会认为复制失败，可以适当调节大这个参数
    （3）对于千兆网卡的机器，一般每秒传输100MB，6G文件，很可能超过60s
    （4）master node在生成rdb时，会将所有新的写命令缓存在内存中，在salve node保存了rdb之后，再将新的写命令复制给salve node
    （5）client-output-buffer-limit slave 256MB 64MB 60，如果在复制期间，内存缓冲区持续消耗超过64MB，或者一次性超过256MB，那么停止复制，复制失败
    （6）slave node接收到rdb之后，清空自己的旧数据，然后重新加载rdb到自己的内存中，同时基于旧的数据版本对外提供服务
    （7）如果slave node开启了AOF，那么会立即执行BGREWRITEAOF，重写AOF
    
    rdb生成、rdb通过网络拷贝、slave旧数据的清理、slave aof rewrite，很耗费时间
    
    如果复制的数据量在4G~6G之间，那么很可能全量复制时间消耗到1分半到2分钟

###### 8、增量复制
    （1）如果全量复制过程中，master-slave网络连接断掉，那么salve重新连接master时，会触发增量复制
    （2）master直接从自己的backlog中获取部分丢失的数据，发送给slave node，默认backlog就是1MB
    （3）msater就是根据slave发送的psync中的offset来从backlog中获取数据的

###### 9、heartbeat
    主从节点互相都会发送heartbeat信息
    master默认每隔10秒发送一次heartbeat，salve node每隔1秒发送一个heartbeat

###### 10、异步复制
    master每次接收到写命令之后，现在内部写入数据，然后异步发送给slave node    
    
### 三、读写分离
###### 1、一主一从
    在slave node上配置：slaveof 192.168.1.1 6379，即可
    
    也可以使用slaveof命令
    
    1、强制读写分离
    
    基于主从复制架构，实现读写分离
    
    redis slave node只读，默认开启，slave-read-only
    
    开启了只读的redis slave node，会拒绝所有的写操作，这样可以强制搭建成读写分离的架构
    
    2、集群安全认证
    
    master上启用安全认证，requirepass
    master连接口令，masterauth
    
    3、读写分离架构的测试
    
    先启动主节点，node01上的redis实例
    再启动从节点，node02上的redis实例
    
    redis slave node telnet 一直说没法连接到主节点的6379的端口
    
    在搭建生产环境的集群的时候，不要忘记修改一个配置，bind
    
    bind 127.0.0.1 -> 本地的开发调试的模式，就只能127.0.0.1本地才能访问到6379的端口
    
    每个redis.conf中的bind 127.0.0.1 -> bind自己的ip地址
    在每个节点上都: iptables -A INPUT -ptcp --dport  6379 -j ACCEPT
    
    redis-cli -h ipaddr
    info replication
    
    在主上写，在从上读    


### 四、水平扩容
    继续配置从节点
    
### 五、哨兵
###### 1、哨兵的介绍
    sentinal，中文名是哨兵
    哨兵是redis集群架构中非常重要的一个组件，主要功能如下
    
    （1）集群监控，负责监控redis master和slave进程是否正常工作
    （2）消息通知，如果某个redis实例有故障，那么哨兵负责发送消息作为报警通知给管理员
    （3）故障转移，如果master node挂掉了，会自动转移到slave node上
    （4）配置中心，如果故障转移发生了，通知client客户端新的master地址
    
    哨兵本身也是分布式的，作为一个哨兵集群去运行，互相协同工作
    
    （1）故障转移时，判断一个master node是宕机了，需要大部分的哨兵都同意才行，涉及到了分布式选举的问题
    （2）即使部分哨兵节点挂掉了，哨兵集群还是能正常工作的，因为如果一个作为高可用机制重要组成部分的故障转移系统本身是单点的，那就很坑爹了
    
    目前采用的是sentinal 2版本，sentinal 2相对于sentinal 1来说，重写了很多代码，主要是让故障转移的机制和算法变得更加健壮和简单
    
###### 2、哨兵的核心知识
    
    （1）哨兵至少需要3个实例，来保证自己的健壮性
    （2）哨兵 + redis主从的部署架构，是不会保证数据零丢失的，只能保证redis集群的高可用性
    （3）对于哨兵 + redis主从这种复杂的部署架构，尽量在测试环境和生产环境，都进行充足的测试和演练
    
###### 3、为什么redis哨兵集群只有2个节点无法正常工作？
    
    哨兵集群必须部署2个以上节点
    
    如果哨兵集群仅仅部署了个2个哨兵实例，quorum=1
    
    +----+         +----+
    | M1 |---------| R1 |
    | S1 |         | S2 |
    +----+         +----+
    
    Configuration: quorum = 1
    
    master宕机，s1和s2中只要有1个哨兵认为master宕机就可以还行切换，同时s1和s2中会选举出一个哨兵来执行故障转移
    
    同时这个时候，需要majority，也就是大多数哨兵都是运行的，2个哨兵的majority就是2（2的majority=2，3的majority=2，5的majority=3，4的majority=2），2个哨兵都运行着，就可以允许执行故障转移
    
    但是如果整个M1和S1运行的机器宕机了，那么哨兵只有1个了，此时就没有majority来允许执行故障转移，虽然另外一台机器还有一个R1，但是故障转移不会执行
    
###### 4、经典的3节点哨兵集群
    
           +----+
           | M1 |
           | S1 |
           +----+
              |
    +----+    |    +----+
    | R2 |----+----| R3 |
    | S2 |         | S3 |
    +----+         +----+
    
    Configuration: quorum = 2，majority
    
    如果M1所在机器宕机了，那么三个哨兵还剩下2个，S2和S3可以一致认为master宕机，然后选举出一个来执行故障转移
    
    同时3个哨兵的majority是2，所以还剩下的2个哨兵运行着，就可以允许执行故障转移
    
###### 5、两种数据丢失的情况

    主备切换的过程，可能会导致数据丢失
    
    （1）异步复制导致的数据丢失
    
    因为master -> slave的复制是异步的，所以可能有部分数据还没复制到slave，master就宕机了，此时这些部分数据就丢失了
    
    （2）脑裂导致的数据丢失
    
    脑裂，也就是说，某个master所在机器突然脱离了正常的网络，跟其他slave机器不能连接，但是实际上master还运行着
    
    此时哨兵可能就会认为master宕机了，然后开启选举，将其他slave切换成了master
    
    这个时候，集群里就会有两个master，也就是所谓的脑裂
    
    此时虽然某个slave被切换成了master，但是可能client还没来得及切换到新的master，还继续写向旧master的数据可能也丢失了
    
    因此旧master再次恢复的时候，会被作为一个slave挂到新的master上去，自己的数据会清空，重新从新的master复制数据


###### 6、解决异步复制和脑裂导致的数据丢失

    min-slaves-to-write 1
    min-slaves-max-lag 10
    
    要求至少有1个slave，数据复制和同步的延迟不能超过10秒
    
    如果说一旦所有的slave，数据复制和同步的延迟都超过了10秒钟，那么这个时候，master就不会再接收任何请求了
    
    上面两个配置可以减少异步复制和脑裂导致的数据丢失
    
    （1）减少异步复制的数据丢失
    
    有了min-slaves-max-lag这个配置，就可以确保说，一旦slave复制数据和ack延时太长，就认为可能master宕机后损失的数据太多了，那么就拒绝写请求，这样可以把master宕机时由于部分数据未同步到slave导致的数据丢失降低的可控范围内
    
    （2）减少脑裂的数据丢失
    
    如果一个master出现了脑裂，跟其他slave丢了连接，那么上面两个配置可以确保说，如果不能继续给指定数量的slave发送数据，而且slave超过10秒没有给自己ack消息，那么就直接拒绝客户端的写请求
    
    这样脑裂后的旧master就不会接受client的新数据，也就避免了数据丢失
    
    上面的配置就确保了，如果跟任何一个slave丢了连接，在10秒后发现没有slave给自己ack，那么就拒绝新的写请求
    
    因此在脑裂场景下，最多就丢失10秒的数据
    
###### 7、sdown和odown转换机制

    sdown和odown两种失败状态
    
    sdown是主观宕机，就一个哨兵如果自己觉得一个master宕机了，那么就是主观宕机
    
    odown是客观宕机，如果quorum数量的哨兵都觉得一个master宕机了，那么就是客观宕机
    
    sdown达成的条件很简单，如果一个哨兵ping一个master，超过了is-master-down-after-milliseconds指定的毫秒数之后，就主观认为master宕机
    
    sdown到odown转换的条件很简单，如果一个哨兵在指定时间内，收到了quorum指定数量的其他哨兵也认为那个master是sdown了，那么就认为是odown了，客观认为master宕机

###### 8、哨兵集群的自动发现机制

    哨兵互相之间的发现，是通过redis的pub/sub系统实现的，每个哨兵都会往__sentinel__:hello这个channel里发送一个消息，这时候所有其他哨兵都可以消费到这个消息，并感知到其他的哨兵的存在
    
    每隔两秒钟，每个哨兵都会往自己监控的某个master+slaves对应的__sentinel__:hello channel里发送一个消息，内容是自己的host、ip和runid还有对这个master的监控配置
    
    每个哨兵也会去监听自己监控的每个master+slaves对应的__sentinel__:hello channel，然后去感知到同样在监听这个master+slaves的其他哨兵的存在
    
    每个哨兵还会跟其他哨兵交换对master的监控配置，互相进行监控配置的同步

###### 9、slave配置的自动纠正

    哨兵会负责自动纠正slave的一些配置，比如slave如果要成为潜在的master候选人，哨兵会确保slave在复制现有master的数据; 如果slave连接到了一个错误的master上，比如故障转移之后，那么哨兵会确保它们连接到正确的master上

###### 10、slave->master选举算法

    如果一个master被认为odown了，而且majority哨兵都允许了主备切换，那么某个哨兵就会执行主备切换操作，此时首先要选举一个slave来
    
    会考虑slave的一些信息
    
    （1）跟master断开连接的时长
    （2）slave优先级
    （3）复制offset
    （4）run id
    
    如果一个slave跟master断开连接已经超过了down-after-milliseconds的10倍，外加master宕机的时长，那么slave就被认为不适合选举为master
    
    (down-after-milliseconds * 10) + milliseconds_since_master_is_in_SDOWN_state
    
    接下来会对slave进行排序
    
    （1）按照slave优先级进行排序，slave priority越低，优先级就越高
    （2）如果slave priority相同，那么看replica offset，哪个slave复制了越多的数据，offset越靠后，优先级就越高
    （3）如果上面两个条件都相同，那么选择一个run id比较小的那个slave

###### 11、quorum和majority

    每次一个哨兵要做主备切换，首先需要quorum数量的哨兵认为odown，然后选举出一个哨兵来做切换，这个哨兵还得得到majority哨兵的授权，才能正式执行切换
    
    如果quorum < majority，比如5个哨兵，majority就是3，quorum设置为2，那么就3个哨兵授权就可以执行切换
    
    但是如果quorum >= majority，那么必须quorum数量的哨兵都授权，比如5个哨兵，quorum是5，那么必须5个哨兵都同意授权，才能执行切换

###### 11、configuration epoch

    哨兵会对一套redis master+slave进行监控，有相应的监控的配置
    
    执行切换的那个哨兵，会从要切换到的新master（salve->master）那里得到一个configuration epoch，这就是一个version号，每次切换的version号都必须是唯一的
    
    如果第一个选举出的哨兵切换失败了，那么其他哨兵，会等待failover-timeout时间，然后接替继续执行切换，此时会重新获取一个新的configuration epoch，作为新的version号

###### 12、configuraiton传播

    哨兵完成切换之后，会在自己本地更新生成最新的master配置，然后同步给其他的哨兵，就是通过之前说的pub/sub消息机制
    
    这里之前的version号就很重要了，因为各种消息都是通过一个channel去发布和监听的，所以一个哨兵完成一次新的切换之后，新的master配置是跟着新的version号的
    
    其他的哨兵都是根据版本号的大小来更新自己的master配置的
    
###### 13、哨兵的配置文件

    sentinel.conf
    
    最小的配置
    
    每一个哨兵都可以去监控多个maser-slaves的主从架构
    
    因为可能你的公司里，为不同的项目，部署了多个master-slaves的redis主从集群
    
    相同的一套哨兵集群，就可以去监控不同的多个redis主从集群
    
    你自己给每个redis主从集群分配一个逻辑的名称
    
    sentinel monitor mymaster 127.0.0.1 6379 2
    sentinel down-after-milliseconds mymaster 60000
    sentinel failover-timeout mymaster 180000
    sentinel parallel-syncs mymaster 1
    
    sentinel monitor resque 192.168.1.3 6380 4
    sentinel down-after-milliseconds resque 10000
    sentinel failover-timeout resque 180000
    sentinel parallel-syncs resque 5
    
    sentinel monitor mymaster 127.0.0.1 6379 
    
    类似这种配置，来指定对一个master的监控，给监控的master指定的一个名称，因为后面分布式集群架构里会讲解，可以配置多个master做数据拆分
    
    sentinel down-after-milliseconds mymaster 60000
    sentinel failover-timeout mymaster 180000
    sentinel parallel-syncs mymaster 1
    
    上面的三个配置，都是针对某个监控的master配置的，给其指定上面分配的名称即可
    
    上面这段配置，就监控了两个master node
    
    这是最小的哨兵配置，如果发生了master-slave故障转移，或者新的哨兵进程加入哨兵集群，那么哨兵会自动更新自己的配置文件
    
    sentinel monitor master-group-name hostname port quorum
    
    quorum的解释如下：
    
    （1）至少多少个哨兵要一致同意，master进程挂掉了，或者slave进程挂掉了，或者要启动一个故障转移操作
    （2）quorum是用来识别故障的，真正执行故障转移的时候，还是要在哨兵集群执行选举，选举一个哨兵进程出来执行故障转移操作
    （3）假设有5个哨兵，quorum设置了2，那么如果5个哨兵中的2个都认为master挂掉了; 2个哨兵中的一个就会做一个选举，选举一个哨兵出来，执行故障转移; 如果5个哨兵中有3个哨兵都是运行的，那么故障转移就会被允许执行
    
    down-after-milliseconds，超过多少毫秒跟一个redis实例断了连接，哨兵就可能认为这个redis实例挂了
    
    parallel-syncs，新的master别切换之后，同时有多少个slave被切换到去连接新master，重新做同步，数字越低，花费的时间越多
    
    假设你的redis是1个master，4个slave
    
    然后master宕机了，4个slave中有1个切换成了master，剩下3个slave就要挂到新的master上面去
    
    这个时候，如果parallel-syncs是1，那么3个slave，一个一个地挂接到新的master上面去，1个挂接完，而且从新的master sync完数据之后，再挂接下一个
    
    如果parallel-syncs是3，那么一次性就会把所有slave挂接到新的master上去
    
    failover-timeout，执行故障转移的timeout超时时长
    
###### 14、正式的配置

    哨兵默认用26379端口，默认不能跟其他机器在指定端口连通，只能在本地访问
    
    mkdir /etc/sentinal
    mkdir -p /var/sentinal/5000
    
    /etc/sentinel/5000.conf
    
    port 5000
    bind 192.168.31.205
    dir /var/sentinal/5000
    sentinel monitor mymaster 192.168.31.205 6379 2
    sentinel down-after-milliseconds mymaster 30000
    sentinel failover-timeout mymaster 60000
    sentinel parallel-syncs mymaster 1
    
    port 5000
    bind 192.168.31.206
    dir /var/sentinal/5000
    sentinel monitor mymaster 192.168.31.206 6379 2
    sentinel down-after-milliseconds mymaster 30000
    sentinel failover-timeout mymaster 60000
    sentinel parallel-syncs mymaster 1
    
    port 5000
    bind 192.168.31.206
    dir /var/sentinal/5000
    sentinel monitor mymaster 192.168.31.187 206 2
    sentinel down-after-milliseconds mymaster 30000
    sentinel failover-timeout mymaster 60000
    sentinel parallel-syncs mymaster 1

###### 15、启动哨兵进程

    在node01、node02、node03三台机器上，分别启动三个哨兵进程，组成一个集群，观察一下日志的输出
    
    redis-sentinel /etc/sentinal/5000.conf
    redis-server /etc/sentinal/5000.conf --sentinel
    
    日志里会显示出来，每个哨兵都能去监控到对应的redis master，并能够自动发现对应的slave
    
    哨兵之间，互相会自动进行发现，用的就是之前说的pub/sub，消息发布和订阅channel消息系统和机制

###### 16、检查哨兵状态

    redis-cli -h 192.168.31.205 -p 5000
    
    sentinel master mymaster
    SENTINEL slaves mymaster
    SENTINEL sentinels mymaster
    
    SENTINEL get-master-addr-by-name mymaster

###### 17、哨兵节点的增加和删除

    增加sentinal，会自动发现
    
    删除sentinal的步骤
    
    （1）停止sentinal进程
    （2）SENTINEL RESET *，在所有sentinal上执行，清理所有的master状态
    （3）SENTINEL MASTER mastername，在所有sentinal上执行，查看所有sentinal对数量是否达成了一致

###### 18、slave的永久下线

让master摘除某个已经下线的slave：SENTINEL RESET mastername，在所有的哨兵上面执行

###### 19、slave切换为Master的优先级

    slave->master选举优先级：slave-priority，值越小优先级越高

###### 20、基于哨兵集群架构下的安全认证

    每个slave都有可能切换成master，所以每个实例都要配置两个指令

    master上启用安全认证，requirepass
    master连接口令，masterauth

    sentinal，sentinel auth-pass <master-group-name> <pass>
    
###### 21、容灾演练
    
    通过哨兵看一下当前的master：SENTINEL get-master-addr-by-name mymaster
    
    把master节点kill -9掉，pid文件也删除掉
    
    查看sentinal的日志，是否出现+sdown字样，识别出了master的宕机问题; 然后出现+odown字样，就是指定的quorum哨兵数量，都认为master宕机了
    
    （1）三个哨兵进程都认为master是sdown了
    （2）超过quorum指定的哨兵进程都认为sdown之后，就变为odown
    （3）哨兵1是被选举为要执行后续的主备切换的那个哨兵
    （4）哨兵1去新的master（slave）获取了一个新的config version
    （5）尝试执行failover
    （6）投票选举出一个slave区切换成master，每隔哨兵都会执行一次投票
    （7）让salve，slaveof noone，不让它去做任何节点的slave了; 把slave提拔成master; 旧的master认为不再是master了
    （8）哨兵就自动认为之前的205:6379变成了slave了，206:6379变成了master了
    （9）哨兵去探查了一下205:6379这个salve的状态，认为它sdown了
    
    所有哨兵选举出了一个，来执行主备切换操作
    
    如果哨兵的majority都存活着，那么就会执行主备切换操作
    
    再通过哨兵看一下master：SENTINEL get-master-addr-by-name mymaster
    
    尝试连接一下新的master
    
    故障恢复，再将旧的master重新启动，查看是否被哨兵自动切换成slave节点
    
    （1）手动杀掉master
    （2）哨兵能否执行主备切换，将slave切换为master
    （3）哨兵完成主备切换后，新的master能否使用
    （4）故障恢复，将旧的master重新启动
    （5）哨兵能否自动将旧的master变为slave，挂接到新的master上面去，而且也是可以使用的
    
###### 22、、哨兵的生产环境部署
    
    daemonize yes
    logfile /var/log/sentinel/5000/sentinel.log
    
    mkdir -p /var/log/sentinel/5000