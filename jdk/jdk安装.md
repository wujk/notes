###### 1、下载：
    wget https://download.oracle.com/otn-pub/java/jdk/8u201-b09/42970487e3af4f5aa5bca3f542482c60/jdk-8u201-linux-x64.tar.gz

###### 2、解压：
    tar -zxvf jdk-8u201-linux-x64.tar.gz

###### 3、配置环境变量
    vi /etc/profile
    export JAVA_HOME=/usr/local/kevin/jdk1.8.0_201
    export PATH=$PATH:$JAVA_HOME/bin
    export CLASSPATH=.:$JAVA_HOME/lib/dt.jar:$JAVA_HOME/lib/tools.jar
    source /etc/profile