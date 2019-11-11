# 安装kafka

### 1、下载

### 2、解压
    tar -zxvf kafka_2.12-2.3.0.tgz
    mv kafka_2.12-2.3.0 kafka
    
### 3、配置kafka
    vim /usr/local/wujk/kafka/config/server.properties
    broker.id：依次增长的整数，0、1、2，集群中Broker的唯一id
    zookeeper.connect=192.168.31.205:2181,192.168.31.206:2181,192.168.31.207:2181
    
### 4、安装slf4j

    把slf4j中的slf4j-nop-1.7.26.jar复制到kafka的libs目录下面

### 5、解决kafka Unrecognized VM option 'UseCompressedOops'问题

    vi /usr/local/wujk/kafka/bin/kafka-run-class.sh 
    
    if [ -z "$KAFKA_JVM_PERFORMANCE_OPTS" ]; then
      KAFKA_JVM_PERFORMANCE_OPTS="-server  -XX:+UseCompressedOops -XX:+UseParNewGC -XX:+UseConcMarkSweepGC -XX:+CMSClassUnloadingEnabled -XX:+CMSScavengeBeforeRemark -XX:+DisableExplicitGC -Djava.awt.headless=true"
    fi
    
    去掉-XX:+UseCompressedOops即可

### 6、按照上述步骤在另外两台机器分别安装kafka
    唯一区别的，就是server.properties中的broker.id，要设置为1和2
    
    在三台机器上的kafka目录下，分别执行以下命令：nohup /usr/local/wujk/kafka/bin/kafka-server-start.sh config/server.properties >/dev/null 2>&1 &

    使用jps检查启动是否成功

### 7、使用基本命令检查kafka是否搭建成功
    
    bin/kafka-topics.sh --zookeeper 192.168.31.205:2181,192.168.31.206:2181,192.168.31.207:2181 --topic test --replication-factor 1 --partitions 1 --create
    
    bin/kafka-console-producer.sh --broker-list 192.168.31.205:9092,192.168.31.206:9092,192.168.31.207:9092 --topic test
    
    老版本：
    bin/kafka-console-consumer.sh --zookeeper 192.168.31.205:2181,192.168.31.206:2181,192.168.31.207:2181 --topic test --from-beginning
    
    新版本：
    bin/kafka-console-consumer.sh --bootstrap-server 192.168.31.205:9092,192.168.31.206:9092,192.168.31.207:9092 --topic test --from-beginning