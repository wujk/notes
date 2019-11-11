# openresty安装

###### Fedora 和 RedHat 用户
yum install pcre-devel openssl-devel gcc curl

###### 下载openresty
    wget http://openresty.org/download/openresty-1.15.8.2
    tar -xzvf openresty-1.15.8.2  
    cd /usr/local/wujk/openresty-1.15.8.2/
    
    cd bundle/LuaJIT-2.1-20150120/  
    make clean && make && make install  
    ln -sf luajit-2.1.0-beta3 /usr/local/bin/luajit

###### 下载ngx_cache_purge    
    cd bundle  
    wget https://github.com/FRiCKLE/ngx_cache_purge/archive/2.3.tar.gz  
    tar -xvf 2.3.tar.gz  

###### 下载nginx_upstream_check_module     
    cd bundle  
    wget https://github.com/yaoweibin/nginx_upstream_check_module/archive/v0.3.0.tar.gz  
    tar -xvf v0.3.0.tar.gz  

###### 重新安装    
    cd /usr/local/wujk/openresty-1.15.8.2/ 
    ./configure --prefix=/usr/local/wujk/openresty --with-http_realip_module  --with-pcre  --with-luajit --add-module=./bundle/ngx_cache_purge-2.3/ --add-module=./bundle/nginx_upstream_check_module-0.3.0/ -j2  
    make && make install 
    
    cd /usr/local/wujk/openresty 
    ll
    
    /usr/local/wujk/openresty/luajit
    /usr/local/wujk/openresty/lualib
    /usr/local/wujk/openresty/nginx
    /usr/local/wujk/openresty/nginx/sbin/nginx -V 
    
    启动nginx: /usr/local/wujk/openresty/nginx/sbin/nginx

##### nginx配置文件
    vim /usr/local/wujk/openresty/nginx/conf/nginx.conf
    
    在http部分添加：
    lua_package_path "/usr/local/wujk/openresty/lualib/?.lua;;";  
    lua_package_cpath "/usr/local/wujk/openresty/lualib/?.so;;";
    
##### 测试
    1、在/usr/local/wujk/openresty/nginx/conf/下编写lua.conf
    
    2、/usr/local/wujk/openresty/nginx/conf/nginx.conf 
    http部分添加：
    include lua.conf;
    
    3、重启nginx
    /usr/local/wujk/openresty/nginx/sbin/nginx -s reload
    
    访问：http://192.168.31.205/lua
    返回： hello world