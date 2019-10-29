**spring-cloud-config**

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
        <groupId>org.springframework.cloud</groupId>
        <artifactId>spring-cloud-starter-netflix-eureka-client</artifactId>
    </dependency>
    
2、配置文件（application.properties）
-
    spring.application.name=config-server
    server.port=8889  # 8890 启动两个服务无
    
    spring.cloud.config.server.git.uri=https://github.com/wujk/spring-boot-cloud/
    spring.cloud.config.server.git.searchPaths=prop
    spring.cloud.config.label=master
    spring.cloud.config.server.git.username=
    spring.cloud.config.server.git.password=
    eureka.client.serviceUrl.defaultZone=http://localhost:8761/eureka/
        
3、启动
-
    @SpringBootApplication
    @EnableConfigServer
    @EnableEurekaClient
    public class ConfigServerApplication {
    
        public static void main(String[] args) {
            SpringApplication.run(ConfigServerApplication.class, args);
        }
    }
    
4、访问浏览器
- 
    http://localhost:8889/config-server/dev/master
    http://localhost:8890/config-server/dev/master
    ------------------------------------------ 
    {"name":"config-server","profiles":["dev"],"label":"master","version":"6b72fb00cb30b53ebe359790a12ccfa9e6069091","state":null,"propertySources":[{"name":"https://github.com/wujk/spring-boot-cloud//prop/config-server-dev.properties","source":{"name":"wujk","server.port":"8770"}}]}
 

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
    <dependency>
        <groupId>org.springframework.cloud</groupId>
        <artifactId>spring-cloud-starter-netflix-eureka-client</artifactId>
    </dependency>
    
2、配置文件(bootstrap.preoperties)
-
    spring.application.name=config-client
    server.port=8769
    
    spring.cloud.config.label=master
    spring.cloud.config.profile=dev
    spring.cloud.config.name=config-server
    #spring.cloud.config.uri=http://localhost:8888/
    spring.cloud.config.discovery.service-id=config-server
    spring.cloud.config.discovery.enabled=true
    eureka.client.serviceUrl.defaultZone=http://localhost:8761/eureka/
    
3、启动
- 
    @SpringBootApplication
    @EnableEurekaClient
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
        




   