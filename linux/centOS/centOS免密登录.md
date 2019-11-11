# centOS免密登录
### 1、生成密钥
    ssh-keygen -t rsa

### 2、cd ~/.ssh
    cat id_rsa.pub >> authorized_keys

### 3、ssh-copy-id -i hostname(需要配置hosts文件) | ip 命令将本机的公钥拷贝到指定机器的authorized_keys文件中
    ssh-copy-id -i node02
    