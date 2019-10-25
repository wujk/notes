# redis安装

### 1、下载
    wget http://download.redis.io/releases/redis-5.0.3.tar.gz

### 2、解压
    tar xzf redis-5.0.3.tar.gz

### 3、进入安装目录
    cd redis-5.0.3

### 4、编译
    make
    make test
    make install
###### 报错
    You need tcl 8.5 or newer in order to run the Redis test
    make[1]: *** [test] 错误 1
    make[1]: Leaving directory `/usr/local/wujk/redis-5.0.5/src'
    make: *** [test] 错误 2
###### 解决
    wget http://downloads.sourceforge.net/tcl/tcl8.6.1-src.tar.gz
    tar -xzvf tcl8.6.1-src.tar.gz
    cd  /usr/local/tcl8.6.1/unix/
    ./configure  
    make && make install

### 5、修改配置文件redis.conf
    bind 127.0.0.1 (指定访问地址：不写则所有ip均可访问)
    daemonize yes  yes后台开启，no则显式开启 
    requirepass 123456 开启密码（3.2后新增protected-mode配置，默认是yes，即开启。解决方法分为两种：1、关闭protected-mode模式  2、配置bind或者设置密码）

### 6、启动redis
    进入src目录
    redis-server redis.conf指定配置文件

### 7、连接redis
    redis-cli -h 192.168.140.215 -p 6379 -a "pass" -n 6
    
# redis的生产环境启动方案
###  如果一般的学习课程，你就随便用redis-server启动一下redis，做一些实验，这样的话，没什么意义要把redis作为一个系统的daemon进程去运行的，每次系统启动，redis进程一起启动
    
    （1）redis utils目录下，有个redis_init_script脚本
    （2）将redis_init_script脚本拷贝到linux的/etc/init.d目录中，将redis_init_script重命名为redis_6379，6379是我们希望这个redis实例监听的端口号
    （3）修改redis_6379脚本的第6行的REDISPORT，设置为相同的端口号（默认就是6379）
    （4）创建两个目录：/etc/redis（存放redis的配置文件），/var/redis/6379（存放redis的持久化文件）
    （5）修改redis配置文件（默认在根目录下，redis.conf），拷贝到/etc/redis目录中，修改名称为6379.conf
    （6）修改redis.conf中的部分配置为生产环境
  
     daemonize	yes							让redis以daemon进程运行
     pidfile	/var/run/redis_6379.pid 	设置redis的pid文件位置
     port		6379						设置redis的监听端口号
     dir 		/var/redis/6379				设置持久化文件的存储位置
  
    （7）启动redis，执行cd /etc/init.d, chmod 777 redis_6379，./redis_6379 start
    （8）确认redis进程是否启动，ps -ef | grep redis
    （9）让redis跟随系统启动自动启动
     在redis_6379脚本中，最上面，加入两行注释  
     # chkconfig:   2345 90 10
     # description:  Redis is a persistent key-value database
     chkconfig redis_6379 on
     
# redis cli的使用
      
    redis-cli SHUTDOWN，连接本机的6379端口停止redis进程
  
    redis-cli -h 127.0.0.1 -p 6379 SHUTDOWN，制定要连接的ip和端口号
  
    redis-cli PING，ping redis的端口，看是否正常
  
    redis-cli，进入交互式命令行
	