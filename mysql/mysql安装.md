###### 1、下载：
    wget https://dev.mysql.com/get/Downloads/MySQL-5.7/mysql-5.7.28-linux-glibc2.12-x86_64.tar.gz
    
###### 2、解压：
    tar -zxvf mysql-5.7.28-linux-glibc2.12-x86_64.tar.gz

###### 3、修改目录：
    mv mysql-5.7.28-linux-glibc2.12-x86_64/ mysql/
    
###### 4、新建data目录
    mkdir -p /usr/local/kevin/mysql/data

###### 5、创建用户组和用户：
    groupadd mysql
    useradd mysql -g mysql
    
###### 6、将/usr/local/mysql的所有者及所属组改为mysql：
    chown -R mysql.mysql /usr/local/kevin/mysql/

###### 7、开始初始化：
    ./bin/mysqld --initialize --user=mysql --basedir=/usr/local/kevin/mysql --datadir=/usr/local/kevin/mysql/data/
    
    报错：
    ./bin/mysqld: error while loading shared libraries: libnuma.so.1: cannot open shared object file: No such file or directory
    
    解决：
    yum -y install numactl
    
###### 8、再次初始化
    2019-10-16T11:16:41.596568Z 0 [Warning] TIMESTAMP with implicit DEFAULT value is deprecated. Please use --explicit_defaults_for_timestamp server option (see documentation for more details).
    2019-10-16T11:16:42.731168Z 0 [Warning] InnoDB: New log files created, LSN=45790
    2019-10-16T11:16:42.901356Z 0 [Warning] InnoDB: Creating foreign key constraint system tables.
    2019-10-16T11:16:42.970920Z 0 [Warning] No existing UUID has been found, so we assume that this is the first time that this server has been started. Generating a new UUID: 6ebaae15-f006-11e9-ae24-0050562049f5.
    2019-10-16T11:16:42.973333Z 0 [Warning] Gtid table is not ready to be used. Table 'mysql.gtid_executed' cannot be opened.
    2019-10-16T11:16:43.257389Z 0 [Warning] CA certificate ca.pem is self signed.
    2019-10-16T11:16:43.404179Z 1 [Note] A temporary password is generated for root@localhost: 1=lbygykxLzT

###### 9、vim /etc/my.cnf
    [mysqld]
    datadir=/usr/local/kevin/mysql/data
    basedir=/usr/local/kevin/mysql
    socket=/usr/local/kevin/mysql/tmp/mysql.sock
    user=mysql
    port=3306
    # Disabling symbolic-links is recommended to prevent assorted security risks
    symbolic-links=0
    
    [mysqld_safe]
    log-error=/var/log/mysqld.log
    pid-file=/var/run/mysqld/mysqld.pid

##### 注意:完整 my.cnf
    [mysqld]
    datadir=/usr/local/kevin/mysql/data
    basedir=/usr/local/kevin/mysql
    socket=/usr/local/kevin/mysql/tmp/mysql.sock
    user=mysql
    port=3306
    # Disabling symbolic-links is recommended to prevent assorted security risks
    symbolic-links=0
    
    [client]
    socket=/usr/local/kevin/mysql/tmp/mysql.sock
    
    [mysqld_safe]
    log-error=/var/log/mysqld.log
    pid-file=/var/run/mysqld/mysqld.pid
    
    
###### 10、加入服务
    cp /usr/local/kevin/mysql/support-files/mysql.server /etc/init.d/mysql

###### 11、启动服务
    service mysql start
    
    报错：
    Starting MySQL... ERROR! The server quit without updating PID file (/usr/local/kevin/mysql/data/kevin.pid).

    解决：查看错误日志/var/log/mysqld.log发现
    [ERROR] Could not create unix socket lock file /var/lib/mysql/mysql.sock.lock.
    2019-10-16T11:29:57.175227Z 0 [ERROR] Unable to setup unix socket lock file.
    2019-10-16T11:29:57.175235Z 0 [ERROR] Aborting
    
    修改：vim/etc/my.cnf
    socket=/usr/local/kevin/mysql/tmp/mysql.sock
    
    创建目录，然后赋予mysql用户权限
    mkdir -p /usr/local/kevin/mysql/tmp
    chown -R mysql.mysql /usr/local/kevin/mysql/
    
###### 12、客户端访问
    ./bin/mysql -u root -p
    
    报错：
    ERROR 2002 (HY000): Can't connect to local MySQL server through socket '/tmp/mysql.sock' (2)
    
    解决：
    vim /etc/my.cnf
    [client]
    socket=/usr/local/kevin/mysql/tmp/mysql.sock
    
###### 13、设置密码
    use mysql;
    update user set authentication_string=password('123456') where user='root';
    flush privileges;
    
###### 14、允许远程连接
    use mysql;
    update user set host='%' where user = 'root';
    flush privileges;
    
###### 报错：ERROR 1820 (HY000): You must reset your password using ALTER USER statement before executing this statement.
    原因：MySQL版本5.6.6版本起，添加了password_expired功能，它允许设置用户的过期时间。这个特性已经添加到mysql.user数据表，但是它的默认值是”N”，可以使用ALTER USER语句来修改这个值。此时，用户可以登录到MYSQL服务器，但是在用户为设置新密码之前，不能运行任何命令，就会得到上图的报错，修改密码即可正常运行账户权限内的所有命令。由于此版本密码过期天数无法通过命令来实现，所以DBA可以通过cron定时器任务来设置MySQL用户的密码过期时间。
     MySQL版本5.7.6版本以前用户可以使用如下命令：
     SET PASSWORD = PASSWORD('123456'); 
     
     MySQL版本5.7.6版本开始的用户可以使用如下命令：
     ALTER USER 'root'@'localhost' IDENTIFIED BY '123456';
     
#####  MySQL 5.7.4版开始，用户的密码过期时间这个特性得以改进，可以通过一个全局变量default_password_lifetime来设置密码过期的策略，此全局变量可以设置一个全局的自动密码过期策略。可以在MySQL的my.cnf配置文件中设置一个默认值，这会使得所有MySQL用户的密码过期时间都为120天，MySQL会从启动时开始计算时间。
    [mysqld]
    default_password_lifetime=120
    
#####  如果要设置密码永不过期，my.cnf配置如下：
    [mysqld]
    default_password_lifetime=0
    
##### 输入以下命令，将账号密码强制到期：
    ALTER USER 'root'@'localhost' PASSWORD EXPIRE;    

##### 如果要为每个具体的用户账户设置单独的特定值，可以使用以下命令完成（注意：此命令会覆盖全局策略），单位是“天”，命令如下：
    ALTER USER 'root'@'localhost' PASSWORD EXPIRE INTERVAL 250 DAY;
    
##### 如果让用户恢复默认策略，命令如下：
    ALTER USER 'root'@'localhost' PASSWORD EXPIRE DEFAULT;
    
##### 个别使用者为了后期麻烦，会将密码过期功能禁用，命令如下：
    ALTER USER 'root'@'localhost' PASSWORD EXPIRE NEVER;
