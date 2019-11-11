# storm安装
#### 安装storm-2.1.0：
    Java 8+ (Apache Storm 2.x is tested through travis ci against a java 8 JDK)
    Python 2.6.6  (Python 3.x should work too, but is not tested as part of our CI enviornment)
    
#### 1、下载
    wget https://mirrors.tuna.tsinghua.edu.cn/apache/storm/apache-storm-2.1.0/apache-storm-2.1.0.tar.gz

#### 2、修改配置 （创建目录：mkdir -p /var/storm）
    storm.zookeeper.servers:
    	- "192.168.31.205"
    	- "192.168.31.206"
    	- "192.168.31.207"
    
    nimbus.seeds: ["192.168.31.205"]
    
    supervisor.slots.ports:
        - 6700
        - 6701
        - 6702
        - 6703
    
    storm.local.dir: "/var/storm"
    
    storm.health.check.dir: "healthchecks"
    
    storm.health.check.timeout.ms: 5000
  

#### 3、启动
    一个节点，storm nimbus >/dev/null 2>&1 &
    三个节点，storm supervisor >/dev/null 2>&1 &
    一个nimbus节点，storm ui >/dev/null 2>&1 &
    在两个supervisor节点，storm logviewer >/dev/null 2>&1 &
    