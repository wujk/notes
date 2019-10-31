# 安装scala

### 1、下载

### 2、解压
    tar -zxvf scala-2.12.10.tgz
    mv scala-2.12.10 scala
    
### 3、环境变量
    vi /etc/profile
    export SCALA_HOME=/usr/local/wujk/scala
    export PATH=$PATH:$SCALA_HOME/bin
    source /etc/profile