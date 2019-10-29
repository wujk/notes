**spring-cloud-cofnig-db**

# 服务端
1、引入jar包
- 
    <dependency>
        <groupId>org.springframework.boot</groupId>
        <artifactId>spring-boot-starter-web</artifactId>
    </dependency>
    <dependency>
        <groupId>org.springframework.cloud</groupId>
        <artifactId>spring-cloud-config-server</artifactId>
    </dependency>
    <dependency>
        <groupId>mysql</groupId>
        <artifactId>mysql-connector-java</artifactId>
        <version>5.1.36</version>
        <scope>runtime</scope>
    </dependency>
    <dependency>
        <groupId>org.springframework.boot</groupId>
        <artifactId>spring-boot-starter-jdbc</artifactId>
    </dependency>
    
2、配置文件（application.yml）
-
    spring:
      profiles:
        active: jdbc  # 开启数据库配置
      application:
        name: config-db-server
      datasource:
        url: jdbc:mysql://192.168.140.215:3306/config_server?useUnicode=true&characterEncoding=utf8&characterSetResults=utf8&serverTimezone=GMT%2B8
        username: root
        password: 111111
        driver-class-name: com.mysql.jdbc.Driver
      cloud:
        config:
          server:
            jdbc:
              sql: SELECT `KEY`, `VALUE` from `PROPERTIES` where APPLICATION=? and PROFILE=? and LABEL=?
    
    server:
      port: 8889
        
3、启动
-
    @SpringBootApplication
    @EnableConfigServer
    public class ConfigServerApplication {
    
        public static void main(String[] args) {
            SpringApplication.run(ConfigServerApplication.class, args);
        }
    }

# 客户端
1、引入jar包
-
    <dependency>
        <groupId>org.springframework.boot</groupId>
        <artifactId>spring-boot-starter-web</artifactId>
    </dependency>
    <dependency>
        <groupId>org.springframework.cloud</groupId>
        <artifactId>spring-cloud-starter-config</artifactId>
    </dependency>
    
2、配置文件(bootstrap.preoperties)
-
    spring.application.name=config-client
    server.port=8769
    
    # INSERT INTO `config_server`.`PROPERTIES`(`ID`, `KEY`, `VALUE`, `APPLICATION`, `PROFILE`, `LABEL`) VALUES (1, 'name', 'wujk_jdbc', 'config-client-jdbc', 'dev', 'master');
    # SELECT `KEY`, `VALUE` from `PROPERTIES` where APPLICATION=? and PROFILE=? and LABEL=?
    spring.cloud.config.label=master    # 对应LABEL字段
    spring.cloud.config.profile=dev     # 对应PROFILE字段
    spring.cloud.config.name=config-client-jdbc  # 对应APPLICATION字段
    spring.cloud.config.fail-fast=true  # 快速失败
    spring.cloud.config.uri=http://localhost:8889/
    
    
3、启动
- 
    @SpringBootApplication
    @RestController
    public class ConfigClientApplication {
    
        @Value("${name}")
        private String name;
    
        public static void main(String[] args) {
            SpringApplication.run(ConfigClientApplication.class, args);
        }
    
        @GetMapping
        public String hello() {
            return "hello, " + name;
        }
    }
        




   