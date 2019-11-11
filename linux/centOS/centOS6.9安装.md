# 在虚拟机中安装CentOS

- 1、创建虚拟机：打开Virtual Box，点击“新建”按钮，点击“下一步”，输入虚拟机名称为node01，选择操作系统为Linux，选择版本为Red Hat，分配1024MB内存，后面的选项全部用默认，在Virtual Disk File location and size中，一定要自己选择一个目录来存放虚拟机文件，最后点击“create”按钮，开始创建虚拟机。
- 2、设置虚拟机网卡：选择创建好的虚拟机，点击“设置”按钮，在网络一栏中，连接方式中，选择“桥接”。
- 3、安装虚拟机中的CentOS 6.9操作系统：选择创建好的虚拟机，点击“开始”按钮，选择安装介质（即本地的CentOS 6.5镜像文件），选择第一项开始安装-Skip-欢迎界面Next-选择默认语言-Baisc Storage Devices-Yes, discard any data-主机名:spark2upgrade01-选择时区-设置初始密码为hadoop-Replace Existing Linux System-Write changes to disk-CentOS 6.5自己开始安装。
- 4、安装完以后，CentOS会提醒你要重启一下，就是reboot，你就reboot就可以了。
- 5、配置网络 vi /etc/sysconfig/network-scripts/ifcfg-eth0
---
    DEVICE=eth0
    TYPE=Ethernet
    ONBOOT=yes
    BOOTPROTO=dhcp
- 6、service network restart
- 7、配置静态ip
--- 
    BOOTPROTO=static
    IPADDR=192.168.31.205
    NETMASK=255.255.255.0
    GATEWAY=192.168.31.1 
- 8、service network restart
- 9、配置hosts，vi /etc/hosts 配置本机的hostname到ip地址的映射
---
    192.168.31.205  node01
    
- 10、关闭防火墙
---     
     service iptables stop
     service ip6tables stop
     chkconfig iptables off
     chkconfig ip6tables off
     
     vi /etc/selinux/config
     SELINUX=disabled

- 11、配置yum
---     
     yum clean all
     yum makecache
     yum install wget
     
- 12、安装gcc
---
    yum install -y gcc

- 13、ssh 超时设置
---
    vim /etc/ssh/sshd_config
    
    ClientAliveInterval 3600
    ClientAliveCountMax 10
    
    ClientAliveInterval 是指系统判断超时的时间，单位是s，这里的意思是3600s无响应则判断为超时一次
    ClientAliveCountMax 是指允许超时的次数，这里允许超时十次
    
    service sshd restart