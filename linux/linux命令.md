# linux 常用命令
#####  查看linux系统的CPU型号、类型以及大小
    cat /proc/cpuinfo

##### 查看linux系统内存大小的详细信息，可以查看总内存，剩余内存、可使用内存等信息
    cat /proc/meminfo  
      
##### 查看linux系统各分区的使用情况
    df -h 
    
##### 查看linux系统内存使用量和交换区使用量
    free -m 
    
##### linux 查看端口
    netstat命令参数：
    　　-t : 指明显示TCP端口
    　　-u : 指明显示UDP端口
    　　-l : 仅显示监听套接字(所谓套接字就是使应用程序能够读写与收发通讯协议(protocol)与资料的程序)
    　　-p : 显示进程标识符和程序名称，每一个套接字/端口都属于一个程序。
    　　-n : 不进行DNS轮询，显示IP(可以加速操作)
    即可显示当前服务器上所有端口及进程服务，于grep结合可查看某个具体端口及服务情况··
    netstat -ntlp   //查看当前所有tcp端口·
    netstat -ntulp |grep 80   //查看所有80端口使用情况·
    netstat -an | grep 3306   //查看所有3306端口使用情况·
    查看一台服务器上面哪些服务及端口
    netstat  -lanp
    查看一个服务有几个端口。比如要查看mysqld
    ps -ef |grep mysqld
    查看某一端口的连接数量,比如3306端口
    netstat -pnt |grep :3306 |wc
    查看某一端口的连接客户端IP 比如3306端口
    netstat -anp |grep 3306
    netstat -an 查看网络端口 
    
    lsof -i :port，使用lsof -i :port就能看见所指定端口运行的程序，同时还有当前连接。 
    
    nmap 端口扫描
    netstat -nupl  (UDP类型的端口)
    netstat -ntpl  (TCP类型的端口)
    netstat -anp 显示系统端口使用情况
    
    
#####  yum使用
   
    yum [options] [command] [package ...]
    options：可选，选项包括-h（帮助），-y（当安装过程提示选择全部为"yes"），-q（不显示安装的过程）等等。 
    command：要进行的操作。 
    package操作的对象。
    
    yum常用命令：
    1.列出所有可更新的软件清单命令：yum check-update
    2.更新所有软件命令：yum update
    3.仅安装指定的软件命令：yum install <package_name>
    4.仅更新指定的软件命令：yum update <package_name>
    5.列出所有可安裝的软件清单命令：yum list
    6.删除软件包命令：yum remove <package_name> 
    7.查找软件包 命令：yum search <keyword> 
    8.清除缓存命令: 
    yum clean packages: 清除缓存目录下的软件包
    yum clean headers: 清除缓存目录下的 headers
    yum clean oldheaders: 清除缓存目录下旧的 headers
    yum clean, yum clean all (= yum clean packages; yum clean oldheaders) :清除缓存目录下的软件包及旧的headers