# redis备份

### 1、企业级的持久化的配置策略
    在企业中，RDB的生成策略，用默认的也差不多（看具体业务量）
    save 60 10000：如果你希望尽可能确保说，RDB最多丢1分钟的数据，那么尽量就是每隔1分钟都生成一个快照，低峰期，数据量很少，也没必要
    10000->生成RDB，1000->RDB，这个根据你自己的应用和业务的数据量，你自己去决定
    AOF一定要打开，fsync，everysec
    auto-aof-rewrite-percentage 100: 就是当前AOF大小膨胀到超过上次100%，上次的两倍
    auto-aof-rewrite-min-size 64mb: 根据你的数据量来定，16mb，32mb

### 2、企业级的数据备份方案
    
    RDB非常适合做冷备，每次生成之后，就不会再有修改了
    数据备份方案
    （1）写crontab定时调度脚本去做数据备份
    （2）每小时都copy一份rdb的备份，到一个目录中去，仅仅保留最近48小时的备份
     -----------------------------------------------------------------------------    
         crontab -e 
         0 * * * * sh /usr/local/redis/copy/redis_rdb_copy_hourly.sh
         
         redis_rdb_copy_hourly.sh
         
         #!/bin/sh 
         
         cur_date=`date +%Y%m%d%k`
         rm -rf /usr/local/redis/snapshotting/$cur_date
         mkdir /usr/local/redis/snapshotting/$cur_date
         cp /var/redis/6379/dump.rdb /usr/local/redis/snapshotting/$cur_date
         
         del_date=`date -d -48hour +%Y%m%d%k`
         rm -rf /usr/local/redis/snapshotting/$del_date
      -----------------------------------------------------------------------------      
            
    （3）每天都保留一份当日的rdb的备份，到一个目录中去，仅仅保留最近1个月的备份
    ----------------------------------------------------------------------------- 
        crontab -e 
        0 0 * * * sh /usr/local/redis/copy/redis_rdb_copy_daily.sh
        
        redis_rdb_copy_daily.sh
        
        #!/bin/sh 
        
        cur_date=`date +%Y%m%d`
        rm -rf /usr/local/redis/snapshotting/$cur_date
        mkdir /usr/local/redis/snapshotting/$cur_date
        cp /var/redis/6379/dump.rdb /usr/local/redis/snapshotting/$cur_date
        
        del_date=`date -d -1month +%Y%m%d`
        rm -rf /usr/local/redis/snapshotting/$del_date
    ----------------------------------------------------------------------------- 
    （4）每次copy备份的时候，都把太旧的备份给删了
    （5）每天晚上将当前服务器上所有的数据备份，发送一份到远程的云服务上去

### 3、数据恢复方案

    （1）如果是redis进程挂掉，那么重启redis进程即可，直接基于AOF日志文件恢复数据
    
    （2）如果是redis进程所在机器挂掉，那么重启机器后，尝试重启redis进程，尝试直接基于AOF日志文件进行数据恢复
     AOF没有破损，也是可以直接基于AOF恢复的
     AOF append-only，顺序写入，如果AOF文件破损，那么用redis-check-aof fix
    
    （3）如果redis当前最新的AOF和RDB文件出现了丢失/损坏，那么可以尝试基于该机器上当前的某个最新的RDB数据副本进行数据恢复
     当前最新的AOF和RDB文件都出现了丢失/损坏到无法恢复，一般不是机器的故障，人为
     大数据系统，hadoop，有人不小心就把hadoop中存储的大量的数据文件对应的目录，rm -rf一下，我朋友的一个小公司，运维不太靠谱，权限也弄的不太好
     /var/redis/6379下的文件给删除了
     找到RDB最新的一份备份，小时级的备份可以了，小时级的肯定是最新的，copy到redis里面去，就可以恢复到某一个小时的数据   
     appendonly.aof + dump.rdb，优先用appendonly.aof去恢复数据，但是我们发现redis自动生成的appendonly.aof是没有数据的
     然后我们自己的dump.rdb是有数据的，但是明显没用我们的数据
     redis启动的时候，自动重新基于内存的数据，生成了一份最新的rdb快照，直接用空的数据，覆盖掉了我们有数据的，拷贝过去的那份dump.rdb
     你停止redis之后，其实应该先删除appendonly.aof，然后将我们的dump.rdb拷贝过去，然后再重启redis
     很简单，就是虽然你删除了appendonly.aof，但是因为打开了aof持久化，redis就一定会优先基于aof去恢复，即使文件不在，那就创建一个新的空的aof文件
     停止redis，暂时在配置中关闭aof，然后拷贝一份rdb过来，再重启redis，数据能不能恢复过来，可以恢复过来
     脑子一热，再关掉redis，手动修改配置文件，打开aof，再重启redis，数据又没了，空的aof文件，所有数据又没了
     在数据安全丢失的情况下，基于rdb冷备，如何完美的恢复数据，同时还保持aof和rdb的双开
     停止redis，关闭aof，拷贝rdb备份，重启redis，确认数据恢复，直接在命令行热修改redis配置，打开aof，这个redis就会将内存中的数据对应的日志，写入aof文件中
     此时aof和rdb两份数据文件的数据就同步了
     redis config set热修改配置参数，可能配置文件中的实际的参数没有被持久化的修改，再次停止redis，手动修改配置文件，打开aof的命令，再次重启redis  
    
     （4）如果当前机器上的所有RDB文件全部损坏，那么从远程的云服务上拉取最新的RDB快照回来恢复数据
     
     （5）如果是发现有重大的数据错误，比如某个小时上线的程序一下子将数据全部污染了，数据全错了，那么可以选择某个更早的时间点，对数据进行恢复
    