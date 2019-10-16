#### 192.168.140.77 主库
#### 192.168.140.159 从库     

# 配置主库
###### 1、master 节点配置
    vim /etc/my.cnf
    
    [mysqld]
    datadir=/usr/local/kevin/mysql/data
    basedir=/usr/local/kevin/mysql
    socket=/usr/local/kevin/mysql/tmp/mysql.sock
    user=mysql
    port=3306
    # Disabling symbolic-links is recommended to prevent assorted security risks
    symbolic-links=0
    
    #server-id给数据库服务的唯一标识,在从库必须设置为不同的值。
    server-id=1
    
    #log-bin设置此参数表示启用binlog功能，并指定路径名称
    log-bin=/usr/local/kevin/mysql/mysql-bin
    sync_binlog=0
    
    # 设置日志的过期天数
    expire_logs_days=7
    
    # 指定需要同步的数据库
    binlog-do-db=cool
    binlog-do-db=cool2
    
    #表示同步的时候忽略的数据库
    binlog-ignore-db=information_schema
    binlog-ignore-db=sys
    binlog-ignore-db=mysql
    binlog-ignore-db=performance_schema
    
    [client]
    socket=/usr/local/kevin/mysql/tmp/mysql.sock
    
    [mysqld_safe]
    log-error=/var/log/mysqld.log
    pid-file=/var/run/mysqld/mysqld.pid
    
##### 2、重启mysql
    service mysql restart
    
##### 3、登录master客户端，赋予从库权限账号，允许用户在主库上读取日志，赋予192.168.140.159也就是Slave机器有File权限
    grant FILE on *.* to 'root'@'192.168.140.159' identified by '123456';
    grant replication slave on *.* to 'root'@'192.168.140.159' identified by '123456';
    flush privileges;
    
##### 4、重启mysql
    service mysql restart
    
##### 5、登录
    show master status;
    
    File: mysql-bin.000002
    Position: 154
    Binlog_Do_DB: cool,cool2
    Binlog_Ignore_DB: information_schema,sys,mysql,performance_schema
    Executed_Gtid_Set:
    

# 配置从库
###### 1、slave 节点配置
    vim /etc/my.cnf
    
    basedir=/usr/local/kevin/mysql
    socket=/usr/local/kevin/mysql/tmp/mysql.sock
    user=mysql
    port=3306
    
    # Disabling symbolic-links is recommended to prevent assorted security risks
    symbolic-links=0
    
    server-id=2
    
    log-bin=/usr/local/kevin/mysql/mysql-bin
    
    binlog-ignore-db=information_schema
    binlog-ignore-db=sys
    binlog-ignore-db=mysql
    binlog-ignore-db=performance_schema
    
    replicate-ignore-db=information_schema
    replicate-ignore-db=sys
    replicate-ignore-db=mysql
    replicate-ignore-db=performance_schema
    
    
    replicate-do-db=cool
    replicate-do-db=cool2
    
    log-slave-updates
    slave-skip-errors=all
    slave-net-timeout=60
    
    [client]
    socket=/usr/local/kevin/mysql/tmp/mysql.sock
    
    [mysqld_safe]
    log-error=/var/log/mysqld.log
    pid-file=/var/run/mysqld/mysqld.pid
    
##### 2、重启mysql
    service mysql restart
    

##### 3、登录slave客户端，执行下面操作：
    stop slave;
    change master to master_host='192.168.140.77',master_user='root',master_password='123456',master_log_file='mysql-bin.000002', master_log_pos=154;
    start slave;
   
    注意：上面的master_log_file是在Master中show master status显示的File，
    而master_log_pos是在Master中show master status显示的Position。
    
##### 4、查看从节点：
    show master status;
    
     Slave_IO_State: Waiting for master to send event
                      Master_Host: 192.168.140.77
                      Master_User: root
                      Master_Port: 3306
                    Connect_Retry: 60
                  Master_Log_File: mysql-bin.000002
              Read_Master_Log_Pos: 154
                   Relay_Log_File: kevin-relay-bin.000002
                    Relay_Log_Pos: 320
            Relay_Master_Log_File: mysql-bin.000002
                 Slave_IO_Running: Yes
                Slave_SQL_Running: Yes
                  Replicate_Do_DB: cool,cool2
              Replicate_Ignore_DB: information_schema,sys,mysql,performance_schema
               Replicate_Do_Table:
           Replicate_Ignore_Table:
          Replicate_Wild_Do_Table:
      Replicate_Wild_Ignore_Table:
                       Last_Errno: 0
                       Last_Error:
                     Skip_Counter: 0
              Exec_Master_Log_Pos: 154
                  Relay_Log_Space: 527
                  Until_Condition: None
                   Until_Log_File:
                    Until_Log_Pos: 0
               Master_SSL_Allowed: No
               Master_SSL_CA_File:
               Master_SSL_CA_Path:
                  Master_SSL_Cert:
                Master_SSL_Cipher:
                   Master_SSL_Key:
            Seconds_Behind_Master: 0
    Master_SSL_Verify_Server_Cert: No
                    Last_IO_Errno: 0
                    Last_IO_Error:
                   Last_SQL_Errno: 0
                   Last_SQL_Error:
      Replicate_Ignore_Server_Ids:
                 Master_Server_Id: 1
                      Master_UUID: dbbd5989-f008-11e9-8309-0050562049f5
                 Master_Info_File: /usr/local/kevin/mysql/data/master.info
                        SQL_Delay: 0
              SQL_Remaining_Delay: NULL
          Slave_SQL_Running_State: Slave has read all relay log; waiting for more updates
               Master_Retry_Count: 86400
                      Master_Bind:
          Last_IO_Error_Timestamp:
         Last_SQL_Error_Timestamp:
                   Master_SSL_Crl:
               Master_SSL_Crlpath:
               Retrieved_Gtid_Set:
                Executed_Gtid_Set:
                    Auto_Position: 0
             Replicate_Rewrite_DB:
                     Channel_Name:
               Master_TLS_Version:
               
##### Slave_IO_Running: Yes和Slave_SQL_Running: Yes，证明成功。

##### 配置第二个从库的时候，需要重新从matser获取File和position。
    
    
    



    
    

